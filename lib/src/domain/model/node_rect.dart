import 'dart:ui';

import 'package:infinite_canvas/src/shared/utils/helpers.dart';

import '../utils/resize_helper.dart';

/// A representation of the offset and size of a node;
/// in contrast to the Rect class, the 4 main attributes are changeable here
class NodeRect {
  NodeRect.fromLTRB(double left, double top, double right, double bottom)
      : left = left <= right ? left : right,
        right = left <= right ? right : left,
        top = top <= bottom ? top : bottom,
        bottom = top <= bottom ? bottom : top;

  NodeRect.fromLTWH(this.left, this.top, double width, double height)
      : right = left + width,
        bottom = top + height;

  NodeRect.fromRect(Rect rect)
      : left = rect.left,
        top = rect.top,
        right = rect.right,
        bottom = rect.bottom;

  NodeRect.fromOffsetAndSize(Offset offset, Size size)
      : left = offset.dx,
        top = offset.dy,
        right = offset.dx + size.width,
        bottom = offset.dy + size.height;

  double left;
  double top;
  double right;
  double bottom;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeRect &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          top == other.top &&
          right == other.right &&
          bottom == other.bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() {
    return 'NodeRect(left: $left, top: $top, right: $right, bottom: $bottom)';
  }

  double get width => right - left;
  double get height => bottom - top;

  Offset get offset => Offset(left, top);
  set offset(Offset newOffset) {
    final oldWidth = width;
    final oldHeight = height;
    left = newOffset.dx;
    top = newOffset.dy;
    right = newOffset.dx + oldWidth;
    bottom = newOffset.dy + oldHeight;
  }

  Size get size => Size(width, height);
  set size(Size size) {
    right = left + size.width;
    bottom = top + size.height;
  }

  Offset get topLeft => Offset(left, top);
  Offset get topRight => Offset(right, top);
  Offset get bottomLeft => Offset(left, bottom);
  Offset get bottomRight => Offset(right, bottom);

  Rect toRect() {
    return Rect.fromLTRB(left, top, right, bottom);
  }

  NodeRect copyWith(
      {double? left, double? top, double? right, double? bottom}) {
    return NodeRect.fromLTRB(left ?? this.left, top ?? this.top,
        right ?? this.right, bottom ?? this.bottom);
  }

  NodeRect adjustToBounds(Size min, Size max,
      {bool moveLeftEdge = false, bool moveTopEdge = false}) {
    final adjustedSize = size.adjustToBounds(min: min, max: max);
    return copyWith(
      left: moveLeftEdge ? right - adjustedSize.width : null,
      top: moveTopEdge ? bottom - adjustedSize.height : null,
      right: !moveLeftEdge ? left + adjustedSize.width : null,
      bottom: !moveTopEdge ? top + adjustedSize.height : null,
    );
  }

  Offset getClosestSnapPosition(Size gridSize) {
    final snappedX =
        _getClosestSnapPositionForAxis(left, width, gridSize.width);
    final snappedY =
        _getClosestSnapPositionForAxis(top, height, gridSize.height);
    return Offset(snappedX, snappedY);
  }

  double _getClosestSnapPositionForAxis(
      double nodePosition, double nodeLength, double gridSpacing,
      {PositioningSnapMode snapMode = PositioningSnapMode.closest}) {
    final snapAtStartPos = adjustEdgeToGrid(nodePosition, gridSpacing);
    if (snapMode == PositioningSnapMode.start) {
      return snapAtStartPos;
    }

    final snapAtEndPos =
        adjustEdgeToGrid(nodePosition + nodeLength, gridSpacing) - nodeLength;
    if (snapMode == PositioningSnapMode.end) {
      return snapAtEndPos;
    }

    final snapAtStartDelta = (snapAtStartPos - nodePosition).abs();
    final snapAtEndDelta = (snapAtEndPos - nodePosition).abs();
    return snapAtEndDelta < snapAtStartDelta ? snapAtEndPos : snapAtStartPos;
  }

  NodeRect getRectResizedToGrid(Size gridSize, Size minimumNodeSize,
      Size maximumNodeSize, ResizeSnapMode snapMode) {
    final resizeHelper =
        ResizeHelper(gridSize, minimumNodeSize, maximumNodeSize, snapMode);
    return resizeHelper.getRectResizedToGrid(this);
  }

  bool isLeftBoundCloserThanRight(NodeRect otherBounds) {
    return (otherBounds.left - left).abs() <= (otherBounds.right - right).abs();
  }

  bool isTopBoundCloserThanBottom(NodeRect otherBounds) {
    return (otherBounds.top - top).abs() <= (otherBounds.bottom - bottom).abs();
  }
}

enum PositioningSnapMode { closest, start, end }

enum ResizeSnapMode { closest, shrink, grow }
