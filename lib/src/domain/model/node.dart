import 'package:flutter/material.dart';
import 'package:infinite_canvas/src/presentation/utils/helpers.dart';

import 'canvas_config.dart';
import 'node_rect.dart';

/// A node in the [InfiniteCanvas].
class InfiniteCanvasNode<T> {
  InfiniteCanvasNode({
    required this.key,
    required CanvasConfig canvasConfig,
    required NodeRect nodeRect,
    required this.child,
    this.label,
    this.resizeHandlesMode = ResizeHandlesMode.disabled,
    this.allowMove = true,
    this.clipBehavior = Clip.none,
    this.value,
  })  : _canvasConfig = canvasConfig,
        _nodeRect = nodeRect.adjustToBounds(
            canvasConfig.minimumNodeSize, canvasConfig.minimumNodeSize);

  String get id => key.toString();

  final LocalKey key;

  CanvasConfig _canvasConfig;
  CanvasConfig get canvasConfig => _canvasConfig;
  set canvasConfig(CanvasConfig newConfig) {
    CanvasConfig oldConfig = _canvasConfig;
    _canvasConfig = newConfig;

    if ((newConfig.minimumNodeSize != oldConfig.minimumNodeSize ||
        newConfig.maximumNodeSize != oldConfig.maximumNodeSize)) {
      _setSize(size, enforceBounds: true);
    }
  }

  NodeRect _nodeRect;
  Size get size => _nodeRect.size;
  void _setSize(Size givenSize, {bool enforceBounds = false}) {
    final resizedNodeRect =
        NodeRect.fromOffsetAndSize(_nodeRect.offset, givenSize);
    _nodeRect = enforceBounds
        ? resizedNodeRect.adjustToBounds(
            canvasConfig.minimumNodeSize, canvasConfig.maximumNodeSize)
        : resizedNodeRect;
  }

  Offset get offset => _nodeRect.offset;
  set offset(value) {
    _nodeRect.offset = value;
  }

  String? label;
  T? value;
  final Widget child;
  final ResizeHandlesMode resizeHandlesMode;
  bool currentlyResizing = false;
  final bool allowMove;
  final Clip clipBehavior;
  Rect get rect => _nodeRect.toRect();
  static const double borderInset = 2;

  void update(
      {Size? size, Offset? offset, String? label, bool? setCurrentlyResizing}) {
    if (setCurrentlyResizing != null) {
      currentlyResizing = setCurrentlyResizing;
    }
    final canBeMoved =
        setCurrentlyResizing == null && allowMove && !currentlyResizing;

    if (offset != null && setCurrentlyResizing == true) {
      this.offset = offset;
    } else if (offset != null && canBeMoved) {
      if (canvasConfig.snapMovementToGrid) {
        final nodeRect = NodeRect.fromOffsetAndSize(offset, size ?? this.size);
        this.offset = nodeRect.getClosestSnapPosition(canvasConfig.gridSize);
      } else {
        this.offset = offset;
      }
    }

    if (size != null && resizeHandlesMode.isEnabled) {
      _setSize(size, enforceBounds: true);
    }
    if (label != null) this.label = label;
  }

  void alignWithGrid(Size gridSize,
      {PositioningSnapMode snapMode = PositioningSnapMode.closest}) {
    final nodeBounds = NodeRect.fromOffsetAndSize(offset, size);
    this.offset = nodeBounds.getClosestSnapPosition(canvasConfig.gridSize);
  }

  void resizeToFitGrid(Size gridSize,
      {Size? minimumNodeSize,
      ResizeSnapMode snapMode = ResizeSnapMode.closest}) {
    final currentRect = NodeRect.fromOffsetAndSize(offset, size);
    final newBounds = currentRect.getNewBoundsResizedToGrid(gridSize);

    offset = newBounds.topLeft;
    setSize(newBounds.size, minSize: minimumSize);
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
