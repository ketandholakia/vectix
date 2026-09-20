import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../tools/tool_provider.dart';
import '../state/editor_state.dart';

class ToolPreviewPainter extends CustomPainter {
  final WidgetRef ref;
  final ViewportState viewport;

  ToolPreviewPainter(this.ref, this.viewport, {Listenable? repaint}) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final tool = ref.read(toolProvider);
    
    canvas.save();
    canvas.translate(viewport.pan.dx, viewport.pan.dy);
    canvas.scale(viewport.zoom);
    
    tool.paint(canvas);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ToolPreviewPainter oldDelegate) {
    return oldDelegate.viewport != viewport || oldDelegate.ref != ref;
  }
}
