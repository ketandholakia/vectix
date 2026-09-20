import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class Tool {
  void onPointerDown(PointerDownEvent event, Offset scenePos, WidgetRef ref);
  void onPointerMove(PointerMoveEvent event, Offset scenePos, WidgetRef ref);
  void onPointerUp(PointerUpEvent event, Offset scenePos, WidgetRef ref);
  void onPointerCancel(WidgetRef ref) {}
  void paint(Canvas canvas) {}
  MouseCursor getCursorForPosition(Offset scenePos, WidgetRef ref) => SystemMouseCursors.precise;
}
