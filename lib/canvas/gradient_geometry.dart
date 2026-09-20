import 'dart:math' as math;
import 'dart:ui';

import '../models/vx_element.dart';

/// A linear gradient resolved into element-local coordinates.
class LinearGradientGeometry {
  const LinearGradientGeometry(this.from, this.to);

  final Offset from;
  final Offset to;
}

/// A radial gradient resolved into element-local coordinates.
class RadialGradientGeometry {
  const RadialGradientGeometry(this.center, this.radius);

  final Offset center;
  final double radius;
}

/// Resolves a model gradient against an element's bounds.
///
/// SVG expresses gradient geometry either as absolute element-local
/// coordinates (`userSpaceOnUse`) or as fractions of the element's bounding box
/// (`objectBoundingBox`, the SVG default, which scales with the shape).
///
/// The painter used to ignore the gradient's geometry entirely and always swept
/// horizontally across the bounds, so gradients neither matched the authored
/// direction nor agreed with the exported SVG (finding P0-5). The PDF exporter
/// had the same problem. Both now resolve through here, and the logic is unit
/// tested rather than buried inside a paint call.
class GradientGeometry {
  const GradientGeometry._();

  static LinearGradientGeometry linear(LinearFill fill, Rect bounds) {
    if (fill.units == GradientUnits.userSpaceOnUse || bounds.isEmpty) {
      return LinearGradientGeometry(fill.start, fill.end);
    }
    return LinearGradientGeometry(
      _map(fill.start, bounds),
      _map(fill.end, bounds),
    );
  }

  static RadialGradientGeometry radial(RadialFill fill, Rect bounds) {
    if (fill.units == GradientUnits.userSpaceOnUse || bounds.isEmpty) {
      return RadialGradientGeometry(fill.center, fill.radius);
    }
    // A unit-space radius maps onto the bounding box's normalized diagonal.
    final diagonal =
        math.sqrt(bounds.width * bounds.width + bounds.height * bounds.height) /
            math.sqrt2;
    return RadialGradientGeometry(
      _map(fill.center, bounds),
      fill.radius * diagonal,
    );
  }

  static Offset _map(Offset fraction, Rect bounds) => Offset(
    bounds.left + fraction.dx * bounds.width,
    bounds.top + fraction.dy * bounds.height,
  );

  /// Stop offsets clamped to 0..1 and forced to be non-decreasing, as both
  /// Skia's gradient API and the PDF shading API require. SVG specifies that an
  /// offset below its predecessor is raised to it.
  static List<double> stopOffsets(List<ColorStop> stops) {
    final offsets = <double>[];
    var previous = 0.0;
    for (final stop in stops) {
      var value = stop.offset.clamp(0.0, 1.0);
      if (value < previous) value = previous;
      offsets.add(value);
      previous = value;
    }
    return offsets;
  }

  static List<Color> stopColors(List<ColorStop> stops) =>
      [for (final stop in stops) stop.color];
}
