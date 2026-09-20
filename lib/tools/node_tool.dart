import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tool.dart';

import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../state/editor_notifier.dart';
import '../models/vx_element.dart';
import '../commands/update_element_command.dart';
import '../state/history_manager.dart';

class NodeTool extends ChangeNotifier implements Tool {
  String? _targetId;
  int? _selectedSegmentIndex;
  Offset? _dragStartPos;
  VxPath? _originalElement;
  VxPath? _previewElement;
  bool _didDrag = false;

  @override
  void onPointerDown(PointerDownEvent event, Offset scenePos, WidgetRef ref) {
    final state = ref.read(editorProvider);
    if (state.selectedIds.length != 1) return;
    
    final id = state.selectedIds.first;
    final element = state.document.elements.firstWhere((e) => e.id == id);
    if (element is! VxPath) return;
    
    _targetId = id;
    _originalElement = element;
    _previewElement = element;
    
    // hit test segments
    final zoom = state.viewport.zoom;
    final hitSize = 10.0 / zoom;
    
    for (int i = 0; i < element.segments.length; i++) {
      final seg = element.segments[i];
      final pt = seg.whenOrNull(
        moveTo: (p) => p,
        lineTo: (p) => p,
        quadraticBezierTo: (c, p) => p,
        cubicBezierTo: (c1, c2, p) => p,
      );
      if (pt != null) {
        // apply transform to pt? Node editing is usually in local space, but we draw in scene space.
        // For simplicity, assume scene space (identity transform) or apply transform.
        final transformedPt = element.transform.transform3(Vector3(pt.dx, pt.dy, 0));
        final scenePt = Offset(transformedPt.x, transformedPt.y);
        if ((scenePos - scenePt).distance <= hitSize) {
          _selectedSegmentIndex = i;
          _dragStartPos = scenePos;
          _didDrag = false;
          notifyListeners();
          return;
        }
      }
    }
    
    _selectedSegmentIndex = null;
    notifyListeners();
  }

  @override
  void onPointerMove(PointerMoveEvent event, Offset scenePos, WidgetRef ref) {
    if (_selectedSegmentIndex != null && _dragStartPos != null && _originalElement != null) {
      // For simplicity, we just modify the point based on delta.
      // But we need the inverse transform to map delta to local space.
      final invTransform = Matrix4.copy(_originalElement!.transform)..invert();
      final localPos3 = invTransform.transform3(Vector3(scenePos.dx, scenePos.dy, 0));
      final localPos = Offset(localPos3.x, localPos3.y);
      
      final segs = List<PathSegment>.from(_originalElement!.segments);
      final oldSeg = segs[_selectedSegmentIndex!];
      
      segs[_selectedSegmentIndex!] = oldSeg.when(
        moveTo: (p) => PathSegment.moveTo(localPos),
        lineTo: (p) => PathSegment.lineTo(localPos),
        quadraticBezierTo: (c, p) => PathSegment.quadraticBezierTo(c, localPos), // only moving point, not controls yet
        cubicBezierTo: (c1, c2, p) => PathSegment.cubicBezierTo(c1, c2, localPos),
        close: () => const PathSegment.close(),
      );
      
      _previewElement = _originalElement!.copyWith(segments: segs) as VxPath;
      ref.read(editorProvider.notifier).updateElement(_previewElement!);
      _didDrag = true;
      notifyListeners();
    }
  }

  @override
  void onPointerUp(PointerUpEvent event, Offset scenePos, WidgetRef ref) {
    if (_didDrag && _originalElement != null && _previewElement != null) {
      ref.read(historyProvider).execute(UpdateElementCommand(
        oldElements: [_originalElement!],
        newElements: [_previewElement!],
        actionName: 'Edit nodes',
      ));
    }
    _dragStartPos = null;
    _didDrag = false;
    notifyListeners();
  }

  @override
  void onPointerCancel(WidgetRef ref) {
    if (_didDrag && _originalElement != null) {
      ref.read(editorProvider.notifier).updateElement(_originalElement!);
    }
    _dragStartPos = null;
    _didDrag = false;
    notifyListeners();
  }

  @override
  void paint(Canvas canvas) {
    if (_previewElement == null) return;
    
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    for (int i = 0; i < _previewElement!.segments.length; i++) {
      final seg = _previewElement!.segments[i];
      final pt = seg.whenOrNull(
        moveTo: (p) => p,
        lineTo: (p) => p,
        quadraticBezierTo: (c, p) => p,
        cubicBezierTo: (c1, c2, p) => p,
      );
      
      if (pt != null) {
        final transformedPt = _previewElement!.transform.transform3(Vector3(pt.dx, pt.dy, 0));
        final scenePt = Offset(transformedPt.x, transformedPt.y);
        
        if (i == _selectedSegmentIndex) {
          paint.color = Colors.red;
        } else {
          paint.color = Colors.blue;
        }
        
        canvas.drawCircle(scenePt, 4, paint);
        canvas.drawCircle(scenePt, 4, strokePaint);
      }
    }
  }

  @override
  MouseCursor getCursorForPosition(Offset scenePos, WidgetRef ref) {
    if (_selectedSegmentIndex != null && _dragStartPos != null) {
      return SystemMouseCursors.move;
    }
    return SystemMouseCursors.precise;
  }
}
