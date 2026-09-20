import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'tool.dart';
import '../models/vx_element.dart';
import '../state/history_manager.dart';
import '../commands/add_element_command.dart';
import '../state/editor_notifier.dart';

class StarTool extends ChangeNotifier implements Tool {
  Offset? _startPos;
  Offset? _currentPos;
  VxElement? _previewElement;
  List<Offset> _previewPoints = [];
  int _spikes = 5;
  double _innerRatio = 0.45;

  @override
  void onPointerDown(PointerDownEvent event, Offset scenePos, WidgetRef ref) {
    final state = ref.read(editorProvider);
    _spikes = state.starSpikes;
    _innerRatio = state.starInnerRatio;
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
    _previewPoints = [];
    notifyListeners();
  }

  @override
  void onPointerCancel(WidgetRef ref) {
    _startPos = null;
    _currentPos = null;
    _previewElement = null;
    _previewPoints = [];
    notifyListeners();
  }

  void _updatePreview() {
    if (_startPos == null || _currentPos == null) return;

    final center = _startPos!;
    final outerRadius = (_currentPos! - _startPos!).distance;

    if (outerRadius < 1) return;

    final innerRadius = outerRadius * _innerRatio;
    final pts = _starPoints(center, outerRadius, innerRadius, _spikes);
    _previewPoints = pts;

    final segments = <PathSegment>[
      PathSegment.moveTo(pts.first),
      for (int i = 1; i < pts.length; i++) PathSegment.lineTo(pts[i]),
      PathSegment.close(),
    ];

    _previewElement = VxElement.path(
      id: const Uuid().v4(),
      segments: segments,
      transform: Matrix4.identity(),
      fill: VxFill.solid(color: Colors.grey),
      stroke: VxStroke(
        color: Colors.black,
        width: 2,
        cap: StrokeCap.butt,
        join: StrokeJoin.miter,
      ),
    );
    notifyListeners();
  }

  /// Alternates between outer and inner radii to build the star vertices.
  List<Offset> _starPoints(
      Offset center, double outerR, double innerR, int numSpikes) {
    final pts = <Offset>[];
    final totalVertices = numSpikes * 2;
    for (int i = 0; i < totalVertices; i++) {
      final angle = (pi * i / numSpikes) - pi / 2;
      final r = i.isEven ? outerR : innerR;
      pts.add(Offset(
        center.dx + r * cos(angle),
        center.dy + r * sin(angle),
      ));
    }
    return pts;
  }

  @override
  void paint(Canvas canvas) {
    if (_previewPoints.length < 2) return;

    final path = Path()
      ..moveTo(_previewPoints.first.dx, _previewPoints.first.dy);
    for (int i = 1; i < _previewPoints.length; i++) {
      path.lineTo(_previewPoints[i].dx, _previewPoints[i].dy);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Outer radius guide line
    if (_startPos != null && _currentPos != null) {
      canvas.drawLine(
        _startPos!,
        _currentPos!,
        Paint()
          ..color = Colors.blue.withValues(alpha: 0.5)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  MouseCursor getCursorForPosition(Offset scenePos, WidgetRef ref) =>
      SystemMouseCursors.precise;
}
