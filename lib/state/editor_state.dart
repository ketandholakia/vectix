import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/vx_document.dart';

part 'editor_state.freezed.dart';

enum ActiveTool { select, rect, ellipse, line, polygon, star, freehand, text, node, hand, pen }

@freezed
abstract class ViewportState with _$ViewportState {
  const factory ViewportState({
    required double zoom,
    required Offset pan,
  }) = _ViewportState;
}

@freezed
abstract class EditorState with _$EditorState {
  const factory EditorState({
    required VxDocument document,
    required Set<String> selectedIds,
    required ActiveTool activeTool,
    required ViewportState viewport,
    required bool showGrid,
    required bool snapToGrid,
    required double gridSize,
    String? editingTextId,
    @Default(6) int polygonSides,
    @Default(5) int starSpikes,
    @Default(0.45) double starInnerRatio,
    @Default(0.7) double freehandSmoothing,
    @Default(1.5) double lineStrokeWidth,
  }) = _EditorState;

  factory EditorState.initial() => EditorState(
        document: const VxDocument(
          id: 'doc_1',
          title: 'Untitled Design',
          width: 800,
          height: 600,
          elements: [],
        ),
        selectedIds: {},
        activeTool: ActiveTool.select,
        viewport: const ViewportState(zoom: 1.0, pan: Offset.zero),
        showGrid: true,
        snapToGrid: false,
        gridSize: 20.0,
        editingTextId: null,
        polygonSides: 6,
        starSpikes: 5,
        starInnerRatio: 0.45,
        freehandSmoothing: 0.7,
        lineStrokeWidth: 1.5,
      );
}
