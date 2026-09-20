import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vectix/state/editor_notifier.dart';
import 'package:vectix/state/history_manager.dart';
import 'package:vectix/commands/add_element_command.dart';
import 'package:vectix/commands/delete_element_command.dart';
import 'package:vectix/commands/update_element_command.dart';
import 'package:vectix/commands/reorder_element_command.dart';
import 'package:vectix/models/vx_element.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:flutter/material.dart';

void main() {
  group('HistoryManager and Commands', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    VxElement createDummyElement(String id) {
      return VxElement.rect(
        id: id,
        x: 0,
        y: 0,
        width: 100,
        height: 100,
        transform: Matrix4.identity(),
        fill: const VxFill.none(),
        stroke: const VxStroke(color: Colors.black, width: 1, cap: StrokeCap.butt, join: StrokeJoin.miter),
      );
    }

    test('AddElementCommand executes and undoes correctly', () {
      final history = container.read(historyProvider);
      final element = createDummyElement('1');

      history.execute(AddElementCommand(element));

      var state = container.read(editorProvider);
      expect(state.document.elements.length, 1);
      expect(state.document.elements.first.id, '1');

      history.undo();

      state = container.read(editorProvider);
      expect(state.document.elements, isEmpty);

      history.redo();

      state = container.read(editorProvider);
      expect(state.document.elements.length, 1);
    });

    test('DeleteElementCommand executes and undoes correctly', () {
      final history = container.read(historyProvider);
      final element = createDummyElement('1');
      container.read(editorProvider.notifier).addElement(element);

      history.execute(DeleteElementCommand([element]));

      var state = container.read(editorProvider);
      expect(state.document.elements, isEmpty);

      history.undo();

      state = container.read(editorProvider);
      expect(state.document.elements.length, 1);
      expect(state.document.elements.first.id, '1');
    });

    test('UpdateElementCommand executes and undoes correctly', () {
      final history = container.read(historyProvider);
      final element = createDummyElement('1');
      container.read(editorProvider.notifier).addElement(element);

      final newElement = (element as VxRect).copyWith(width: 500);
      history.execute(UpdateElementCommand(oldElements: [element], newElements: [newElement]));

      var state = container.read(editorProvider);
      expect((state.document.elements.first as VxRect).width, 500);

      history.undo();

      state = container.read(editorProvider);
      expect((state.document.elements.first as VxRect).width, 100);
    });

    test('ReorderElementsCommand executes and undoes correctly', () {
      final history = container.read(historyProvider);
      final e1 = createDummyElement('1');
      final e2 = createDummyElement('2');
      container.read(editorProvider.notifier).setElements([e1, e2]);

      final oldElements = [e1, e2];
      final newElements = [e2, e1];

      history.execute(ReorderElementsCommand(oldElements: oldElements, newElements: newElements));

      var state = container.read(editorProvider);
      expect(state.document.elements[0].id, '2');
      expect(state.document.elements[1].id, '1');

      history.undo();

      state = container.read(editorProvider);
      expect(state.document.elements[0].id, '1');
      expect(state.document.elements[1].id, '2');
    });
  });
}
