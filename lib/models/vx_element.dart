import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vector_math/vector_math_64.dart';
import 'converters.dart';

part 'vx_element.freezed.dart';
part 'vx_element.g.dart';

@freezed
abstract class PathSegment with _$PathSegment {
  const factory PathSegment.moveTo(@OffsetConverter() Offset point) = MoveToSegment;
  const factory PathSegment.lineTo(@OffsetConverter() Offset point) = LineToSegment;
  const factory PathSegment.quadraticBezierTo(@OffsetConverter() Offset control, @OffsetConverter() Offset point) = QuadraticBezierToSegment;
  const factory PathSegment.cubicBezierTo(@OffsetConverter() Offset control1, @OffsetConverter() Offset control2, @OffsetConverter() Offset point) = CubicBezierToSegment;
  const factory PathSegment.close() = CloseSegment;

  factory PathSegment.fromJson(Map<String, dynamic> json) => _$PathSegmentFromJson(json);
}

@freezed
abstract class ColorStop with _$ColorStop {
  const factory ColorStop({
    required double offset,
    @ColorConverter() required Color color,
  }) = _ColorStop;

  factory ColorStop.fromJson(Map<String, dynamic> json) => _$ColorStopFromJson(json);
}

/// How gradient coordinates are interpreted, mirroring SVG's `gradientUnits`.
///
/// `objectBoundingBox` (SVG's default) is the one designers expect: the
/// gradient is expressed as fractions of the element's bounds, so it scales
/// with the shape when the shape is resized.
enum GradientUnits {
  userSpaceOnUse,
  objectBoundingBox,
}

@freezed
abstract class VxFill with _$VxFill {
    const factory VxFill.solid({@ColorConverter() required Color color}) = SolidFill;
  const factory VxFill.linear({
    @Default(GradientUnits.userSpaceOnUse) GradientUnits units,
    @OffsetConverter() required Offset start,
    @OffsetConverter() required Offset end,
    required List<ColorStop> stops,
  }) = LinearFill;
  const factory VxFill.radial({
    @Default(GradientUnits.userSpaceOnUse) GradientUnits units,
    @OffsetConverter() required Offset center,
    required double radius,
    required List<ColorStop> stops,
  }) = RadialFill;
  const factory VxFill.none() = NoFill;

  factory VxFill.fromJson(Map<String, dynamic> json) => _$VxFillFromJson(json);
}

@freezed
abstract class VxStroke with _$VxStroke {
  const factory VxStroke({
    @ColorConverter() required Color color,
    required double width,
    required StrokeCap cap,
    required StrokeJoin join,
    @Default(1.0) double opacity,
    // SVG's initial value (and Skia's default). The old default of 1.0 would
    // bevel every miter join now that the painter applies the limit.
    @Default(4.0) double miterLimit,
    List<double>? dashArray,
  }) = _VxStroke;

  factory VxStroke.fromJson(Map<String, dynamic> json) => _$VxStrokeFromJson(json);
}

@freezed
abstract class VxElement with _$VxElement {
  const factory VxElement.rect({
    required String id,
    String? artboardId,
    required double x,
    required double y,
    required double width,
    required double height,
    @Matrix4Converter() required Matrix4 transform,
    required VxFill fill,
    required VxStroke stroke,
    @Default(1.0) double opacity,
    @Default(false) bool locked,
    @Default(true) bool visible,
    String? clipPathId,
    String? maskId,
  }) = VxRect;

  const factory VxElement.ellipse({
    required String id,
    String? artboardId,
    required double cx,
    required double cy,
    required double rx,
    required double ry,
    @Matrix4Converter() required Matrix4 transform,
    required VxFill fill,
    required VxStroke stroke,
    @Default(1.0) double opacity,
    @Default(false) bool locked,
    @Default(true) bool visible,
    String? clipPathId,
    String? maskId,
  }) = VxEllipse;

  const factory VxElement.path({
    required String id,
    String? artboardId,
    required List<PathSegment> segments,
    @Matrix4Converter() required Matrix4 transform,
    required VxFill fill,
    required VxStroke stroke,
    @Default(1.0) double opacity,
    @Default(false) bool locked,
    @Default(true) bool visible,
    String? clipPathId,
    String? maskId,
  }) = VxPath;

  const factory VxElement.text({
    required String id,
    String? artboardId,
    required String content,
    required double x,
    required double y,
    @TextStyleConverter() required TextStyle style,
    @Default(TextAlign.start) TextAlign align,
    double? letterSpacing,
    double? wordSpacing,
    double? lineHeight,
    int? fontWeightValue,
    FontStyle? fontStyle,
    @Default(1) int maxLines,
    @Matrix4Converter() required Matrix4 transform,
    @Default(1.0) double opacity,
    @Default(false) bool locked,
    @Default(true) bool visible,
    String? clipPathId,
    String? maskId,
  }) = VxText;

  const factory VxElement.group({
    required String id,
    String? artboardId,
    required List<VxElement> children,
    @Matrix4Converter() required Matrix4 transform,
    @Default(1.0) double opacity,
    @Default(false) bool locked,
    @Default(true) bool visible,
    String? clipPathId,
    String? maskId,
  }) = VxGroup;

  const factory VxElement.compound({
    required String id,
    String? artboardId,
    required int operation, // 0: difference, 1: intersect, 2: union, 3: xor
    required List<VxElement> children,
    @Matrix4Converter() required Matrix4 transform,
    required VxFill fill,
    required VxStroke stroke,
    @Default(1.0) double opacity,
    @Default(false) bool locked,
    @Default(true) bool visible,
    String? clipPathId,
    String? maskId,
  }) = VxCompound;

  const factory VxElement.use({
    required String id,
    String? artboardId,
    required String href, // the ID of the symbol/element to instantiate
    @Matrix4Converter() required Matrix4 transform,
    @Default(1.0) double opacity,
    @Default(false) bool locked,
    @Default(true) bool visible,
    String? clipPathId,
    String? maskId,
  }) = VxUse;

  const factory VxElement.symbol({
    required String id,
    String? artboardId,
    required List<VxElement> children,
    // Symbols don't render themselves directly, only when instantiated via VxUse.
    @Matrix4Converter() required Matrix4 transform,
    @Default(1.0) double opacity,
    @Default(false) bool locked,
    @Default(true) bool visible,
    String? clipPathId,
    String? maskId,
  }) = VxSymbol;

  factory VxElement.fromJson(Map<String, dynamic> json) => _$VxElementFromJson(json);
}
