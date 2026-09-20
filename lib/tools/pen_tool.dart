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

class PenTool extends ChangeNotifier implements Tool {
  final List<PathSegment> _segments = [];
  Offset? _currentPos;
  VxElement? _previewElement;

  @override
  void onPointerDown(PointerDownEvent event, Offset scenePos, WidgetRef ref) {
    if (_segments.isEmpty) {
      _segments.add(PathSegment.moveTo(scenePos));
    } else {
      // Check if close to start
      final startPos = _segments.first.whenOrNull(moveTo: (p) => p);
      final state = ref.read(editorProvider);
      final zoom = state.viewport.zoom;
      
      if (startPos != null && (scenePos - startPos).distance < 10.0 / zoom) {
        _segments.add(const PathSegment.close());
        _commit(ref);
        return;
      }
      
      _segments.add(PathSegment.lineTo(scenePos));
    }
    _currentPos = scenePos;
    _updatePreview(ref);
  }

  @override
  void onPointerMove(PointerMoveEvent event, Offset scenePos, WidgetRef ref) {
    if (_segments.isNotEmpty) {
      _currentPos = scenePos;
      _updatePreview(ref);
    }
  }

  @override
  void onPointerUp(PointerUpEvent event, Offset scenePos, WidgetRef ref) {}

  @override
  void onPointerCancel(WidgetRef ref) {}

  void _commit(WidgetRef ref) {
    if (_previewElement != null && _segments.length > 1) {
      ref.read(historyProvider).execute(AddElementCommand(_previewElement!));
    }
    _segments.clear();
    _currentPos = null;
    _previewElement = null;
    notifyListeners();
  }
  
  // Can be called when switching tools to commit the open path
  void commitOpenPath(WidgetRef ref) {
    _commit(ref);
  }

  void _updatePreview(WidgetRef ref) {
    if (_segments.isEmpty) return;

    final state = ref.read(editorProvider);
    final strokeWidth = state.lineStrokeWidth;
    
    final previewSegments = List<PathSegment>.from(_segments);
    if (_currentPos != null && previewSegments.last is! CloseSegment) {
      previewSegments.add(PathSegment.lineTo(_currentPos!));
    }

    _previewElement = VxElement.path(
      id: const Uuid().v4(),
      artboardId: state.document.artboards.isNotEmpty ? state.document.artboards[state.document.activePageIndex].id : null,
      segments: previewSegments,
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
    bool moved = false;
    final pathElement = _previewElement as VxPath;
    for (final seg in pathElement.segments) {
      seg.when(
        moveTo: (p) { path.moveTo(p.dx, p.dy); moved = true; },
        lineTo: (p) { if (moved) path.lineTo(p.dx, p.dy); },
        quadraticBezierTo: (c, p) { if (moved) path.quadraticBezierTo(c.dx, c.dy, p.dx, p.dy); },
        cubicBezierTo: (c1, c2, p) { if (moved) path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p.dx, p.dy); },
        close: () => path.close(),
      );
    }
    
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
