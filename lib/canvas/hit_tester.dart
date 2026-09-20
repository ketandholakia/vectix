import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../models/vx_document.dart';
import '../models/vx_element.dart';
import 'scene_index.dart';

class HitTester {
  static VxDocument? _cachedDoc;
  static final Map<int, Rect> _localBoundsCache = {};
  static final Map<int, Rect> _sceneBoundsCache = {};
  static final Map<String, List<String>> _cellIndex = {};
  static final Map<String, TextPainter> _textPainterCache = {};
  static const double _cellSize = 256.0;

  static String? hitTest(Offset point, VxDocument doc) {
    _ensureCache(doc);
    final candidates = _candidatesForPoint(point, doc);
    for (final element in candidates.reversed) {
      if (!_belongsToActiveArtboard(element, doc)) continue;
      if (element.locked || !element.visible) continue;
      if (_elementContains(element, point, doc)) return element.id;
    }
    return null;
  }

  static bool _belongsToActiveArtboard(VxElement element, VxDocument doc) {
    // Shared rule — see SceneIndex.belongsToArtboard.
    return SceneIndex.belongsToArtboard(
      element,
      doc,
      SceneIndex.activeArtboard(doc)?.id,
    );
  }

  static Offset _toLocalPoint(Offset point, Matrix4 transform) {
    if (transform == Matrix4.identity()) return point;
    final inverse = Matrix4.copy(transform);
    if (inverse.determinant().abs() < 1e-10) return point;
    inverse.invert();
    final local = inverse.transform3(Vector3(point.dx, point.dy, 0));
    return Offset(local.x, local.y);
  }

  static bool _elementContains(
    VxElement element,
    Offset point,
    VxDocument doc,
  ) {
    return element.when(
      rect:
          (
            id,
            artboardId,
            x,
            y,
            width,
            height,
            transform,
            fill,
            stroke,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) {
            final localPoint = _toLocalPoint(point, transform);
            return Rect.fromLTWH(x, y, width, height).contains(localPoint);
          },
      ellipse:
          (
            id,
            artboardId,
            cx,
            cy,
            rx,
            ry,
            transform,
            fill,
            stroke,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) {
            final localPoint = _toLocalPoint(point, transform);
            if (rx == 0 || ry == 0) return false;
            final dx = localPoint.dx - cx;
            final dy = localPoint.dy - cy;
            return (dx * dx) / (rx * rx) + (dy * dy) / (ry * ry) <= 1.0;
          },
      path:
          (
            id,
            artboardId,
            segments,
            transform,
            fill,
            stroke,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) {
            final localPoint = _toLocalPoint(point, transform);
            return _buildPath(segments).contains(localPoint);
          },
      text:
          (
            id,
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
            locked,
            visible,
            clipPathId,
            maskId,
          ) {
            final localPoint = _toLocalPoint(point, transform);
            final bounds = _measureTextBounds(content, x, y, style);
            return bounds.contains(localPoint);
          },
      group:
          (
            id,
            artboardId,
            children,
            transform,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) {
            final localPoint = _toLocalPoint(point, transform);
            for (final child in children) {
              if (_elementContains(child, localPoint, doc)) return true;
            }
            return false;
          },
      compound:
          (
            id,
            artboardId,
            operation,
            children,
            transform,
            fill,
            stroke,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) {
            final localPoint = _toLocalPoint(point, transform);
            Rect bounds = Rect.zero;
            if (children.isNotEmpty) {
              bounds = _getLocalBounds(children.first, doc);
              for (int i = 1; i < children.length; i++) {
                bounds = bounds.expandToInclude(
                  _getLocalBounds(children[i], doc),
                );
              }
            }
            return bounds.contains(localPoint);
          },
      use:
          (
            id,
            artboardId,
            href,
            transform,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) {
            final localPoint = _toLocalPoint(point, transform);
            final targetId = href.startsWith('#') ? href.substring(1) : href;
            final target = _resolve(doc, targetId);
            return target != null && _elementContains(target, localPoint, doc);
          },
      symbol:
          (
            id,
            artboardId,
            children,
            transform,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) {
            final localPoint = _toLocalPoint(point, transform);
            for (final child in children) {
              if (_elementContains(child, localPoint, doc)) return true;
            }
            return false;
          },
    );
  }

