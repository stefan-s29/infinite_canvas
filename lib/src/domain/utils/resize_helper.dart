import 'dart:ui';

import 'package:infinite_canvas/src/domain/model/node_rect.dart';
import 'package:infinite_canvas/src/shared/utils/helpers.dart';

import '../../shared/model/changeable_edges.dart';

/// Class to handle resizing of nodes while snapping to the grid
/// and respecting the min/max node size
class ResizeHelper {
  ResizeHelper(this.gridSize, this.minNodeSize, this.maxNodeSize, this.snapMode,
      {this.changeableEdges = ChangeableEdges.all});

  final Size gridSize;
  final Size minNodeSize;
  final Size maxNodeSize;

  /// If changeableEdges is null, all 4 edges can be moved equally
  final ChangeableEdges changeableEdges;
  final ResizeSnapMode snapMode;

  /// Returns a new NodeRect object for the given NodeRect object
  /// that is resized to align with the grid, respecting the minimum
  /// and maximum node size
  NodeRect getRectResizedToGrid(NodeRect originalRect) {
    NodeRect snappedRectIgnoringConstraints = originalRect.transform(
        _adjustAllChangeableEdgesToGrid,
        changedEdges: changeableEdges);

    if (snappedRectIgnoringConstraints.size
        .isWithinBounds(min: minNodeSize, max: maxNodeSize)) {
      return snappedRectIgnoringConstraints;
    }
    return _adjustRectOnGridToConstraints(
      snappedRectIgnoringConstraints,
      originalRect,
    );
  }

  double _adjustAllChangeableEdgesToGrid(edgePos,
      {required bool leftOrTop, required bool horizontal}) {
    final gridEdge = horizontal ? gridSize.width : gridSize.height;
    final roundingMode =
        _getRoundingModeForSnapMode(snapMode, edgePos, leftOrTop: leftOrTop);
    return adjustEdgeToGrid(edgePos, gridEdge, roundingMode: roundingMode);
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

  NodeRect _adjustRectOnGridToConstraints(
      NodeRect snappedRect, NodeRect originalRect) {
    final widthConstraintsDelta = getConstraintDelta(
      snappedRect.width,
      minimum: minNodeSize.width,
      maximum: maxNodeSize.width,
    );
    final heightConstraintsDelta = getConstraintDelta(
      snappedRect.height,
      minimum: minNodeSize.height,
      maximum: maxNodeSize.height,
    );

    calcMovedEdgeCandidate(double snappedEdgePos,
        {required bool leftOrTop, required bool horizontal}) {
      if (horizontal) {
        if (widthConstraintsDelta == 0) {
          return snappedEdgePos;
        }
        return _moveEdgeOnGridToSatisfyConstraint(
            snappedEdgePos, gridSize.width, widthConstraintsDelta, leftOrTop);
      } else if (heightConstraintsDelta == 0) {
        return snappedEdgePos;
      }
      return _moveEdgeOnGridToSatisfyConstraint(
          snappedEdgePos, gridSize.height, heightConstraintsDelta, leftOrTop);
    }

    final allMovedEdgeCandidates = snappedRect.transform(
      calcMovedEdgeCandidate,
      changedEdges: changeableEdges,
    );
    return _selectMovedEdgeCandidates(
      allMovedEdgeCandidates,
      originalRect,
      snappedRect,
    );
  }

  /// Adjusts a coordinate value in steps of the grid edge size to satisfy
  /// an unsatisfied constraint
  ///
  /// constraintDelta: Negative if referenced rect is too small,
  ///                  positive if too large
  /// Left/Top: Value decreases if rect is too small, increases if too large
  /// Right/Bottom: Value increases if rect is too small, decreases if too large
  double _moveEdgeOnGridToSatisfyConstraint(double originalPos, double gridEdge,
      double constraintDelta, bool leftOrTop) {
    if (constraintDelta == 0) {
      return originalPos;
    }
    final bool isTooLarge = constraintDelta > 0;
    final int direction = leftOrTop ? -1 : 1;
    final constraintRefPos = originalPos - direction * constraintDelta;
    final distanceToRefPos = constraintRefPos - originalPos;
    final edgesNeeded = coverDistanceByGridEdges(distanceToRefPos, gridEdge,
        keepBelowDistance: isTooLarge);
    return originalPos + gridEdge * edgesNeeded;
  }

  /// Creates a new NodeRect where one calculated edge to satisfy the
  /// constraints is selected for each dimension (horizontal / vertical) so that
  ///   1. The constraints are still satisfied
  ///   2. Only changeable edges are moved
  ///   3. All changeable edges are snapped to the grid
  ///   4. Smaller movement distances are preferred for dimensions with both
  ///      sides changeable
  NodeRect _selectMovedEdgeCandidates(NodeRect edgesSatisfyingConstraints,
      NodeRect originalRect, NodeRect snappedRect) {
    final finalRect = edgesSatisfyingConstraints.copyWith();
    if (changeableEdges.left && changeableEdges.right) {
      // Both left and right edges are changeable: Only move the one with the
      // smaller moving distance, reset the other one to the snapped position
      if (edgesSatisfyingConstraints.isLeftBoundCloserThanRight(originalRect)) {
        finalRect.right = snappedRect.right;
      } else {
        finalRect.left = snappedRect.left;
      }
    }
    if (changeableEdges.top && changeableEdges.bottom) {
      // Both top and bottom edges are changeable: Only move the one with the
      // smaller moving distance, reset the other one to the snapped position
      if (edgesSatisfyingConstraints.isTopBoundCloserThanBottom(originalRect)) {
        finalRect.bottom = snappedRect.bottom;
      } else {
        finalRect.top = snappedRect.top;
      }
    }
    return finalRect;
  }
}
