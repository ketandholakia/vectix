import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:path_parsing/path_parsing.dart';
import 'package:uuid/uuid.dart';
import '../models/vx_document.dart';
import '../models/vx_element.dart';

class SvgImporter {
  static const uuid = Uuid();
  static final Map<String, XmlElement> _defs = {};

  static VxDocument? import(String xmlString) {
    try {
      final document = XmlDocument.parse(xmlString);
      final svgRoot = document.findElements('svg').first;

    double width = 800;
    double height = 600;

    final widthAttr = svgRoot.getAttribute('width');
    final heightAttr = svgRoot.getAttribute('height');
    final viewBoxAttr = svgRoot.getAttribute('viewBox');

    if (widthAttr != null)
      width =
          double.tryParse(widthAttr.replaceAll(RegExp(r'[a-zA-Z]'), '')) ??
          width;
    if (heightAttr != null)
      height =
          double.tryParse(heightAttr.replaceAll(RegExp(r'[a-zA-Z]'), '')) ??
          height;

    if (viewBoxAttr != null) {
      final parts = viewBoxAttr.split(RegExp(r'[ ,]+'));
      if (parts.length >= 4) {
        width = double.tryParse(parts[2]) ?? width;
        height = double.tryParse(parts[3]) ?? height;
      }
    }

    final elements = <VxElement>[];
    _defs.clear();

    for (final node in svgRoot.children) {
      if (node is XmlElement) {
        if (node.name.local == 'defs') {
          for (final defNode in node.children) {
            if (defNode is XmlElement) {
              final defId = defNode.getAttribute('id');
              if (defId != null) _defs[defId] = defNode;
            }
          }
        } else {
          final el = _parseElement(node);
          if (el != null) elements.add(el);
        }
      }
    }

      return VxDocument(
        id: uuid.v4(),
        width: width,
        height: height,
        elements: elements,
        title: 'Imported SVG',
      );
    } catch (e) {
      debugPrint('Error parsing SVG: $e');
      return null;
    }
  }

