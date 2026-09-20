import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tool.dart';

import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../state/editor_notifier.dart';
import '../state/editor_state.dart';
import '../models/vx_element.dart';

class TextTool extends ChangeNotifier implements Tool {
  @override
  void onPointerDown(PointerDownEvent event, Offset scenePos, WidgetRef ref) {
    final state = ref.read(editorProvider);
    final textElement = VxElement.text(
      id: const Uuid().v4(),
      artboardId: state.document.artboards.isNotEmpty ? state.document.artboards[state.document.activePageIndex].id : null,
      content: 'Text',
      x: scenePos.dx,
      y: scenePos.dy,
      style: const TextStyle(fontSize: 24, color: Colors.black),
      transform: Matrix4.identity(),
    );
    
    ref.read(editorProvider.notifier).addElement(textElement);
    ref.read(editorProvider.notifier).setSelection({textElement.id});
    ref.read(editorProvider.notifier).setTool(ActiveTool.select);
    ref.read(editorProvider.notifier).startTextEditing(textElement.id);
  }

  @override
  void onPointerMove(PointerMoveEvent event, Offset scenePos, WidgetRef ref) {}

  @override
  void onPointerUp(PointerUpEvent event, Offset scenePos, WidgetRef ref) {}

  @override
  void onPointerCancel(WidgetRef ref) {}

  @override
  void paint(Canvas canvas) {}

  @override
  MouseCursor getCursorForPosition(Offset scenePos, WidgetRef ref) => SystemMouseCursors.text;
}