  static Rect _getLocalBounds(VxElement element, VxDocument doc) {
    _ensureCache(doc);
    final cacheKey = element.hashCode;
    final cached = _localBoundsCache[cacheKey];
    if (cached != null) return cached;

    final result = element.when(
      rect:
          (
            id,
            artboardId,
            x,
            y,
            width,
            height,
            transform,
            fill,
            stroke,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) => Rect.fromLTWH(x, y, width, height),
      ellipse:
          (
            id,
            artboardId,
            cx,
            cy,
            rx,
            ry,
            transform,
            fill,
            stroke,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) => Rect.fromCenter(
            center: Offset(cx, cy),
            width: rx * 2,
            height: ry * 2,
          ),
      path:
          (
            id,
            artboardId,
            segments,
            transform,
            fill,
            stroke,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) => _buildPath(segments).getBounds(),
      text:
          (
            id,
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
            locked,
            visible,
            clipPathId,
            maskId,
          ) => _measureTextBounds(content, x, y, style),
      group:
          (
            id,
            artboardId,
            children,
            transform,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) {
            if (children.isEmpty) return Rect.zero;
            Rect bounds = getBounds(children.first, doc);
            for (int i = 1; i < children.length; i++) {
              bounds = bounds.expandToInclude(getBounds(children[i], doc));
            }
            return bounds;
          },
      compound:
          (
            id,
            artboardId,
            operation,
            children,
            transform,
            fill,
            stroke,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) {
            if (children.isEmpty) return Rect.zero;
            Rect bounds = getBounds(children.first, doc);
            for (int i = 1; i < children.length; i++) {
              bounds = bounds.expandToInclude(getBounds(children[i], doc));
            }
            return bounds;
          },
      use:
          (
            id,
            artboardId,
            href,
            transform,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) {
            final targetId = href.startsWith('#') ? href.substring(1) : href;
            final target = _resolve(doc, targetId);
            return target != null ? getBounds(target, doc) : Rect.zero;
          },
      symbol:
          (
            id,
            artboardId,
            children,
            transform,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) {
            if (children.isEmpty) return Rect.zero;
            Rect bounds = getBounds(children.first, doc);
            for (int i = 1; i < children.length; i++) {
              bounds = bounds.expandToInclude(getBounds(children[i], doc));
            }
            return bounds;
          },
    );

    _localBoundsCache[cacheKey] = result;
    return result;
  }

  static Rect getBounds(VxElement element, VxDocument doc) {
    _ensureCache(doc);
    final cacheKey = element.hashCode;
    final cached = _sceneBoundsCache[cacheKey];
    if (cached != null) return cached;

    final localBounds = _getLocalBounds(element, doc);
    if (localBounds == Rect.zero) return Rect.zero;

    final transform = element.when(
      rect:
          (
            id,
            artboardId,
            x,
            y,
            width,
            height,
            transform,
            fill,
            stroke,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) => transform,
      ellipse:
          (
            id,
            artboardId,
            cx,
            cy,
            rx,
            ry,
            transform,
            fill,
            stroke,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) => transform,
      path:
          (
            id,
            artboardId,
            segments,
            transform,
            fill,
            stroke,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) => transform,
      text:
          (
            id,
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
            locked,
            visible,
            clipPathId,
            maskId,
          ) => transform,
      group:
          (
            id,
            artboardId,
            children,
            transform,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) => transform,
      compound:
          (
            id,
            artboardId,
            operation,
            children,
            transform,
            fill,
            stroke,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) => transform,
      use:
          (
            id,
            artboardId,
            href,
            transform,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) => transform,
      symbol:
          (
            id,
            artboardId,
            children,
            transform,
            opacity,
            locked,
            visible,
            clipPathId,
            maskId,
          ) => transform,
    );

    if (transform == Matrix4.identity()) {
      _sceneBoundsCache[cacheKey] = localBounds;
      return localBounds;
    }

    final corners = [
      localBounds.topLeft,
      localBounds.topRight,
      localBounds.bottomLeft,
      localBounds.bottomRight,
    ];

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    for (final corner in corners) {
      final transformed = transform.transform3(
        Vector3(corner.dx, corner.dy, 0),
      );
      if (transformed.x < minX) minX = transformed.x;
      if (transformed.y < minY) minY = transformed.y;
      if (transformed.x > maxX) maxX = transformed.x;
      if (transformed.y > maxY) maxY = transformed.y;
    }

    final result = Rect.fromLTRB(minX, minY, maxX, maxY);
    _sceneBoundsCache[cacheKey] = result;
    return result;
  }

