import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'tool.dart';
import '../canvas/hit_tester.dart';
import '../state/editor_notifier.dart';
import '../state/editor_state.dart';
import '../state/history_manager.dart';
import '../models/vx_element.dart';
import '../models/vx_document.dart';
import '../commands/update_element_command.dart';

enum DragMode {
  move,
  resize,
  rotate,
  rubberBand
}

enum ResizeHandle {
  topLeft, topCenter, topRight,
  centerLeft, centerRight,
  bottomLeft, bottomCenter, bottomRight
}

class SelectTool extends ChangeNotifier implements Tool {
  Offset? _dragStartPos;
  List<VxElement>? _originalElements;
  List<VxElement>? _previewElements;
  bool _didDrag = false;
  
  DragMode _dragMode = DragMode.rubberBand;
  ResizeHandle? _activeHandle;
  Rect? _initialCombinedBounds;
  Offset? _fixedPoint;
  double? _initialAngle;

  Offset? _rubberBandStart;
  Offset? _rubberBandCurrent;

  List<double> _snapX = [];
  List<double> _snapY = [];

  @override
  void onPointerDown(PointerDownEvent event, Offset scenePos, WidgetRef ref) {
    final state = ref.read(editorProvider);
    final zoom = state.viewport.zoom;
    
    if (state.selectedIds.isNotEmpty) {
      final combinedBounds = _getCombinedBounds(state.selectedIds.toList(), state.document);
      if (combinedBounds != null) {
        final rotHandle = Offset(combinedBounds.topCenter.dx, combinedBounds.topCenter.dy - 30.0 / zoom);
        if ((scenePos - rotHandle).distance <= 10.0 / zoom) {
          _dragMode = DragMode.rotate;
          _initialCombinedBounds = combinedBounds;
          _fixedPoint = combinedBounds.center;
          _initialAngle = _getAngle(_fixedPoint!, scenePos);
          _dragStartPos = scenePos;
          _originalElements = state.document.elements.where((e) => state.selectedIds.contains(e.id)).toList();
          _didDrag = false;
          return;
        }

        final handle = _hitTestHandles(scenePos, combinedBounds, zoom);
        if (handle != null) {
          _dragMode = DragMode.resize;
          _activeHandle = handle;
          _initialCombinedBounds = combinedBounds;
          _fixedPoint = _getFixedPoint(combinedBounds, handle);
          _dragStartPos = scenePos;
          _originalElements = state.document.elements.where((e) => state.selectedIds.contains(e.id)).toList();
          _didDrag = false;
          return;
        }
      }
    }

    final hitId = HitTester.hitTest(scenePos, state.document);

    if (hitId != null && state.selectedIds.contains(hitId)) {
      _dragMode = DragMode.move;
      _dragStartPos = scenePos;
      _originalElements = state.document.elements.where((e) => state.selectedIds.contains(e.id)).toList();
      _didDrag = false;
    } else if (hitId != null) {
      ref.read(editorProvider.notifier).selectElement(hitId);
      _dragMode = DragMode.move;
      _dragStartPos = scenePos;
      _originalElements = [state.document.elements.firstWhere((e) => e.id == hitId)];
      _didDrag = false;
    } else {
      ref.read(editorProvider.notifier).clearSelection();
      _dragMode = DragMode.rubberBand;
      _originalElements = null;
      _rubberBandStart = scenePos;
      _rubberBandCurrent = scenePos;
    }
  }

