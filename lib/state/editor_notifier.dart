import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'editor_state.dart';
import '../models/vx_document.dart';
import '../models/vx_element.dart';
import '../canvas/hit_tester.dart';
import '../canvas/scene_index.dart';
import '../commands/add_element_command.dart';
import '../commands/update_element_command.dart';
import 'history_manager.dart';

class SnapResult {
  final Offset point;
  final List<double> snapX;
  final List<double> snapY;
  SnapResult(this.point, [this.snapX = const [], this.snapY = const []]);
}

final editorProvider = NotifierProvider<EditorNotifier, EditorState>(
  EditorNotifier.new,
);

class EditorNotifier extends Notifier<EditorState> {
  @override
  EditorState build() {
    return EditorState.initial();
  }

  void setTool(ActiveTool tool) {
    state = state.copyWith(activeTool: tool);
  }

  void setPolygonSides(int sides) {
    state = state.copyWith(polygonSides: sides.clamp(3, 24));
  }

  void setStarSpikes(int spikes) {
    state = state.copyWith(starSpikes: spikes.clamp(3, 24));
  }

  void setStarInnerRatio(double ratio) {
    state = state.copyWith(starInnerRatio: ratio.clamp(0.1, 0.9));
  }

  void setFreehandSmoothing(double value) {
    state = state.copyWith(freehandSmoothing: value.clamp(0.0, 1.0));
  }

  void setLineStrokeWidth(double value) {
    state = state.copyWith(lineStrokeWidth: value.clamp(0.5, 12.0));
  }

  void loadDocument(VxDocument document) {
    final normalized = document.artboards.isEmpty
        ? document.copyWith(
            artboards: [
              VxArtboard(
                id: '${document.id}_artboard_1',
                name: 'Artboard 1',
                x: 0,
                y: 0,
                width: document.width,
                height: document.height,
              ),
            ],
            artboardMode: 'multi',
          )
        : document;
    state = state.copyWith(document: normalized, selectedIds: {});
  }

  void startTextEditing(String id) {
    state = state.copyWith(editingTextId: id);
  }

  void cancelTextEditing() {
    state = state.copyWith(editingTextId: null);
  }

  String? get activeArtboardId {
    if (state.document.artboards.isEmpty) return null;
    final index = state.document.activePageIndex.clamp(
      0,
      state.document.artboards.length - 1,
    );
    return state.document.artboards[index].id;
  }

  void previewTextContent(String id, String content) {
    final current = state.document.elements.firstWhere(
      (e) => e.id == id,
      orElse: () => throw StateError('Text element not found'),
    );
    if (current is! VxText) return;
    final updated = current.copyWith(content: content);
    state = state.copyWith(
      document: state.document.copyWith(
        elements: _updateElementInList(state.document.elements, updated),
      ),
    );
  }

  void updatePan(Offset delta) {
    state = state.copyWith(
      viewport: state.viewport.copyWith(pan: state.viewport.pan + delta),
    );
  }

  void updateZoom(double zoomDelta, Offset focalPoint) {
    // Current pan and zoom
    final currentPan = state.viewport.pan;
    final currentZoom = state.viewport.zoom;

    // Calculate new zoom
    final newZoom = (currentZoom * zoomDelta).clamp(0.1, 10.0);

    // Calculate new pan to keep focal point stationary
    // focalPoint = pan + scenePoint * zoom
    // scenePoint = (focalPoint - pan) / zoom
    final scenePoint = (focalPoint - currentPan) / currentZoom;

    // newPan = focalPoint - scenePoint * newZoom
    final newPan = focalPoint - scenePoint * newZoom;

    state = state.copyWith(
      viewport: state.viewport.copyWith(zoom: newZoom, pan: newPan),
    );
  }

