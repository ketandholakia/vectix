import 'package:flutter/material.dart';
import '../state/editor_state.dart';
import '../models/vx_element.dart';
import '../models/vx_document.dart';
import 'hit_tester.dart';
import 'scene_index.dart';

class SelectionPainter extends CustomPainter {
  final EditorState state;

  SelectionPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    if (state.selectedIds.isEmpty) return;
    if (state.activeTool == ActiveTool.node) return; // NodeTool draws its own selection

    canvas.save();
    canvas.translate(state.viewport.pan.dx, state.viewport.pan.dy);
    canvas.scale(state.viewport.zoom);

    final paint = Paint()
      ..color = Colors.blue[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / state.viewport.zoom;

    final handlePaint = Paint()
      ..color = Colors.blue[400]!
      ..style = PaintingStyle.fill;
      
    final handleStrokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / state.viewport.zoom;

    final sceneIndex = SceneIndex.of(state.document);
    final elementsById = {for (final element in sceneIndex.activeElements) element.id: element};
    final handleSize = state.viewport.zoom < 0.75 ? 10.0 / state.viewport.zoom : 8.0 / state.viewport.zoom;
    for (final id in state.selectedIds) {
      final element = elementsById[id];
      if (element == null) continue;
      
      // Calculate bounds using hit tester logic for accuracy across all types
      final bounds = HitTester.getBounds(element, state.document);
      if (bounds != Rect.zero) {
        // Draw bounding box
        canvas.drawRect(bounds, paint);

        // Draw 8 handles
        final handles = [
          bounds.topLeft,
          bounds.topCenter,
          bounds.topRight,
          bounds.centerLeft,
          bounds.centerRight,
          bounds.bottomLeft,
          bounds.bottomCenter,
          bounds.bottomRight,
        ];

        for (final handle in handles) {
          canvas.drawCircle(handle, handleSize / 2, handlePaint);
          canvas.drawCircle(handle, handleSize / 2, handleStrokePaint);
        }

        // Draw rotation handle
        final rotHandle = Offset(bounds.topCenter.dx, bounds.topCenter.dy - 34.0 / state.viewport.zoom);
        canvas.drawLine(bounds.topCenter, rotHandle, paint);
        canvas.drawCircle(rotHandle, handleSize / 2, handlePaint);
        canvas.drawCircle(rotHandle, handleSize / 2, handleStrokePaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SelectionPainter oldDelegate) {
    return oldDelegate.state != state;
  }
}

