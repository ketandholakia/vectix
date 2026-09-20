import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tool.dart';

import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../state/editor_notifier.dart';
import '../models/vx_element.dart';
import '../commands/add_element_command.dart';
import '../state/history_manager.dart';

class FreehandTool extends ChangeNotifier implements Tool {
  List<Offset> _points = [];
  VxElement? _previewElement;

  @override
  void onPointerDown(PointerDownEvent event, Offset scenePos, WidgetRef ref) {
    _points = [scenePos];
    _updatePreview(ref);
  }

  @override
  void onPointerMove(PointerMoveEvent event, Offset scenePos, WidgetRef ref) {
    if (_points.isEmpty) return;
    _points.add(scenePos);
    _updatePreview(ref);
  }

  @override
  void onPointerUp(PointerUpEvent event, Offset scenePos, WidgetRef ref) {
    if (_points.length > 1 && _previewElement != null) {
      ref.read(historyProvider).execute(AddElementCommand(_previewElement!));
    }
    _points.clear();
    _previewElement = null;
    notifyListeners();
  }

  @override
  void onPointerCancel(WidgetRef ref) {
    _points.clear();
    _previewElement = null;
    notifyListeners();
  }

  void _updatePreview(WidgetRef ref) {
    if (_points.isEmpty) return;

    final state = ref.read(editorProvider);
    final strokeWidth = state.lineStrokeWidth;
    
    final segments = <PathSegment>[];
    segments.add(PathSegment.moveTo(_points.first));
    for (int i = 1; i < _points.length; i++) {
      segments.add(PathSegment.lineTo(_points[i]));
    }

    _previewElement = VxElement.path(
      id: const Uuid().v4(),
      artboardId: state.document.artboards.isNotEmpty ? state.document.artboards[state.document.activePageIndex].id : null,
      segments: segments,
      transform: Matrix4.identity(),
      fill: const VxFill.none(),
      stroke: VxStroke(color: Colors.black, width: strokeWidth, cap: StrokeCap.round, join: StrokeJoin.round),
    );
    notifyListeners();
  }

  @override
  void paint(Canvas canvas) {
    if (_previewElement == null) return;
    final path = Path();
    path.moveTo(_points.first.dx, _points.first.dy);
    for (int i = 1; i < _points.length; i++) {
      path.lineTo(_points[i].dx, _points[i].dy);
    }
    
    // Quick paint without looking up ref again, just hardcoded or fallback
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    canvas.drawPath(path, paint);
  }

  @override
  MouseCursor getCursorForPosition(Offset scenePos, WidgetRef ref) => SystemMouseCursors.precise;
}
