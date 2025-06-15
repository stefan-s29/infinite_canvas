import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:infinite_canvas/src/shared/model/changeable_edges.dart';
import 'package:infinite_canvas/src/shared/utils/helpers.dart';

import '../utils/edge_type.dart';

typedef TransformerFunction = double Function(double, EdgeType);

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

  /// Returns a copy of the rectangle that is resized by resizeOffset
  /// by moving the edges selected by changeableEdges
  NodeRect resize(Offset resizeOffset, ChangeableEdges changeableEdges) {
    return copyWith(
        left: changeableEdges.left ? min(right, left + resizeOffset.dx) : null,
        top: changeableEdges.top ? min(bottom, top + resizeOffset.dy) : null,
        right:
            changeableEdges.right ? max(left, right + resizeOffset.dx) : null,
        bottom:
            changeableEdges.bottom ? max(top, bottom + resizeOffset.dy) : null);
  }

  /// Returns a copy of the rectangle where each coordinate property is defined
  /// by applying a given transformer function on the original coordinate
  NodeRect transform(TransformerFunction transformer,
      {ChangeableEdges changedEdges = ChangeableEdges.all}) {
    return copyWith(
        left: changedEdges.left ? transformer(left, EdgeType.left) : null,
        top: changedEdges.top ? transformer(top, EdgeType.top) : null,
        right: changedEdges.right ? transformer(right, EdgeType.right) : null,
        bottom:
            changedEdges.bottom ? transformer(bottom, EdgeType.bottom) : null);
  }

  /// Returns a copy of the rectangle that satisfies the given min/max
  /// constraints by moving either the left or right and either
  /// the top or bottom edge
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

  /// Returns the position on the grid defined by the given gridSize with the
  /// minimum distance to the top left or bottom right corner of the rectangle
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

  /// Returns true if the left bounds of this and the other given rectangle
  /// are closer to each other than the right bounds
  bool isLeftBoundCloserThanRight(NodeRect otherBounds) {
    return (otherBounds.left - left).abs() < (otherBounds.right - right).abs();
  }

  /// Returns true if the top bounds of this and the other given rectangle
  /// are closer to each other than the bottom bounds
  bool isTopBoundCloserThanBottom(NodeRect otherBounds) {
    return (otherBounds.top - top).abs() < (otherBounds.bottom - bottom).abs();
  }
}

enum PositioningSnapMode { closest, start, end }

enum ResizeSnapMode { closest, shrink, grow }
