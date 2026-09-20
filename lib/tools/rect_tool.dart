import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'tool.dart';
import '../models/vx_element.dart';
import '../state/history_manager.dart';
import '../commands/add_element_command.dart';
import '../state/editor_notifier.dart';

class RectTool extends ChangeNotifier implements Tool {
  Offset? _startPos;
  Offset? _currentPos;
  VxElement? _previewElement;

  @override
  void onPointerDown(PointerDownEvent event, Offset scenePos, WidgetRef ref) {
    _startPos = scenePos;
    _currentPos = scenePos;
    _updatePreview();
  }

  @override
  void onPointerMove(PointerMoveEvent event, Offset scenePos, WidgetRef ref) {
    if (_startPos == null) return;
    _currentPos = scenePos;
    _updatePreview();
  }

  @override
  void onPointerUp(PointerUpEvent event, Offset scenePos, WidgetRef ref) {
    if (_startPos != null && _previewElement != null) {
      if ((_startPos! - scenePos).distance > 2) {
        ref.read(historyProvider).execute(AddElementCommand(_previewElement!));
        ref.read(editorProvider.notifier).selectElement(_previewElement!.id);
      }
    }
    _startPos = null;
    _currentPos = null;
    _previewElement = null;
    notifyListeners();
  }

  @override
  void onPointerCancel(WidgetRef ref) {
    _startPos = null;
    _currentPos = null;
    _previewElement = null;
    notifyListeners();
  }

  void _updatePreview() {
    if (_startPos == null || _currentPos == null) return;
    final rect = Rect.fromPoints(_startPos!, _currentPos!);
    
    _previewElement = VxElement.rect(
      id: const Uuid().v4(),
      x: rect.left,
      y: rect.top,
      width: rect.width,
      height: rect.height,
      transform: Matrix4.identity(),
      fill: const VxFill.solid(color: Colors.grey),
      stroke: const VxStroke(color: Colors.black, width: 2, cap: StrokeCap.butt, join: StrokeJoin.miter),
    );
    notifyListeners();
  }

  @override
  void paint(Canvas canvas) {
    if (_previewElement != null) {
      final rect = _previewElement as VxRect;
      final fillPaint = Paint()..color = (rect.fill as SolidFill).color..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = rect.stroke.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.stroke.width;
        
      final drawRect = Rect.fromLTWH(rect.x, rect.y, rect.width, rect.height);
      canvas.drawRect(drawRect, fillPaint);
      canvas.drawRect(drawRect, strokePaint);
    }
  }

  @override
  MouseCursor getCursorForPosition(Offset scenePos, WidgetRef ref) => SystemMouseCursors.precise;
}
