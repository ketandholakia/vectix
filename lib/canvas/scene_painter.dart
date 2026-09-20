import 'package:flutter/material.dart';
import '../models/vx_document.dart';
import '../models/vx_element.dart';
import '../state/editor_state.dart';
import 'scene_index.dart';

class ScenePainter extends CustomPainter {
  final VxDocument document;
  final ViewportState viewport;
  final Map<String, Path> _pathCache = {};

  ScenePainter(this.document, this.viewport);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(viewport.pan.dx, viewport.pan.dy);
    canvas.scale(viewport.zoom);

    final activeElements = SceneIndex.of(document).activeElements;
    for (final element in activeElements) {
      _paintElement(canvas, element);
    }

    canvas.restore();
  }

  bool _belongsToActiveArtboard(VxElement element, VxDocument document) {
    if (document.artboards.isEmpty) return true;
    final index = document.activePageIndex.clamp(
      0,
      document.artboards.length - 1,
    );
    final activeId = document.artboards[index].id;
    return element.artboardId == null || element.artboardId == activeId;
  }

  void _paintElement(Canvas canvas, VxElement element) {
    if (!element.visible) return;

    canvas.save();
    canvas.transform(element.transform.storage);

    if (element.opacity < 1.0) {
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(255, 255, 255, element.opacity));
    }

    final paint = Paint();
    final clipTarget = _resolveReference(element.clipPathId);
    if (clipTarget != null) {
      canvas.clipPath(_getElementAsPath(clipTarget));
    }
    final maskTarget = _resolveReference(element.maskId);
    if (maskTarget != null) {
      final bounds = _getElementAsPath(maskTarget).getBounds();
      canvas.saveLayer(bounds, Paint());
    }

    element.when(
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
            final rect = Rect.fromLTWH(x, y, width, height);
            _applyFill(paint, fill, rect);
            if (fill is! NoFill) canvas.drawRect(rect, paint);
            _applyStroke(paint, stroke);
            if (stroke.width > 0) {
              final outline = Path()..addRect(rect);
              _drawStrokePath(canvas, outline, paint, stroke);
            }
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
            final rect = Rect.fromCenter(
              center: Offset(cx, cy),
              width: rx * 2,
              height: ry * 2,
            );
            _applyFill(paint, fill, rect);
            if (fill is! NoFill) canvas.drawOval(rect, paint);
            _applyStroke(paint, stroke);
            if (stroke.width > 0) {
              final outline = Path()..addOval(rect);
              _drawStrokePath(canvas, outline, paint, stroke);
            }
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
            final path = _cachedPath(id, segments);
            _applyFill(paint, fill, path.getBounds());
            if (fill is! NoFill) canvas.drawPath(path, paint);
            _applyStroke(paint, stroke);
            if (stroke.width > 0) _drawStrokePath(canvas, path, paint, stroke);
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
            final textSpan = TextSpan(text: content, style: style);
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            textPainter.paint(canvas, Offset(x, y));
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
            for (final child in children) {
              _paintElement(canvas, child);
            }
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
            final target = _resolveReference(targetId);
            if (target != null) {
              canvas.save();
              canvas.transform(target.transform.storage);
              if (target is VxSymbol) {
                for (final child in target.children) {
                  _paintElement(canvas, child);
                }
              } else {
                _paintElement(canvas, target);
              }
              canvas.restore();
            }
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
            // Symbols don't render directly on canvas until instantiated by <use>
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
            if (children.isEmpty) return;

            // Convert operation int to PathOperation
            PathOperation pathOp = PathOperation.difference;
            if (operation == 1)
              pathOp = PathOperation.intersect;
            else if (operation == 2)
              pathOp = PathOperation.union;
            else if (operation == 3)
              pathOp = PathOperation.xor;

            // Build the combined path
            Path resultPath = _getElementAsPath(children.first);
            for (int i = 1; i < children.length; i++) {
              final childPath = _getElementAsPath(children[i]);
              resultPath = Path.combine(pathOp, resultPath, childPath);
            }

            // Transform the combined path
            resultPath = resultPath.transform(transform.storage);

            _applyFill(paint, fill, resultPath.getBounds());
            if (fill is! NoFill) canvas.drawPath(resultPath, paint);
            _applyStroke(paint, stroke);
            if (stroke.width > 0)
              _drawStrokePath(canvas, resultPath, paint, stroke);
          },
    );

    if (maskTarget != null) {
      final maskPaint = Paint()
        ..color = Colors.white
        ..blendMode = BlendMode.dstIn;
      canvas.drawPath(_getElementAsPath(maskTarget), maskPaint);
      canvas.restore();
    }

    if (element.opacity < 1.0) {
      canvas.restore();
    }

    canvas.restore();
  }

  final Map<int, Path> _elementPathCache = {};

  Path _getElementAsPath(VxElement element) {
    final key = element.hashCode;
    if (_elementPathCache.containsKey(key)) {
      return _elementPathCache[key]!;
    }
    
    if (_elementPathCache.length > 5000) {
      _elementPathCache.clear();
    }

    final path = element.when(
      rect:
          (
            _,
            __,
            x,
            y,
            w,
            h,
            t,
            ___,
            ____,
            _____,
            ______,
            _______,
            ________,
            _________,
          ) => Path()
            ..addRect(Rect.fromLTWH(x, y, w, h))
            ..transform(t.storage),
      ellipse:
          (
            _,
            __,
            cx,
            cy,
            rx,
            ry,
            t,
            ___,
            ____,
            _____,
            ______,
            _______,
            ________,
            _________,
          ) => Path()
            ..addOval(
              Rect.fromCenter(
                center: Offset(cx, cy),
                width: rx * 2,
                height: ry * 2,
              ),
            )
            ..transform(t.storage),
      path:
          (
            id,
            __,
            segments,
            t,
            ___,
            ____,
            _____,
            ______,
            _______,
            ________,
            _________,
          ) {
            final p = Path.from(_cachedPath(id, segments));
            return p..transform(t.storage);
          },
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
            t,
            __1,
            __2,
            __3,
            __4,
            __5,
          ) => Path(),
      group: (_, __, children, t, ___, ____, _____, ______, ________) {
        Path p = Path();
        for (final child in children) {
          p.addPath(_getElementAsPath(child), Offset.zero);
        }
        return p.transform(t.storage);
      },
      use: (_, __, href, t, ___, ____, _____, ______, ________) {
        final targetId = href.startsWith('#') ? href.substring(1) : href;
        final target = _resolveReference(targetId);
        if (target != null) {
          return _getElementAsPath(target).transform(t.storage);
        }
        return Path();
      },
      symbol: (_, __, children, t, ___, ____, _____, ______, ________) =>
          Path(),
      compound:
          (
            id,
            artboardId,
            op,
            children,
            t,
            f,
            s,
            ____,
            _____,
            ______,
            _______,
            ________,
          ) {
            PathOperation pathOp = PathOperation.difference;
            if (op == 1)
              pathOp = PathOperation.intersect;
            else if (op == 2)
              pathOp = PathOperation.union;
            else if (op == 3)
              pathOp = PathOperation.xor;

            if (children.isEmpty) return Path();
            Path resultPath = _getElementAsPath(children.first);
            for (int i = 1; i < children.length; i++) {
              resultPath = Path.combine(
                pathOp,
                resultPath,
                _getElementAsPath(children[i]),
              );
            }
            return resultPath.transform(t.storage);
          },
    );
    
    _elementPathCache[key] = path;
    return path;
  }

  void _applyFill(Paint paint, VxFill fill, Rect bounds) {
    paint.style = PaintingStyle.fill;
    fill.when(
      solid: (color) => paint.color = color,
      linear: (start, end, stops) {
        paint.shader = LinearGradient(
          colors: stops.map((s) => s.color).toList(),
          stops: stops.map((s) => s.offset).toList(),
        ).createShader(bounds);
      },
      radial: (center, radius, stops) {
        paint.shader = RadialGradient(
          colors: stops.map((s) => s.color).toList(),
          stops: stops.map((s) => s.offset).toList(),
        ).createShader(bounds);
      },
      none: () => paint.color = Colors.transparent,
    );
  }

  void _applyStroke(Paint paint, VxStroke stroke) {
    paint.style = PaintingStyle.stroke;
    paint.color = stroke.color;
    paint.strokeWidth = stroke.width;
    paint.strokeCap = stroke.cap;
    paint.strokeJoin = stroke.join;
    // Dash array handling would go here, maybe using path_drawing package
  }

  void _drawStrokePath(Canvas canvas, Path path, Paint paint, VxStroke stroke) {
    final dash = stroke.dashArray;
    if (dash == null || dash.isEmpty) {
      canvas.drawPath(path, paint);
      return;
    }
    final segments = path.computeMetrics();
    for (final metric in segments) {
      double distance = 0.0;
      int index = 0;
      while (distance < metric.length) {
        final len = dash[index % dash.length].abs();
        if (len == 0) {
          index++;
          continue;
        }
        final next = (distance + len).clamp(0.0, metric.length);
        if (index.isEven) {
          final segment = metric.extractPath(distance, next);
          canvas.drawPath(segment, paint);
        }
        distance = next;
        index++;
      }
    }
  }

  Path _buildPath(List<PathSegment> segments) {
    final path = Path();
    for (final segment in segments) {
      segment.when(
        moveTo: (p) => path.moveTo(p.dx, p.dy),
        lineTo: (p) => path.lineTo(p.dx, p.dy),
        quadraticBezierTo: (c, p) =>
            path.quadraticBezierTo(c.dx, c.dy, p.dx, p.dy),
        cubicBezierTo: (c1, c2, p) =>
            path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p.dx, p.dy),
        close: () => path.close(),
      );
    }
    return path;
  }

  Path _cachedPath(String id, List<PathSegment> segments) {
    final key = '${id}_${Object.hashAll(segments)}';
    final cached = _pathCache[key];
    if (cached != null) return cached;
    final path = _buildPath(segments);
    _pathCache[key] = path;
    return path;
  }

  @override
  bool shouldRepaint(covariant ScenePainter oldDelegate) {
    return oldDelegate.document != document || oldDelegate.viewport != viewport;
  }

  VxElement? _findElementById(List<VxElement> elements, String id) {
    for (final el in elements) {
      if (el.id == id) return el;
      VxElement? found;
      el.whenOrNull(
        group: (_, __, children, ___, ____, _____, ______, _______, ________) =>
            found = _findElementById(children, id),
        compound:
            (
              _,
              __,
              ___,
              children,
              ____,
              _____,
              ______,
              _______,
              ________,
              _________,
              __________,
              ___________,
            ) => found = _findElementById(children, id),
        symbol:
            (_, __, children, ___, ____, _____, ______, _______, ________) =>
                found = _findElementById(children, id),
      );
      if (found != null) return found;
    }
    return null;
  }

  VxElement? _resolveReference(String? id) {
    if (id == null) return null;
    return _findElementById(document.elements, id);
  }
}
