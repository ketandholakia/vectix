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
