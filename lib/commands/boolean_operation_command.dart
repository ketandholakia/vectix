import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart';
import '../models/vx_element.dart';
import '../state/editor_notifier.dart';
import 'command.dart';

class BooleanOperationCommand implements Command {
  final List<VxElement> oldElements;
  final int operation; // 0: difference, 1: intersect, 2: union, 3: xor
  late VxCompound newElement;

  BooleanOperationCommand({
    required this.oldElements,
    required this.operation,
  }) {
    // Keep the fill and stroke of the first element (or bottom-most element)
    final baseElement = oldElements.first;
    
    VxFill baseFill = const VxFill.solid(color: Color(0xFFCCCCCC));
    VxStroke baseStroke = const VxStroke(color: Color(0xFF000000), width: 1.0, cap: StrokeCap.butt, join: StrokeJoin.miter);
    
    baseElement.mapOrNull(
      rect: (e) { baseFill = e.fill; baseStroke = e.stroke; },
      ellipse: (e) { baseFill = e.fill; baseStroke = e.stroke; },
      path: (e) { baseFill = e.fill; baseStroke = e.stroke; },
      compound: (e) { baseFill = e.fill; baseStroke = e.stroke; },
    );

    newElement = VxCompound(
      id: const Uuid().v4(),
      operation: operation,
      children: oldElements,
      transform: Matrix4.identity(),
      fill: baseFill,
      stroke: baseStroke,
    );
  }

  @override
  void execute(EditorNotifier editor) {
    for (final el in oldElements) {
      editor.removeElement(el.id);
    }
    editor.addElement(newElement);
    editor.setSelection({newElement.id});
  }

  @override
  void undo(EditorNotifier editor) {
    editor.removeElement(newElement.id);
    for (final el in oldElements) {
      editor.addElement(el);
    }
    editor.setSelection(oldElements.map((e) => e.id).toSet());
  }

  @override
  String get description {
    switch (operation) {
      case 0: return 'Boolean Difference';
      case 1: return 'Boolean Intersect';
      case 2: return 'Boolean Union';
      case 3: return 'Boolean XOR';
      default: return 'Boolean Operation';
    }
  }
}

