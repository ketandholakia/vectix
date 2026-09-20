import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:vectix/canvas/gradient_geometry.dart';
import 'package:vectix/canvas/scene_painter.dart';
import 'package:vectix/models/vx_document.dart';
import 'package:vectix/models/vx_element.dart';
import 'package:vectix/state/editor_state.dart';
import 'package:vectix/svg/svg_exporter.dart';
import 'package:vectix/svg/svg_importer.dart';

/// Regression tests for **B4** — finding P0-5.
///
/// The painter used to ignore a gradient's own geometry and always sweep
/// horizontally across the element's bounds, so an authored top-to-bottom or
/// angled gradient rendered wrong and disagreed with the exported SVG. The PDF
/// exporter had the same bug, and SVG's `gradientUnits` (`objectBoundingBox` by
/// default) was not modelled at all.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const red = Color(0xFFFF0000);
  const blue = Color(0xFF0000FF);

  VxFill verticalFill() => const VxFill.linear(
    units: GradientUnits.objectBoundingBox,
    start: Offset(0, 0),
    end: Offset(0, 1),
    stops: [ColorStop(offset: 0, color: red), ColorStop(offset: 1, color: blue)],
  );

  VxFill horizontalFill() => const VxFill.linear(
    units: GradientUnits.objectBoundingBox,
    start: Offset(0, 0),
    end: Offset(1, 0),
    stops: [ColorStop(offset: 0, color: red), ColorStop(offset: 1, color: blue)],
  );

  VxDocument docWith(VxFill fill) => VxDocument(
    id: 'd',
    title: 't',
    width: 100,
    height: 100,
    elements: [
      VxElement.rect(
        id: 'r',
        x: 0,
        y: 0,
        width: 100,
        height: 100,
        transform: Matrix4.identity(),
        fill: fill,
        stroke: const VxStroke(
          color: Colors.transparent,
          width: 0,
          cap: StrokeCap.butt,
          join: StrokeJoin.miter,
        ),
      ),
    ],
  );

  Future<Uint8List> render(VxFill fill) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    ScenePainter(
      docWith(fill),
      const ViewportState(zoom: 1, pan: Offset.zero),
    ).paint(canvas, const Size(100, 100));
    final image = await recorder.endRecording().toImage(100, 100);
    return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
  }

  ({int r, int g, int b, int a}) pixelAt(Uint8List rgba, int x, int y) {
    final i = (y * 100 + x) * 4;
    return (r: rgba[i], g: rgba[i + 1], b: rgba[i + 2], a: rgba[i + 3]);
  }

  group('GradientGeometry resolution', () {
    test('userSpaceOnUse coordinates pass through unchanged', () {
      const fill = LinearFill(
        units: GradientUnits.userSpaceOnUse,
        start: Offset(5, 7),
        end: Offset(30, 40),
        stops: [],
      );
      final g = GradientGeometry.linear(fill, const Rect.fromLTWH(0, 0, 100, 50));
      expect(g.from, const Offset(5, 7));
      expect(g.to, const Offset(30, 40));
    });

    test('objectBoundingBox maps fractions onto the bounds', () {
      const fill = LinearFill(
        units: GradientUnits.objectBoundingBox,
        start: Offset(0, 0),
        end: Offset(0, 1),
        stops: [],
      );
      final g = GradientGeometry.linear(fill, const Rect.fromLTWH(10, 20, 100, 50));
      expect(g.from, const Offset(10, 20), reason: 'top edge');
      expect(g.to, const Offset(10, 70), reason: 'bottom edge, vertical');
    });

    test('objectBoundingBox radial uses the normalized diagonal', () {
      const fill = RadialFill(
        units: GradientUnits.objectBoundingBox,
        center: Offset(0.5, 0.5),
        radius: 0.5,
        stops: [],
      );
      final square = GradientGeometry.radial(
        fill,
        const Rect.fromLTWH(0, 0, 100, 100),
      );
      expect(square.center, const Offset(50, 50));
      expect(square.radius, closeTo(50, 1e-9));

      final wide = GradientGeometry.radial(
        fill,
        const Rect.fromLTWH(0, 0, 200, 100),
      );
      expect(wide.radius, closeTo(0.5 * 158.113883, 1e-4));
    });

    test('degenerate bounds fall back to raw coordinates', () {
      const fill = LinearFill(
        start: Offset(0, 0),
        end: Offset(1, 1),
        stops: [],
      );
      final g = GradientGeometry.linear(fill, Rect.zero);
      expect(g.from, const Offset(0, 0));
      expect(g.to, const Offset(1, 1));
    });

    test('stop offsets are clamped and made non-decreasing', () {
      final offsets = GradientGeometry.stopOffsets(const [
        ColorStop(offset: 0.5, color: red),
        ColorStop(offset: 0.2, color: blue),
        ColorStop(offset: 1.4, color: red),
      ]);
      expect(offsets, [0.5, 0.5, 1.0]);
    });

    test('stop offsets handle empty and negative input', () {
      expect(GradientGeometry.stopOffsets(const []), isEmpty);
      expect(
        GradientGeometry.stopOffsets(const [
          ColorStop(offset: -1, color: red),
        ]),
        [0.0],
      );
    });
  });

  group('gradientUnits on import', () {
    String wrap(String body) =>
        '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">$body</svg>';

    test('defaults to objectBoundingBox, SVG\'s initial value', () {
      final doc = SvgImporter.import(
        wrap(
          '<defs><linearGradient id="g"><stop offset="0" stop-color="#fff"/>'
          '<stop offset="1" stop-color="#000"/></linearGradient></defs>'
          '<rect x="0" y="0" width="10" height="10" fill="url(#g)"/>',
        ),
      )!;
      final fill = (doc.elements.single as VxRect).fill as LinearFill;
      expect(fill.units, GradientUnits.objectBoundingBox);
    });

    test('honours an explicit userSpaceOnUse', () {
      final doc = SvgImporter.import(
        wrap(
          '<defs><linearGradient id="g" gradientUnits="userSpaceOnUse" '
          'x1="0" y1="0" x2="0" y2="50">'
          '<stop offset="0" stop-color="#fff"/>'
          '<stop offset="1" stop-color="#000"/></linearGradient></defs>'
          '<rect x="0" y="0" width="10" height="10" fill="url(#g)"/>',
        ),
      )!;
      final fill = (doc.elements.single as VxRect).fill as LinearFill;
      expect(fill.units, GradientUnits.userSpaceOnUse);
      expect(fill.end, const Offset(0, 50));
    });

    test('percentage coordinates become fractions', () {
      final doc = SvgImporter.import(
        wrap(
          '<defs><linearGradient id="g" x1="0%" y1="0%" x2="0%" y2="100%">'
          '<stop offset="0" stop-color="#fff"/>'
          '<stop offset="1" stop-color="#000"/></linearGradient></defs>'
          '<rect x="0" y="0" width="10" height="10" fill="url(#g)"/>',
        ),
      )!;
      final fill = (doc.elements.single as VxRect).fill as LinearFill;
      expect(fill.start, const Offset(0, 0));
      expect(fill.end, const Offset(0, 1));
    });

    test('out-of-order stop offsets are raised to their predecessor', () {
      final doc = SvgImporter.import(
        wrap(
          '<defs><linearGradient id="g">'
          '<stop offset="0.8" stop-color="#fff"/>'
          '<stop offset="0.2" stop-color="#000"/></linearGradient></defs>'
          '<rect x="0" y="0" width="10" height="10" fill="url(#g)"/>',
        ),
      )!;
      final fill = (doc.elements.single as VxRect).fill as LinearFill;
      expect(fill.stops.map((s) => s.offset).toList(), [0.8, 0.8]);
    });

    test('units survive an export -> import round trip', () {
      final doc = SvgImporter.import(
        wrap(
          '<defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1">'
          '<stop offset="0" stop-color="#ff0000"/>'
          '<stop offset="1" stop-color="#0000ff"/></linearGradient></defs>'
          '<rect x="0" y="0" width="10" height="10" fill="url(#g)"/>',
        ),
      )!;
      final exported = SvgExporter.export(doc);
      expect(exported, contains('gradientUnits="objectBoundingBox"'));

      final reimported = SvgImporter.import(exported)!.elements.single as VxRect;
      final fill = reimported.fill as LinearFill;
      expect(fill.units, GradientUnits.objectBoundingBox);
      expect(fill.end, const Offset(0, 1));
    });
  });

  group('gradient rendering direction', () {
    test('a vertical gradient varies vertically, not horizontally', () async {
      final rgba = await render(verticalFill());

      final top = pixelAt(rgba, 50, 2);
      final bottom = pixelAt(rgba, 50, 97);
      // Direction is honoured: red at the top, blue at the bottom. Before the
      // fix every gradient swept left-to-right, so these were identical.
      expect(top.r, greaterThan(top.b));
      expect(bottom.b, greaterThan(bottom.r));

      // A vertical gradient has no horizontal variation.
      final topLeft = pixelAt(rgba, 2, 2);
      final topRight = pixelAt(rgba, 97, 2);
      expect((topLeft.r - topRight.r).abs(), lessThan(3));
      expect((topLeft.b - topRight.b).abs(), lessThan(3));
    });

    test('a horizontal gradient varies horizontally, not vertically', () async {
      final rgba = await render(horizontalFill());

      final left = pixelAt(rgba, 2, 50);
      final right = pixelAt(rgba, 97, 50);
      expect(left.r, greaterThan(left.b));
      expect(right.b, greaterThan(right.r));

      final top = pixelAt(rgba, 50, 2);
      final bottom = pixelAt(rgba, 50, 97);
      expect((top.r - bottom.r).abs(), lessThan(3));
    });

    test('a radial gradient is brightest at its centre', () async {
      final rgba = await render(
        const VxFill.radial(
          units: GradientUnits.objectBoundingBox,
          center: Offset(0.5, 0.5),
          radius: 0.5,
          stops: [
            ColorStop(offset: 0, color: red),
            ColorStop(offset: 1, color: blue),
          ],
        ),
      );
      final centre = pixelAt(rgba, 50, 50);
      final edge = pixelAt(rgba, 99, 50);
      expect(centre.r, greaterThan(edge.r));
      expect(edge.b, greaterThan(centre.b));
    });
  });
}
