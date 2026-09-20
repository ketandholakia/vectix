import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vectix/canvas/scene_exporter.dart';
import 'package:vectix/svg/svg_importer.dart';

void main() {
  // NOTE (2026-09-20): this golden currently encodes the *unmasked* render.
  // The `<mask>` in `test/fixtures/masked_group.svg` lives inside `<defs>` and
  // is dropped on import (finding P0-4), so this test passes while masks do not
  // work at all. Regenerate the golden as part of task B1 and keep the pixel
  // assertions in `test/mask_defs_regression_test.dart` as the real gate.
  test('imports a masked SVG fixture and renders a PNG preview', () async {
    final svg = await File('test/fixtures/masked_group.svg').readAsString();
    // SvgImporter.import returns VxDocument? (null on malformed input).
    final document = SvgImporter.import(svg)!;

    expect(document.elements, isNotEmpty);
    expect(document.elements.first.maskId, 'mask_1');

    final png = await SceneExporter.renderPng(
      document,
      transparentBackground: true,
    );

    expect(png, isNotEmpty);

    const generateGolden = bool.fromEnvironment(
      'GENERATE_EXPORT_GOLDEN',
      defaultValue: false,
    );
    const goldenPath = 'test/goldens/masked_group.png';

    if (generateGolden) {
      await File(goldenPath).create(recursive: true);
      await File(goldenPath).writeAsBytes(png);
      expect(true, isTrue);
      return;
    }

    final golden = await File(goldenPath).readAsBytes();
    expect(png, golden);
  });
}
