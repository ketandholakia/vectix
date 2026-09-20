import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tool.dart';

import '../state/editor_notifier.dart';

class HandTool extends ChangeNotifier implements Tool {
  bool _isDragging = false;

  @override
  void onPointerDown(PointerDownEvent event, Offset scenePos, WidgetRef ref) {
    _isDragging = true;
    notifyListeners();
  }

  @override
  void onPointerMove(PointerMoveEvent event, Offset scenePos, WidgetRef ref) {
    if (_isDragging) {
      ref.read(editorProvider.notifier).updatePan(event.localDelta);
    }
  }

  @override
  void onPointerUp(PointerUpEvent event, Offset scenePos, WidgetRef ref) {
    _isDragging = false;
    notifyListeners();
  }

  @override
  void onPointerCancel(WidgetRef ref) {
    _isDragging = false;
    notifyListeners();
  }

  @override
  void paint(Canvas canvas) {}

  @override
  MouseCursor getCursorForPosition(Offset scenePos, WidgetRef ref) {
    return _isDragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab;
  }
}
