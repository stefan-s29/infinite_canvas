import 'package:flutter/material.dart';
import 'package:infinite_canvas/src/presentation/utils/helpers.dart';

/// A node in the [InfiniteCanvas].
class InfiniteCanvasNode<T> {
  InfiniteCanvasNode({
    required this.key,
    Size? minimumNodeSize,
    required Size size,
    required this.offset,
    required this.child,
    this.label,
    this.resizeHandlesMode = ResizeHandlesMode.disabled,
    this.allowMove = true,
    this.clipBehavior = Clip.none,
    this.value,
  }) {
    setSize(size, minimumNodeSize);
  }

  String get id => key.toString();

  final LocalKey key;
  late Size _size;
  Size get size => _size;
  void setSize(Size value, Size? minimumNodeSize) {
    _size = enforceBoundsOnSize(value, min: minimumNodeSize);
  }

  late Offset offset;
  String? label;
  T? value;
  final Widget child;
  final ResizeHandlesMode resizeHandlesMode;
  bool currentlyResizing = false;
  final bool allowMove;
  final Clip clipBehavior;
  Rect get rect => offset & _size;
  static const double borderInset = 2;

  void update(
      {Size? size,
      Offset? offset,
      String? label,
      bool? setCurrentlyResizing,
      bool? snapMovementToGrid,
      Size? gridSize,
      Size? minimumNodeSize}) {
    if (setCurrentlyResizing != null) {
      currentlyResizing = setCurrentlyResizing;
    }

    if (offset != null && setCurrentlyResizing == true) {
      this.offset = offset;
    } else if (offset != null &&
        setCurrentlyResizing == null &&
        allowMove &&
        !currentlyResizing) {
      if (snapMovementToGrid == true && gridSize != null) {
        final snappedX = _getClosestSnapPosition(
            offset.dx, size?.width ?? this.size.width, gridSize.width);
        final snappedY = _getClosestSnapPosition(
            offset.dy, size?.height ?? this.size.height, gridSize.height);
        this.offset = Offset(snappedX, snappedY);
      } else {
        this.offset = offset;
      }
    }

    if (size != null && resizeHandlesMode.isEnabled) {
      setSize(size, minimumNodeSize);
    }
    if (label != null) this.label = label;

    if (minimumNodeSize != null &&
        (_size.width < minimumNodeSize.width ||
            _size.height < minimumNodeSize.height)) {
      setSize(_size, minimumNodeSize);
    }
  }

  void alignWithGrid(Size gridSize,
      {PositioningSnapMode snapMode = PositioningSnapMode.closest}) {
    final snappedX = _getClosestSnapPosition(
        offset.dx, size.width, gridSize.width,
        snapMode: snapMode);
    final snappedY = _getClosestSnapPosition(
        offset.dy, size.height, gridSize.height,
        snapMode: snapMode);
    this.offset = Offset(snappedX, snappedY);
  }

  void resizeToFitGrid(Size gridSize,
      {Size? minimumNodeSize,
      ResizeSnapMode snapMode = ResizeSnapMode.closest}) {
    final currentBounds = offset & size;

    final minimumSize = _getMinimumSizeToFitGrid(gridSize, minimumNodeSize);
    final leftOrTopRoundingMode = _getRoundingModeForSnapMode(snapMode, true);
    final rightOrBottomRoundingMode =
        _getRoundingModeForSnapMode(snapMode, false);

    Rect newBounds = Rect.fromLTRB(
        adjustEdgeToGrid(currentBounds.left, gridSize.width,
            roundingMode: leftOrTopRoundingMode),
        adjustEdgeToGrid(currentBounds.top, gridSize.height,
            roundingMode: leftOrTopRoundingMode),
        adjustEdgeToGrid(currentBounds.right, gridSize.width,
            roundingMode: rightOrBottomRoundingMode),
        adjustEdgeToGrid(currentBounds.bottom, gridSize.height,
            roundingMode: rightOrBottomRoundingMode));
    newBounds = extendBoundsGridWiseToRiseAboveMinimum(
        newBounds, currentBounds, minimumSize, gridSize);

    offset = newBounds.topLeft;
    setSize(newBounds.size, minimumSize);
  }

