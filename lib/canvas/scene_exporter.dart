import 'dart:io';
import 'dart:typed_data';
import 'dart:ui'
    show Canvas, FontStyle, Offset, Path, Rect, Size, TextStyle, VoidCallback;
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' as material;
import 'package:pdf/pdf.dart';
import 'package:pdf/src/pdf/obj/smask.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/src/pdf/obj/function.dart' as pdf_fn;
import 'package:pdf/src/pdf/obj/pattern.dart' as pdf_pattern;
import 'package:pdf/src/pdf/obj/shading.dart' as pdf_shading;
import 'package:vector_math/vector_math_64.dart';

import '../models/vx_document.dart';
import '../models/vx_element.dart';
import '../state/editor_state.dart';
import 'scene_painter.dart';

class SceneExporter {
  static final Map<String, Uint8List> _thumbnailCache = {};

  static Future<void> exportToPng(
    VxDocument document, {
    bool transparentBackground = false,
    double scale = 1.0,
  }) async {
    final String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export PNG',
      fileName: '${document.title}.png',
      type: FileType.custom,
      allowedExtensions: ['png'],
    );
    if (path == null) return;
    final image = await renderPng(
      document,
      transparentBackground: transparentBackground,
      scale: scale,
    );
    final file = File(path);
    await file.writeAsBytes(image);
  }

  static Future<Uint8List> renderPng(
    VxDocument document, {
    bool transparentBackground = false,
    double scale = 1.0,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final activeArtboard =
        document.artboards.isNotEmpty &&
            document.activePageIndex < document.artboards.length
        ? document.artboards[document.activePageIndex]
        : null;
    final baseSize = Size(
      activeArtboard?.width ?? document.width,
      activeArtboard?.height ?? document.height,
    );
    final size = Size(baseSize.width * scale, baseSize.height * scale);
    if (!transparentBackground) {
      canvas.drawRect(
        Offset.zero & size,
        ui.Paint()..color = material.Colors.white,
      );
    }
    final painter = ScenePainter(
      document,
      const ViewportState(zoom: 1.0, pan: Offset.zero),
    );
    canvas.save();
    canvas.scale(scale);
    painter.paint(canvas, baseSize);
    canvas.restore();
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  static Future<void> exportToPdf(
    VxDocument document, {
    List<String>? artboardIds,
    double bleed = 0,
    bool cropMarks = false,
  }) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export PDF',
      fileName: '${document.title}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path == null) return;

    final pdf = pw.Document();
    final selectedArtboards = _selectedArtboards(document, artboardIds);
    if (selectedArtboards.isEmpty) return;

    final artboards = document.artboards.isEmpty
        ? <VxArtboard?>[null]
        : selectedArtboards.cast<VxArtboard?>();
    for (final artboard in artboards) {
      final pageWidth = artboard?.width ?? document.width;
      final pageHeight = artboard?.height ?? document.height;
      final pdfWidth = pageWidth + bleed * 2;
      final pdfHeight = pageHeight + bleed * 2;
      final page = PdfPage(
        pdf.document!,
        pageFormat: PdfPageFormat(pdfWidth, pdfHeight),
      );
      final graphics = page.getGraphics();
      final font = PdfFont.helvetica(pdf.document!);
      if (cropMarks && bleed > 0) {
        _drawCropMarks(
          graphics,
          pageWidth,
          pageHeight,
          bleed,
          pdfWidth,
          pdfHeight,
        );
      }
      _drawPdfDocument(
        graphics,
        font,
        pdf.document!,
        document,
        pageHeight,
        bleed: bleed,
        artboardId: artboard?.id,
      );
    }
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
  }

  static List<VxArtboard> _selectedArtboards(
    VxDocument document,
    List<String>? artboardIds,
  ) {
    if (document.artboards.isEmpty) return const [];
    if (artboardIds == null || artboardIds.isEmpty) return document.artboards;
    final wanted = artboardIds.toSet();
    return document.artboards
        .where((artboard) => wanted.contains(artboard.id))
        .toList(growable: false);
  }

  static Future<Uint8List?> renderSymbolThumbnailBytes(
    VxDocument document,
    VxSymbol symbol, {
    double size = 128,
  }) async {
    final key = _thumbnailKey(symbol);
    final cached = _thumbnailCache[key];
    if (cached != null) return cached;
    final tempDoc = document.copyWith(
      elements: symbol.children,
      artboards: const [],
      activePageIndex: 0,
      width: size,
      height: size,
    );
    final data = await renderPng(tempDoc, transparentBackground: true);
    _thumbnailCache[key] = data;
    return data;
  }

  static Uint8List? cachedThumbnail(VxSymbol symbol) {
    return _thumbnailCache[_thumbnailKey(symbol)];
  }

  static String _thumbnailKey(VxSymbol symbol) => symbol.toJson().toString();

  static void _drawPdfDocument(
    PdfGraphics g,
    PdfFont font,
    PdfDocument pdfDocument,
    VxDocument document,
    double pageHeight, {
    double bleed = 0,
    String? artboardId,
  }) {
    g.saveContext();
    if (bleed > 0) {
      g.setTransform(Matrix4.translationValues(bleed, bleed, 0));
    }
    for (final element in document.elements) {
      _drawPdfElement(
        g,
        font,
        pdfDocument,
        document,
        element,
        Matrix4.identity(),
        pageHeight,
        bleed: bleed,
        artboardId: artboardId,
      );
    }
    g.restoreContext();
  }

  static void _drawPdfElement(
    PdfGraphics g,
    PdfFont font,
    PdfDocument pdfDocument,
    VxDocument document,
    VxElement element,
    Matrix4 parentTransform,
    double pageHeight, {
    double bleed = 0,
    String? artboardId,
  }) {
    if (!_belongsToArtboard(element, artboardId)) return;
    final maskTarget = element.maskId == null
        ? null
        : _resolve(document, element.maskId!);
    if (maskTarget != null) {
      _withSoftMask(
        g,
        pdfDocument,
        document,
        maskTarget,
        parentTransform,
        pageHeight,
        artboardId: artboardId,
        body: () => _drawPdfElementWithoutMask(
          g,
          font,
          pdfDocument,
          document,
          element,
          parentTransform,
          pageHeight,
          bleed: bleed,
          artboardId: artboardId,
        ),
      );
      return;
    }
    _drawPdfElementWithoutMask(
      g,
      font,
      pdfDocument,
      document,
      element,
      parentTransform,
      pageHeight,
      bleed: bleed,
      artboardId: artboardId,
    );
  }

  static void _drawPdfElementWithoutMask(
    PdfGraphics g,
    PdfFont font,
    PdfDocument pdfDocument,
    VxDocument document,
    VxElement element,
    Matrix4 parentTransform,
    double pageHeight, {
    double bleed = 0,
    String? artboardId,
  }) {
    if (!_belongsToArtboard(element, artboardId)) return;
    element.whenOrNull(
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
            final m = parentTransform * transform;
            _withTransform(g, m, pageHeight, () {
              if (clipPathId != null) {
                final clip = _resolve(document, clipPathId);
                if (clip != null) {
                  _clipToElement(
                    g,
                    document,
                    clip,
                    Matrix4.identity(),
                    pageHeight,
                    artboardId: artboardId,
                  );
                }
              }
              final r = Rect.fromLTWH(x, y, width, height);
              _paintRect(g, pdfDocument, r, fill, stroke);
            });
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
            final m = parentTransform * transform;
            _withTransform(g, m, pageHeight, () {
              if (clipPathId != null) {
                final clip = _resolve(document, clipPathId);
                if (clip != null) {
                  _clipToElement(
                    g,
                    document,
                    clip,
                    Matrix4.identity(),
                    pageHeight,
                    artboardId: artboardId,
                  );
                }
              }
              _paintEllipse(g, pdfDocument, cx, cy, rx, ry, fill, stroke);
            });
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
            final m = parentTransform * transform;
            _withTransform(g, m, pageHeight, () {
              if (clipPathId != null) {
                final clip = _resolve(document, clipPathId);
                if (clip != null) {
                  _clipToElement(
                    g,
                    document,
                    clip,
                    Matrix4.identity(),
                    pageHeight,
                    artboardId: artboardId,
                  );
                }
              }
              _paintPath(g, pdfDocument, segments, pageHeight, fill, stroke);
            });
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
            final m = parentTransform * transform;
            _withTransform(g, m, pageHeight, () {
              final size = style.fontSize ?? 24;
              final pdfFont = _pdfTextFont(
                pdfDocument,
                style,
                fontWeightValue,
                fontStyle,
              );
              g.setFillColor(
                PdfColor.fromInt(
                  style.color?.value ?? material.Colors.black.value,
                ),
              );
              g.drawString(
                pdfFont,
                size,
                content,
                x,
                pageHeight - y,
                charSpace: letterSpacing,
                wordSpace: wordSpacing,
                mode: PdfTextRenderingMode.fill,
              );
            });
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
            final m = parentTransform * transform;
            for (final child in children) {
              _drawPdfElement(
                g,
                font,
                pdfDocument,
                document,
                child,
                m,
                pageHeight,
                artboardId: artboardId,
              );
            }
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
            final m = parentTransform * transform;
            for (final child in children) {
              _drawPdfElement(
                g,
                font,
                pdfDocument,
                document,
                child,
                m,
                pageHeight,
                artboardId: artboardId,
              );
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
            final target = _resolve(document, href);
            if (target != null) {
              _drawPdfElement(
                g,
                font,
                pdfDocument,
                document,
                target,
                parentTransform * transform,
                pageHeight,
                artboardId: artboardId,
              );
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
            for (final child in children) {
              _drawPdfElement(
                g,
                font,
                pdfDocument,
                document,
                child,
                parentTransform * transform,
                pageHeight,
                artboardId: artboardId,
              );
            }
          },
    );
  }

  static void _withSoftMask(
    PdfGraphics g,
    PdfDocument pdfDocument,
    VxDocument document,
    VxElement maskTarget,
    Matrix4 parentTransform,
    double pageHeight, {
    required VoidCallback body,
    String? artboardId,
  }) {
    final bounds = _elementBounds(maskTarget);
    if (bounds == null || bounds.isEmpty) {
      body();
      return;
    }
    final softMask = PdfSoftMask(
      pdfDocument,
      boundingBox: PdfRect(
        bounds.left,
        bounds.top,
        bounds.width,
        bounds.height,
      ),
    );
    final maskGraphics = softMask.getGraphics();
    if (maskGraphics == null) {
      body();
      return;
    }
    _drawPdfElementWithoutMask(
      maskGraphics,
      PdfFont.helvetica(pdfDocument),
      pdfDocument,
      document,
      maskTarget,
      parentTransform,
      pageHeight,
      artboardId: artboardId,
    );
    g.saveContext();
    g.setGraphicState(PdfGraphicState(softMask: softMask));
    body();
    g.restoreContext();
  }

  static void _paintRect(
    PdfGraphics g,
    PdfDocument pdfDocument,
    Rect rect,
    VxFill fill,
    VxStroke stroke,
  ) {
    g.moveTo(rect.left, rect.bottom);
    g.lineTo(rect.right, rect.bottom);
    g.lineTo(rect.right, rect.top);
    g.lineTo(rect.left, rect.top);
    g.closePath();
    _applyPdfFill(g, pdfDocument, fill);
    g.fillPath();
    if (stroke.width > 0) {
      g.moveTo(rect.left, rect.bottom);
      g.lineTo(rect.right, rect.bottom);
      g.lineTo(rect.right, rect.top);
      g.lineTo(rect.left, rect.top);
      g.closePath();
      _applyPdfStroke(g, stroke);
      g.strokePath();
    }
  }

  static void _paintEllipse(
    PdfGraphics g,
    PdfDocument pdfDocument,
    double cx,
    double cy,
    double rx,
    double ry,
    VxFill fill,
    VxStroke stroke,
  ) {
    g.moveTo(cx + rx, cy);
    g.bezierArc(cx, cy, rx, ry, 0, 360);
    g.closePath();
    _applyPdfFill(g, pdfDocument, fill);
    g.fillPath();
    if (stroke.width > 0) {
      g.moveTo(cx + rx, cy);
      g.bezierArc(cx, cy, rx, ry, 0, 360);
      g.closePath();
      _applyPdfStroke(g, stroke);
      g.strokePath();
    }
  }

  static void _paintPath(
    PdfGraphics g,
    PdfDocument pdfDocument,
    List<PathSegment> segments,
    double pageHeight,
    VxFill fill,
    VxStroke stroke,
  ) {
    if (segments.isEmpty) return;
    _drawPdfSegments(g, segments, pageHeight);
    _applyPdfFill(g, pdfDocument, fill);
    g.fillPath();
    if (stroke.width > 0) {
      _applyPdfStroke(g, stroke);
      _drawPdfSegments(g, segments, pageHeight);
      g.strokePath();
    }
  }

  static void _clipToElement(
    PdfGraphics g,
    VxDocument document,
    VxElement element,
    Matrix4 parentTransform,
    double pageHeight, {
    String? artboardId,
  }) {
    if (!_belongsToArtboard(element, artboardId)) return;
    element.whenOrNull(
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
            final m = parentTransform * transform;
            _withTransform(g, m, pageHeight, () {
              g.moveTo(x, pageHeight - y);
              g.lineTo(x + width, pageHeight - y);
              g.lineTo(x + width, pageHeight - (y + height));
              g.lineTo(x, pageHeight - (y + height));
              g.closePath();
              g.clipPath();
            });
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
            final m = parentTransform * transform;
            _withTransform(g, m, pageHeight, () {
              g.moveTo(cx + rx, pageHeight - cy);
              g.bezierArc(cx, pageHeight - cy, rx, ry, 0, 360);
              g.closePath();
              g.clipPath();
            });
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
            final m = parentTransform * transform;
            _withTransform(g, m, pageHeight, () {
              _drawPdfSegments(g, segments, pageHeight);
              g.clipPath();
            });
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
              _clipToElement(
                g,
                document,
                child,
                parentTransform * transform,
                pageHeight,
                artboardId: artboardId,
              );
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
            for (final child in children) {
              _clipToElement(
                g,
                document,
                child,
                parentTransform * transform,
                pageHeight,
                artboardId: artboardId,
              );
            }
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
          ) {},
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
          ) {},
    );
  }

  static void _drawPdfSegments(PdfGraphics g, List<PathSegment> segments, double pageHeight) {
    Offset currentPos = Offset.zero;
    for (final segment in segments) {
      segment.when(
        moveTo: (p) {
          currentPos = p;
          g.moveTo(p.dx, pageHeight - p.dy);
        },
        lineTo: (p) {
          currentPos = p;
          g.lineTo(p.dx, pageHeight - p.dy);
        },
        quadraticBezierTo: (c, p) {
          final cp1x = currentPos.dx + (c.dx - currentPos.dx) * (2 / 3);
          final cp1y = currentPos.dy + (c.dy - currentPos.dy) * (2 / 3);
          final cp2x = p.dx + (c.dx - p.dx) * (2 / 3);
          final cp2y = p.dy + (c.dy - p.dy) * (2 / 3);
          g.curveTo(cp1x, pageHeight - cp1y, cp2x, pageHeight - cp2y, p.dx, pageHeight - p.dy);
          currentPos = p;
        },
        cubicBezierTo: (c1, c2, p) {
          currentPos = p;
          g.curveTo(c1.dx, pageHeight - c1.dy, c2.dx, pageHeight - c2.dy, p.dx, pageHeight - p.dy);
        },
        close: () => g.closePath(),
      );
    }
  }

  static Rect? _elementBounds(VxElement element) {
    return element.whenOrNull(
      rect:
          (
            _,
            __,
            x,
            y,
            width,
            height,
            ___,
            ____,
            _____,
            ______,
            _______,
            ________,
            _________,
            __________,
          ) => Rect.fromLTWH(x, y, width, height),
      ellipse:
          (
            _,
            __,
            cx,
            cy,
            rx,
            ry,
            ___,
            ____,
            _____,
            ______,
            _______,
            ________,
            _________,
            __________,
          ) => Rect.fromLTRB(cx - rx, cy - ry, cx + rx, cy + ry),
      path:
          (
            _,
            __,
            segments,
            ___,
            ____,
            _____,
            ______,
            _______,
            ________,
            _________,
            __________,
          ) {
            final path = _buildPath(segments, 0);
            return path.getBounds();
          },
      group: (_, __, children, ___, ____, _____, ______, _______, ________) {
        Rect? bounds;
        for (final child in children) {
          final childBounds = _elementBounds(child);
          if (childBounds == null) continue;
          bounds = bounds == null
              ? childBounds
              : bounds.expandToInclude(childBounds);
        }
        return bounds;
      },
      symbol: (_, __, children, ___, ____, _____, ______, _______, ________) {
        Rect? bounds;
        for (final child in children) {
          final childBounds = _elementBounds(child);
          if (childBounds == null) continue;
          bounds = bounds == null
              ? childBounds
              : bounds.expandToInclude(childBounds);
        }
        return bounds;
      },
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
            __________,
            ___________,
            ____________,
          ) {
            Rect? bounds;
            for (final child in children) {
              final childBounds = _elementBounds(child);
              if (childBounds == null) continue;
              bounds = bounds == null
                  ? childBounds
                  : bounds.expandToInclude(childBounds);
            }
            return bounds;
          },
    );
  }

  static void _withTransform(
    PdfGraphics g,
    Matrix4 matrix,
    double pageHeight,
    VoidCallback body,
  ) {
    g.saveContext();
    final sx = matrix.storage[0];
    final sy = matrix.storage[5];
    final tx = matrix.storage[12];
    final ty = matrix.storage[13];
    g.setTransform(
      Matrix4(sx, 0, 0, 0, 0, -sy, 0, 0, 0, 0, 1, 0, tx, pageHeight - ty, 0, 1),
    );
    body();
    g.restoreContext();
  }

  static PdfColor _fillColor(VxFill fill) {
    return fill.when(
      solid: (color) => PdfColor.fromInt(color.value),
      linear: (_, __, stops) => PdfColor.fromInt(stops.first.color.value),
      radial: (_, __, stops) => PdfColor.fromInt(stops.first.color.value),
      none: () => PdfColor.fromInt(0x00000000),
    );
  }

  static PdfColor _strokeColor(VxStroke stroke) =>
      PdfColor.fromInt(stroke.color.value);

  static void _applyPdfFill(
    PdfGraphics g,
    PdfDocument pdfDocument,
    VxFill fill,
  ) {
    fill.when(
      solid: (color) => g.setFillColor(PdfColor.fromInt(color.value)),
      linear: (start, end, stops) {
        final shading = pdf_shading.PdfShading(
          pdfDocument,
          shadingType: pdf_shading.PdfShadingType.axial,
          function: pdf_fn.PdfBaseFunction.colorsAndStops(
            pdfDocument,
            stops.map((s) => PdfColor.fromInt(s.color.value)).toList(),
            stops.map((s) => s.offset).toList(),
          ),
          start: PdfPoint(start.dx, start.dy),
          end: PdfPoint(end.dx, end.dy),
          extendStart: true,
          extendEnd: true,
        );
        g.setFillPattern(
          pdf_pattern.PdfShadingPattern(pdfDocument, shading: shading),
        );
      },
      radial: (center, radius, stops) {
        final shading = pdf_shading.PdfShading(
          pdfDocument,
          shadingType: pdf_shading.PdfShadingType.radial,
          function: pdf_fn.PdfBaseFunction.colorsAndStops(
            pdfDocument,
            stops.map((s) => PdfColor.fromInt(s.color.value)).toList(),
            stops.map((s) => s.offset).toList(),
          ),
          start: PdfPoint(center.dx, center.dy),
          end: PdfPoint(center.dx, center.dy),
          radius0: 0,
          radius1: radius,
          extendStart: true,
          extendEnd: true,
        );
        g.setFillPattern(
          pdf_pattern.PdfShadingPattern(pdfDocument, shading: shading),
        );
      },
      none: () => g.setFillColor(PdfColor.fromInt(0x00000000)),
    );
  }

  static void _applyPdfStroke(PdfGraphics g, VxStroke stroke) {
    g.setStrokeColor(PdfColor.fromInt(stroke.color.value));
    g.setLineWidth(stroke.width);
    if (stroke.dashArray != null && stroke.dashArray!.isNotEmpty) {
      g.setLineDashPattern(stroke.dashArray!, 0);
    }
  }

  static Path _buildPath(List<PathSegment> segments, double pageHeight) {
    final path = Path();
    for (final segment in segments) {
      segment.when(
        moveTo: (p) => path.moveTo(p.dx, pageHeight - p.dy),
        lineTo: (p) => path.lineTo(p.dx, pageHeight - p.dy),
        quadraticBezierTo: (c, p) => path.quadraticBezierTo(
          c.dx,
          pageHeight - c.dy,
          p.dx,
          pageHeight - p.dy,
        ),
        cubicBezierTo: (c1, c2, p) => path.cubicTo(
          c1.dx,
          pageHeight - c1.dy,
          c2.dx,
          pageHeight - c2.dy,
          p.dx,
          pageHeight - p.dy,
        ),
        close: () => path.close(),
      );
    }
    return path;
  }

  static PdfFont _pdfTextFont(
    PdfDocument document,
    material.TextStyle style,
    int? fontWeightValue,
    material.FontStyle? fontStyle,
  ) {
    final weight = fontWeightValue ?? style.fontWeight?.value ?? 400;
    final bold = weight >= 700;
    final italic =
        fontStyle == material.FontStyle.italic ||
        style.fontStyle == material.FontStyle.italic;
    if (bold && italic) return PdfFont.helveticaBoldOblique(document);
    if (bold) return PdfFont.helveticaBold(document);
    if (italic) return PdfFont.helveticaOblique(document);
    return PdfFont.helvetica(document);
  }

  static VxElement? _resolve(VxDocument document, String refId) {
    // Document definitions (masks / clip paths / symbols) first, then artwork.
    final def = document.defs[refId];
    if (def != null) return def;
    for (final el in document.elements) {
      final found = _resolveElement(el, refId);
      if (found != null) return found;
    }
    return null;
  }

  static VxElement? _resolveElement(VxElement element, String refId) {
    if (element.id == refId) return element;
    return element.whenOrNull(
      group: (_, __, children, ___, ____, _____, ______, _______, ________) {
        for (final child in children) {
          final found = _resolveElement(child, refId);
          if (found != null) return found;
        }
        return null;
      },
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
            __________,
            ___________,
            ____________,
          ) {
            for (final child in children) {
              final found = _resolveElement(child, refId);
              if (found != null) return found;
            }
            return null;
          },
      symbol: (_, __, children, ___, ____, _____, ______, _______, ________) {
        for (final child in children) {
          final found = _resolveElement(child, refId);
          if (found != null) return found;
        }
        return null;
      },
    );
  }

  static bool _belongsToActiveArtboard(VxElement element, VxDocument document) {
    if (document.artboards.isEmpty) return true;
    final index = document.activePageIndex.clamp(
      0,
      document.artboards.length - 1,
    );
    final activeId = document.artboards[index].id;
    return element.artboardId == null || element.artboardId == activeId;
  }

  static bool _belongsToArtboard(VxElement element, String? artboardId) {
    if (artboardId == null) return true;
    return element.artboardId == null || element.artboardId == artboardId;
  }

  static void _drawCropMarks(
    PdfGraphics g,
    double pageWidth,
    double pageHeight,
    double bleed,
    double pdfWidth,
    double pdfHeight,
  ) {
    if (bleed <= 0) return;
    g.setStrokeColor(PdfColor.fromInt(material.Colors.black.value));
    g.setLineWidth(0.5);
    const tick = 12.0;
    final left = bleed;
    final top = bleed;
    final right = bleed + pageWidth;
    final bottom = bleed + pageHeight;

    void mark(double x1, double y1, double x2, double y2) {
      g.moveTo(x1, y1);
      g.lineTo(x2, y2);
      g.strokePath();
    }

    mark(left, 0, left, tick);
    mark(0, top, tick, top);
    mark(right, 0, right, tick);
    mark(pdfWidth - tick, top, pdfWidth, top);
    mark(left, pdfHeight - tick, left, pdfHeight);
    mark(0, bottom, tick, bottom);
    mark(right, pdfHeight - tick, right, pdfHeight);
    mark(pdfWidth - tick, bottom, pdfWidth, bottom);
  }
}
