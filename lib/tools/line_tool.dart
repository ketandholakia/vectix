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

class LineTool extends ChangeNotifier implements Tool {
  Offset? _startPos;
  Offset? _currentPos;
  VxElement? _previewElement;

  @override
  void onPointerDown(PointerDownEvent event, Offset scenePos, WidgetRef ref) {
    _startPos = scenePos;
    _currentPos = scenePos;
    _updatePreview(ref);
  }

  @override
  void onPointerMove(PointerMoveEvent event, Offset scenePos, WidgetRef ref) {
    if (_startPos == null) return;
    _currentPos = scenePos;
    _updatePreview(ref);
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

  void _updatePreview(WidgetRef ref) {
    if (_startPos == null || _currentPos == null) return;
    
    final strokeWidth = ref.read(editorProvider).lineStrokeWidth;
    
    _previewElement = VxElement.path(
      id: const Uuid().v4(),
      segments: [
        PathSegment.moveTo(_startPos!),
        PathSegment.lineTo(_currentPos!),
      ],
      transform: Matrix4.identity(),
      fill: const VxFill.none(),
      stroke: VxStroke(color: Colors.black, width: strokeWidth, cap: StrokeCap.butt, join: StrokeJoin.miter),
    );
    notifyListeners();
  }

  @override
  void paint(Canvas canvas) {
    if (_previewElement != null) {
      final pathEl = _previewElement as VxPath;
      final strokePaint = Paint()
        ..color = pathEl.stroke.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = pathEl.stroke.width;
        
      if (pathEl.segments.length >= 2) {
        canvas.drawLine(
          (pathEl.segments[0] as MoveToSegment).point,
          (pathEl.segments[1] as LineToSegment).point,
          strokePaint,
        );
      }
    }
  }

  @override
  MouseCursor getCursorForPosition(Offset scenePos, WidgetRef ref) => SystemMouseCursors.precise;
}
