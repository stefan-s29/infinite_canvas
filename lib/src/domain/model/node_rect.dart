import 'dart:ui';

import 'package:infinite_canvas/src/presentation/utils/helpers.dart';

/// A representation of the offset and size of a node;
/// in contrast to the Rect class, the 4 main attributes are changeable here
class NodeRect {
  NodeRect.fromLTRB(this.left, this.top, this.right, this.bottom);

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

  double get width => right - left;
  double get height => bottom - top;
  Offset get offset => Offset(left, top);
  set offset(Offset offset) {
    left = offset.dx;
    top = offset.dy;
  }

  Size get size => Size(width, height);
  set size(Size size) {
    right = left + size.width;
    bottom = top + size.height;
  }

  Rect toRect() {
    return Rect.fromLTRB(left, top, right, bottom);
  }

  NodeRect copyWith(
      {double? left, double? top, double? right, double? bottom}) {
    return NodeRect.fromLTRB(left ?? this.left, top ?? this.top,
        right ?? this.right, bottom ?? this.bottom);
  }

  NodeRect adjustToBounds(Size min, Size max) {
    final adjustedSize = size.adjustToBounds(min: min, max: max);
    return NodeRect.fromOffsetAndSize(offset, adjustedSize);
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

  NodeRect getNewBoundsResizedToGrid(Size gridSize) {
    final minimumSize = _getMinimumSizeToFitGrid(gridSize, minimumNodeSize);
    final leftOrTopRoundingMode = _getRoundingModeForSnapMode(snapMode, true);
    final rightOrBottomRoundingMode =
        _getRoundingModeForSnapMode(snapMode, false);

    NodeRect newBounds = NodeRect.fromLTRB(
        adjustEdgeToGrid(left, gridSize.width,
            roundingMode: leftOrTopRoundingMode),
        adjustEdgeToGrid(top, gridSize.height,
            roundingMode: leftOrTopRoundingMode),
        adjustEdgeToGrid(right, gridSize.width,
            roundingMode: rightOrBottomRoundingMode),
        adjustEdgeToGrid(bottom, gridSize.height,
            roundingMode: rightOrBottomRoundingMode));
    newBounds = extendBoundsGridWiseToRiseAboveMinimum(
        newBounds, currentBounds, minimumSize, gridSize);
  }

  bool isLeftBoundCloserThanRight(NodeRect otherBounds) {
    return (otherBounds.left - left).abs() <= (otherBounds.right - right).abs();
  }

  bool isTopBoundCloserThanBottom(NodeRect otherBounds) {
    return (otherBounds.top - top).abs() <= (otherBounds.bottom - bottom).abs();
  }

  /// Returns new bounds that fulfill the given minimum size
  /// by extending the current bounds in steps of gridSize
  /// on the side where the bound is closer to the original one
  NodeRect getNewBoundsWithMinimumSizeOnGrid(
      NodeRect originalBounds, Size minimumSize, Size gridSize) {
    NodeRect newBounds = copyWith();
    while (width < minimumSize.width) {
      if (isLeftBoundCloserThanRight(originalBounds)) {
        newBounds.right += gridSize.width;
      } else {
        newBounds.left -= gridSize.width;
      }
    }
    while (height < minimumSize.height) {
      if (isTopBoundCloserThanBottom(originalBounds)) {
        newBounds.bottom += gridSize.height;
      } else {
        newBounds.top -= gridSize.height;
      }
    }
    return newBounds;
  }

  /// Returns new bounds that fulfill the given maximum size
  /// by shrinking the current bounds in steps of gridSize
  /// on the side where the bound is closer to the original one
  NodeRect getNewBoundsWithMaximumSizeOnGrid(
      NodeRect originalBounds, Size maximumSize, Size gridSize) {
    NodeRect newBounds = copyWith();
    while (width > maximumSize.width) {
      if (isLeftBoundCloserThanRight(originalBounds)) {
        newBounds.right -= gridSize.width;
      } else {
        newBounds.left += gridSize.width;
      }
    }
    while (height > maximumSize.height) {
      if (isTopBoundCloserThanBottom(originalBounds)) {
        newBounds.bottom -= gridSize.height;
      } else {
        newBounds.top += gridSize.height;
      }
    }
    return newBounds;
  }
}

enum PositioningSnapMode { closest, start, end }

enum ResizeSnapMode { closest, shrink, grow }
