import 'dart:ui';

import 'package:infinite_canvas/src/domain/model/node_rect.dart';
import 'package:infinite_canvas/src/shared/model/drag_handle_alignment.dart';
import 'package:infinite_canvas/src/shared/utils/helpers.dart';

/// Class to handle resizing of nodes while snapping to the grid
/// and respecting the min/max node size
class ResizeHelper {
  ResizeHelper(
      this.gridSize, Size minimumNodeSize, Size maximumNodeSize, this.snapMode,
      {this.changeableEdges})
      : minimumSizeOnGrid = _getMinimumSizeOnGrid(gridSize, minimumNodeSize),
        maximumSizeOnGrid = _getMaximumSizeOnGrid(gridSize, maximumNodeSize);

  final Size gridSize;
  final Size minimumSizeOnGrid;
  final Size? maximumSizeOnGrid;

  /// If changeableEdges is null, all 4 edges can be moved equally
  final DragHandleAlignment? changeableEdges;
  final ResizeSnapMode snapMode;

  /// Returns a new NodeRect object for the given NodeRect object
  /// that is resized to align with the grid, respecting the minimum
  /// and maximum node size
  NodeRect getRectResizedToGrid(NodeRect originalRect) {
    NodeRect resizedRect = _getRectResizedToGridIgnoringBounds(originalRect);
    return _getNewRectWithinBoundsOnGrid(resizedRect, originalRect);
  }

  NodeRect _getRectResizedToGridIgnoringBounds(NodeRect originalRect) {
    final roundingModeLeft = _getRoundingModeForSnapMode(
        snapMode, originalRect.left,
        leftOrTop: true);
    final roundingModeTop = _getRoundingModeForSnapMode(
        snapMode, originalRect.top,
        leftOrTop: true);
    final roundingModeRight = _getRoundingModeForSnapMode(
        snapMode, originalRect.right,
        leftOrTop: false);
    final roundingModeBottom = _getRoundingModeForSnapMode(
        snapMode, originalRect.bottom,
        leftOrTop: false);

    final newLeft = adjustEdgeToGrid(originalRect.left, gridSize.width,
        roundingMode: roundingModeLeft);
    final newTop = adjustEdgeToGrid(originalRect.top, gridSize.height,
        roundingMode: roundingModeTop);
    final newRight = adjustEdgeToGrid(originalRect.right, gridSize.width,
        roundingMode: roundingModeRight);
    final newBottom = adjustEdgeToGrid(originalRect.bottom, gridSize.height,
        roundingMode: roundingModeBottom);

    if (changeableEdges != null) {
      return originalRect.copyWith(
          left: changeableEdges!.isLeft ? newLeft : null,
          top: changeableEdges!.isTop ? newTop : null,
          right: changeableEdges!.isRight ? newRight : null,
          bottom: changeableEdges!.isBottom ? newBottom : null);
    }
    return NodeRect.fromLTRB(newLeft, newTop, newRight, newBottom);
  }

  RoundingMode _getRoundingModeForSnapMode(
      ResizeSnapMode snapMode, double value,
      {bool leftOrTop = true}) {
    switch (snapMode) {
      case ResizeSnapMode.closest:
        return RoundingMode.closest;
      case ResizeSnapMode.grow:
        // Left and top coordinates need to decrease (floor)
        // for the rectangle to get bigger;
        // Right and bottom coordinates need to increase (ceil)
        return leftOrTop ? RoundingMode.floor : RoundingMode.ceil;
      case ResizeSnapMode.shrink:
        // Left and top coordinates need to increase (ceil)
        // for the rectangle to get smaller;
        // Right and bottom coordinates need to decrease (floor)
        return leftOrTop ? RoundingMode.ceil : RoundingMode.floor;
    }
  }

  NodeRect _getNewRectWithinBoundsOnGrid(
      NodeRect rectOnGrid, NodeRect originalRect) {
    double newWidth = enforceBounds(
        rectOnGrid.width, minimumSizeOnGrid.width, maximumSizeOnGrid?.width);
    double newHeight = enforceBounds(
        rectOnGrid.height, minimumSizeOnGrid.height, maximumSizeOnGrid?.height);

    if (newWidth != rectOnGrid.width) {
      // If the resized width did not satisfy the constraints, either the left
      // or the right edge needs to be moved accordingly, depending on which
      // edge is changeable and which original edge is closer to the next grid line
      if ((changeableEdges == null &&
              rectOnGrid.isLeftBoundCloserThanRight(originalRect)) ||
          changeableEdges!.isRight) {
        rectOnGrid.right = rectOnGrid.left + newWidth;
      } else {
        rectOnGrid.left = rectOnGrid.right - newWidth;
      }
    }

    if (newHeight != rectOnGrid.height) {
      // If the resized height did not satisfy the constraints, either the top
      // or the bottom edge needs to be moved accordingly, depending on which
      // edge is changeable and which original edge is closer to the next grid line
      if ((changeableEdges == null &&
              rectOnGrid.isTopBoundCloserThanBottom(originalRect)) ||
          changeableEdges!.isBottom) {
        rectOnGrid.bottom = rectOnGrid.top + newHeight;
      } else {
        rectOnGrid.top = rectOnGrid.bottom - newHeight;
      }
    }

    return rectOnGrid;
  }

  static Size _getMinimumSizeOnGrid(Size gridSize, Size? minimumNodeSize) {
    if (minimumNodeSize == null) {
      return Size(gridSize.width, gridSize.height);
    }
    final minWidth = minimumNodeSize.width <= gridSize.width
        ? gridSize.width
        : adjustEdgeToGrid(minimumNodeSize.width, gridSize.width,
            roundingMode: RoundingMode.ceil);
    final minHeight = minimumNodeSize.height <= gridSize.height
        ? gridSize.height
        : adjustEdgeToGrid(minimumNodeSize.height, gridSize.height,
            roundingMode: RoundingMode.ceil);
    return Size(minWidth, minHeight);
  }

  static Size? _getMaximumSizeOnGrid(Size gridSize, Size? maximumNodeSize) {
    if (maximumNodeSize == null) {
      return null;
    }
    // If the maximum node size is smaller than the grid size
    // we still return the maximum node size
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