  @override
  void onPointerMove(PointerMoveEvent event, Offset scenePos, WidgetRef ref) {
    if (_dragMode == DragMode.move && _dragStartPos != null) {
      final snappedResult = ref.read(editorProvider.notifier).snap(scenePos);
      _snapX = snappedResult.snapX;
      _snapY = snappedResult.snapY;
      final delta = snappedResult.point - _dragStartPos!;
      final state = ref.read(editorProvider);
      _previewElements = _buildMovedElements(state, delta);
      _didDrag = true;
    } else if (_dragMode == DragMode.resize && _dragStartPos != null && _initialCombinedBounds != null && _fixedPoint != null) {
      final snappedResult = ref.read(editorProvider.notifier).snap(scenePos);
      _snapX = snappedResult.snapX;
      _snapY = snappedResult.snapY;
      final totalDelta = snappedResult.point - _dragStartPos!;
      
      double sx = 1.0;
      double sy = 1.0;
      
      double oldW = _initialCombinedBounds!.width;
      double oldH = _initialCombinedBounds!.height;
      if (oldW == 0) oldW = 1;
      if (oldH == 0) oldH = 1;
      
      switch (_activeHandle!) {
        case ResizeHandle.topLeft:
          sx = (oldW - totalDelta.dx) / oldW;
          sy = (oldH - totalDelta.dy) / oldH;
          break;
        case ResizeHandle.topCenter:
          sy = (oldH - totalDelta.dy) / oldH;
          break;
        case ResizeHandle.topRight:
          sx = (oldW + totalDelta.dx) / oldW;
          sy = (oldH - totalDelta.dy) / oldH;
          break;
        case ResizeHandle.centerLeft:
          sx = (oldW - totalDelta.dx) / oldW;
          break;
        case ResizeHandle.centerRight:
          sx = (oldW + totalDelta.dx) / oldW;
          break;
        case ResizeHandle.bottomLeft:
          sx = (oldW - totalDelta.dx) / oldW;
          sy = (oldH + totalDelta.dy) / oldH;
          break;
        case ResizeHandle.bottomCenter:
          sy = (oldH + totalDelta.dy) / oldH;
          break;
        case ResizeHandle.bottomRight:
          sx = (oldW + totalDelta.dx) / oldW;
          sy = (oldH + totalDelta.dy) / oldH;
          break;
      }
      
      if (sx == 0) sx = 0.001;
      if (sy == 0) sy = 0.001;
      
      final scaleMatrix = Matrix4.identity()
        ..translate(_fixedPoint!.dx, _fixedPoint!.dy)
        ..scale(sx, sy, 1.0)
        ..translate(-_fixedPoint!.dx, -_fixedPoint!.dy);
        
      _previewElements = _originalElements!.map((originalElement) {
        final newTransform = scaleMatrix * originalElement.transform;
        return _withTransform(originalElement, newTransform);
      }).toList();
      _didDrag = true;
    } else if (_dragMode == DragMode.rotate && _dragStartPos != null && _initialCombinedBounds != null && _fixedPoint != null && _initialAngle != null) {
      final currentAngle = _getAngle(_fixedPoint!, scenePos);
      final deltaAngle = currentAngle - _initialAngle!;
      
      final rotMatrix = Matrix4.identity()
        ..translate(_fixedPoint!.dx, _fixedPoint!.dy)
        ..rotateZ(deltaAngle)
        ..translate(-_fixedPoint!.dx, -_fixedPoint!.dy);

      _previewElements = _originalElements!.map((originalElement) {
        final newTransform = rotMatrix * originalElement.transform;
        return _withTransform(originalElement, newTransform);
      }).toList();
      _didDrag = true;
    } else if (_dragMode == DragMode.rubberBand && _rubberBandStart != null) {
      _rubberBandCurrent = scenePos;
    }
    
    if (_previewElements != null && _dragMode != DragMode.rubberBand) {
      for (final el in _previewElements!) {
        ref.read(editorProvider.notifier).updateElement(el);
      }
    }
    
    notifyListeners();
  }