  static VxElement? _parseElement(XmlElement node) {
    final transform = _parseTransform(node.getAttribute('transform'));
    final id = node.getAttribute('id') ?? uuid.v4();
    final attrs = _parseStyleAttributes(node);
    final fill = _parseFill(attrs['fill'] ?? node.getAttribute('fill'));
    final stroke = _parseStroke(node, attrs);
    final opacity =
        _parseDouble(attrs['opacity'] ?? node.getAttribute('opacity')) ?? 1.0;
    final clipPathId = _parseUrlReference(
      attrs['clip-path'] ?? node.getAttribute('clip-path'),
    );
    final maskId = _parseUrlReference(
      attrs['mask'] ?? node.getAttribute('mask'),
    );

    switch (node.name.local) {
      case 'rect':
        final x = double.tryParse(node.getAttribute('x') ?? '0') ?? 0;
        final y = double.tryParse(node.getAttribute('y') ?? '0') ?? 0;
        final w = double.tryParse(node.getAttribute('width') ?? '0') ?? 0;
        final h = double.tryParse(node.getAttribute('height') ?? '0') ?? 0;
        return VxElement.rect(
          id: id,
          x: x,
          y: y,
          width: w,
          height: h,
          transform: transform,
          fill: fill,
          stroke: stroke,
          opacity: opacity,
          clipPathId: clipPathId,
          maskId: maskId,
        );

      case 'ellipse':
        final cx = double.tryParse(node.getAttribute('cx') ?? '0') ?? 0;
        final cy = double.tryParse(node.getAttribute('cy') ?? '0') ?? 0;
        final rx = double.tryParse(node.getAttribute('rx') ?? '0') ?? 0;
        final ry = double.tryParse(node.getAttribute('ry') ?? '0') ?? 0;
        return VxElement.ellipse(
          id: id,
          cx: cx,
          cy: cy,
          rx: rx,
          ry: ry,
          transform: transform,
          fill: fill,
          stroke: stroke,
          opacity: opacity,
          clipPathId: clipPathId,
          maskId: maskId,
        );

      case 'circle':
        final cx = double.tryParse(node.getAttribute('cx') ?? '0') ?? 0;
        final cy = double.tryParse(node.getAttribute('cy') ?? '0') ?? 0;
        final r = double.tryParse(node.getAttribute('r') ?? '0') ?? 0;
        return VxElement.ellipse(
          id: id,
          cx: cx,
          cy: cy,
          rx: r,
          ry: r,
          transform: transform,
          fill: fill,
          stroke: stroke,
          opacity: opacity,
          clipPathId: clipPathId,
          maskId: maskId,
        );

      case 'path':
        final d = node.getAttribute('d') ?? '';
        final segments = _parsePathData(d);
        return VxElement.path(
          id: id,
          segments: segments,
          transform: transform,
          fill: fill,
          stroke: stroke,
          opacity: opacity,
          clipPathId: clipPathId,
          maskId: maskId,
        );

      case 'line':
        final x1 = double.tryParse(node.getAttribute('x1') ?? '0') ?? 0;
        final y1 = double.tryParse(node.getAttribute('y1') ?? '0') ?? 0;
        final x2 = double.tryParse(node.getAttribute('x2') ?? '0') ?? 0;
        final y2 = double.tryParse(node.getAttribute('y2') ?? '0') ?? 0;
        return VxElement.path(
          id: id,
          segments: [
            PathSegment.moveTo(Offset(x1, y1)),
            PathSegment.lineTo(Offset(x2, y2)),
          ],
          transform: transform,
          fill: const VxFill.none(),
          stroke: stroke,
          opacity: opacity,
          clipPathId: clipPathId,
          maskId: maskId,
        );

      case 'text':
        final x = double.tryParse(node.getAttribute('x') ?? '0') ?? 0;
        final y = double.tryParse(node.getAttribute('y') ?? '0') ?? 0;
        final content = node.innerText;
        final fontSize =
            double.tryParse(
              attrs['font-size'] ?? node.getAttribute('font-size') ?? '16',
            ) ??
            16;
        final textColor =
            _parseColor(attrs['fill'] ?? node.getAttribute('fill')) ??
            Colors.black;
        final fontFamily =
            attrs['font-family'] ?? node.getAttribute('font-family');
        return VxElement.text(
          id: id,
          content: content,
          x: x,
          y: y,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontFamily: fontFamily,
          ),
          align: TextAlign.start,
          maxLines: 1,
          transform: transform,
          opacity: opacity,
          clipPathId: clipPathId,
          maskId: maskId,
        );

      case 'g':
        final children = <VxElement>[];
        for (final child in node.children) {
          if (child is XmlElement) {
            final el = _parseElement(child);
            if (el != null) children.add(el);
          }
        }

        final compoundOp = node.getAttribute('data-vectix-compound-op');
        if (compoundOp != null) {
          return VxElement.compound(
            id: id,
            operation: int.tryParse(compoundOp) ?? 0,
            children: children,
            transform: transform,
            fill: fill,
            stroke: stroke,
            opacity: opacity,
            clipPathId: clipPathId,
            maskId: maskId,
          );
        }

        return VxElement.group(
          id: id,
          children: children,
          transform: transform,
          opacity: opacity,
          clipPathId: clipPathId,
          maskId: maskId,
        );

      case 'use':
        final href =
            node.getAttribute('href') ?? node.getAttribute('xlink:href') ?? '';
        return VxElement.use(
          id: id,
          href: href,
          transform: transform,
          opacity: opacity,
          clipPathId: clipPathId,
          maskId: maskId,
        );

      case 'symbol':
        final children = <VxElement>[];
        for (final child in node.children) {
          if (child is XmlElement) {
            final el = _parseElement(child);
            if (el != null) children.add(el);
          }
        }
        return VxElement.symbol(
          id: id,
          children: children,
          transform: transform,
          opacity: opacity,
          clipPathId: clipPathId,
          maskId: maskId,
        );

      case 'clipPath':
      case 'mask':
        final children = <VxElement>[];
        for (final child in node.children) {
          if (child is XmlElement) {
            final el = _parseElement(child);
            if (el != null) children.add(el);
          }
        }
        return VxElement.group(
          id: id,
          children: children,
          transform: transform,
          opacity: opacity,
          clipPathId: clipPathId,
          maskId: maskId,
        );
    }

