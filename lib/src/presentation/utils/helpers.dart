import 'dart:ui';

import 'package:infinite_canvas/src/domain/model/node_rect.dart';

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

bool exceedsLimit(Size checkedSize, {Size? minimum, Size? maximum}) {
  if (minimum != null &&
      (checkedSize.width < minimum.width ||
          checkedSize.height < minimum.height)) return true;
  if (maximum != null &&
      (checkedSize.width > maximum.width ||
          checkedSize.height > maximum.height)) return true;
  return false;
}

double enforceBounds(double value, double? min, double? max) {
  if (max != null && value > max) return max;
  if (min != null && value < min) return min;
  return value;
}

extension SizeWithinBounds on Size {
  bool isWithinBounds({Size? min, Size? max}) {
    return (min == null || (width >= min.width && height >= min.height)) &&
        (max == null || (width <= max.width && height <= max.height));
  }

  Size adjustToBounds({Size? min, Size? max}) {
    final newWidth = enforceBounds(width, min?.width, max?.width);
    final newHeight = enforceBounds(height, min?.height, max?.height);
    return Size(newWidth, newHeight);
  }
}
