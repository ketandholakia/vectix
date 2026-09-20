import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vectix/models/vx_element.dart';
import 'package:vectix/svg/svg_exporter.dart';
import 'package:vectix/svg/svg_importer.dart';

/// Regression tests for **B2** (SVG defaults + presentation inheritance) and
/// **B3** (value fidelity: colours, rounded rects, stroke caps/joins/opacity).
///
/// Findings covered: P1-2 (default fill / inheritance), P1-3 (colour grammar)
/// and P1-4 (alpha, caps, joins, stroke-opacity, miter limit).
void main() {
  String wrap(String body, {String attrs = ''}) =>
      '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100"$attrs>$body</svg>';

  VxElement only(String body, {String attrs = ''}) =>
      SvgImporter.import(wrap(body, attrs: attrs))!.elements.single;

  VxElement child(VxElement group) => (group as VxGroup).children.single;

  int argb(Color c) => c.toARGB32();

  group('B2: defaults and inheritance', () {
    test('a shape with no fill imports as solid black, not invisible', () {
      final rect = only('<rect x="1" y="2" width="10" height="10"/>') as VxRect;
      expect(rect.fill, isA<SolidFill>());
      expect(argb((rect.fill as SolidFill).color), 0xFF000000);
    });

    test('fill/stroke inherit from the wrapping <g>', () {
      final group = only(
        '<g fill="red" stroke="blue" stroke-width="3">'
        '<rect x="0" y="0" width="10" height="10"/></g>',
      );
      final rect = child(group) as VxRect;
      expect(rect.fill, isA<SolidFill>());
      expect(argb((rect.fill as SolidFill).color), 0xFFFF0000);
      expect(argb(rect.stroke.color), 0xFF0000FF);
      expect(rect.stroke.width, 3.0);
    });

    test('a child overrides the inherited value', () {
      final group = only(
        '<g fill="red"><rect x="0" y="0" width="10" height="10" fill="lime"/></g>',
      );
      final rect = child(group) as VxRect;
      expect(argb((rect.fill as SolidFill).color), 0xFF00FF00);
    });

    test('inheritance reaches through nested groups', () {
      final outer = only(
        '<g fill="#123456"><g><rect x="0" y="0" width="10" height="10"/></g></g>',
      );
      final inner = child(outer);
      final rect = child(inner) as VxRect;
      expect(argb((rect.fill as SolidFill).color), 0xFF123456);
    });

    test('presentation attributes on the root <svg> are inherited (icon sets)', () {
      final doc = SvgImporter.import(
        wrap('<rect x="0" y="0" width="10" height="10"/>', attrs: ' fill="none"'),
      )!;
      final rect = doc.elements.single as VxRect;
      expect(rect.fill, isA<NoFill>());
    });

    test('font properties and text-anchor inherit into <text>', () {
      final group = only(
        '<g font-family="\'Open Sans\', sans-serif" font-size="22" '
        'font-weight="bold" font-style="italic" text-anchor="middle" '
        'letter-spacing="2">'
        '<text x="0" y="0">hi</text></g>',
      );
      final text = child(group) as VxText;
      expect(text.style.fontFamily, 'Open Sans');
      expect(text.style.fontSize, 22.0);
      expect(text.fontWeightValue, 700);
      expect(text.fontStyle, FontStyle.italic);
      expect(text.align, TextAlign.center);
      expect(text.letterSpacing, 2.0);
    });

    test('opacity is not inherited', () {
      final group = only(
        '<g opacity="0.5"><rect x="0" y="0" width="10" height="10"/></g>',
      );
      expect(group.opacity, 0.5);
      expect(child(group).opacity, 1.0);
    });
  });

  group('B3: colour grammar', () {
    Future<Color> fillOf(String value) async {
      final rect = only(
        '<rect x="0" y="0" width="10" height="10" fill="$value"/>',
      ) as VxRect;
      return (rect.fill as SolidFill).color;
    }

    test('6-digit hex', () async {
      expect(argb(await fillOf('#00AEEF')), 0xFF00AEEF);
    });

    test('3-digit hex expands', () async {
      expect(argb(await fillOf('#0AF')), 0xFF00AAFF);
    });

    test('8-digit hex is #rrggbbaa, not #aarrggbb', () async {
      final c = await fillOf('#00AEEF80');
      expect(argb(c) >> 24 & 0xff, 0x80, reason: 'alpha must come from the last pair');
      expect(argb(c) & 0xffffff, 0x00AEEF, reason: 'rgb must come from the first pairs');
    });

    test('4-digit hex is #rgba', () async {
      final c = await fillOf('#0AF8');
      expect(argb(c) >> 24 & 0xff, 0x88);
      expect(argb(c) & 0xffffff, 0x00AAFF);
    });

    test('rgb() with numbers and percentages', () async {
      expect(argb(await fillOf('rgb(255, 0, 0)')), 0xFFFF0000);
      expect(argb(await fillOf('rgb(100%, 0%, 0%)')), 0xFFFF0000);
    });

    test('rgba() with alpha', () async {
      expect(argb(await fillOf('rgba(0, 0, 255, 0.5)')), 0x800000FF);
    });

    test('hsl() conversion', () async {
      expect(argb(await fillOf('hsl(120, 100%, 50%)')), 0xFF00FF00);
      expect(argb(await fillOf('hsl(0, 0%, 100%)')), 0xFFFFFFFF);
    });

    test('named colours, transparent and currentColor', () async {
      expect(argb(await fillOf('rebeccapurple')), 0xFF663399);
      expect(argb(await fillOf('transparent')), 0x00000000);
      final group = only(
        '<g color="#FF8800"><rect x="0" y="0" width="10" height="10" '
        'fill="currentColor"/></g>',
      );
      expect(
        argb(((child(group) as VxRect).fill as SolidFill).color),
        0xFFFF8800,
      );
    });
  });

  group('B3: geometry and stroke values', () {
    test('rounded rect imports as a path with cubic corner arcs', () {
      final el = only(
        '<rect x="10" y="20" width="100" height="50" rx="10" fill="red"/>',
      );
      expect(el, isA<VxPath>());
      final segments = (el as VxPath).segments;
      expect(segments.length, 10);
      expect(
        (segments.first as MoveToSegment).point,
        const Offset(20, 20),
        reason: 'starts rx in from the left edge',
      );
      expect(segments.whereType<CubicBezierToSegment>().length, 4);
      expect(segments.last, isA<CloseSegment>());
    });

    test('rx is clamped to half the width', () {
      final el =
          only('<rect x="0" y="0" width="100" height="50" rx="999"/>') as VxPath;
      expect((el.segments.first as MoveToSegment).point, const Offset(50, 0));
    });

    test('ry defaults to rx when only rx is given', () {
      final el =
          only('<rect x="0" y="0" width="100" height="50" rx="10"/>') as VxPath;
      expect(el.segments.length, 10);
      expect((el.segments.first as MoveToSegment).point, const Offset(10, 0));
    });

    test('polygon and polyline import', () {
      final poly = only(
        '<polygon points="0,0 10,0 10,10" fill="red"/>',
      ) as VxPath;
      expect(poly.segments.length, 4, reason: '3 points + close');
      expect(poly.segments.last, isA<CloseSegment>());

      final line = only('<polyline points="0,0 10,0 10,10"/>') as VxPath;
      expect(line.segments.length, 3);
      expect(line.fill, isA<NoFill>());
    });

    test('stroke linecap / linejoin / miterlimit import', () {
      final rect = only(
        '<rect x="0" y="0" width="10" height="10" stroke="black" '
        'stroke-width="2" stroke-linecap="round" stroke-linejoin="bevel" '
        'stroke-miterlimit="2"/>',
      ) as VxRect;
      expect(rect.stroke.cap, StrokeCap.round);
      expect(rect.stroke.join, StrokeJoin.bevel);
      expect(rect.stroke.miterLimit, 2.0);
    });

    test('stroke-width 0 means no stroke', () {
      final rect = only(
        '<rect x="0" y="0" width="10" height="10" stroke="black" stroke-width="0"/>',
      ) as VxRect;
      expect(rect.stroke.width, 0.0);
      expect(rect.stroke.color.a, 0.0);
    });

    test('fill-opacity and stroke-opacity fold into colour alpha', () {
      final rect = only(
        '<rect x="0" y="0" width="10" height="10" fill="#FF0000" '
        'fill-opacity="0.5" stroke="#0000FF" stroke-width="2" '
        'stroke-opacity="0.25"/>',
      ) as VxRect;
      expect((rect.fill as SolidFill).color.a, closeTo(0.5, 1e-6));
      expect(rect.stroke.color.a, closeTo(0.25, 1e-6));
    });
  });

  group('B3: export fidelity round trip', () {
    test('opacity, caps, joins and miter limit survive export -> import', () {
      const source =
          '<rect x="0" y="0" width="10" height="10" fill="#00AEEF" '
          'fill-opacity="0.4" stroke="#FF0000" stroke-width="3" '
          'stroke-opacity="0.5" stroke-linecap="round" stroke-linejoin="round"/>';
      final original = only(source) as VxRect;

      final exported = SvgExporter.export(
        SvgImporter.import(wrap(source))!,
      );
      expect(exported, contains('fill-opacity="0.4"'));
      expect(exported, contains('stroke-opacity="0.5"'));
      expect(exported, contains('stroke-linecap="round"'));
      expect(exported, contains('stroke-linejoin="round"'));

      final reimported = SvgImporter.import(exported)!.elements.single as VxRect;
      expect(
        (reimported.fill as SolidFill).color.a,
        closeTo((original.fill as SolidFill).color.a, 1e-6),
      );
      expect(
        argb((reimported.fill as SolidFill).color) & 0xffffff,
        argb((original.fill as SolidFill).color) & 0xffffff,
      );
      expect(reimported.stroke.cap, StrokeCap.round);
      expect(reimported.stroke.join, StrokeJoin.round);
      expect(reimported.stroke.color.a, closeTo(0.5, 1e-6));
      expect(reimported.stroke.width, 3.0);
    });

    test('gradient stop opacity survives the round trip', () {
      const source =
          '<defs><linearGradient id="g1" x1="0" y1="0" x2="10" y2="0">'
          '<stop offset="0" stop-color="#FF0000" stop-opacity="0.25"/>'
          '<stop offset="1" stop-color="#0000FF" stop-opacity="1"/>'
          '</linearGradient></defs>'
          '<rect x="0" y="0" width="10" height="10" fill="url(#g1)"/>';
      final doc = SvgImporter.import(wrap(source))!;
      final rect = doc.elements.single as VxRect;
      expect(rect.fill, isA<LinearFill>());
      expect((rect.fill as LinearFill).stops.first.color.a, closeTo(0.25, 1e-6));

      final exported = SvgExporter.export(doc);
      expect(exported, contains('stop-opacity="0.25"'));

      final reimported = SvgImporter.import(exported)!.elements.single as VxRect;
      expect(
        (reimported.fill as LinearFill).stops.first.color.a,
        closeTo(0.25, 1e-6),
      );
    });

    test('text style properties survive the round trip', () {
      const source =
          '<text x="5" y="20" font-family="Georgia" font-size="18" '
          'font-weight="700" font-style="italic" text-anchor="end" '
          'letter-spacing="1.5" fill="#112233">Hi</text>';
      final original = only(source) as VxText;
      final exported = SvgExporter.export(SvgImporter.import(wrap(source))!);
      expect(exported, contains('font-weight="700"'));
      expect(exported, contains('font-style="italic"'));
      expect(exported, contains('text-anchor="end"'));
      expect(exported, contains('letter-spacing="1.5"'));

      final reimported = SvgImporter.import(exported)!.elements.single as VxText;
      expect(reimported.content, original.content);
      expect(reimported.style.fontFamily, 'Georgia');
      expect(reimported.style.fontSize, 18.0);
      expect(reimported.fontWeightValue, 700);
      expect(reimported.fontStyle, FontStyle.italic);
      expect(reimported.align, TextAlign.end);
      expect(reimported.letterSpacing, 1.5);
    });
  });
}