  void setZoom(double zoom, {Offset? focalPoint}) {
    final clamped = zoom.clamp(0.1, 10.0);
    final currentPan = state.viewport.pan;
    final currentZoom = state.viewport.zoom;
    final focus = focalPoint ?? Offset.zero;
    final scenePoint = (focus - currentPan) / currentZoom;
    final newPan = focus - scenePoint * clamped;

    state = state.copyWith(
      viewport: state.viewport.copyWith(zoom: clamped, pan: newPan),
    );
  }

  void fitToScreen(Size viewportSize, {double padding = 48.0}) {
    if (viewportSize.width <= 0 || viewportSize.height <= 0) return;
    final doc = state.document;
    final active =
        doc.artboards.isNotEmpty && doc.activePageIndex < doc.artboards.length
        ? doc.artboards[doc.activePageIndex]
        : null;
    final width = active?.width ?? doc.width;
    final height = active?.height ?? doc.height;
    if (width <= 0 || height <= 0) return;

    final availableWidth = (viewportSize.width - padding * 2).clamp(
      1.0,
      double.infinity,
    );
    final availableHeight = (viewportSize.height - padding * 2).clamp(
      1.0,
      double.infinity,
    );
    final zoom = (availableWidth / width).clamp(0.1, 10.0);
    final zoomY = (availableHeight / height).clamp(0.1, 10.0);
    final targetZoom = zoom < zoomY ? zoom : zoomY;
    final pan = Offset(
      (viewportSize.width - width * targetZoom) / 2,
      (viewportSize.height - height * targetZoom) / 2,
    );

    state = state.copyWith(
      viewport: state.viewport.copyWith(zoom: targetZoom, pan: pan),
    );
  }

  void zoomToSelection(Size viewportSize) {
    if (state.selectedIds.isEmpty) return;
    Rect? bounds;
    for (final id in state.selectedIds) {
      VxElement? element;
      for (final candidate in state.document.elements) {
        if (candidate.id == id) {
          element = candidate;
          break;
        }
      }
      if (element == null) continue;
      final b = HitTester.getBounds(element, state.document);
      if (b == Rect.zero) continue;
      bounds = bounds == null ? b : bounds.expandToInclude(b);
    }
    if (bounds == null || viewportSize.width <= 0 || viewportSize.height <= 0)
      return;

    final padding = 64.0;
    final availableWidth = (viewportSize.width - padding * 2).clamp(
      1.0,
      double.infinity,
    );
    final availableHeight = (viewportSize.height - padding * 2).clamp(
      1.0,
      double.infinity,
    );
    final scaleX = availableWidth / bounds.width;
    final scaleY = availableHeight / bounds.height;
    final targetZoom = scaleX < scaleY ? scaleX : scaleY;
    final clampedZoom = targetZoom.clamp(0.1, 10.0);
    final center = bounds.center;
    final pan = Offset(
      viewportSize.width / 2 - center.dx * clampedZoom,
      viewportSize.height / 2 - center.dy * clampedZoom,
    );

    state = state.copyWith(
      viewport: state.viewport.copyWith(zoom: clampedZoom, pan: pan),
    );
  }

  void addElement(VxElement element) {
    state = state.copyWith(
      document: state.document.copyWith(
        elements: [...state.document.elements, element],
      ),
    );
  }

  void insertElementAt(VxElement element, int index) {
    final newElements = List<VxElement>.from(state.document.elements);
    if (index >= 0 && index <= newElements.length) {
      newElements.insert(index, element);
    } else {
      newElements.add(element);
    }
    state = state.copyWith(
      document: state.document.copyWith(elements: newElements),
    );
  }

  void removeElement(String id) {
    state = state.copyWith(
      document: state.document.copyWith(
        elements: _removeElementInList(state.document.elements, id),
      ),
      selectedIds: state.selectedIds.where((e) => e != id).toSet(),
    );
  }

  void selectElement(String id) {
    state = state.copyWith(selectedIds: {id});
  }

