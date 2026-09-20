import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vectix/canvas/scene_painter.dart';
import 'package:vectix/models/vx_document.dart';
import 'package:vectix/state/editor_state.dart';
import 'package:vectix/svg/svg_exporter.dart';
import 'package:vectix/svg/svg_importer.dart';

/// Shared machinery for the SVG fidelity corpus.
///
/// Renders every corpus file at a fixed size and hashes the pixels, so a change
/// in what Vectix draws is a build failure rather than a surprise months later.
/// It also measures *round-trip* fidelity: import -> export -> import, rendered
/// against the original. That metric is relative to the same machine, so it
/// catches asymmetric or lossy conversions without needing committed hashes.
const String corpusManifestPath = 'test/corpus/render_hashes.json';

/// Every corpus file is declared at this size and rendered at this scale, so
/// hashes are comparable.
const int corpusLogicalSize = 100;
const int corpusScale = 2;

class CorpusResult {
  CorpusResult({
    required this.name,
    required this.imported,
    required this.pixelHash,
    required this.roundTripFidelity,
    required this.roundTripPixels,
    this.diffBounds,
    this.error,
  });

  final String name;
  final bool imported;
  final String pixelHash;

  /// Fraction of pixels identical after export -> import, 1.0 being lossless.
  final double roundTripFidelity;
  final int roundTripPixels;

  /// Where the round-trip render differs, when it does.
  final Rect? diffBounds;
  final String? error;

  Map<String, dynamic> toJson() => {
    'pixelHash': pixelHash,
    'roundTripFidelity': double.parse(roundTripFidelity.toStringAsFixed(6)),
  };
}

/// Imports the SVG source. Returns null when the importer rejects it.
VxDocument? importCorpus(String svg) => SvgImporter.import(svg);

/// Renders a document to raw RGBA, fitted into the corpus canvas so artwork of
/// any declared size produces a comparable image.
Future<Uint8List> renderRaw(VxDocument doc) async {
  const canvasSide = corpusLogicalSize * corpusScale * 1.0;
  final width = doc.width <= 0 ? 1.0 : doc.width;
  final height = doc.height <= 0 ? 1.0 : doc.height;
  final zoom = canvasSide / (width > height ? width : height);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  ScenePainter(
    doc,
    ViewportState(zoom: zoom, pan: Offset.zero),
  ).paint(canvas, const Size(canvasSide, canvasSide));
  final image = await recorder.endRecording().toImage(200, 200);
  return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer
      .asUint8List();
}

/// SHA-256 is not available without adding a dependency, so this uses a 64-bit
/// FNV-1a over the pixel bytes. Stable across runs and platforms, and more than
/// wide enough to catch a rendering change in these images. The result is
/// formatted as unsigned, since Dart's 64-bit ints are signed and would
/// otherwise print a leading minus sign.
String pixelHash(Uint8List bytes) {
  var hash = 0xcbf29ce484222325;
  const prime = 0x100000001b3;
  for (final byte in bytes) {
    hash ^= byte;
    hash *= prime;
  }
  return _unsignedHex(hash);
}

/// Formats a 64-bit value as 16 unsigned hex digits. Dart's ints are signed and
/// `toUnsigned(64)` is necessarily a no-op, so the two halves are formatted
/// separately (the `& mask` yields a non-negative int).
String _unsignedHex(int value) {
  final high = (value >> 32) & 0xFFFFFFFF;
  final low = value & 0xFFFFFFFF;
  return high.toRadixString(16).padLeft(8, '0') +
      low.toRadixString(16).padLeft(8, '0');
}

/// Fraction of byte positions that are identical between two renders.
double fidelity(Uint8List a, Uint8List b) {
  if (a.length != b.length) return 0;
  if (a.isEmpty) return 1;
  var same = 0;
  for (var i = 0; i < a.length; i++) {
    if (a[i] == b[i]) same++;
  }
  return same / a.length;
}

/// Bounding box of the pixels that differ, in the 200x200 render space, so a
/// fidelity failure points at the part of the artwork that changed instead of
/// just reporting a percentage.
Rect? diffBounds(Uint8List a, Uint8List b) {
  if (a.length != b.length || a.isEmpty) return null;
  var minX = 1000, minY = 1000, maxX = -1, maxY = -1;
  for (var i = 0; i + 3 < a.length; i += 4) {
    final differs = a[i] != b[i] ||
        a[i + 1] != b[i + 1] ||
        a[i + 2] != b[i + 2] ||
        a[i + 3] != b[i + 3];
    if (!differs) continue;
    final pixel = i ~/ 4;
    final x = pixel % 200;
    final y = pixel ~/ 200;
    if (x < minX) minX = x;
    if (y < minY) minY = y;
    if (x > maxX) maxX = x;
    if (y > maxY) maxY = y;
  }
  if (maxX < 0) return null;
  return Rect.fromLTRB(
    minX.toDouble(),
    minY.toDouble(),
    maxX.toDouble(),
    maxY.toDouble(),
  );
}

/// Runs one corpus entry end to end.
Future<CorpusResult> evaluateCorpus(String name, String svg) async {
  try {
    final original = importCorpus(svg);
    if (original == null) {
      return CorpusResult(
        name: name,
        imported: false,
        pixelHash: '',
        roundTripFidelity: 0,
        roundTripPixels: 0,
        error: 'importer returned null',
      );
    }

    final originalPixels = await renderRaw(original);

    // Import -> export -> import, then compare the two renders.
    final exported = SvgExporter.export(original);
    final reimported = SvgImporter.import(exported);
    final roundTripPixels = reimported == null
        ? null
        : await renderRaw(reimported);
    final roundTripFidelity = roundTripPixels == null
        ? 0.0
        : fidelity(originalPixels, roundTripPixels);

    return CorpusResult(
      name: name,
      imported: true,
      pixelHash: pixelHash(originalPixels),
      roundTripFidelity: roundTripFidelity,
      roundTripPixels: originalPixels.length,
      diffBounds: roundTripPixels == null
          ? null
          : diffBounds(originalPixels, roundTripPixels),
      error: reimported == null ? 'exported SVG failed to re-import' : null,
    );
  } catch (e) {
    return CorpusResult(
      name: name,
      imported: false,
      pixelHash: '',
      roundTripFidelity: 0,
      roundTripPixels: 0,
      error: e.toString(),
    );
  }
}

Map<String, dynamic> readManifest() {
  final file = File(corpusManifestPath);
  if (!file.existsSync()) return {};
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void writeManifest(Map<String, dynamic> manifest) {
  final entries = manifest.keys.toList()..sort();
  final sorted = {for (final key in entries) key: manifest[key]};
  File(corpusManifestPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(sorted) + '\n',
    );
}
