import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vectix/canvas/scene_painter.dart';
import 'package:vectix/models/vx_document.dart';
import 'package:vectix/models/vx_element.dart';
import 'package:vectix/state/editor_state.dart';
import 'package:vectix/svg/svg_exporter.dart';
import 'package:vectix/svg/svg_importer.dart';

/// Acceptance tests for finding **P0-4** (see
/// `docs/vectix-deep-analysis-and-plan.md` §4).
///
/// `SvgImporter` used to collect `<defs>` content into a static map that
/// nothing resolved against, while `ScenePainter` / `HitTester` looked
/// references up in `document.elements` only. Mask, clip-path and symbol
/// definitions were therefore dropped on import and the references silently
/// did nothing.
///
/// Before the fix, measured on `test/fixtures/masked_group.svg`:
///   * imported tree held 1 element and no mask definition
///   * centre pixel (100,100) = rgba(255,107,107,255) — opaque where the
///     mask's black circle (r=60) must hide it
///
/// The mask renderer was also alpha-based (`dstIn` with a white paint), so a
/// black shape inside a mask hid nothing even when it resolved. It now applies
/// true luminance-to-alpha masking.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Uint8List> alphaOf(VxDocument doc) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    ScenePainter(
      doc,
      const ViewportState(zoom: 1, pan: Offset.zero),
    ).paint(canvas, const Size(200, 200));
    final image = await recorder.endRecording().toImage(200, 200);
    final rgba = (await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    ))!.buffer.asUint8List();
    return Uint8List.fromList([
      for (var i = 3; i < rgba.length; i += 4) rgba[i],
    ]);
  }

  test('a mask defined in <defs> is applied to the referencing group', () async {
    final svg = await File('test/fixtures/masked_group.svg').readAsString();
    final doc = SvgImporter.import(svg)!;

    // Definitions are resolved data, not artwork.
    expect(doc.elements.length, 1, reason: 'definitions are not painted');
    final mask = doc.defs['mask_1'];
    expect(mask, isA<VxGroup>(), reason: 'mask_1 must survive import');
    expect((mask! as VxGroup).children.length, 2);

    final alpha = await alphaOf(doc);
    int alphaAt(int x, int y) => alpha[y * 200 + x];

    // Centre is inside the mask's black circle => hidden => transparent.
    expect(alphaAt(100, 100), 0);
    // Inside the artwork but outside the mask's black circle => still visible.
    expect(alphaAt(30, 30), greaterThan(0));
  });

  test('mask definitions survive an export -> import round trip', () async {
    final svg = await File('test/fixtures/masked_group.svg').readAsString();
    final original = SvgImporter.import(svg)!;
    final exported = SvgExporter.export(original);

    // The definition must be written as a <mask>, not as visible artwork, and
    // exactly once (the legacy reference path must not duplicate it).
    expect(exported, contains('<mask id="mask_1">'));
    expect('id="mask_1"'.allMatches(exported).length, 1);

    final reimported = SvgImporter.import(exported)!;
    expect(reimported.defs['mask_1'], isNotNull);
    expect(reimported.elements.length, 1);

    expect(await alphaOf(reimported), await alphaOf(original));
  });
}