  static Path _buildPath(List<PathSegment> segments) {
    final path = Path();
    for (final segment in segments) {
      segment.when(
        moveTo: (point) => path.moveTo(point.dx, point.dy),
        lineTo: (point) => path.lineTo(point.dx, point.dy),
        quadraticBezierTo: (control, point) =>
            path.quadraticBezierTo(control.dx, control.dy, point.dx, point.dy),
        cubicBezierTo: (control1, control2, point) => path.cubicTo(
          control1.dx,
          control1.dy,
          control2.dx,
          control2.dy,
          point.dx,
          point.dy,
        ),
        close: () => path.close(),
      );
    }
    return path;
  }

  static Rect _measureTextBounds(
    String content,
    double x,
    double y,
    TextStyle style,
  ) {
    if (content.isEmpty) {
      return Rect.fromLTWH(x, y, 60, (style.fontSize ?? 16) * 1.2);
    }
    final cacheKey = '${style.hashCode}|$content';
    final textPainter = _textPainterCache.putIfAbsent(cacheKey, () {
      final textSpan = TextSpan(text: content, style: style);
      return TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    });
    textPainter.text = TextSpan(text: content, style: style);
    textPainter.layout();
    return Rect.fromLTWH(x, y, textPainter.width, textPainter.height);
  }

  /// Resolves a reference id against document definitions first (masks, clip
  /// paths, symbols), then against the painted element tree.
  static VxElement? _resolve(VxDocument doc, String id) {
    final def = doc.defs[id];
    if (def != null) return def;
    return _findElementById(doc.elements, id);
  }

  static VxElement? _findElementById(List<VxElement> elements, String id) {
    for (final element in elements) {
      if (element.id == id) return element;
      VxElement? found;
      element.whenOrNull(
        group:
            (
              gid,
              artboardId,
              children,
              transform,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) {
              found = _findElementById(children, id);
            },
        compound:
            (
              cid,
              artboardId,
              operation,
              children,
              transform,
              fill,
              stroke,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) {
              found = _findElementById(children, id);
            },
        symbol:
            (
              sid,
              artboardId,
              children,
              transform,
              opacity,
              locked,
              visible,
              clipPathId,
              maskId,
            ) {
              found = _findElementById(children, id);
            },
      );
      if (found != null) return found;
    }
    return null;
  }

  static void _ensureCache(VxDocument doc) {
    if (!identical(_cachedDoc, doc)) {
      _cachedDoc = doc;
      if (_localBoundsCache.length > 5000) {
        _localBoundsCache.clear();
        _sceneBoundsCache.clear();
      }
      _cellIndex.clear();
      _textPainterCache.clear();
      _buildIndex(doc);
    }
  }

  static void _buildIndex(VxDocument doc) {
    final activeElements = SceneIndex.of(doc).activeElements;
    for (final element in activeElements) {
      final bounds = getBounds(element, doc);
      if (bounds == Rect.zero) continue;
      final minCol = (bounds.left / _cellSize).floor();
      final maxCol = (bounds.right / _cellSize).floor();
      final minRow = (bounds.top / _cellSize).floor();
      final maxRow = (bounds.bottom / _cellSize).floor();
      for (int row = minRow; row <= maxRow; row++) {
        for (int col = minCol; col <= maxCol; col++) {
          final key = '$col:$row';
          (_cellIndex[key] ??= []).add(element.id);
        }
      }
    }
  }

  static List<VxElement> _candidatesForPoint(Offset point, VxDocument doc) {
    final key =
        '${(point.dx / _cellSize).floor()}:${(point.dy / _cellSize).floor()}';
    final ids = _cellIndex[key];
    final activeElements = SceneIndex.of(doc).activeElements;
    if (ids == null || ids.isEmpty) return activeElements;
    final byId = {for (final element in activeElements) element.id: element};
    return ids.map((id) => byId[id]).whereType<VxElement>().toList();
  }
}