  @override
  void onPointerUp(PointerUpEvent event, Offset scenePos, WidgetRef ref) {
    if ((_dragMode == DragMode.move || _dragMode == DragMode.resize || _dragMode == DragMode.rotate) && _dragStartPos != null && _didDrag && _originalElements != null && _originalElements!.isNotEmpty) {
      final newElements = _previewElements ?? _originalElements!;
      
      String actionName = 'Move element(s)';
      if (_dragMode == DragMode.resize) actionName = 'Resize element(s)';
      if (_dragMode == DragMode.rotate) actionName = 'Rotate element(s)';

      ref.read(historyProvider).execute(UpdateElementCommand(
        oldElements: _originalElements!,
        newElements: newElements,
        actionName: actionName,
      ));
    } else if (_dragMode == DragMode.rubberBand && _rubberBandStart != null && _rubberBandCurrent != null) {
      final rect = Rect.fromPoints(_rubberBandStart!, _rubberBandCurrent!);
      final state = ref.read(editorProvider);
      
      // Ignore tiny rubber bands (e.g. simple clicks on empty space)
      if (rect.width > 2 || rect.height > 2) {
        final selectedIds = <String>{};
        for (final el in state.document.elements) {
          if (el.locked || !el.visible) continue;
          final bounds = _getBounds(el.id, state.document);
          if (rect.overlaps(bounds)) {
            selectedIds.add(el.id);
          }
        }
        
        if (selectedIds.isNotEmpty) {
          ref.read(editorProvider.notifier).setSelection(selectedIds);
        }
      }
    }
    
    _dragStartPos = null;
    _originalElements = null;
    _previewElements = null;
    _didDrag = false;
    _rubberBandStart = null;
    _rubberBandCurrent = null;
    _snapX = [];
    _snapY = [];
    _dragMode = DragMode.rubberBand;
    notifyListeners();
  }

  @override
  void onPointerCancel(WidgetRef ref) {
    if (_didDrag && _originalElements != null) {
      for (final original in _originalElements!) {
        ref.read(editorProvider.notifier).updateElement(original);
      }
    }
    _dragStartPos = null;
    _originalElements = null;
    _previewElements = null;
    _didDrag = false;
    _rubberBandStart = null;
    _rubberBandCurrent = null;
    _snapX = [];
    _snapY = [];
    _dragMode = DragMode.rubberBand;
    notifyListeners();
  }

  VxElement _withTransform(VxElement element, Matrix4 transform) {
    return element.copyWith(transform: transform);
  }

  List<VxElement> _buildMovedElements(EditorState state, Offset delta) {
    final elements = <VxElement>[];
    for (final original in _originalElements!) {
      final newTransform = original.transform.clone()..translate(delta.dx, delta.dy);
      elements.add(original.copyWith(transform: newTransform));
    }
    return elements;
  }

  @override
  void paint(Canvas canvas) {
    if (_previewElements != null) {
      for (final el in _previewElements!) {
        // Just draw bounds or something simple for preview
        final rect = HitTester.getBounds(el, VxDocument(id: 'temp', title: 'temp', width: 800, height: 600, elements: _previewElements!));
        canvas.drawRect(rect, Paint()..color=Colors.blue.withOpacity(0.5)..style=PaintingStyle.stroke);
      }
    }

    if (_dragMode == DragMode.rubberBand && _rubberBandStart != null && _rubberBandCurrent != null) {
      final rect = Rect.fromPoints(_rubberBandStart!, _rubberBandCurrent!);
      final fillPaint = Paint()..color = Colors.blue.withOpacity(0.2)..style = PaintingStyle.fill;
      final borderPaint = Paint()..color = Colors.blue..style = PaintingStyle.stroke..strokeWidth = 1;
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, borderPaint);
    }

