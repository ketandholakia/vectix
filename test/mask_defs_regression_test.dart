import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vectix/canvas/scene_painter.dart';
import 'package:vectix/state/editor_state.dart';
import 'package:vectix/svg/svg_importer.dart';

/// Acceptance test for finding **P0-4** (see
/// `docs/vectix-deep-analysis-and-plan.md` §4):
/// definitions that live inside `<defs>` — `<mask>`, `<clipPath>`, `<symbol>` —
/// are collected into a static map by `SvgImporter` and never inserted into the
/// document element tree, while the painter resolves references against
/// `document.elements` only. The referenced element therefore never resolves.
///
/// Measured on 2026-09-20 against `test/fixtures/masked_group.svg`:
///   * imported tree contains 1 element (the `<g>`), mask source absent
///   * centre pixel (100,100) = rgba(255,107,107,255) — opaque red
///   * the mask's black circle (r=60, centred at 100,100) must hide that point,
///     so a correct implementation renders alpha = 0 there
///
/// Skipped until task **B1** (defs registry) lands. Remove the `skip:` argument
/// as part of B1 — this test is the definition of done for that task.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'P0-4: a mask defined in <defs> is applied to the referencing group',
    () async {
      final svg = await File('test/fixtures/masked_group.svg').readAsString();
      final doc = SvgImporter.import(svg)!;

      // The mask source must be reachable from the document.
      expect(doc.elements.length, greaterThan(1));

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      ScenePainter(
        doc,
        const ViewportState(zoom: 1, pan: Offset.zero),
      ).paint(canvas, const Size(200, 200));
      final image = await recorder.endRecording().toImage(200, 200);
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();

      int alphaAt(int x, int y) => bytes[(y * 200 + x) * 4 + 3];

      // Centre is inside the mask's black circle => hidden => transparent.
      expect(alphaAt(100, 100), 0);
      // Inside the artwork but outside the mask's black circle => still visible.
      expect(alphaAt(30, 30), greaterThan(0));
    },
    skip: 'blocked by P0-4 (mask/clip/symbol definitions in <defs> are dropped '
        'on import) — enable and make pass in task B1',
  );
}
