import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:vector_math/vector_math_64.dart';
import '../models/vx_document.dart';
import '../models/vx_element.dart';

class SvgExporter {
  static String export(VxDocument doc) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    final activeArtboard =
        doc.artboards.isNotEmpty && doc.activePageIndex < doc.artboards.length
        ? doc.artboards[doc.activePageIndex]
        : null;
    final width = activeArtboard?.width ?? doc.width;
    final height = activeArtboard?.height ?? doc.height;

    builder.element(
      'svg',
      attributes: {
        'xmlns': 'http://www.w3.org/2000/svg',
        'width': '$width',
        'height': '$height',
        'viewBox': '0 0 $width $height',
      },
      nest: () {
        final defTags = _collectReferenceTags(doc);
        final writtenDefIds = <String>{};
        builder.element(
          'defs',
          nest: () {
            // 1. Definitions carried by the document: <mask>, <clipPath>,
            //    <symbol> and clip/mask sources. Not painted as artwork.
            for (final entry in doc.defs.entries) {
              _writeDocumentDef(
                builder,
                entry.key,
                entry.value,
                defTags,
                writtenDefIds,
              );
            }
            // 2. Gradient definitions, derived from the elements that use them.
            for (final el in doc.elements) {
              _writeDefsForElement(builder, el, writtenDefIds);
            }
            // 3. Legacy fallback for references that point at ordinary
            //    artwork (documents saved before definitions were modelled).
            for (final el in doc.elements) {
              _writeReferencedDef(
                builder,
                doc,
                el.clipPathId,
                'clipPath',
                writtenDefIds,
              );
              _writeReferencedDef(
                builder,
                doc,
                el.maskId,
                'mask',
                writtenDefIds,
              );
            }
          },
        );

        // Write elements
        for (final el in doc.elements) {
          _writeElement(builder, el);
        }
      },
    );

