import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:vectix/commands/element_splice.dart';
import 'package:vectix/models/vx_element.dart';

/// Unit tests for the ordering helpers behind the structural commands.
///
/// These exist because an undo that restores the right elements in the wrong
/// order is still a visible bug — layers jump — and the first version of
/// [reinsertElements] used descending insertion, which is only accidentally
/// correct when the index clamps to the end of the list.
void main() {
  VxElement box(String id) => VxElement.rect(
    id: id,
    x: 0,
    y: 0,
    width: 1,
    height: 1,
    transform: Matrix4.identity(),
    fill: const VxFill.none(),
    stroke: const VxStroke(
      color: Colors.transparent,
      width: 0,
      cap: StrokeCap.butt,
      join: StrokeJoin.miter,
    ),
  );

  List<String> idsOf(List<VxElement> elements) =>
      [for (final element in elements) element.id];

  test('indicesOf reports positions and -1 for absent ids', () {
    final elements = [box('a'), box('b'), box('c')];
    expect(indicesOf(elements, ['c', 'a', 'zz']), [2, 0, -1]);
  });

  test('withoutIds keeps the surviving order', () {
    final elements = [box('a'), box('b'), box('c')];
    expect(idsOf(withoutIds(elements, {'b'})), ['a', 'c']);
    expect(idsOf(withoutIds(elements, {'a', 'c'})), ['b']);
  });

  test('containerInsertIndex uses the topmost source position', () {
    final elements = [box('a'), box('b'), box('c'), box('d')];
    // a(0) and c(2) removed -> container sits above b, below d
    expect(containerInsertIndex([0, 2], elements), 1);
    // b(1) and c(2) removed -> 'a' survives below, 'd' above
    expect(containerInsertIndex([1, 2], elements), 1);
    // only the top source removed -> sits at the top
    expect(containerInsertIndex([3], elements), 3);
    // no sources found -> append
    expect(containerInsertIndex([-1], elements), 4);
    expect(containerInsertIndex([], elements), 4);
  });

  test('spliceElements removes and inserts at a clamped index', () {
    final elements = [box('a'), box('b'), box('c')];
    expect(
      idsOf(
        spliceElements(
          elements,
          removedIds: {'a', 'c'},
          index: 1,
          inserted: [box('container')],
        ),
      ),
      ['b', 'container'],
    );
    expect(
      idsOf(
        spliceElements(
          elements,
          removedIds: {'b'},
          index: 99,
          inserted: [box('container')],
        ),
      ),
      ['a', 'c', 'container'],
    );
  });

  group('reinsertElements', () {
    test('restores removed elements to their original positions', () {
      final original = [box('a'), box('b'), box('c'), box('d')];
      final remaining = withoutIds(original, {'b', 'd'});

      final restored = reinsertElements(remaining, [
        MapEntry(1, original[1]),
        MapEntry(3, original[3]),
      ]);

      expect(idsOf(restored), idsOf(original));
    });

    test('restores adjacent elements that were not last', () {
      // The case the descending implementation got wrong: the surviving tail
      // element must stay *after* the reinserted pair.
      final original = [box('t1'), box('l1'), box('r1'), box('e1')];
      final remaining = withoutIds(original, {'l1', 'r1'});

      final restored = reinsertElements(remaining, [
        MapEntry(2, original[2]),
        MapEntry(1, original[1]),
      ]);

      expect(idsOf(restored), ['t1', 'l1', 'r1', 'e1']);
    });

    test('restores the leading element', () {
      final original = [box('a'), box('b'), box('c')];
      final remaining = withoutIds(original, {'a'});
      expect(
        idsOf(reinsertElements(remaining, [MapEntry(0, original[0])])),
        ['a', 'b', 'c'],
      );
    });

    test('appends entries whose index no longer exists', () {
      final restored = reinsertElements([box('a')], [MapEntry(7, box('z'))]);
      expect(idsOf(restored), ['a', 'z']);
    });
  });
}
