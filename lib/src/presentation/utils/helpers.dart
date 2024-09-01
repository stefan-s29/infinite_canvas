import 'dart:ui';

double adjustEdgeToGrid(double rawOffsetEdge, double gridEdge,
    {double? minimum, double? maximum}) {
  double snappedBound = (rawOffsetEdge / gridEdge).roundToDouble() * gridEdge;
  if (minimum != null && snappedBound < minimum) {
    return minimum;
  }
  if (maximum != null && snappedBound > maximum) {
    return maximum;
  }
  return snappedBound;
}

double enforceBounds(double value, double min, double max) {
  if (value > max) return max;
  if (value < min) return min;
  return value;
}

Size enforceBoundsOnSize(Size value, Size min, Size max) {
  return Size(enforceBounds(value.width, min.width, max.width),
      enforceBounds(value.height, min.height, max.height));
}
