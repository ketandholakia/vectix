import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:vectix/commands/add_element_command.dart';
import 'package:vectix/commands/boolean_operation_command.dart';
import 'package:vectix/commands/delete_element_command.dart';
import 'package:vectix/commands/group_command.dart';
import 'package:vectix/commands/reorder_element_command.dart';
import 'package:vectix/commands/text_edit_command.dart';
import 'package:vectix/commands/ungroup_command.dart';
import 'package:vectix/commands/update_element_command.dart';
import 'package:vectix/models/vx_element.dart';
import 'package:vectix/state/document_edit.dart';
import 'package:vectix/state/editor_notifier.dart';
import 'package:vectix/state/history_manager.dart';

/// Regression tests for **C1** — finding P1-6.
///
/// Undo covered the drawing tools, dragging and node editing, but a dozen paths
/// wrote state directly: creating text, lock/hide, artboard operations, document
/// size, element metadata. This suite is the contract: every user-level
/// operation changes the document *and* reverses cleanly, and a deep stack of
/// them unwinds to a byte-identical snapshot.
void main() {
  late ProviderContainer container;
  late EditorNotifier editor;
  late HistoryManager history;

  setUp(() {
    container = ProviderContainer();
    editor = container.read(editorProvider.notifier);
    history = container.read(historyProvider);
  });

  tearDown(() => container.dispose());

  /// The document serialised — deep, ordered, and exact.
  String snapshot() => jsonEncode(container.read(editorProvider).document.toJson());

  List<VxElement> elements() => container.read(editorProvider).document.elements;

  void docEdit(String name, void Function() mutate) => recordDocumentEdit(
    editor: editor,
    history: history,
    actionName: name,
    mutate: mutate,
  );

  const noStroke = VxStroke(
    color: Colors.transparent,
    width: 0,
    cap: StrokeCap.butt,
    join: StrokeJoin.miter,
  );

  VxElement rect(String id, {double x = 0, double y = 0, Color color = Colors.red}) =>
      VxElement.rect(
        id: id,
        x: x,
        y: y,
        width: 20,
        height: 10,
        transform: Matrix4.identity(),
        fill: VxFill.solid(color: color),
        stroke: noStroke,
      );

  VxElement ellipse(String id, {double x = 40}) => VxElement.ellipse(
    id: id,
    cx: x,
    cy: 5,
    rx: 10,
    ry: 5,
    transform: Matrix4.identity(),
    fill: VxFill.solid(color: Colors.blue),
    stroke: noStroke,
  );

  VxElement line(String id) => VxElement.path(
    id: id,
    segments: [const PathSegment.moveTo(Offset(0, 0)), const PathSegment.lineTo(Offset(30, 30))],
    transform: Matrix4.identity(),
    fill: const VxFill.none(),
    stroke: const VxStroke(
      color: Colors.black,
      width: 2,
      cap: StrokeCap.butt,
      join: StrokeJoin.miter,
    ),
  );

  VxElement text(String id) => VxElement.text(
    id: id,
    content: 'Text',
    x: 5,
    y: 40,
    style: const TextStyle(fontSize: 12, color: Colors.black),
    transform: Matrix4.identity(),
  );

  VxElement find(String id) => elements().firstWhere((e) => e.id == id);

  /// One user-level operation, expressed through the same commands the UI uses.
  final steps = <({String name, void Function() run})>[
    (name: 'add rectangle', run: () => history.execute(AddElementCommand(rect('r1')))),
    (name: 'add ellipse', run: () => history.execute(AddElementCommand(ellipse('e1')))),
    (name: 'add line', run: () => history.execute(AddElementCommand(line('l1')))),
    (name: 'add text', run: () => history.execute(AddElementCommand(text('t1')))),
    (
      name: 'move rectangle',
      run: () {
        final before = find('r1');
        history.execute(
          UpdateElementCommand(
            oldElements: [before],
            newElements: [before.copyWith(transform: Matrix4.identity()..translate(12.0, 7.0))],
            actionName: 'Move element(s)',
          ),
        );
      },
    ),
    (
      name: 'resize ellipse',
      run: () {
        final before = find('e1') as VxEllipse;
        history.execute(
          UpdateElementCommand(
            oldElements: [before],
            newElements: [before.copyWith(rx: 18)],
            actionName: 'Resize element(s)',
          ),
        );
      },
    ),
    (
      name: 'rotate line',
      run: () {
        final before = find('l1');
        history.execute(
          UpdateElementCommand(
            oldElements: [before],
            newElements: [before.copyWith(transform: Matrix4.rotationZ(0.4))],
            actionName: 'Rotate element(s)',
          ),
        );
      },
    ),
    (
      name: 'change fill',
      run: () {
        final before = find('r1') as VxRect;
        history.execute(
          UpdateElementCommand(
            oldElements: [before],
            newElements: [before.copyWith(fill: const VxFill.solid(color: Colors.green))],
            actionName: 'Change fill color',
          ),
        );
      },
    ),
    (
      name: 'change stroke',
      run: () {
        final before = find('e1') as VxEllipse;
        history.execute(
          UpdateElementCommand(
            oldElements: [before],
            newElements: [
              before.copyWith(
                stroke: const VxStroke(
                  color: Colors.black,
                  width: 3,
                  cap: StrokeCap.round,
                  join: StrokeJoin.round,
                ),
              ),
            ],
            actionName: 'Change stroke color',
          ),
        );
      },
    ),
    (
      name: 'reorder layers',
      run: () {
        final before = elements();
        history.execute(
          ReorderElementsCommand(
            oldElements: before,
            newElements: before.reversed.toList(),
          ),
        );
      },
    ),
    (
      name: 'group',
      run: () => history.execute(GroupCommand([find('r1'), find('e1')])),
    ),
    (
      name: 'ungroup',
      run: () {
        final group = elements().whereType<VxGroup>().first;
        history.execute(UngroupCommand(group));
      },
    ),
    (
      name: 'boolean union',
      run: () => history.execute(
        BooleanOperationCommand(oldElements: [find('r1'), find('l1')], operation: 2),
      ),
    ),
    (
      name: 'edit text',
      run: () {
        final before = elements().whereType<VxText>().first;
        history.execute(
          TextEditCommand(
            oldElement: before,
            newElement: before.copyWith(content: 'Edited'),
          ),
        );
      },
    ),
    (
      name: 'lock element',
      run: () => docEdit(
        'Lock element',
        () => editor.updateElementFlags('e1', locked: true),
      ),
    ),
    (
      name: 'hide element',
      run: () => docEdit(
        'Hide element',
        // 't1', not 'l1': the line was consumed by the boolean union above, and
        // hiding a non-existent element changes nothing (correctly recording no
        // undo step, which is asserted separately below).
        () => editor.updateElementFlags('t1', visible: false),
      ),
    ),
    (
      name: 'add artboard',
      run: () => docEdit('Add artboard', () => editor.addPage()),
    ),
    (
      name: 'rename artboard',
      run: () => docEdit('Rename artboard', () => editor.renameActivePage('Cover')),
    ),
    (
      name: 'change document size',
      run: () => docEdit(
        'Change artboard size',
        () => editor.setDocumentSize(2100, 2970),
      ),
    ),
    (
      name: 'delete element',
      run: () => history.execute(DeleteElementCommand([find('t1')])),
    ),
  ];

  test('there are 20 operations under test', () {
    expect(steps.length, 20);
  });

  test('each operation changes the document and reverses cleanly', () {
    for (final step in steps) {
      final before = snapshot();

      step.run();
      final after = snapshot();
      expect(after, isNot(before), reason: '${step.name} changed nothing');

      history.undo();
      expect(snapshot(), before, reason: '${step.name} left the document changed after undo');

      history.redo();
      expect(snapshot(), after, reason: '${step.name} did not redo to the same state');
    }
  });

  test('20 operations unwind to a byte-identical snapshot', () {
    final initial = snapshot();
    for (final step in steps) {
      step.run();
    }
    final finalState = snapshot();

    for (var i = 0; i < steps.length; i++) {
      expect(history.canUndo, isTrue, reason: 'history ran out at undo #${i + 1}');
      history.undo();
    }
    expect(snapshot(), initial, reason: 'undoing everything must restore the start');

    for (var i = 0; i < steps.length; i++) {
      history.redo();
    }
    expect(snapshot(), finalState, reason: 'redoing everything must restore the end');
  });

  test('a document edit that changes nothing does not touch the undo stack', () {
    final initial = snapshot();
    final depthBefore = container.read(editorProvider).document;

    // Renaming to the existing name is a no-op inside the notifier.
    docEdit('Rename artboard', () => editor.renameActivePage('Artboard 1'));

    expect(snapshot(), initial);
    expect(container.read(editorProvider).document, depthBefore);
    expect(history.canUndo, isFalse, reason: 'a no-op must not create an undo step');
  });
}