    if (_snapX.isNotEmpty || _snapY.isNotEmpty) {
      final snapPaint = Paint()
        ..color = Colors.pinkAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0; // Needs viewport zoom, but for now 1 is okay
      
      for (final x in _snapX) {
        canvas.drawLine(Offset(x, -100000), Offset(x, 100000), snapPaint);
      }
      for (final y in _snapY) {
        canvas.drawLine(Offset(-100000, y), Offset(100000, y), snapPaint);
      }
    }
  }

  double _getAngle(Offset center, Offset point) {
    return math.atan2(point.dy - center.dy, point.dx - center.dx);
  }

  bool _hitTestRect(Offset point, Rect bounds) {
    return bounds.contains(point);
  }

  Rect _getBounds(String id, VxDocument doc) {
    final element = doc.elements.firstWhere((e) => e.id == id);
    return HitTester.getBounds(element, doc);
  }

  Rect? _getCombinedBounds(List<String> ids, VxDocument doc) {
    if (ids.isEmpty) return null;
    Rect? bounds;
    for (final id in ids) {
      final b = _getBounds(id, doc);
      if (b != Rect.zero) {
        bounds = bounds == null ? b : bounds.expandToInclude(b);
      }
    }
    return bounds;
  }

  ResizeHandle? _hitTestHandles(Offset point, Rect bounds, double zoom) {
    final handleSize = 10.0 / zoom;
    final handles = {
      ResizeHandle.topLeft: bounds.topLeft,
      ResizeHandle.topCenter: bounds.topCenter,
      ResizeHandle.topRight: bounds.topRight,
      ResizeHandle.centerLeft: bounds.centerLeft,
      ResizeHandle.centerRight: bounds.centerRight,
      ResizeHandle.bottomLeft: bounds.bottomLeft,
      ResizeHandle.bottomCenter: bounds.bottomCenter,
      ResizeHandle.bottomRight: bounds.bottomRight,
    };

    for (final entry in handles.entries) {
      if ((point - entry.value).distance <= handleSize) {
        return entry.key;
      }
    }
    return null;
  }

  Offset _getFixedPoint(Rect bounds, ResizeHandle handle) {
    switch (handle) {
      case ResizeHandle.topLeft: return bounds.bottomRight;
      case ResizeHandle.topCenter: return bounds.bottomCenter;
      case ResizeHandle.topRight: return bounds.bottomLeft;
      case ResizeHandle.centerLeft: return bounds.centerRight;
      case ResizeHandle.centerRight: return bounds.centerLeft;
      case ResizeHandle.bottomLeft: return bounds.topRight;
      case ResizeHandle.bottomCenter: return bounds.topCenter;
      case ResizeHandle.bottomRight: return bounds.topLeft;
    }
  }

  @override
  MouseCursor getCursorForPosition(Offset scenePos, WidgetRef ref) {
    if (_dragMode != DragMode.rubberBand) {
      if (_dragMode == DragMode.rotate) return SystemMouseCursors.grabbing;
      if (_dragMode == DragMode.move) return SystemMouseCursors.move;
      return SystemMouseCursors.precise; 
    }

    final state = ref.read(editorProvider);
    if (state.selectedIds.isEmpty) return SystemMouseCursors.precise;
    
    final zoom = state.viewport.zoom;
    final combinedBounds = _getCombinedBounds(state.selectedIds.toList(), state.document);
    
    if (combinedBounds != null) {
      final rotHandle = Offset(combinedBounds.topCenter.dx, combinedBounds.topCenter.dy - 30.0 / zoom);
      if ((scenePos - rotHandle).distance <= 10.0 / zoom) {
        return SystemMouseCursors.alias; // Rotation cursor
      }

      final handle = _hitTestHandles(scenePos, combinedBounds, zoom);
      if (handle != null) {
        switch (handle) {
          case ResizeHandle.topLeft:
          case ResizeHandle.bottomRight:
            return SystemMouseCursors.resizeUpLeftDownRight;
          case ResizeHandle.topRight:
          case ResizeHandle.bottomLeft:
            return SystemMouseCursors.resizeUpRightDownLeft;
          case ResizeHandle.topCenter:
          case ResizeHandle.bottomCenter:
            return SystemMouseCursors.resizeUpDown;
          case ResizeHandle.centerLeft:
          case ResizeHandle.centerRight:
            return SystemMouseCursors.resizeLeftRight;
        }
      }
      
      for (final id in state.selectedIds) {
        if (_hitTestRect(scenePos, _getBounds(id, state.document))) {
          return SystemMouseCursors.move;
        }
      }
    }
    
    return SystemMouseCursors.precise;
  }
}
