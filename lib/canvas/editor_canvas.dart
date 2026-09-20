import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/editor_notifier.dart';
import '../state/editor_state.dart';
import '../tools/tool_provider.dart';
import 'grid_painter.dart';
import 'scene_painter.dart';
import 'selection_painter.dart';
import 'tool_preview_painter.dart';
import 'inline_text_editor.dart';

class EditorCanvas extends ConsumerStatefulWidget {
  const EditorCanvas({super.key});

  @override
  ConsumerState<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends ConsumerState<EditorCanvas> {
  Offset? _touchScaleStart;
  Offset _touchStartPan = Offset.zero;
  double _touchStartZoom = 1.0;
  MouseCursor _currentCursor = SystemMouseCursors.precise;

  void _updateCursor(PointerEvent e, ViewportState viewport, dynamic tool) {
    final scenePos = (e.localPosition - viewport.pan) / viewport.zoom;
    final nextCursor = tool.getCursorForPosition(scenePos, ref);
    if (nextCursor != _currentCursor) {
      setState(() {
        _currentCursor = nextCursor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final tool = ref.watch(toolProvider);
    final activeArtboard = state.document.artboards.isNotEmpty && state.document.activePageIndex < state.document.artboards.length
        ? state.document.artboards[state.document.activePageIndex]
        : null;
    final documentSize = Size(activeArtboard?.width ?? state.document.width, activeArtboard?.height ?? state.document.height);

    return ClipRect(
      child: Stack(
        children: [
          RepaintBoundary(
            child: CustomPaint(
              painter: GridPainter(
                state.viewport,
                state.gridSize,
                documentSize,
                state.showGrid,
              ),
              size: Size.infinite,
            ),
          ),
          RepaintBoundary(
            child: CustomPaint(
              painter: ScenePainter(state.document, state.viewport),
              size: Size.infinite,
            ),
          ),
          RepaintBoundary(
            child: CustomPaint(
              painter: SelectionPainter(state),
              size: Size.infinite,
            ),
          ),
          RepaintBoundary(
            child: CustomPaint(
              painter: ToolPreviewPainter(ref, state.viewport, repaint: tool is Listenable ? tool as Listenable : null),
              size: Size.infinite,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onScaleStart: (details) {
              if (details.pointerCount > 1) {
                _touchScaleStart = details.focalPoint;
                _touchStartPan = state.viewport.pan;
                _touchStartZoom = state.viewport.zoom;
              }
            },
            onScaleUpdate: (details) {
              if (details.pointerCount < 2) return;
              final notifier = ref.read(editorProvider.notifier);
              final nextZoom = (_touchStartZoom * details.scale).clamp(0.1, 10.0);
              final scenePoint = (_touchScaleStart! - state.viewport.pan) / state.viewport.zoom;
              final nextPan = details.focalPoint - scenePoint * nextZoom;
              notifier.setZoom(nextZoom, focalPoint: details.focalPoint);
              notifier.updatePan(nextPan - ref.read(editorProvider).viewport.pan);
            },
            onScaleEnd: (details) {
              _touchScaleStart = null;
            },
            child: Listener(
            onPointerDown: (e) {
              if (e.buttons == kMiddleMouseButton) return; // Handled by gesture detector or later
              final scenePos = (e.localPosition - state.viewport.pan) / state.viewport.zoom;
              tool.onPointerDown(e, scenePos, ref);
            },
            onPointerHover: (e) {
              _updateCursor(e, state.viewport, tool);
            },
            onPointerMove: (e) {
              _updateCursor(e, state.viewport, tool);
              if (e.buttons == kMiddleMouseButton) {
                ref.read(editorProvider.notifier).updatePan(e.delta);
                return;
              }
              final scenePos = (e.localPosition - state.viewport.pan) / state.viewport.zoom;
              tool.onPointerMove(e, scenePos, ref);
            },
            onPointerUp: (e) {
              final scenePos = (e.localPosition - state.viewport.pan) / state.viewport.zoom;
              tool.onPointerUp(e, scenePos, ref);
            },
            onPointerCancel: (e) {
              tool.onPointerCancel(ref);
            },
            onPointerSignal: (e) {
              if (e is PointerScrollEvent) {
                final zoomDelta = e.scrollDelta.dy > 0 ? 0.9 : 1.1;
                ref.read(editorProvider.notifier).updateZoom(zoomDelta, e.localPosition);
              }
            },
            child: MouseRegion(
              cursor: _currentCursor,
              child: Container(
                color: Colors.transparent, // Capture events
              ),
            ),
          )),
          if (state.editingTextId != null)
            InlineTextEditor(elementId: state.editingTextId!),
        ],
      ),
    );
  }
}
