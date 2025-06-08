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

    if (changeableEdges != null) {
      return originalRect.copyWith(
          left: changeableEdges!.isLeft ? newLeft : null,
          top: changeableEdges!.isTop ? newTop : null,
          right: changeableEdges!.isRight ? newRight : null,
          bottom: changeableEdges!.isBottom ? newBottom : null);
    }
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

  NodeRect _getNewRectWithinBoundsOnGrid(
      NodeRect rectOnGrid, NodeRect originalRect) {
    double newWidth = enforceBounds(
        rectOnGrid.width, minimumSizeOnGrid.width, maximumSizeOnGrid?.width);
    double newHeight = enforceBounds(
        rectOnGrid.height, minimumSizeOnGrid.height, maximumSizeOnGrid?.height);

    if (newWidth != rectOnGrid.width) {
      if ((changeableEdges == null &&
              rectOnGrid.isLeftBoundCloserThanRight(originalRect)) ||
          changeableEdges!.isRight) {
        rectOnGrid.right = rectOnGrid.left + newWidth;
      } else {
        rectOnGrid.left = rectOnGrid.right - newWidth;
      }
    }

    if (newHeight != rectOnGrid.height) {
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
