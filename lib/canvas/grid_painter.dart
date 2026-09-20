import 'package:flutter/material.dart';
import '../state/editor_state.dart';

class GridPainter extends CustomPainter {
  final ViewportState viewport;
  final double gridSize;
  final Size documentSize;
  final bool showGrid;

  GridPainter(this.viewport, this.gridSize, this.documentSize, this.showGrid);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(viewport.pan.dx, viewport.pan.dy);
    canvas.scale(viewport.zoom);

    // Draw artboard background
    final artboardRect = Rect.fromLTWH(0, 0, documentSize.width, documentSize.height);
    canvas.drawRect(artboardRect, Paint()..color = Colors.transparent);

    if (showGrid && gridSize > 0) {
      final paint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.2)
        ..strokeWidth = 1.0 / viewport.zoom; // Keep 1px logical width regardless of zoom

      for (double x = 0; x <= documentSize.width; x += gridSize) {
        canvas.drawLine(Offset(x, 0), Offset(x, documentSize.height), paint);
      }
      for (double y = 0; y <= documentSize.height; y += gridSize) {
        canvas.drawLine(Offset(0, y), Offset(documentSize.width, y), paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.viewport != viewport ||
        oldDelegate.gridSize != gridSize ||
        oldDelegate.documentSize != documentSize ||
        oldDelegate.showGrid != showGrid;
  }
}
