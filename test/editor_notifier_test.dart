import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vectix/state/editor_notifier.dart';
import 'package:vectix/state/editor_state.dart';
import 'package:vectix/models/vx_document.dart';
import 'package:vectix/models/vx_element.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:flutter/material.dart';

void main() {
  group('EditorNotifier State Management', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has empty document and select tool', () {
      final state = container.read(editorProvider);
      expect(state.activeTool, ActiveTool.select);
      expect(state.document.elements, isEmpty);
      expect(state.selectedIds, isEmpty);
    });

    test('setTool changes active tool', () {
      container.read(editorProvider.notifier).setTool(ActiveTool.rect);
      expect(container.read(editorProvider).activeTool, ActiveTool.rect);
    });

    test('addElement adds an element to the document', () {
      final notifier = container.read(editorProvider.notifier);
      final element = VxElement.rect(
        id: '1',
        x: 0,
        y: 0,
        width: 100,
        height: 100,
        transform: Matrix4.identity(),
        fill: const VxFill.solid(color: Colors.red),
        stroke: const VxStroke(color: Colors.black, width: 1, cap: StrokeCap.butt, join: StrokeJoin.miter),
      );

      notifier.addElement(element);

      final state = container.read(editorProvider);
      expect(state.document.elements.length, 1);
      expect(state.document.elements.first.id, '1');
    });

    test('removeElement removes an element', () {
      final notifier = container.read(editorProvider.notifier);
      final element = VxElement.rect(
        id: '1',
        x: 0,
        y: 0,
        width: 100,
        height: 100,
        transform: Matrix4.identity(),
        fill: const VxFill.solid(color: Colors.red),
        stroke: const VxStroke(color: Colors.black, width: 1, cap: StrokeCap.butt, join: StrokeJoin.miter),
      );

      notifier.addElement(element);
      notifier.selectElement('1');
      expect(container.read(editorProvider).document.elements.length, 1);
      expect(container.read(editorProvider).selectedIds.contains('1'), isTrue);

      notifier.removeElement('1');

      final state = container.read(editorProvider);
      expect(state.document.elements, isEmpty);
      expect(state.selectedIds, isEmpty); // selection should be cleared
    });

    test('selectElement and clearSelection work correctly', () {
      final notifier = container.read(editorProvider.notifier);
      notifier.selectElement('test_id');
      expect(container.read(editorProvider).selectedIds, {'test_id'});

      notifier.clearSelection();
      expect(container.read(editorProvider).selectedIds, isEmpty);
    });

    test('updateElement correctly replaces an existing element', () {
      final notifier = container.read(editorProvider.notifier);
      final element = VxElement.rect(
        id: '1',
        x: 0,
        y: 0,
        width: 100,
        height: 100,
        transform: Matrix4.identity(),
        fill: const VxFill.solid(color: Colors.red),
        stroke: const VxStroke(color: Colors.black, width: 1, cap: StrokeCap.butt, join: StrokeJoin.miter),
      );

      notifier.addElement(element);

      final updatedElement = (element as VxRect).copyWith(width: 200);
      notifier.updateElement(updatedElement);

      final state = container.read(editorProvider);
      expect((state.document.elements.first as VxRect).width, 200);
    });

    test('setElements replaces all elements', () {
      final notifier = container.read(editorProvider.notifier);
      final element1 = VxElement.rect(
        id: '1',
        x: 0,
        y: 0,
        width: 100,
        height: 100,
        transform: Matrix4.identity(),
        fill: const VxFill.solid(color: Colors.red),
        stroke: const VxStroke(color: Colors.black, width: 1, cap: StrokeCap.butt, join: StrokeJoin.miter),
      );
      final element2 = element1.copyWith(id: '2');

      notifier.setElements([element1, element2]);

      final state = container.read(editorProvider);
      expect(state.document.elements.length, 2);
      expect(state.document.elements[0].id, '1');
      expect(state.document.elements[1].id, '2');
    });
  });
}