    return null;
  }

  static Matrix4 _parseTransform(String? val) {
    if (val == null || val.isEmpty) return Matrix4.identity();
    final result = Matrix4.identity();
    final matches = RegExp(r'(\w+)\(([^)]*)\)').allMatches(val);
    if (matches.isEmpty && val.startsWith('matrix(')) {
      matches.toList();
    }
    for (final match in matches) {
      final name = match.group(1)!;
      final parts = match
          .group(2)!
          .split(RegExp(r'[ ,]+'))
          .where((e) => e.isNotEmpty)
          .map((e) => double.tryParse(e) ?? 0.0)
          .toList();
      switch (name) {
        case 'translate':
          final tx = parts.isNotEmpty ? parts[0] : 0.0;
          final ty = parts.length > 1 ? parts[1] : 0.0;
          result.translate(tx, ty);
          break;
        case 'scale':
          final sx = parts.isNotEmpty ? parts[0] : 1.0;
          final sy = parts.length > 1 ? parts[1] : sx;
          result.scale(sx, sy, 1.0);
          break;
        case 'rotate':
          final angle =
              (parts.isNotEmpty ? parts[0] : 0.0) * (3.141592653589793 / 180.0);
          if (parts.length > 2) {
            result.translate(parts[1], parts[2]);
            result.rotateZ(angle);
            result.translate(-parts[1], -parts[2]);
          } else {
            result.rotateZ(angle);
          }
          break;
        case 'skewX':
          final a =
              (parts.isNotEmpty ? parts[0] : 0.0) * (3.141592653589793 / 180.0);
          result.setEntry(0, 1, math.tan(a));
          break;
        case 'skewY':
          final a =
              (parts.isNotEmpty ? parts[0] : 0.0) * (3.141592653589793 / 180.0);
          result.setEntry(1, 0, math.tan(a));
          break;
        case 'matrix':
          if (parts.length >= 6) {
            final m = Matrix4(
              parts[0],
              parts[1],
              0,
              0,
              parts[2],
              parts[3],
              0,
              0,
              0,
              0,
              1,
              0,
              parts[4],
              parts[5],
              0,
              1,
            );
            result.multiply(m);
          }
          break;
      }
    }
    return result;
  }

  static VxFill _parseFill(String? val) {
    if (val == null)
      return const VxFill.none(); // Default none for path, maybe solid for rect? Actually SVG defaults to black
    if (val == 'none') return const VxFill.none();
    if (val.startsWith('url(')) {
      final ref = _parseUrlReference(val);
      if (ref != null) {
        final def = _defs[ref];
        if (def != null && def.name.local.endsWith('Gradient')) {
          return _parseGradient(def);
        }
      }
      return const VxFill.solid(color: Colors.grey);
    }
    final c = _parseColor(val);
    if (c != null) return VxFill.solid(color: c);
    return const VxFill.solid(color: Colors.black);
  }

  static VxStroke _parseStroke(XmlElement node, Map<String, String> attrs) {
    final strokeVal = attrs['stroke'] ?? node.getAttribute('stroke');
    final widthVal = attrs['stroke-width'] ?? node.getAttribute('stroke-width');
    final dashArrayVal =
        attrs['stroke-dasharray'] ?? node.getAttribute('stroke-dasharray');

    if (strokeVal == null || strokeVal == 'none') {
      return const VxStroke(
        color: Colors.transparent,
        width: 0,
        cap: StrokeCap.butt,
        join: StrokeJoin.miter,
      );
    }

    final color = _parseColor(strokeVal) ?? Colors.black;
    final width = double.tryParse(widthVal ?? '1') ?? 1.0;
    final opacity =
        _parseDouble(
          attrs['stroke-opacity'] ?? node.getAttribute('stroke-opacity'),
        ) ??
        1.0;
    final dashArray = _parseDashArray(dashArrayVal);

    return VxStroke(
      color: color,
      width: width,
      cap: StrokeCap.butt,
      join: StrokeJoin.miter,
      opacity: opacity,
      dashArray: dashArray,
    );
  }

  static double? _parseDouble(String? val) =>
      val == null ? null : double.tryParse(val);

  static String? _parseUrlReference(String? val) {
    if (val == null) return null;
    final m = RegExp(r'url\(#([^)]+)\)').firstMatch(val.trim());
    return m?.group(1);
  }

  static VxFill _parseGradient(XmlElement def) {
    final stops = <ColorStop>[];
    for (final child in def.children.whereType<XmlElement>()) {
      if (child.name.local != 'stop') continue;
      final offsetStr = child.getAttribute('offset') ?? '0';
      final offset = offsetStr.endsWith('%')
          ? (double.tryParse(offsetStr.substring(0, offsetStr.length - 1)) ??
                    0) /
                100.0
          : double.tryParse(offsetStr) ?? 0.0;
      final stopColor =
          _parseColor(
            child.getAttribute('stop-color') ?? child.getAttribute('stopColor'),
          ) ??
          Colors.black;
      stops.add(ColorStop(offset: offset, color: stopColor));
    }
    if (def.name.local == 'linearGradient') {
      final x1 = _parseDouble(def.getAttribute('x1')) ?? 0.0;
      final y1 = _parseDouble(def.getAttribute('y1')) ?? 0.0;
      final x2 = _parseDouble(def.getAttribute('x2')) ?? 1.0;
      final y2 = _parseDouble(def.getAttribute('y2')) ?? 0.0;
      return VxFill.linear(
        start: Offset(x1, y1),
        end: Offset(x2, y2),
        stops: stops,
      );
    }
    if (def.name.local == 'radialGradient') {
      final cx = _parseDouble(def.getAttribute('cx')) ?? 0.5;
      final cy = _parseDouble(def.getAttribute('cy')) ?? 0.5;
      final r = _parseDouble(def.getAttribute('r')) ?? 0.5;
      return VxFill.radial(center: Offset(cx, cy), radius: r, stops: stops);
    }
    return const VxFill.none();
  }

  static Map<String, String> _parseStyleAttributes(XmlElement node) {
    final result = <String, String>{};
    final style = node.getAttribute('style');
    if (style != null) {
      for (final entry in style.split(';')) {
        final idx = entry.indexOf(':');
        if (idx <= 0) continue;
        final key = entry.substring(0, idx).trim();
        final value = entry.substring(idx + 1).trim();
        if (key.isNotEmpty && value.isNotEmpty) {
          result[key] = value;
        }
      }
    }

    const presentationAttrs = [
      'fill',
      'stroke',
      'stroke-width',
      'stroke-opacity',
      'stroke-dasharray',
      'fill-opacity',
      'opacity',
      'font-family',
      'font-size',
      'font-weight',
      'text-anchor',
      'letter-spacing',
      'word-spacing',
      'dominant-baseline',
    ];
    for (final name in presentationAttrs) {
      final value = node.getAttribute(name);
      if (value != null && value.isNotEmpty) {
        result[name] = value;
      }
    }
    return result;
  }

  static List<double>? _parseDashArray(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    if (normalized.isEmpty || normalized == 'none') return null;

    final parts = normalized.split(RegExp(r'[ ,]+')).where((e) => e.isNotEmpty);
    final values = parts
        .map((part) => double.tryParse(part))
        .whereType<double>()
        .toList();
    return values.isEmpty ? null : values;
  }

  static Color? _parseColor(String? val) {
    if (val == null) return null;
    if (val.startsWith('#')) {
      var hex = val.substring(1);
      if (hex.length == 3) {
        hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
      }
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      final num = int.tryParse(hex, radix: 16);
      if (num != null) return Color(num);
    }
    // Very basic color names
    if (val == 'black') return Colors.black;
    if (val == 'white') return Colors.white;
    if (val == 'red') return Colors.red;
    if (val == 'green') return Colors.green;
    if (val == 'blue') return Colors.blue;
    return null;
  }

  static List<PathSegment> _parsePathData(String d) {
    final builder = _PathSegmentBuilder();
    try {
      writeSvgPathDataToPath(d, builder);
    } catch (e) {
      debugPrint('Error parsing SVG path data: $e');
    }
    return builder.segments;
  }
}

class _PathSegmentBuilder extends PathProxy {
  final List<PathSegment> segments = [];

  @override
  void close() {
    segments.add(const PathSegment.close());
  }

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    segments.add(
      PathSegment.cubicBezierTo(Offset(x1, y1), Offset(x2, y2), Offset(x3, y3)),
    );
  }

  @override
  void lineTo(double x, double y) {
    segments.add(PathSegment.lineTo(Offset(x, y)));
  }

  @override
  void moveTo(double x, double y) {
    segments.add(PathSegment.moveTo(Offset(x, y)));
  }
}
