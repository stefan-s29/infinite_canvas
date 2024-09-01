import 'dart:ui';

enum RoundingMode { closest, floor, ceil }

double adjustEdgeToGrid(double rawValue, double gridEdge,
    {double? minimum,
    double? maximum,
    bool allowMinAndMaxSizes = false,
    RoundingMode roundingMode = RoundingMode.closest}) {
  final quotient = rawValue / gridEdge;
  final quotientRounded = roundingMode == RoundingMode.closest
      ? quotient.round()
      : roundingMode == RoundingMode.ceil
          ? quotient.ceil()
          : quotient.floor();
  final snapped = quotientRounded * gridEdge;

  if (minimum != null && snapped < minimum) {
    if (allowMinAndMaxSizes) {
      return minimum;
    } else {
      return snapped + gridEdge;
    }
  }
  if (maximum != null && snapped > maximum) {
    if (allowMinAndMaxSizes) {
      return maximum;
    } else {
      return snapped - gridEdge;
    }
  }
  return snapped;
}

double enforceBounds(double value, double? min, double? max) {
  if (max != null && value > max) return max;
  if (min != null && value < min) return min;
  return value;
}

Size enforceBoundsOnSize(Size value, {Size? min, Size? max}) {
  return Size(enforceBounds(value.width, min?.width, max?.width),
      enforceBounds(value.height, min?.height, max?.height));
}