  void setSelection(Set<String> ids) {
    state = state.copyWith(selectedIds: ids);
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: {});
  }

  List<VxElement> _removeElementInList(List<VxElement> elements, String id) {
    return elements
        .where((e) => e.id != id)
        .map((e) {
          return e.when(
            rect:
                (
                  _,
                  __,
                  ___,
                  ____,
                  _____,
                  ______,
                  _______,
                  ________,
                  _________,
                  __________,
                  ___________,
                  ____________,
                  _____________,
                  ______________,
                ) => e,
            ellipse:
                (
                  _,
                  __,
                  ___,
                  ____,
                  _____,
                  ______,
                  _______,
                  ________,
                  _________,
                  __________,
                  ___________,
                  ____________,
                  _____________,
                  ______________,
                ) => e,
            path:
                (
                  _,
                  __,
                  ___,
                  ____,
                  _____,
                  ______,
                  _______,
                  ________,
                  _________,
                  __________,
                  ___________,
                ) => e,
            text:
                (
                  _,
                  __,
                  ___,
                  ____,
                  _____,
                  ______,
                  _______,
                  ________,
                  _________,
                  __________,
                  ___________,
                  ____________,
                  _____________,
                  ______________,
                  _______________,
                  ________________,
                  _________________,
                  __________________,
                  ___________________,
                ) => e,
            group:
                (
                  gId,
                  artboardId,
                  children,
                  t,
                  opacity,
                  locked,
                  visible,
                  clipPathId,
                  maskId,
                ) => VxElement.group(
                  id: gId,
                  artboardId: artboardId,
                  children: _removeElementInList(children, id),
                  transform: t,
                  opacity: opacity,
                  locked: locked,
                  visible: visible,
                  clipPathId: clipPathId,
                  maskId: maskId,
                ),
            compound:
                (
                  cId,
                  artboardId,
                  op,
                  children,
                  t,
                  f,
                  s,
                  opacity,
                  locked,
                  visible,
                  clipPathId,
                  maskId,
                ) => VxElement.compound(
                  id: cId,
                  artboardId: artboardId,
                  operation: op,
                  children: _removeElementInList(children, id),
                  transform: t,
                  fill: f,
                  stroke: s,
                  opacity: opacity,
                  locked: locked,
                  visible: visible,
                  clipPathId: clipPathId,
                  maskId: maskId,
                ),
            use:
                (
                  _,
                  __,
                  ___,
                  ____,
                  _____,
                  ______,
                  _______,
                  ________,
                  _________,
                ) => e,
            symbol:
                (
                  sId,
                  artboardId,
                  children,
                  t,
                  opacity,
                  locked,
                  visible,
                  clipPathId,
                  maskId,
                ) => VxElement.symbol(
                  id: sId,
                  artboardId: artboardId,
                  children: _removeElementInList(children, id),
                  transform: t,
                  opacity: opacity,
                  locked: locked,
                  visible: visible,
                  clipPathId: clipPathId,
                  maskId: maskId,
                ),
          );
        })
        .toList(growable: false);
  }

  void updateElementFlags(String id, {bool? locked, bool? visible}) {
    final updated = state.document.elements.map((element) {
      if (element.id != id) return element;
      return element.when(
        rect:
            (
              eid,
              artboardId,
              x,
              y,
              width,
              height,
              transform,
              fill,
              stroke,
              opacity,
              currentLocked,
              currentVisible,
              clipPathId,
              maskId,
            ) => VxElement.rect(
              id: eid,
              artboardId: artboardId,
              x: x,
              y: y,
              width: width,
              height: height,
              transform: transform,
              fill: fill,
              stroke: stroke,
              opacity: opacity,
              locked: locked ?? currentLocked,
              visible: visible ?? currentVisible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
        ellipse:
            (
              eid,
              artboardId,
              cx,
              cy,
              rx,
              ry,
              transform,
              fill,
              stroke,
              opacity,
              currentLocked,
              currentVisible,
              clipPathId,
              maskId,
            ) => VxElement.ellipse(
              id: eid,
              artboardId: artboardId,
              cx: cx,
              cy: cy,
              rx: rx,
              ry: ry,
              transform: transform,
              fill: fill,
              stroke: stroke,
              opacity: opacity,
              locked: locked ?? currentLocked,
              visible: visible ?? currentVisible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
        path:
            (
              eid,
              artboardId,
              segments,
              transform,
              fill,
              stroke,
              opacity,
              currentLocked,
              currentVisible,
              clipPathId,
              maskId,
            ) => VxElement.path(
              id: eid,
              artboardId: artboardId,
              segments: segments,
              transform: transform,
              fill: fill,
              stroke: stroke,
              opacity: opacity,
              locked: locked ?? currentLocked,
              visible: visible ?? currentVisible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
        text:
            (
              eid,
              artboardId,
              content,
              x,
              y,
              style,
              align,
              letterSpacing,
              wordSpacing,
              lineHeight,
              fontWeightValue,
              fontStyle,
              maxLines,
              transform,
              opacity,
              currentLocked,
              currentVisible,
              clipPathId,
              maskId,
            ) => VxElement.text(
              id: eid,
              artboardId: artboardId,
              content: content,
              x: x,
              y: y,
              style: style,
              align: align,
              letterSpacing: letterSpacing,
              wordSpacing: wordSpacing,
              lineHeight: lineHeight,
              fontWeightValue: fontWeightValue,
              fontStyle: fontStyle,
              maxLines: maxLines,
              transform: transform,
              opacity: opacity,
              locked: locked ?? currentLocked,
              visible: visible ?? currentVisible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
        group:
            (
              eid,
              artboardId,
              children,
              transform,
              opacity,
              currentLocked,
              currentVisible,
              clipPathId,
              maskId,
            ) => VxElement.group(
              id: eid,
              artboardId: artboardId,
              children: children,
              transform: transform,
              opacity: opacity,
              locked: locked ?? currentLocked,
              visible: visible ?? currentVisible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
        compound:
            (
              eid,
              artboardId,
              operation,
              children,
              transform,
              fill,
              stroke,
              opacity,
              currentLocked,
              currentVisible,
              clipPathId,
              maskId,
            ) => VxElement.compound(
              id: eid,
              artboardId: artboardId,
              operation: operation,
              children: children,
              transform: transform,
              fill: fill,
              stroke: stroke,
              opacity: opacity,
              locked: locked ?? currentLocked,
              visible: visible ?? currentVisible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
        use:
            (
              eid,
              artboardId,
              href,
              transform,
              opacity,
              currentLocked,
              currentVisible,
              clipPathId,
              maskId,
            ) => VxElement.use(
              id: eid,
              artboardId: artboardId,
              href: href,
              transform: transform,
              opacity: opacity,
              locked: locked ?? currentLocked,
              visible: visible ?? currentVisible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
        symbol:
            (
              eid,
              artboardId,
              children,
              transform,
              opacity,
              currentLocked,
              currentVisible,
              clipPathId,
              maskId,
            ) => VxElement.symbol(
              id: eid,
              artboardId: artboardId,
              children: children,
              transform: transform,
              opacity: opacity,
              locked: locked ?? currentLocked,
              visible: visible ?? currentVisible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
      );
    }).toList();
    replaceElements(updated);
  }

  void updateElement(VxElement newElement) {
    replaceElements(_updateElementInList(state.document.elements, newElement));
  }

  void updatePathSegments(String id, List<PathSegment> segments) {
    final element = state.document.elements.firstWhere(
      (e) => e.id == id,
      orElse: () => throw StateError('Path not found'),
    );
    if (element is! VxPath) return;
    updateElement(element.copyWith(segments: segments));
  }

  void insertPathNode(String id) {
    final element = state.document.elements.firstWhere(
      (e) => e.id == id,
      orElse: () => throw StateError('Path not found'),
    );
    if (element is! VxPath || element.segments.length < 2) return;
    final segments = List<PathSegment>.from(element.segments);
    for (var i = 0; i < segments.length - 1; i++) {
      final current = segments[i];
      final next = segments[i + 1];
      Offset? anchorA;
      Offset? anchorB;
      current.whenOrNull(
        moveTo: (p) => anchorA = p,
        lineTo: (p) => anchorA = p,
        quadraticBezierTo: (c, p) => anchorA = p,
        cubicBezierTo: (c1, c2, p) => anchorA = p,
      );
      next.whenOrNull(
        moveTo: (p) => anchorB = p,
        lineTo: (p) => anchorB = p,
        quadraticBezierTo: (c, p) => anchorB = p,
        cubicBezierTo: (c1, c2, p) => anchorB = p,
      );
      if (anchorA == null || anchorB == null) continue;
      final mid = Offset(
        (anchorA!.dx + anchorB!.dx) / 2,
        (anchorA!.dy + anchorB!.dy) / 2,
      );
      segments.insert(i + 1, PathSegment.lineTo(mid));
      updateElement(element.copyWith(segments: segments));
      return;
    }
  }

  void deleteLastPathNode(String id) {
    final element = state.document.elements.firstWhere(
      (e) => e.id == id,
      orElse: () => throw StateError('Path not found'),
    );
    if (element is! VxPath || element.segments.length <= 2) return;
    final segments = List<PathSegment>.from(element.segments);
    segments.removeAt(segments.length - 2);
    updateElement(element.copyWith(segments: segments));
  }

  void replaceElements(List<VxElement> elements) {
    state = state.copyWith(
      document: state.document.copyWith(elements: elements),
    );
  }

  void replaceDocument(VxDocument document) {
    state = state.copyWith(document: document, selectedIds: {});
  }

  void updateDocumentMetadata(Map<String, dynamic> metadata) {
    state = state.copyWith(
      document: state.document.copyWith(metadata: metadata),
    );
  }

  void setActivePageIndex(int index) {
    final pageCount = state.document.artboards.isEmpty
        ? state.document.pageCount
        : state.document.artboards.length;
    final clamped = index.clamp(0, pageCount - 1);
    state = state.copyWith(
      document: state.document.copyWith(activePageIndex: clamped),
    );
  }

  void addPage() {
    final artboards = List<VxArtboard>.from(state.document.artboards);
    final nextIndex = artboards.length + 1;
    artboards.add(
      VxArtboard(
        id: '${state.document.id}_artboard_$nextIndex',
        name: 'Artboard $nextIndex',
        x: 0,
        y: 0,
        width: state.document.width,
        height: state.document.height,
      ),
    );
    state = state.copyWith(
      document: state.document.copyWith(
        artboards: artboards,
        pageCount: artboards.length,
        activePageIndex: artboards.length - 1,
        artboardMode: 'multi',
      ),
    );
  }

  void renameActivePage(String name) {
    if (state.document.artboards.isEmpty) return;
    final index = state.document.activePageIndex.clamp(
      0,
      state.document.artboards.length - 1,
    );
    final artboards = List<VxArtboard>.from(state.document.artboards);
    artboards[index] = artboards[index].copyWith(
      name: name.trim().isEmpty ? artboards[index].name : name.trim(),
    );
    state = state.copyWith(
      document: state.document.copyWith(artboards: artboards),
    );
  }

  void duplicateActivePage() {
    if (state.document.artboards.isEmpty) return;
    final index = state.document.activePageIndex.clamp(
      0,
      state.document.artboards.length - 1,
    );
    final artboards = List<VxArtboard>.from(state.document.artboards);
    final source = artboards[index];
    final duplicateIndex = index + 1;
    artboards.insert(
      duplicateIndex,
      source.copyWith(id: '${source.id}_copy', name: '${source.name} Copy'),
    );
    state = state.copyWith(
      document: state.document.copyWith(
        artboards: artboards,
        pageCount: artboards.length,
        activePageIndex: duplicateIndex,
        artboardMode: 'multi',
      ),
    );
  }

  void moveActivePage(int delta) {
    if (state.document.artboards.length < 2) return;
    final current = state.document.activePageIndex.clamp(
      0,
      state.document.artboards.length - 1,
    );
    final target = (current + delta).clamp(
      0,
      state.document.artboards.length - 1,
    );
    if (current == target) return;
    final artboards = List<VxArtboard>.from(state.document.artboards);
    final item = artboards.removeAt(current);
    artboards.insert(target, item);
    state = state.copyWith(
      document: state.document.copyWith(
        artboards: artboards,
        activePageIndex: target,
      ),
    );
  }

  void setDocumentSize(double width, double height) {
    final currentIndex = state.document.activePageIndex;
    final artboards = state.document.artboards.isEmpty
        ? <VxArtboard>[]
        : List<VxArtboard>.from(state.document.artboards);
    if (artboards.isNotEmpty && currentIndex < artboards.length) {
      artboards[currentIndex] = artboards[currentIndex].copyWith(
        width: width,
        height: height,
      );
    }
    state = state.copyWith(
      document: state.document.copyWith(
        width: width,
        height: height,
        artboards: artboards.isEmpty ? state.document.artboards : artboards,
      ),
    );
  }

  void removePage() {
    final artboards = List<VxArtboard>.from(state.document.artboards);
    if (artboards.length <= 1) return;
    
    final removedIndex = state.document.activePageIndex.clamp(0, artboards.length - 1);
    final removedArtboardId = artboards[removedIndex].id;
    artboards.removeAt(removedIndex);
    
    final nextIndex = state.document.activePageIndex.clamp(
      0,
      artboards.length - 1,
    );
    
    final newElements = state.document.elements.where((e) => e.artboardId != removedArtboardId).toList();
    
    state = state.copyWith(
      document: state.document.copyWith(
        artboards: artboards,
        pageCount: artboards.length,
        activePageIndex: nextIndex,
        elements: newElements,
      ),
    );
  }

  List<VxElement> _updateElementInList(
    List<VxElement> elements,
    VxElement newElement,
  ) {
    return elements.map((e) {
      if (e.id == newElement.id) return newElement;
      return e.when(
        rect:
            (
              _,
              __,
              ___,
              ____,
              _____,
              ______,
              _______,
              ________,
              _________,
              __________,
              ___________,
              ____________,
              _____________,
              ______________,
            ) => e,
        ellipse:
            (
              _,
              __,
              ___,
              ____,
              _____,
              ______,
              _______,
              ________,
              _________,
              __________,
              ___________,
              ____________,
              _____________,
              ______________,
            ) => e,
        path:
            (
              _,
              __,
              ___,
              ____,
              _____,
              ______,
              _______,
              ________,
              _________,
              __________,
              ___________,
            ) => e,
        text:
            (
              _,
              __,
              ___,
              ____,
              _____,
              ______,
              _______,
              ________,
              _________,
              __________,
              ___________,
              ____________,
              _____________,
              ______________,
              _______________,
              ________________,
              _________________,
              __________________,
              ___________________,
            ) => e,
        group:
            (
              gId,
              artboardId,
              children,
              t,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) => VxElement.group(
              id: gId,
              artboardId: artboardId,
              children: _updateElementInList(children, newElement),
              transform: t,
              opacity: opacity,
              locked: locked,
              visible: visible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
        compound:
            (
              cId,
              artboardId,
              op,
              children,
              t,
              f,
              s,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) => VxElement.compound(
              id: cId,
              artboardId: artboardId,
              operation: op,
              children: _updateElementInList(children, newElement),
              transform: t,
              fill: f,
              stroke: s,
              opacity: opacity,
              locked: locked,
              visible: visible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
        use: (_, __, ___, ____, _____, ______, _______, ________, _________) =>
            e,
        symbol:
            (
              sId,
              artboardId,
              children,
              t,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) => VxElement.symbol(
              id: sId,
              artboardId: artboardId,
              children: _updateElementInList(children, newElement),
              transform: t,
              opacity: opacity,
              locked: locked,
              visible: visible,
              clipPathId: clipPathId,
              maskId: maskId,
            ),
      );
    }).toList();
  }

  void setElements(List<VxElement> elements) {
    replaceElements(elements);
  }

  void updateViewport(ViewportState viewport) {
    state = state.copyWith(viewport: viewport);
  }

  List<VxElement> computeAlignment(Alignment alignment) {
    if (state.selectedIds.length < 2) return [];

    final elements = state.selectedIds
        .map((id) => state.document.elements.firstWhere((e) => e.id == id))
        .toList();

    Rect groupBounds = _getElementBounds(elements.first);
    for (int i = 1; i < elements.length; i++) {
      groupBounds = groupBounds.expandToInclude(_getElementBounds(elements[i]));
    }

    final newElements = <VxElement>[];

    for (final element in elements) {
      final bounds = _getElementBounds(element);
      double dx = 0;
      double dy = 0;

      if (alignment == Alignment.centerLeft)
        dx = groupBounds.left - bounds.left;
      else if (alignment == Alignment.center) {
        dx = groupBounds.center.dx - bounds.center.dx;
        dy = groupBounds.center.dy - bounds.center.dy;
      } else if (alignment == Alignment.centerRight)
        dx = groupBounds.right - bounds.right;
      else if (alignment == Alignment.topCenter)
        dy = groupBounds.top - bounds.top;
      else if (alignment == Alignment.bottomCenter)
        dy = groupBounds.bottom - bounds.bottom;

      if (dx != 0 || dy != 0) {
        final newTransform = element.transform.clone()..translate(dx, dy);
        newElements.add(element.copyWith(transform: newTransform));
      } else {
        newElements.add(element);
      }
    }

    return newElements;
  }

  Rect _getElementBounds(VxElement element) {
    return HitTester.getBounds(element, state.document);
  }

  SnapResult snap(Offset point, {Set<String> ignoreIds = const {}}) {
    double x = point.dx;
    double y = point.dy;
    List<double> snapX = [];
    List<double> snapY = [];

    if (state.snapToGrid) {
      final size = state.gridSize;
      x = (point.dx / size).roundToDouble() * size;
      y = (point.dy / size).roundToDouble() * size;
    } else {
      const snapThreshold = 5.0 / 1.0; // Assume zoom 1 for now, or could pass zoom
      double minDx = snapThreshold;
      double minDy = snapThreshold;
      
      final activeElements = SceneIndex.of(state.document).activeElements;
      
      for (final element in activeElements) {
        if (ignoreIds.contains(element.id)) continue;
        
        final bounds = HitTester.getBounds(element, state.document);
        if (bounds == Rect.zero) continue;

        // X targets
        final targetsX = [bounds.left, bounds.center.dx, bounds.right];
        for (final target in targetsX) {
          final dist = (point.dx - target).abs();
          if (dist < minDx) {
            minDx = dist;
            x = target;
            snapX = [target];
          } else if (dist == minDx && minDx < snapThreshold) {
            if (!snapX.contains(target)) snapX.add(target);
          }
        }

        // Y targets
        final targetsY = [bounds.top, bounds.center.dy, bounds.bottom];
        for (final target in targetsY) {
          final dist = (point.dy - target).abs();
          if (dist < minDy) {
            minDy = dist;
            y = target;
            snapY = [target];
          } else if (dist == minDy && minDy < snapThreshold) {
            if (!snapY.contains(target)) snapY.add(target);
          }
        }
      }
    }

    return SnapResult(Offset(x, y), snapX, snapY);
  }

  void toggleSnapToGrid() {
    state = state.copyWith(snapToGrid: !state.snapToGrid);
  }
}