  Size _getMinimumSizeToFitGrid(Size gridSize, Size? minimumSize) {
    final minWidth =
        (minimumSize == null || minimumSize.width <= gridSize.width)
            ? gridSize.width
            : gridSize.width * 2;
    final minHeight =
        (minimumSize == null || minimumSize.height <= gridSize.height)
            ? gridSize.height
            : gridSize.height * 2;
    return Size(minWidth, minHeight);
  }

  RoundingMode _getRoundingModeForSnapMode(
      ResizeSnapMode snapMode, bool leftOrTop) {
    switch (snapMode) {
      case ResizeSnapMode.closest:
        return RoundingMode.closest;
      case ResizeSnapMode.grow:
        if (leftOrTop) {
          return RoundingMode.floor;
        }
        return RoundingMode.ceil;
      case ResizeSnapMode.shrink:
        if (leftOrTop) {
          return RoundingMode.ceil;
        }
        return RoundingMode.floor;
    }
  }

  Rect extendBoundsGridWiseToRiseAboveMinimum(
      Rect newBounds, Rect currentBounds, Size minimumSize, Size gridSize) {
    while (newBounds.width < minimumSize.width) {
      if ((newBounds.left - currentBounds.left).abs() <=
          (newBounds.right - currentBounds.right).abs()) {
        newBounds = Rect.fromLTRB(newBounds.left, newBounds.top,
            newBounds.right + gridSize.width, newBounds.bottom);
      } else {
        newBounds = Rect.fromLTRB(newBounds.left - gridSize.width,
            newBounds.top, newBounds.right, newBounds.bottom);
      }
    }
    while (newBounds.height < minimumSize.height) {
      if ((newBounds.top - currentBounds.top).abs() <=
          (newBounds.bottom - currentBounds.bottom).abs()) {
        newBounds = Rect.fromLTRB(newBounds.left, newBounds.top,
            newBounds.right, newBounds.bottom + gridSize.height);
      } else {
        newBounds = Rect.fromLTRB(newBounds.left,
            newBounds.top - gridSize.height, newBounds.right, newBounds.bottom);
      }
    }
    return newBounds;
  }

  double _getClosestSnapPosition(
      double rawEdge, double nodeLength, double gridEdge,
      {PositioningSnapMode snapMode = PositioningSnapMode.closest}) {
    final snapAtStartPos = adjustEdgeToGrid(rawEdge, gridEdge);
    if (snapMode == PositioningSnapMode.start) {
      return snapAtStartPos;
    }

    final snapAtEndPos =
        adjustEdgeToGrid(rawEdge + nodeLength, gridEdge) - nodeLength;
    if (snapMode == PositioningSnapMode.end) {
      return snapAtEndPos;
    }

    final snapAtStartDelta = (snapAtStartPos - rawEdge).abs();
    final snapAtEndDelta = (snapAtEndPos - rawEdge).abs();
    if (snapAtEndDelta < snapAtStartDelta) {
      return snapAtEndPos;
    }
    return snapAtStartPos;
  }
}

enum ResizeHandlesMode {
  disabled,
  corners,
  edges,
  cornersAndEdges;

  bool get isEnabled => this != ResizeHandlesMode.disabled;
  bool get containsCornerHandles =>
      this == ResizeHandlesMode.corners ||
      this == ResizeHandlesMode.cornersAndEdges;
  bool get containsEdgeHandles =>
      this == ResizeHandlesMode.edges ||
      this == ResizeHandlesMode.cornersAndEdges;
}

enum PositioningSnapMode { closest, start, end }

enum ResizeSnapMode { closest, shrink, grow }
