import 'dart:ui';

import 'package:infinite_canvas/src/domain/model/node_rect.dart';
import 'package:infinite_canvas/src/shared/utils/helpers.dart';

import '../../shared/model/changeable_edges.dart';

/// Class to handle resizing of nodes while snapping to the grid
/// and respecting the min/max node size
class ResizeHelper {
  ResizeHelper(
      this.gridSize, this.minimumNodeSize, this.maximumNodeSize, this.snapMode,
      {this.changeableEdges = ChangeableEdges.all})
      : minimumSizeOnGrid = _getMinimumSizeOnGrid(gridSize, minimumNodeSize),
        maximumSizeOnGrid = _getMaximumSizeOnGrid(gridSize, maximumNodeSize);

  final Size gridSize;
  final Size minimumNodeSize;
  final Size maximumNodeSize;
  final Size minimumSizeOnGrid;
  final Size? maximumSizeOnGrid;

  /// If changeableEdges is null, all 4 edges can be moved equally
  final ChangeableEdges changeableEdges;
  final ResizeSnapMode snapMode;

  /// Returns a new NodeRect object for the given NodeRect object
  /// that is resized to align with the grid, respecting the minimum
  /// and maximum node size
  NodeRect getRectResizedToGrid(NodeRect originalRect) {
    NodeRect resizedRectIgnoringBounds = originalRect.transform(
        _adjustAllChangeableEdgesToGrid,
        changedEdges: changeableEdges);
    if (resizedRectIgnoringBounds.size
        .isWithinBounds(min: minimumNodeSize, max: maximumNodeSize)) {
      return resizedRectIgnoringBounds;
    }
    return _getNewRectWithinBoundsOnGrid(
        resizedRectIgnoringBounds, originalRect);
  }

  double _adjustAllChangeableEdgesToGrid(edgePos, {required bool leftOrTop}) {
    return adjustEdgeToGrid(edgePos, gridSize.width,
        roundingMode: _getRoundingModeForSnapMode(snapMode, edgePos,
            leftOrTop: leftOrTop));
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
      NodeRect resizedRect, NodeRect originalRect) {
    final rectOnGridIfChangeable = originalRect.copyWith(
        left: changeableEdges.left ? resizedRect.left : null,
        top: changeableEdges.top ? resizedRect.top : null,
        right: changeableEdges.right ? resizedRect.right : null,
        bottom: changeableEdges.bottom ? resizedRect.bottom : null);

    final widthConstraintsDelta = getLimitDelta(rectOnGridIfChangeable.width,
        minimum: minimumNodeSize.width, maximum: maximumNodeSize.width);
    final heightConstraintsDelta = getLimitDelta(rectOnGridIfChangeable.height,
        minimum: minimumNodeSize.height, maximum: maximumNodeSize.height);

    if (widthConstraintsDelta != 0) {
      // If the resized width did not satisfy the constraints, either the left
      // or the right edge needs to be moved accordingly. Default is right edge.
      bool adjustLeft = false;
      final adjustedLeft = adjustEdgeToGrid(
          widthConstraintsDelta > 0
              ? resizedRect.right - maximumNodeSize.width
              : resizedRect.right - minimumNodeSize.width,
          gridSize.width,
          minimum: resizedRect.right - maximumNodeSize.width,
          maximum: resizedRect.right - minimumNodeSize.width);
      final adjustedRight = adjustEdgeToGrid(
          widthConstraintsDelta > 0
              ? resizedRect.left + minimumNodeSize.width
              : resizedRect.left + maximumNodeSize.width,
          gridSize.width,
          minimum: resizedRect.left + minimumNodeSize.width,
          maximum: resizedRect.left + maximumNodeSize.width);
      final adjustedBounds = rectOnGridIfChangeable.copyWith(
          left: adjustedLeft, right: adjustedRight);

      if (changeableEdges.left) {
        if (changeableEdges.right) {
          // Both edges are changeable: Which original edge needs to be moved
          // less far to satisfy the constraint?
          adjustLeft = adjustedBounds.isLeftBoundCloserThanRight(originalRect);
        } else {
          adjustLeft = true;
        }
      }

      if (adjustLeft) {
        rectOnGridIfChangeable.left = adjustedBounds.left;
      } else {
        rectOnGridIfChangeable.right = adjustedBounds.right;
      }
    }

    if (heightConstraintsDelta != 0) {
      // If the resized height did not satisfy the constraints, either the top
      // or the bottom edge needs to be moved accordingly. Default is bottom edge.
      bool adjustTop = false;
      final adjustedTop = adjustEdgeToGrid(
          heightConstraintsDelta > 0
              ? resizedRect.bottom - maximumNodeSize.height
              : resizedRect.bottom - minimumNodeSize.height,
          gridSize.height,
          minimum: resizedRect.bottom - maximumNodeSize.height,
          maximum: resizedRect.bottom - minimumNodeSize.height);
      final adjustedBottom = adjustEdgeToGrid(
          heightConstraintsDelta > 0
              ? resizedRect.top + minimumNodeSize.height
              : resizedRect.top + maximumNodeSize.height,
          gridSize.height,
          minimum: resizedRect.top + minimumNodeSize.height,
          maximum: resizedRect.top + maximumNodeSize.height);
      final adjustedBounds = rectOnGridIfChangeable.copyWith(
          top: adjustedTop, bottom: adjustedBottom);

      if (changeableEdges.top) {
        if (changeableEdges.bottom) {
          // Both edges are changeable: Which original edge needs to be moved
          // less far to satisfy the constraint?
          adjustTop = adjustedBounds.isTopBoundCloserThanBottom(originalRect);
        } else {
          adjustTop = true;
        }
      }

      if (adjustTop) {
        resizedRect.top = adjustedBounds.top;
      } else {
        resizedRect.bottom = adjustedBounds.bottom;
      }
    }

    return rectOnGridIfChangeable;
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