    return builder.buildDocument().toXmlString(pretty: true);
  }

  /// Which SVG tag each definition must be written as, derived from how the
  /// document references it (`mask=` vs `clip-path=`).
  static Map<String, String> _collectReferenceTags(VxDocument doc) {
    final tags = <String, String>{};
    void visit(VxElement el) {
      final mask = el.maskId;
      if (mask != null) tags[mask] = 'mask';
      final clip = el.clipPathId;
      if (clip != null) tags[clip] = 'clipPath';
      for (final child in _childrenOf(el)) {
        visit(child);
      }
    }

    for (final el in doc.elements) {
      visit(el);
    }
    for (final el in doc.defs.values) {
      visit(el);
    }
    return tags;
  }

  static List<VxElement> _childrenOf(VxElement el) {
    return el.mapOrNull(
          group: (e) => e.children,
          compound: (e) => e.children,
          symbol: (e) => e.children,
        ) ??
        const <VxElement>[];
  }

  /// Writes the body of a definition wrapper. Containers contribute their
  /// children directly (so `<mask id="x"><g id="x">` cannot happen); a leaf
  /// definition is written under a derived id to keep wrapper ids unique.
  static void _writeDefBody(XmlBuilder b, VxElement element) {
    final children = _childrenOf(element);
    if (children.isNotEmpty) {
      for (final child in children) {
        _writeElement(b, child);
      }
      return;
    }
    _writeElement(b, element.copyWith(id: '${element.id}__src'));
  }

  static void _writeDocumentDef(
    XmlBuilder b,
    String id,
    VxElement element,
    Map<String, String> referenceTags,
    Set<String> written,
  ) {
    if (!written.add(id)) return;
    final tag = referenceTags[id] ?? (element is VxSymbol ? 'symbol' : 'g');
    b.element(
      tag,
      attributes: {'id': id},
      nest: () => _writeDefBody(b, element),
    );
  }

  static void _writeDefsForElement(
    XmlBuilder b,
    VxElement el,
    Set<String> written,
  ) {
    el.mapOrNull(
      rect: (e) => _writeFillDef(b, e.fill, e.id),
      ellipse: (e) => _writeFillDef(b, e.fill, e.id),
      path: (e) => _writeFillDef(b, e.fill, e.id),
      compound: (e) {
        _writeFillDef(b, e.fill, e.id);
        for (final c in e.children) _writeDefsForElement(b, c, written);
      },
      group: (e) {
        for (final c in e.children) _writeDefsForElement(b, c, written);
      },
      symbol: (e) {
        _writeDocumentDef(b, e.id, e, const {}, written);
      },
    );
  }

  static void _writeReferencedDef(
    XmlBuilder b,
    VxDocument doc,
    String? refId,
    String tagName,
    Set<String> written,
  ) {
    if (refId == null) return;
    if (written.contains(refId)) return;
    final target = _findElementById(doc.elements, refId);
    if (target == null) return;
    written.add(refId);
    b.element(
      tagName,
      attributes: {'id': refId},
      nest: () => _writeDefBody(b, target),
    );
  }

  static void _writeFillDef(XmlBuilder b, VxFill fill, String elementId) {
    void writeStop(ColorStop s) {
      b.element(
        'stop',
        attributes: {
          'offset': '${s.offset * 100}%',
          'stop-color': _colorToHex(s.color),
          if (s.color.a < 1) 'stop-opacity': _num(s.color.a),
        },
      );
    }

    fill.mapOrNull(
      linear: (f) {
        b.element(
          'linearGradient',
          attributes: {
            'id': 'fill_$elementId',
            'gradientUnits': _gradientUnitsName(f.units),
            'x1': '${f.start.dx}',
            'y1': '${f.start.dy}',
            'x2': '${f.end.dx}',
            'y2': '${f.end.dy}',
          },
          nest: () {
            for (final s in f.stops) {
              writeStop(s);
            }
          },
        );
      },
      radial: (f) {
        b.element(
          'radialGradient',
          attributes: {
            'id': 'fill_$elementId',
            'gradientUnits': _gradientUnitsName(f.units),
            'cx': '${f.center.dx}',
            'cy': '${f.center.dy}',
            'r': '${f.radius}',
          },
          nest: () {
            for (final s in f.stops) {
              writeStop(s);
            }
          },
        );
      },
    );
  }

  /// SVG names for the model's gradient coordinate space.
  static String _gradientUnitsName(GradientUnits units) => switch (units) {
    GradientUnits.userSpaceOnUse => 'userSpaceOnUse',
    GradientUnits.objectBoundingBox => 'objectBoundingBox',
  };

  static void _writeElement(XmlBuilder b, VxElement el) {
    el.map(
      rect: (e) => b.element(
        'rect',
        attributes: {
          'id': e.id,
          'x': '${e.x}',
          'y': '${e.y}',
          'width': '${e.width}',
          'height': '${e.height}',
          ..._paintAttributes(e.fill, e.stroke, e.id),
          if (e.opacity != 1.0) 'opacity': '${e.opacity}',
          if (e.clipPathId != null) 'clip-path': 'url(#${e.clipPathId})',
          if (e.maskId != null) 'mask': 'url(#${e.maskId})',
          if (!_isIdentity(e.transform)) 'transform': _matrixToSvg(e.transform),
        },
      ),
      ellipse: (e) => b.element(
        'ellipse',
        attributes: {
          'id': e.id,
          'cx': '${e.cx}',
          'cy': '${e.cy}',
          'rx': '${e.rx}',
          'ry': '${e.ry}',
          ..._paintAttributes(e.fill, e.stroke, e.id),
          if (e.opacity != 1.0) 'opacity': '${e.opacity}',
          if (e.clipPathId != null) 'clip-path': 'url(#${e.clipPathId})',
          if (e.maskId != null) 'mask': 'url(#${e.maskId})',
          if (!_isIdentity(e.transform)) 'transform': _matrixToSvg(e.transform),
        },
      ),
      path: (e) => b.element(
        // A straight two-point path has to be <line>: writing it as <path> with
        // x1/y1/x2/y2 produces an element with no `d`, which is invalid SVG and
        // renders as nothing. Every straight line in an exported drawing used to
        // vanish (caught by the corpus).
        _isSimpleLine(e.segments) ? 'line' : 'path',
        attributes: {
          if (_isSimpleLine(e.segments)) ...{
            'id': e.id,
            'x1': '${_linePoint(e.segments, 0).dx}',
            'y1': '${_linePoint(e.segments, 0).dy}',
            'x2': '${_linePoint(e.segments, 1).dx}',
            'y2': '${_linePoint(e.segments, 1).dy}',
            'fill': 'none',
            ..._paintAttributes(const VxFill.none(), e.stroke, e.id),
            if (e.opacity != 1.0) 'opacity': '${e.opacity}',
            if (e.clipPathId != null) 'clip-path': 'url(#${e.clipPathId})',
            if (e.maskId != null) 'mask': 'url(#${e.maskId})',
            if (!_isIdentity(e.transform)) 'transform': _matrixToSvg(e.transform),
          } else ...{
            'id': e.id,
            'd': _segmentsToD(e.segments),
            ..._paintAttributes(e.fill, e.stroke, e.id),
            if (e.opacity != 1.0) 'opacity': '${e.opacity}',
            if (e.clipPathId != null) 'clip-path': 'url(#${e.clipPathId})',
            if (e.maskId != null) 'mask': 'url(#${e.maskId})',
            if (!_isIdentity(e.transform)) 'transform': _matrixToSvg(e.transform),
          },
        },
      ),
      text: (e) => b.element(
        'text',
        attributes: {
          'id': e.id,
          'x': '${e.x}',
          'y': '${e.y}',
          'fill': e.style.color != null && e.style.color!.a > 0
              ? _colorToHex(e.style.color!)
              : 'black',
          if (e.style.color != null && e.style.color!.a < 1)
            'fill-opacity': _num(e.style.color!.a),
          if (e.style.fontSize != null) 'font-size': '${e.style.fontSize}',
          if (e.style.fontFamily != null) 'font-family': '${e.style.fontFamily}',
          if (e.fontWeightValue != null) 'font-weight': '${e.fontWeightValue}',
          if (e.fontStyle == FontStyle.italic) 'font-style': 'italic',
          if (e.align != TextAlign.start) 'text-anchor': _textAnchor(e.align),
          if (e.letterSpacing != null) 'letter-spacing': '${e.letterSpacing}',
          if (e.wordSpacing != null) 'word-spacing': '${e.wordSpacing}',
          if (e.opacity != 1.0) 'opacity': '${e.opacity}',
          if (e.clipPathId != null) 'clip-path': 'url(#${e.clipPathId})',
          if (e.maskId != null) 'mask': 'url(#${e.maskId})',
          if (!_isIdentity(e.transform)) 'transform': _matrixToSvg(e.transform),
        },
        nest: () => b.text(e.content),
      ),
      group: (e) => b.element(
        'g',
        attributes: {
          'id': e.id,
          if (e.opacity != 1.0) 'opacity': '${e.opacity}',
          if (e.clipPathId != null) 'clip-path': 'url(#${e.clipPathId})',
          if (e.maskId != null) 'mask': 'url(#${e.maskId})',
          if (!_isIdentity(e.transform)) 'transform': _matrixToSvg(e.transform),
        },
        nest: () {
          for (final c in e.children) _writeElement(b, c);
        },
      ),
      compound: (e) => b.element(
        'g',
        attributes: {
          'id': e.id,
          'data-vectix-compound-op': '${e.operation}',
          if (e.opacity != 1.0) 'opacity': '${e.opacity}',
          if (e.clipPathId != null) 'clip-path': 'url(#${e.clipPathId})',
          if (e.maskId != null) 'mask': 'url(#${e.maskId})',
          if (!_isIdentity(e.transform)) 'transform': _matrixToSvg(e.transform),
        },
        nest: () {
          for (final c in e.children) _writeElement(b, c);
        },
      ),
      use: (e) => b.element(
        'use',
        attributes: {
          'id': e.id,
          'href': e.href.startsWith('#') ? e.href : '#${e.href}',
          if (e.opacity != 1.0) 'opacity': '${e.opacity}',
          if (e.clipPathId != null) 'clip-path': 'url(#${e.clipPathId})',
          if (e.maskId != null) 'mask': 'url(#${e.maskId})',
          if (!_isIdentity(e.transform)) 'transform': _matrixToSvg(e.transform),
        },
      ),
      symbol: (e) {}, // Symbols are written in defs
    );
  }

  /// Paint attributes shared by every shape.
  ///
  /// Alpha is carried by `fill-opacity` / `stroke-opacity` on top of a 6-digit
  /// `#rrggbb` colour: the most widely supported form, and it round-trips
  /// through SvgImporter. The previous exporter dropped alpha entirely (finding
  /// P1-4), so semi-transparent artwork exported fully opaque.
  static Map<String, String> _paintAttributes(
    VxFill fill,
    VxStroke stroke,
    String elementId,
  ) {
    final attrs = <String, String>{};

    final fillValue = _getFillValue(fill, elementId);
    attrs['fill'] = fillValue;
    final fillAlpha = _fillAlpha(fill);
    if (fillValue != 'none' && !fillValue.startsWith('url(') && fillAlpha < 1) {
      attrs['fill-opacity'] = _num(fillAlpha);
    }

    final strokeAlpha = stroke.color.a * stroke.opacity;
    if (stroke.width > 0 && strokeAlpha > 0) {
      attrs['stroke'] = _colorToHex(stroke.color);
      attrs['stroke-width'] = _num(stroke.width);
      if (strokeAlpha < 1) attrs['stroke-opacity'] = _num(strokeAlpha);
      if (stroke.cap != StrokeCap.butt) {
        attrs['stroke-linecap'] = switch (stroke.cap) {
          StrokeCap.round => 'round',
          StrokeCap.square => 'square',
          StrokeCap.butt => 'butt',
        };
      }
      if (stroke.join != StrokeJoin.miter) {
        attrs['stroke-linejoin'] = switch (stroke.join) {
          StrokeJoin.round => 'round',
          StrokeJoin.bevel => 'bevel',
          StrokeJoin.miter => 'miter',
        };
      } else if (stroke.miterLimit != _svgDefaultMiterLimit) {
        attrs['stroke-miterlimit'] = _num(stroke.miterLimit);
      }
      final dash = stroke.dashArray;
      if (dash != null && dash.isNotEmpty) {
        attrs['stroke-dasharray'] = dash.join(' ');
      }
    }

    return attrs;
  }

  static const double _svgDefaultMiterLimit = 4.0;

  static double _fillAlpha(VxFill fill) {
    return fill.when(
      solid: (c) => c.a,
      linear: (_, __, ___, ____) => 1.0,
      radial: (_, __, ___, ____) => 1.0,
      none: () => 1.0,
    );
  }

  static String _textAnchor(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return 'middle';
      case TextAlign.end:
      case TextAlign.right:
        return 'end';
      default:
        return 'start';
    }
  }

  /// Formats a double compactly and stably (avoids float noise like
  /// `0.30000000000000004` in the output).
  static String _num(double value) {
    final rounded = (value * 1000).roundToDouble() / 1000;
    if (rounded == rounded.roundToDouble()) {
      return rounded.toInt().toString();
    }
    return rounded.toString();
  }

  static String _getFillValue(VxFill fill, String elementId) {
    return fill.when(
      solid: (color) => color.a == 0 ? 'none' : _colorToHex(color),
      linear: (_, __, ___, ____) => 'url(#fill_$elementId)',
      radial: (_, __, ___, ____) => 'url(#fill_$elementId)',
      none: () => 'none',
    );
  }

  static String _colorToHex(Color c) {
    // Alpha is emitted separately as fill-opacity / stroke-opacity.
    // Color.r/g/b are 0..1 doubles in the current Flutter API.
    final r = (c.r * 255).round();
    final g = (c.g * 255).round();
    final b = (c.b * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  static bool _isIdentity(Matrix4 m) => m == Matrix4.identity();

  static String _matrixToSvg(Matrix4 m) {
    // SVG matrix: matrix(a, b, c, d, e, f)
    // Flutter Matrix4 is column-major 4x4
    final s = m.storage;
    return 'matrix(${s[0]}, ${s[1]}, ${s[4]}, ${s[5]}, ${s[12]}, ${s[13]})';
  }

  static String _segmentsToD(List<PathSegment> segments) {
    final buffer = StringBuffer();
    for (final seg in segments) {
      seg.when(
        moveTo: (p) => buffer.write('M ${p.dx} ${p.dy} '),
        lineTo: (p) => buffer.write('L ${p.dx} ${p.dy} '),
        quadraticBezierTo: (c, p) =>
            buffer.write('Q ${c.dx} ${c.dy} ${p.dx} ${p.dy} '),
        cubicBezierTo: (c1, c2, p) => buffer.write(
          'C ${c1.dx} ${c1.dy} ${c2.dx} ${c2.dy} ${p.dx} ${p.dy} ',
        ),
        close: () => buffer.write('Z '),
      );
    }
    return buffer.toString().trim();
  }

  static bool _isSimpleLine(List<PathSegment> segments) {
    if (segments.length != 2) return false;
    return segments[0].maybeWhen(moveTo: (_) => true, orElse: () => false) &&
        segments[1].maybeWhen(lineTo: (_) => true, orElse: () => false);
  }

  static Offset _linePoint(List<PathSegment> segments, int index) {
    return segments[index].when(
      moveTo: (p) => p,
      lineTo: (p) => p,
      quadraticBezierTo: (c, p) => p,
      cubicBezierTo: (c1, c2, p) => p,
      close: () => Offset.zero,
    );
  }

  static VxElement? _findElementById(List<VxElement> elements, String id) {
    for (final element in elements) {
      if (element.id == id) return element;
      VxElement? found;
      element.mapOrNull(
        group: (e) => found = _findElementById(e.children, id),
        compound: (e) => found = _findElementById(e.children, id),
        symbol: (e) => found = _findElementById(e.children, id),
      );
      if (found != null) return found;
    }
    return null;
  }
}
