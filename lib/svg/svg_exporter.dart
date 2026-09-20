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
        // Create defs for gradients
        builder.element(
          'defs',
          nest: () {
            for (final el in doc.elements) {
              _writeDefsForElement(builder, el);
            }
            for (final el in doc.elements) {
              _writeReferencedDef(builder, doc, el.clipPathId, 'clipPath');
              _writeReferencedDef(builder, doc, el.maskId, 'mask');
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

  static void _writeDefsForElement(XmlBuilder b, VxElement el) {
    el.mapOrNull(
      rect: (e) => _writeFillDef(b, e.fill, e.id),
      ellipse: (e) => _writeFillDef(b, e.fill, e.id),
      path: (e) => _writeFillDef(b, e.fill, e.id),
      compound: (e) {
        _writeFillDef(b, e.fill, e.id);
        for (final c in e.children) _writeDefsForElement(b, c);
      },
      group: (e) {
        for (final c in e.children) _writeDefsForElement(b, c);
      },
      symbol: (e) {
        b.element(
          'symbol',
          attributes: {'id': e.id},
          nest: () {
            for (final c in e.children) _writeElement(b, c);
          },
        );
      },
    );
  }

  static void _writeReferencedDef(
    XmlBuilder b,
    VxDocument doc,
    String? refId,
    String tagName,
  ) {
    if (refId == null) return;
    final target = _findElementById(doc.elements, refId);
    if (target == null) return;
    b.element(
      tagName,
      attributes: {'id': refId},
      nest: () => _writeElement(b, target),
    );
  }

  static void _writeFillDef(XmlBuilder b, VxFill fill, String elementId) {
    fill.whenOrNull(
      linear: (start, end, stops) {
        b.element(
          'linearGradient',
          attributes: {
            'id': 'fill_$elementId',
            'x1': '${start.dx}',
            'y1': '${start.dy}',
            'x2': '${end.dx}',
            'y2': '${end.dy}',
            'gradientUnits': 'userSpaceOnUse',
          },
          nest: () {
            for (final s in stops) {
              b.element(
                'stop',
                attributes: {
                  'offset': '${s.offset * 100}%',
                  'stop-color': _colorToHex(s.color),
                },
              );
            }
          },
        );
      },
      radial: (center, radius, stops) {
        b.element(
          'radialGradient',
          attributes: {
            'id': 'fill_$elementId',
            'cx': '${center.dx}',
            'cy': '${center.dy}',
            'r': '$radius',
            'gradientUnits': 'userSpaceOnUse',
          },
          nest: () {
            for (final s in stops) {
              b.element(
                'stop',
                attributes: {
                  'offset': '${s.offset * 100}%',
                  'stop-color': _colorToHex(s.color),
                },
              );
            }
          },
        );
      },
    );
  }

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
          'fill': _getFillValue(e.fill, e.id),
          'stroke': _colorToHex(e.stroke.color),
          'stroke-width': '${e.stroke.width}',
          if (e.stroke.dashArray != null && e.stroke.dashArray!.isNotEmpty)
            'stroke-dasharray': e.stroke.dashArray!.join(' '),
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
          'fill': _getFillValue(e.fill, e.id),
          'stroke': _colorToHex(e.stroke.color),
          'stroke-width': '${e.stroke.width}',
          if (e.stroke.dashArray != null && e.stroke.dashArray!.isNotEmpty)
            'stroke-dasharray': e.stroke.dashArray!.join(' '),
          if (e.opacity != 1.0) 'opacity': '${e.opacity}',
          if (e.clipPathId != null) 'clip-path': 'url(#${e.clipPathId})',
          if (e.maskId != null) 'mask': 'url(#${e.maskId})',
          if (!_isIdentity(e.transform)) 'transform': _matrixToSvg(e.transform),
        },
      ),
      path: (e) => b.element(
        'path',
        attributes: {
          if (_isSimpleLine(e.segments)) ...{
            'id': e.id,
            'x1': '${_linePoint(e.segments, 0).dx}',
            'y1': '${_linePoint(e.segments, 0).dy}',
            'x2': '${_linePoint(e.segments, 1).dx}',
            'y2': '${_linePoint(e.segments, 1).dy}',
            'fill': 'none',
            'stroke': _colorToHex(e.stroke.color),
            'stroke-width': '${e.stroke.width}',
            if (e.stroke.dashArray != null && e.stroke.dashArray!.isNotEmpty)
              'stroke-dasharray': e.stroke.dashArray!.join(' '),
            if (e.opacity != 1.0) 'opacity': '${e.opacity}',
            if (e.clipPathId != null) 'clip-path': 'url(#${e.clipPathId})',
            if (e.maskId != null) 'mask': 'url(#${e.maskId})',
            if (!_isIdentity(e.transform)) 'transform': _matrixToSvg(e.transform),
          } else ...{
            'id': e.id,
            'd': _segmentsToD(e.segments),
            'fill': _getFillValue(e.fill, e.id),
            'stroke': _colorToHex(e.stroke.color),
            'stroke-width': '${e.stroke.width}',
            if (e.stroke.dashArray != null && e.stroke.dashArray!.isNotEmpty)
              'stroke-dasharray': e.stroke.dashArray!.join(' '),
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
          'fill': e.style.color != null ? _colorToHex(e.style.color!) : 'black',
          if (e.style.fontSize != null) 'font-size': '${e.style.fontSize}',
          if (e.style.fontFamily != null) 'font-family': '${e.style.fontFamily}',
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

  static String _getFillValue(VxFill fill, String elementId) {
    return fill.when(
      solid: (color) => _colorToHex(color),
      linear: (_, __, ___) => 'url(#fill_$elementId)',
      radial: (_, __, ___) => 'url(#fill_$elementId)',
      none: () => 'none',
    );
  }

  static String _colorToHex(Color c) {
    if (c.alpha == 0) return 'none';
    return '#${c.red.toRadixString(16).padLeft(2, '0')}${c.green.toRadixString(16).padLeft(2, '0')}${c.blue.toRadixString(16).padLeft(2, '0')}';
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
