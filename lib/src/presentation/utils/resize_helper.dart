import 'dart:ui';

import 'package:infinite_canvas/src/domain/model/node_rect.dart';

import 'helpers.dart';

class ResizeHelper {
  ResizeHelper(
      this.gridSize, this.minimumNodeSize, this.maximumNodeSize, this.snapMode)
      : minimumSizeOnGrid = _getMinimumSizeOnGrid(gridSize, minimumNodeSize),
        maximumSizeOnGrid = _getMaximumSizeOnGrid(gridSize, maximumNodeSize);

  final Size gridSize;
  final Size? minimumNodeSize;
  final Size? maximumNodeSize;
  final ResizeSnapMode snapMode;

  final Size minimumSizeOnGrid;
  final Size? maximumSizeOnGrid;

  /// Returns a new NodeRect object for the given NodeRect object
  /// that is resized to align with the grid, respecting the minimum
  /// and maximum node size
  NodeRect getRectResizedToGrid(NodeRect originalRect) {
    NodeRect resizedRect = _getRectResizedToGridIgnoringBounds(originalRect);
    return _fitResizedRectWithinBounds(resizedRect, originalRect);
  }

  NodeRect _getRectResizedToGridIgnoringBounds(NodeRect originalRect) {
    final leftAndTopRoundingMode =
        _getRoundingModeForSnapMode(snapMode, leftOrTop: true);
    final rightAndBottomRoundingMode =
        _getRoundingModeForSnapMode(snapMode, leftOrTop: false);

    final newLeft = adjustEdgeToGrid(originalRect.left, gridSize.width,
        roundingMode: leftAndTopRoundingMode);
    final newTop = adjustEdgeToGrid(originalRect.top, gridSize.height,
        roundingMode: leftAndTopRoundingMode);
    final newRight = adjustEdgeToGrid(originalRect.right, gridSize.width,
        roundingMode: rightAndBottomRoundingMode);
    final newBottom = adjustEdgeToGrid(originalRect.bottom, gridSize.height,
        roundingMode: rightAndBottomRoundingMode);

    return NodeRect.fromLTRB(newLeft, newTop, newRight, newBottom);
  }

  RoundingMode _getRoundingModeForSnapMode(ResizeSnapMode snapMode,
      {bool leftOrTop = true}) {
    switch (snapMode) {
      case ResizeSnapMode.closest:
        return RoundingMode.closest;
      case ResizeSnapMode.grow:
        return leftOrTop ? RoundingMode.floor : RoundingMode.ceil;
      case ResizeSnapMode.shrink:
        return leftOrTop ? RoundingMode.ceil : RoundingMode.floor;
    }
  }

  NodeRect _fitResizedRectWithinBounds(
      NodeRect resizedRect, NodeRect originalRect) {
    NodeRect newRect =
        _getNewBoundsWithMinimumSizeOnGrid(resizedRect, originalRect);
    if (maximumSizeOnGrid != null) {
      newRect = _getNewBoundsWithMaximumSizeOnGrid(newRect, originalRect);
    }
    return newRect;
  }

  /// Extends the resized rect in steps of gridSize if it is too small,
  /// starting on the side where the rect is closer to the original one
  NodeRect _getNewBoundsWithMinimumSizeOnGrid(
      NodeRect rectOnGrid, NodeRect originalRect) {
    NodeRect newRect = rectOnGrid.copyWith();
    while (newRect.width < minimumSizeOnGrid.width) {
      if (newRect.isLeftBoundCloserThanRight(originalRect)) {
        newRect.right += gridSize.width;
      } else {
        newRect.left -= gridSize.width;
      }
    }
    while (newRect.height < minimumSizeOnGrid.height) {
      if (newRect.isTopBoundCloserThanBottom(originalRect)) {
        newRect.bottom += gridSize.height;
      } else {
        newRect.top -= gridSize.height;
      }
    }
    return newRect;
  }

  /// Shrinks the resized rect in steps of gridSize if it is too large,
  /// starting on the side where the edge is closer to the original one
  NodeRect _getNewBoundsWithMaximumSizeOnGrid(
      NodeRect rectOnGrid, NodeRect originalRect) {
    if (maximumSizeOnGrid == null) return rectOnGrid;

    NodeRect newRect = rectOnGrid.copyWith();
    while (newRect.width > maximumSizeOnGrid!.width) {
      if (newRect.isLeftBoundCloserThanRight(originalRect)) {
        newRect.right -= gridSize.width;
      } else {
        newRect.left += gridSize.width;
      }
    }
    while (newRect.height > maximumSizeOnGrid!.height) {
      if (newRect.isTopBoundCloserThanBottom(originalRect)) {
        newRect.bottom -= gridSize.height;
      } else {
        newRect.top += gridSize.height;
      }
    }
    return newRect;
  }

  static Size _getMinimumSizeOnGrid(Size gridSize, Size? minimumNodeSize) {
    final minWidth =
        (minimumNodeSize == null || minimumNodeSize.width <= gridSize.width)
            ? gridSize.width
            : gridSize.width * 2;
    final minHeight =
        (minimumNodeSize == null || minimumNodeSize.height <= gridSize.height)
            ? gridSize.height
            : gridSize.height * 2;
    return Size(minWidth, minHeight);
  }

  static Size? _getMaximumSizeOnGrid(Size gridSize, Size? maximumNodeSize) {
    if (maximumNodeSize == null) {
      return null;
    }
    final maxWidth = maximumNodeSize.width <= gridSize.width
        ? maximumNodeSize.width
        : adjustEdgeToGrid(maximumNodeSize.width, gridSize.width,
            roundingMode: RoundingMode.floor);
    final maxHeight = maximumNodeSize.height <= gridSize.height
        ? maximumNodeSize.height
        : adjustEdgeToGrid(maximumNodeSize.height, gridSize.height,
            roundingMode: RoundingMode.floor);
    return Size(maxWidth, maxHeight);
  }
}
