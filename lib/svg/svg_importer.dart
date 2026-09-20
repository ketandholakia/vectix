import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:path_parsing/path_parsing.dart';
import 'package:uuid/uuid.dart';
import '../models/vx_document.dart';
import '../models/vx_element.dart';

/// Inheritable SVG presentation state, resolved as the parser walks the tree.
///
/// SVG inherits `fill`, the `stroke-*` family, `fill-opacity`, `font-*`,
/// `text-anchor`, `letter-spacing`, `word-spacing`, `color` and `visibility`
/// from ancestors. It does **not** inherit `opacity`, `clip-path`, `mask`,
/// `filter` or `transform` — those stay per-element.
///
/// Before this existed, attributes were read per element with no inheritance
/// and a missing `fill` became *no fill*, so `<g fill="…">` wrappers and the
/// SVG default of black were both lost on import (finding P1-2).
@immutable
class _SvgStyle {
  const _SvgStyle({
    this.fill = 'black',
    this.stroke,
    this.strokeWidth = 1.0,
    this.strokeOpacity = 1.0,
    this.fillOpacity = 1.0,
    this.dashArray,
    this.cap = StrokeCap.butt,
    this.join = StrokeJoin.miter,
    this.miterLimit = 4.0,
    this.fontFamily,
    this.fontSize = 16.0,
    this.fontWeight = 400,
    this.fontStyle = FontStyle.normal,
    this.align = TextAlign.start,
    this.letterSpacing,
    this.wordSpacing,
    this.color = const Color(0xFF000000),
  });

  /// Raw fill value: `none`, `#rrggbb`, `rgb(…)`, `url(#gradient)`, a name.
  final String fill;
  final String? stroke;
  final double strokeWidth;
  final double strokeOpacity;
  final double fillOpacity;
  final List<double>? dashArray;
  final StrokeCap cap;
  final StrokeJoin join;
  final double miterLimit;
  final String? fontFamily;
  final double fontSize;
  final int fontWeight;
  final FontStyle fontStyle;
  final TextAlign align;
  final double? letterSpacing;
  final double? wordSpacing;
  final Color color;

  _SvgStyle copyWith({
    String? fill,
    String? stroke,
    double? strokeWidth,
    double? strokeOpacity,
    double? fillOpacity,
    List<double>? dashArray,
    StrokeCap? cap,
    StrokeJoin? join,
    double? miterLimit,
    String? fontFamily,
    double? fontSize,
    int? fontWeight,
    FontStyle? fontStyle,
    TextAlign? align,
    double? letterSpacing,
    double? wordSpacing,
    Color? color,
  }) {
    return _SvgStyle(
      fill: fill ?? this.fill,
      stroke: stroke ?? this.stroke,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeOpacity: strokeOpacity ?? this.strokeOpacity,
      fillOpacity: fillOpacity ?? this.fillOpacity,
      dashArray: dashArray ?? this.dashArray,
      cap: cap ?? this.cap,
      join: join ?? this.join,
      miterLimit: miterLimit ?? this.miterLimit,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      align: align ?? this.align,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      color: color ?? this.color,
    );
  }
}

class SvgImporter {
  static const uuid = Uuid();
  static final Map<String, XmlElement> _defs = {};

  /// Corner radius control-point ratio for approximating a circular quarter arc
  /// with a cubic Bézier.
  static const double _kappa = 0.5522847498307936;

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
    final defs = <String, VxElement>{};
    final rawDefs = <String, XmlElement>{};
    _defs.clear();

    // The root <svg> can carry presentation attributes that every descendant
    // inherits — icon sets rely on this, e.g. <svg fill="none" stroke="…">.
    final rootStyle = _resolveStyle(svgRoot, const _SvgStyle());

    // Pass 1 — collect <defs> content. Gradients stay as raw XML because
    // _parseFill resolves them lazily while parsing the elements that use them;
    // everything else is a referenceable definition (mask / clipPath / symbol /
    // plain shape used as a clip or mask source).
    for (final node in svgRoot.children) {
      if (node is! XmlElement || node.name.local != 'defs') continue;
      for (final defNode in node.children) {
        if (defNode is! XmlElement) continue;
        final defId = defNode.getAttribute('id');
        if (defId == null) continue;
        if (defNode.name.local.endsWith('Gradient')) {
          _defs[defId] = defNode;
        } else {
          rawDefs[defId] = defNode;
        }
      }
    }

