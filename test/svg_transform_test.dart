import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:vectix/svg/svg_exporter.dart';
import 'package:vectix/svg/svg_importer.dart';

/// Regression tests for finding **P1-1**:
/// `SvgImporter._parseTransform` built a `Matrix4` through the unnamed
/// constructor, which takes *row-major* arguments, while SVG `matrix(a,b,c,d,e,f)`
/// is *column-major*. The off-diagonal terms were therefore swapped and every
/// rotated or skewed artwork imported transposed (mirrored/sheared).
///
/// These tests go through the public API (`SvgImporter.import` /
/// `SvgExporter.export`) because `_parseTransform` is library-private.
void main() {
  const wrap = '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">';
  const rect = '<rect id="r" x="0" y="0" width="10" height="10"/>';

  test('matrix() maps a point using SVG column-major semantics', () {
    // matrix(0,1,-1,0,0,0) is a +90 degree rotation: (1,0) -> (0,1)
    final doc = SvgImporter.import(
      '$wrap<g id="rot" transform="matrix(0,1,-1,0,0,0)">$rect</g></svg>',
    )!;
    final group = doc.elements.single;

    final p = group.transform.transform3(Vector3(1, 0, 0));
    expect(p.x, closeTo(0, 1e-9), reason: 'rotation should move x to y');
    expect(p.y, closeTo(1, 1e-9), reason: 'rotation should move y to -x');
  });

  test('skew matrix() keeps its off-diagonal term on the correct axis', () {
    // matrix(1,0,1,1,0,0) is skewX(45): (0,1) -> (1,1)
    final doc = SvgImporter.import(
      '$wrap<g id="skew" transform="matrix(1,0,1,1,0,0)">$rect</g></svg>',
    )!;
    final group = doc.elements.single;

    final p = group.transform.transform3(Vector3(0, 1, 0));
    expect(p.x, closeTo(1, 1e-9), reason: 'skewX should shift x by y');
    expect(p.y, closeTo(1, 1e-9));
  });

  test('transform survives an export -> import round trip', () {
    final original = SvgImporter.import(
      '$wrap<g id="rot" transform="matrix(0,1,-1,0,0,0)">$rect</g></svg>',
    )!;

    final reimported = SvgImporter.import(SvgExporter.export(original))!;
    final a = original.elements.single.transform.storage;
    final b = reimported.elements.single.transform.storage;

    expect(b.length, a.length);
    for (var i = 0; i < a.length; i++) {
      expect(b[i], closeTo(a[i], 1e-9), reason: 'storage[$i] diverged');
    }
  });
}
