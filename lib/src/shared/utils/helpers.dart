import 'dart:ui';

enum RoundingMode { closest, floor, ceil }

/// allowMinAndMaxSizes: Allow the node to reach the min/max size
/// even if they are not on the grid?
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
  var snapped = quotientRounded * gridEdge;

  if (minimum != null && snapped < minimum) {
    if (allowMinAndMaxSizes) {
      return minimum;
    } else {
      snapped = snapped + gridEdge;
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

bool exceedsLimit(double checkedValue, {double? minimum, double? maximum}) {
  return (minimum != null && checkedValue < minimum) ||
      (maximum != null && checkedValue > maximum);
}

double getLimitDelta(double checkedValue, {double? minimum, double? maximum}) {
  if (minimum != null && checkedValue < minimum) {
    return checkedValue - minimum; // return a negative value if too small
  } else if (maximum != null && checkedValue > maximum) {
    return checkedValue - maximum; // return a positive value if too big
  }
  return 0;
}

bool exceedsSizeLimit(Size checkedSize, {Size? minimum, Size? maximum}) {
  return exceedsLimit(checkedSize.width,
          minimum: minimum?.width, maximum: maximum?.width) ||
      exceedsLimit(checkedSize.height,
          minimum: minimum?.height, maximum: maximum?.height);
}

double enforceBounds(double value, double? min, double? max) {
  if (max != null && value > max) return max;
  if (min != null && value < min) return min;
  return value;
}

extension SizeWithinBounds on Size {
  bool isWithinBounds({Size? min, Size? max}) {
    return !exceedsSizeLimit(this, minimum: min, maximum: max);
  }

  Size adjustToBounds({Size? min, Size? max}) {
    final newWidth = enforceBounds(width, min?.width, max?.width);
    final newHeight = enforceBounds(height, min?.height, max?.height);
    return Size(newWidth, newHeight);
  }
}