    // Pass 2 — parse those definitions into the document. They are not painted
    // (see VxDocument.defs) but must exist so that mask="url(#id)",
    // clip-path="url(#id)" and <use href="#id"> resolve at paint time instead
    // of being silently dropped. Finding P0-4.
    for (final entry in rawDefs.entries) {
      final parsed = _parseElement(entry.value, rootStyle);
      if (parsed != null) defs[entry.key] = parsed;
    }

    // Pass 3 — top-level artwork.
    for (final node in svgRoot.children) {
      if (node is XmlElement && node.name.local != 'defs') {
        final el = _parseElement(node, rootStyle);
        if (el != null) elements.add(el);
      }
    }

      return VxDocument(
        id: uuid.v4(),
        width: width,
        height: height,
        elements: elements,
        defs: defs,
        title: 'Imported SVG',
      );
    } catch (e) {
      debugPrint('Error parsing SVG: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Style resolution
  // ---------------------------------------------------------------------------

  /// Merges an element's own `style=""` declarations and presentation
  /// attributes over the inherited style, producing the style its children see.
  static _SvgStyle _resolveStyle(XmlElement node, _SvgStyle parent) {
    final attrs = _parseStyleAttributes(node);
    String? raw(String name) => attrs[name] ?? node.getAttribute(name);

    var style = parent;

    final colorRaw = raw('color');
    if (colorRaw != null) {
      style = style.copyWith(
        color: _parseColor(colorRaw, currentColor: parent.color) ?? parent.color,
      );
    }

    // fill: the attribute value stays raw so gradients survive inheritance.
    final fillRaw = raw('fill');
    if (fillRaw != null) {
      style = style.copyWith(fill: fillRaw.trim());
    }

    final strokeRaw = raw('stroke');
    if (strokeRaw != null) {
      style = style.copyWith(stroke: strokeRaw.trim());
    }

    final strokeWidth = _parseDouble(raw('stroke-width'));
    if (strokeWidth != null) {
      style = style.copyWith(strokeWidth: strokeWidth);
    }

    final fillOpacity = _parseOpacity(raw('fill-opacity'));
    if (fillOpacity != null) {
      style = style.copyWith(fillOpacity: fillOpacity);
    }

    final strokeOpacity = _parseOpacity(raw('stroke-opacity'));
    if (strokeOpacity != null) {
      style = style.copyWith(strokeOpacity: strokeOpacity);
    }

    final dashRaw = raw('stroke-dasharray');
    if (dashRaw != null) {
      final dash = _parseDashArray(dashRaw);
      style = style.copyWith(dashArray: dash ?? const <double>[]);
    }

    final cap = _parseStrokeCap(raw('stroke-linecap'));
    if (cap != null) style = style.copyWith(cap: cap);

    final join = _parseStrokeJoin(raw('stroke-linejoin'));
    if (join != null) style = style.copyWith(join: join);

    final miterLimit = _parseDouble(raw('stroke-miterlimit'));
    if (miterLimit != null) style = style.copyWith(miterLimit: miterLimit);

    final fontFamily = raw('font-family');
    if (fontFamily != null) {
      style = style.copyWith(fontFamily: _cleanFontFamily(fontFamily));
    }

    final fontSize = _parseFontSize(raw('font-size'));
    if (fontSize != null) style = style.copyWith(fontSize: fontSize);

    final fontWeight = _parseFontWeight(raw('font-weight'));
    if (fontWeight != null) style = style.copyWith(fontWeight: fontWeight);

    final fontStyle = _parseFontStyle(raw('font-style'));
    if (fontStyle != null) style = style.copyWith(fontStyle: fontStyle);

    final align = _parseTextAnchor(raw('text-anchor'));
    if (align != null) style = style.copyWith(align: align);

    final letterSpacing = _parseMaybeLength(raw('letter-spacing'));
    if (letterSpacing != null) {
      style = style.copyWith(letterSpacing: letterSpacing);
    }

    final wordSpacing = _parseMaybeLength(raw('word-spacing'));
    if (wordSpacing != null) {
      style = style.copyWith(wordSpacing: wordSpacing);
    }

    return style;
  }

  static VxElement? _parseElement(XmlElement node, _SvgStyle inherited) {
    final style = _resolveStyle(node, inherited);
    final transform = _parseTransform(node.getAttribute('transform'));
    final id = node.getAttribute('id') ?? uuid.v4();
    final attrs = _parseStyleAttributes(node);
    final fill = _parseFill(style.fill, style);
    final stroke = _parseStroke(style);
    // opacity is a compositing property, not an inherited one.
    final opacity =
        _parseOpacity(attrs['opacity'] ?? node.getAttribute('opacity')) ?? 1.0;
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

        // Rounded corners: the model's rectangle has no radius, so an rx/ry
        // pair is carried as an equivalent path with cubic corner arcs.
        final rxRaw = _parseDouble(node.getAttribute('rx'));
        final ryRaw = _parseDouble(node.getAttribute('ry'));
        final rx = (rxRaw ?? ryRaw ?? 0.0).clamp(0.0, w / 2);
        final ry = (ryRaw ?? rxRaw ?? 0.0).clamp(0.0, h / 2);
        if (rx > 0 && ry > 0 && w > 0 && h > 0) {
          return VxElement.path(
            id: id,
            segments: _roundedRectSegments(x, y, w, h, rx, ry),
            transform: transform,
            fill: fill,
            stroke: stroke,
            opacity: opacity,
            clipPathId: clipPathId,
            maskId: maskId,
          );
        }

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

      case 'polygon':
      case 'polyline':
        final points = _parsePointList(node.getAttribute('points'));
        if (points.length < 2) return null;
        return VxElement.path(
          id: id,
          segments: [
            PathSegment.moveTo(points.first),
            for (int i = 1; i < points.length; i++)
              PathSegment.lineTo(points[i]),
            if (node.name.local == 'polygon') const PathSegment.close(),
          ],
          transform: transform,
          fill: node.name.local == 'polygon' ? fill : const VxFill.none(),
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
        // Text is painted with the inherited/own fill; default black.
        final textColor = fill is SolidFill
            ? (fill as SolidFill).color
            : const Color(0xFF000000);
        return VxElement.text(
          id: id,
          content: content,
          x: x,
          y: y,
          style: TextStyle(
            color: textColor,
            fontSize: style.fontSize,
            fontFamily: style.fontFamily,
          ),
          align: style.align,
          letterSpacing: style.letterSpacing,
          wordSpacing: style.wordSpacing,
          fontWeightValue: style.fontWeight,
          fontStyle: style.fontStyle,
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
            final el = _parseElement(child, style);
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
            final el = _parseElement(child, style);
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
            final el = _parseElement(child, style);
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

  // ---------------------------------------------------------------------------
  // Paint values
  // ---------------------------------------------------------------------------

  /// Turns a raw SVG fill value into a model fill, applying `fill-opacity`.
  static VxFill _parseFill(String? raw, _SvgStyle style) {
    final val = raw?.trim();
    if (val == null || val.isEmpty) {
      return const VxFill.none();
    }
    if (val == 'none') return const VxFill.none();

    if (val.startsWith('url(')) {
      final ref = _parseUrlReference(val);
      final def = ref == null ? null : _defs[ref];
      if (def != null && def.name.local.endsWith('Gradient')) {
        return _applyFillOpacity(_parseGradient(def), style.fillOpacity);
      }
      // Unresolvable paint server (pattern/filter/foreign url) — keep it
      // visible rather than dropping the shape entirely.
      return VxFill.solid(
        color: const Color(0xFF808080).withValues(alpha: style.fillOpacity),
      );
    }

    final color = _parseColor(val, currentColor: style.color);
    if (color == null) return const VxFill.none();
    return VxFill.solid(
      color: color.withValues(alpha: color.a * style.fillOpacity),
    );
  }

  static VxFill _applyFillOpacity(VxFill fill, double opacity) {
    if (opacity >= 1.0) return fill;
    // NB: freezed's `map` hands the concrete variant to the callback, so the
    // fields are reached as named accessors here.
    return fill.map(
      solid: (f) =>
          VxFill.solid(color: f.color.withValues(alpha: f.color.a * opacity)),
      linear: (f) => VxFill.linear(
        start: f.start,
        end: f.end,
        stops: _scaleStops(f.stops, opacity),
      ),
      radial: (f) => VxFill.radial(
        center: f.center,
        radius: f.radius,
        stops: _scaleStops(f.stops, opacity),
      ),
      none: (f) => const VxFill.none(),
    );
  }

  static List<ColorStop> _scaleStops(List<ColorStop> stops, double opacity) => [
    for (final stop in stops)
      ColorStop(
        offset: stop.offset,
        color: stop.color.withValues(alpha: stop.color.a * opacity),
      ),
  ];

  static VxStroke _parseStroke(_SvgStyle style) {
    final strokeVal = style.stroke?.trim();
    if (strokeVal == null || strokeVal.isEmpty || strokeVal == 'none') {
      return const VxStroke(
        color: Colors.transparent,
        width: 0,
        cap: StrokeCap.butt,
        join: StrokeJoin.miter,
      );
    }

    final color =
        _parseColor(strokeVal, currentColor: style.color) ??
        const Color(0xFF000000);

    final width = style.strokeWidth;
    if (width <= 0) {
      return const VxStroke(
        color: Colors.transparent,
        width: 0,
        cap: StrokeCap.butt,
        join: StrokeJoin.miter,
      );
    }

    final dash = style.dashArray;
    return VxStroke(
      color: color.withValues(alpha: color.a * style.strokeOpacity),
      width: width,
      cap: style.cap,
      join: style.join,
      opacity: 1.0,
      miterLimit: style.miterLimit,
      dashArray: (dash == null || dash.isEmpty) ? null : dash,
    );
  }

  // ---------------------------------------------------------------------------
  // Primitive value parsing
  // ---------------------------------------------------------------------------

  static double? _parseDouble(String? val) =>
      val == null ? null : double.tryParse(val.trim());

  /// Parses an opacity-like value in the 0..1 range or as a percentage.
  static double? _parseOpacity(String? val) {
    if (val == null) return null;
    final v = val.trim();
    if (v.isEmpty) return null;
    if (v.endsWith('%')) {
      final pct = double.tryParse(v.substring(0, v.length - 1));
      return pct == null ? null : (pct / 100).clamp(0.0, 1.0);
    }
    final num = double.tryParse(v);
    return num == null ? null : num.clamp(0.0, 1.0);
  }

  /// Parses a length that may be `normal` (meaning "unset").
  static double? _parseMaybeLength(String? val) {
    if (val == null) return null;
    final v = val.trim();
    if (v.isEmpty || v == 'normal') return null;
    return double.tryParse(v.replaceAll(RegExp(r'[a-zA-Z%]+$'), ''));
  }

  static double? _parseFontSize(String? val) {
    if (val == null) return null;
    final v = val.trim().toLowerCase();
    // Absolute keywords, in CSS px.
    const keywordSizes = {
      'xx-small': 9.0,
      'x-small': 10.0,
      'small': 13.0,
      'medium': 16.0,
      'large': 18.0,
      'x-large': 24.0,
      'xx-large': 32.0,
    };
    if (keywordSizes.containsKey(v)) return keywordSizes[v];
    return double.tryParse(v.replaceAll(RegExp(r'[a-zA-Z]+$'), ''));
  }

  static int? _parseFontWeight(String? val) {
    if (val == null) return null;
    switch (val.trim().toLowerCase()) {
      case 'normal':
        return 400;
      case 'bold':
        return 700;
      case 'bolder':
        return 700;
      case 'lighter':
        return 300;
    }
    final num = int.tryParse(val.trim());
    if (num == null) return null;
    // Snap to the nearest available weight.
    return (num ~/ 100 * 100).clamp(100, 900);
  }

  static FontStyle? _parseFontStyle(String? val) {
    if (val == null) return null;
    switch (val.trim().toLowerCase()) {
      case 'italic':
      case 'oblique':
        return FontStyle.italic;
      case 'normal':
        return FontStyle.normal;
    }
    return null;
  }

  static TextAlign? _parseTextAnchor(String? val) {
    if (val == null) return null;
    switch (val.trim().toLowerCase()) {
      case 'middle':
        return TextAlign.center;
      case 'end':
        return TextAlign.end;
      case 'start':
        return TextAlign.start;
    }
    return null;
  }

  static StrokeCap? _parseStrokeCap(String? val) {
    if (val == null) return null;
    switch (val.trim().toLowerCase()) {
      case 'round':
        return StrokeCap.round;
      case 'square':
        return StrokeCap.square;
      case 'butt':
        return StrokeCap.butt;
    }
    return null;
  }

  static StrokeJoin? _parseStrokeJoin(String? val) {
    if (val == null) return null;
    switch (val.trim().toLowerCase()) {
      case 'round':
        return StrokeJoin.round;
      case 'bevel':
        return StrokeJoin.bevel;
      case 'miter':
      case 'miter-clip':
      case 'arcs':
        return StrokeJoin.miter;
    }
    return null;
  }

  /// `font-family` is a comma-separated fallback list; keep the first entry and
  /// strip quotes.
  static String _cleanFontFamily(String value) {
    final first = value.split(',').first.trim();
    return first.replaceAll(RegExp(r'''^['"]|['"]$'''), '').trim();
  }

  static String? _parseUrlReference(String? val) {
    if (val == null) return null;
    final m = RegExp(r'url\(#([^)]+)\)').firstMatch(val.trim());
    return m?.group(1);
  }

  static List<Offset> _parsePointList(String? value) {
    if (value == null) return const [];
    final nums = value
        .split(RegExp(r'[ ,\s]+'))
        .where((e) => e.isNotEmpty)
        .map((e) => double.tryParse(e))
        .whereType<double>()
        .toList();
    final points = <Offset>[];
    for (var i = 0; i + 1 < nums.length; i += 2) {
      points.add(Offset(nums[i], nums[i + 1]));
    }
    return points;
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
      final attrs = _parseStyleAttributes(child);
      final stopColor =
          _parseColor(
            attrs['stop-color'] ?? child.getAttribute('stop-color') ??
                child.getAttribute('stopColor'),
          ) ??
          Colors.black;
      final stopOpacity =
          _parseOpacity(
            attrs['stop-opacity'] ?? child.getAttribute('stop-opacity'),
          ) ??
          1.0;
      stops.add(
        ColorStop(
          offset: offset.clamp(0.0, 1.0),
          color: stopColor.withValues(alpha: stopColor.a * stopOpacity),
        ),
      );
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
      'fill-opacity',
      'fill-rule',
      'stroke',
      'stroke-width',
      'stroke-opacity',
      'stroke-dasharray',
      'stroke-linecap',
      'stroke-linejoin',
      'stroke-miterlimit',
      'opacity',
      'color',
      'font-family',
      'font-size',
      'font-weight',
      'font-style',
      'text-anchor',
      'letter-spacing',
      'word-spacing',
      'dominant-baseline',
      'stop-color',
      'stop-opacity',
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

  /// Colours: `#rgb`, `#rgba`, `#rrggbb`, `#rrggbbaa`, `rgb()`/`rgba()`,
  /// `hsl()`/`hsla()`, `transparent`, `currentColor` and the CSS named colours.
  ///
  /// The previous implementation handled only 6-digit hex plus five names, and
  /// mis-read 8-digit hex as `#aarrggbb` instead of `#rrggbbaa` (finding P1-3).
  static Color? _parseColor(String? val, {Color currentColor = const Color(0xFF000000)}) {
    if (val == null) return null;
    final v = val.trim().toLowerCase();
    if (v.isEmpty) return null;

    if (v == 'transparent') return const Color(0x00000000);
    if (v == 'currentcolor') return currentColor;
    if (v == 'none') return null;

    if (v.startsWith('#')) return _parseHexColor(v.substring(1));
    if (v.startsWith('rgb')) return _parseRgbFunction(v);
    if (v.startsWith('hsl')) return _parseHslFunction(v);

    return _namedColors[v];
  }

  static Color? _parseHexColor(String hex) {
    if (hex.length == 3 || hex.length == 4) {
      final expanded = StringBuffer();
      for (final ch in hex.split('')) {
        expanded.write('$ch$ch');
      }
      hex = expanded.toString();
    }
    if (hex.length == 6) {
      final rgb = int.tryParse(hex, radix: 16);
      return rgb == null ? null : Color(0xFF000000 | rgb);
    }
    if (hex.length == 8) {
      // CSS is #rrggbbaa; Flutter's Color is 0xaarrggbb.
      final rgba = int.tryParse(hex, radix: 16);
      if (rgba == null) return null;
      final rgb = (rgba >> 8) & 0xffffff;
      final alpha = rgba & 0xff;
      return Color((alpha << 24) | rgb);
    }
    return null;
  }

  static Color? _parseRgbFunction(String v) {
    final parts = _functionArgs(v);
    if (parts.length < 3) return null;
    int? component(String raw) {
      final t = raw.trim();
      if (t.endsWith('%')) {
        final pct = double.tryParse(t.substring(0, t.length - 1));
        return pct == null ? null : ((pct / 100) * 255).round().clamp(0, 255);
      }
      final num = double.tryParse(t);
      return num == null ? null : num.round().clamp(0, 255);
    }

    final r = component(parts[0]);
    final g = component(parts[1]);
    final b = component(parts[2]);
    if (r == null || g == null || b == null) return null;
    final a = parts.length >= 4 ? (_parseOpacity(parts[3]) ?? 1.0) : 1.0;
    return Color.fromRGBO(r, g, b, a);
  }

  static Color? _parseHslFunction(String v) {
    final parts = _functionArgs(v);
    if (parts.length < 3) return null;
    final h = double.tryParse(parts[0].trim().replaceAll('deg', ''));
    final s = double.tryParse(parts[1].trim().replaceAll('%', ''));
    final l = double.tryParse(parts[2].trim().replaceAll('%', ''));
    if (h == null || s == null || l == null) return null;

    final a = parts.length >= 4 ? (_parseOpacity(parts[3]) ?? 1.0) : 1.0;
    final hue = (h % 360) / 360.0;
    final sat = (s / 100).clamp(0.0, 1.0);
    final light = (l / 100).clamp(0.0, 1.0);

    if (sat == 0) return Color.fromRGBO(
      (light * 255).round(),
      (light * 255).round(),
      (light * 255).round(),
      a,
    );

    final q = light < 0.5
        ? light * (1 + sat)
        : light + sat - light * sat;
    final p = 2 * light - q;
    double channel(double t) {
      var tt = t;
      if (tt < 0) tt += 1;
      if (tt > 1) tt -= 1;
      if (tt < 1 / 6) return p + (q - p) * 6 * tt;
      if (tt < 1 / 2) return q;
      if (tt < 2 / 3) return p + (q - p) * (2 / 3 - tt) * 6;
      return p;
    }

    return Color.fromRGBO(
      (channel(hue + 1 / 3) * 255).round().clamp(0, 255),
      (channel(hue) * 255).round().clamp(0, 255),
      (channel(hue - 1 / 3) * 255).round().clamp(0, 255),
      a,
    );
  }

  /// Extracts the arguments of `name(...)`, tolerating the comma and the
  /// modern space/slash syntax, e.g. `rgb(255 0 0 / 50%)`.
  static List<String> _functionArgs(String v) {
    final open = v.indexOf('(');
    final close = v.lastIndexOf(')');
    if (open < 0 || close <= open) return const [];
    final inner = v.substring(open + 1, close).replaceAll('/', ' ');
    return inner
        .split(RegExp(r'[,\s]+'))
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  static const Map<String, Color> _namedColors = {
    'aliceblue': Color(0xFFF0F8FF),
    'antiquewhite': Color(0xFFFAEBD7),
    'aqua': Color(0xFF00FFFF),
    'aquamarine': Color(0xFF7FFFD4),
    'azure': Color(0xFFF0FFFF),
    'beige': Color(0xFFF5F5DC),
    'bisque': Color(0xFFFFE4C4),
    'black': Color(0xFF000000),
    'blanchedalmond': Color(0xFFFFEBCD),
    'blue': Color(0xFF0000FF),
    'blueviolet': Color(0xFF8A2BE2),
    'brown': Color(0xFFA52A2A),
    'burlywood': Color(0xFFDEB887),
    'cadetblue': Color(0xFF5F9EA0),
    'chartreuse': Color(0xFF7FFF00),
    'chocolate': Color(0xFFD2691E),
    'coral': Color(0xFFFF7F50),
    'cornflowerblue': Color(0xFF6495ED),
    'cornsilk': Color(0xFFFFF8DC),
    'crimson': Color(0xFFDC143C),
    'cyan': Color(0xFF00FFFF),
    'darkblue': Color(0xFF00008B),
    'darkcyan': Color(0xFF008B8B),
    'darkgoldenrod': Color(0xFFB8860B),
    'darkgray': Color(0xFFA9A9A9),
    'darkgreen': Color(0xFF006400),
    'darkgrey': Color(0xFFA9A9A9),
    'darkkhaki': Color(0xFFBDB76B),
    'darkmagenta': Color(0xFF8B008B),
    'darkolivegreen': Color(0xFF556B2F),
    'darkorange': Color(0xFFFF8C00),
    'darkorchid': Color(0xFF9932CC),
    'darkred': Color(0xFF8B0000),
    'darksalmon': Color(0xFFE9967A),
    'darkseagreen': Color(0xFF8FBC8F),
    'darkslateblue': Color(0xFF483D8B),
    'darkslategray': Color(0xFF2F4F4F),
    'darkslategrey': Color(0xFF2F4F4F),
    'darkturquoise': Color(0xFF00CED1),
    'darkviolet': Color(0xFF9400D3),
    'deeppink': Color(0xFFFF1493),
    'deepskyblue': Color(0xFF00BFFF),
    'dimgray': Color(0xFF696969),
    'dimgrey': Color(0xFF696969),
    'dodgerblue': Color(0xFF1E90FF),
    'firebrick': Color(0xFFB22222),
    'floralwhite': Color(0xFFFFFAF0),
    'forestgreen': Color(0xFF228B22),
    'fuchsia': Color(0xFFFF00FF),
    'gainsboro': Color(0xFFDCDCDC),
    'ghostwhite': Color(0xFFF8F8FF),
    'gold': Color(0xFFFFD700),
    'goldenrod': Color(0xFFDAA520),
    'gray': Color(0xFF808080),
    'green': Color(0xFF008000),
    'greenyellow': Color(0xFFADFF2F),
    'grey': Color(0xFF808080),
    'honeydew': Color(0xFFF0FFF0),
    'hotpink': Color(0xFFFF69B4),
    'indianred': Color(0xFFCD5C5C),
    'indigo': Color(0xFF4B0082),
    'ivory': Color(0xFFFFFFF0),
    'khaki': Color(0xFFF0E68C),
    'lavender': Color(0xFFE6E6FA),
    'lavenderblush': Color(0xFFFFF0F5),
    'lawngreen': Color(0xFF7CFC00),
    'lemonchiffon': Color(0xFFFFFACD),
    'lightblue': Color(0xFFADD8E6),
    'lightcoral': Color(0xFFF08080),
    'lightcyan': Color(0xFFE0FFFF),
    'lightgoldenrodyellow': Color(0xFFFAFAD2),
    'lightgray': Color(0xFFD3D3D3),
    'lightgreen': Color(0xFF90EE90),
    'lightgrey': Color(0xFFD3D3D3),
    'lightpink': Color(0xFFFFB6C1),
    'lightsalmon': Color(0xFFFFA07A),
    'lightseagreen': Color(0xFF20B2AA),
    'lightskyblue': Color(0xFF87CEFA),
    'lightslategray': Color(0xFF778899),
    'lightslategrey': Color(0xFF778899),
    'lightsteelblue': Color(0xFFB0C4DE),
    'lightyellow': Color(0xFFFFFFE0),
    'lime': Color(0xFF00FF00),
    'limegreen': Color(0xFF32CD32),
    'linen': Color(0xFFFAF0E6),
    'magenta': Color(0xFFFF00FF),
    'maroon': Color(0xFF800000),
    'mediumaquamarine': Color(0xFF66CDAA),
    'mediumblue': Color(0xFF0000CD),
    'mediumorchid': Color(0xFFBA55D3),
    'mediumpurple': Color(0xFF9370DB),
    'mediumseagreen': Color(0xFF3CB371),
    'mediumslateblue': Color(0xFF7B68EE),
    'mediumspringgreen': Color(0xFF00FA9A),
    'mediumturquoise': Color(0xFF48D1CC),
    'mediumvioletred': Color(0xFFC71585),
    'midnightblue': Color(0xFF191970),
    'mintcream': Color(0xFFF5FFFA),
    'mistyrose': Color(0xFFFFE4E1),
    'moccasin': Color(0xFFFFE4B5),
    'navajowhite': Color(0xFFFFDEAD),
    'navy': Color(0xFF000080),
    'oldlace': Color(0xFFFDF5E6),
    'olive': Color(0xFF808000),
    'olivedrab': Color(0xFF6B8E23),
    'orange': Color(0xFFFFA500),
    'orangered': Color(0xFFFF4500),
    'orchid': Color(0xFFDA70D6),
    'palegoldenrod': Color(0xFFEEE8AA),
    'palegreen': Color(0xFF98FB98),
    'paleturquoise': Color(0xFFAFEEEE),
    'palevioletred': Color(0xFFDB7093),
    'papayawhip': Color(0xFFFFEFD5),
    'peachpuff': Color(0xFFFFDAB9),
    'peru': Color(0xFFCD853F),
    'pink': Color(0xFFFFC0CB),
    'plum': Color(0xFFDDA0DD),
    'powderblue': Color(0xFFB0E0E6),
    'purple': Color(0xFF800080),
    'rebeccapurple': Color(0xFF663399),
    'red': Color(0xFFFF0000),
    'rosybrown': Color(0xFFBC8F8F),
    'royalblue': Color(0xFF4169E1),
    'saddlebrown': Color(0xFF8B4513),
    'salmon': Color(0xFFFA8072),
    'sandybrown': Color(0xFFF4A460),
    'seagreen': Color(0xFF2E8B57),
    'seashell': Color(0xFFFFF5EE),
    'sienna': Color(0xFFA0522D),
    'silver': Color(0xFFC0C0C0),
    'skyblue': Color(0xFF87CEEB),
    'slateblue': Color(0xFF6A5ACD),
    'slategray': Color(0xFF708090),
    'slategrey': Color(0xFF708090),
    'snow': Color(0xFFFFFAFA),
    'springgreen': Color(0xFF00FF7F),
    'steelblue': Color(0xFF4682B4),
    'tan': Color(0xFFD2B48C),
    'teal': Color(0xFF008080),
    'thistle': Color(0xFFD8BFD8),
    'tomato': Color(0xFFFF6347),
    'turquoise': Color(0xFF40E0D0),
    'violet': Color(0xFFEE82EE),
    'wheat': Color(0xFFF5DEB3),
    'white': Color(0xFFFFFFFF),
    'whitesmoke': Color(0xFFF5F5F5),
    'yellow': Color(0xFFFFFF00),
    'yellowgreen': Color(0xFF9ACD32),
  };

  /// Cubic-Bézier approximation of a rectangle with rounded corners.
  static List<PathSegment> _roundedRectSegments(
    double x,
    double y,
    double w,
    double h,
    double rx,
    double ry,
  ) {
    final cx = rx * _kappa;
    final cy = ry * _kappa;
    final right = x + w;
    final bottom = y + h;
    return [
      PathSegment.moveTo(Offset(x + rx, y)),
      PathSegment.lineTo(Offset(right - rx, y)),
      PathSegment.cubicBezierTo(
        Offset(right - rx + cx, y),
        Offset(right, y + ry - cy),
        Offset(right, y + ry),
      ),
      PathSegment.lineTo(Offset(right, bottom - ry)),
      PathSegment.cubicBezierTo(
        Offset(right, bottom - ry + cy),
        Offset(right - rx + cx, bottom),
        Offset(right - rx, bottom),
      ),
      PathSegment.lineTo(Offset(x + rx, bottom)),
      PathSegment.cubicBezierTo(
        Offset(x + rx - cx, bottom),
        Offset(x, bottom - ry + cy),
        Offset(x, bottom - ry),
      ),
      PathSegment.lineTo(Offset(x, y + ry)),
      PathSegment.cubicBezierTo(
        Offset(x, y + ry - cy),
        Offset(x + rx - cx, y),
        Offset(x + rx, y),
      ),
      const PathSegment.close(),
    ];
  }

  static Matrix4 _parseTransform(String? val) {
    if (val == null || val.isEmpty) return Matrix4.identity();
    final result = Matrix4.identity();
    final matches = RegExp(r'(\w+)\(([^)]*)\)').allMatches(val);
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
              (parts.isNotEmpty ? parts[0] : 0.0) * (math.pi / 180.0);
          if (parts.length > 2) {
            result.translate(parts[1], parts[2]);
            result.rotateZ(angle);
            result.translate(-parts[1], -parts[2]);
          } else {
            result.rotateZ(angle);
          }
          break;
        case 'skewX':
          final a = (parts.isNotEmpty ? parts[0] : 0.0) * (math.pi / 180.0);
          result.setEntry(0, 1, math.tan(a));
          break;
        case 'skewY':
          final a = (parts.isNotEmpty ? parts[0] : 0.0) * (math.pi / 180.0);
          result.setEntry(1, 0, math.tan(a));
          break;
        case 'matrix':
          if (parts.length >= 6) {
            // SVG matrix(a,b,c,d,e,f) is a column-major 2D affine:
            //   | a  c  e |
            //   | b  d  f |
            // Matrix4's unnamed constructor takes ROW-major arguments, so the
            // off-diagonal entries must be swapped relative to the SVG
            // component order (b maps to m10, c maps to m01). Passing
            // (a, b, c, d, e, f) straight through transposes the matrix and
            // mirrors every rotated/skewed artwork (finding P1-1).
            final m = Matrix4.identity()
              ..setEntry(0, 0, parts[0])
              ..setEntry(1, 0, parts[1])
              ..setEntry(0, 1, parts[2])
              ..setEntry(1, 1, parts[3])
              ..setEntry(0, 3, parts[4])
              ..setEntry(1, 3, parts[5]);
            result.multiply(m);
          }
          break;
      }
    }
    return result;
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
