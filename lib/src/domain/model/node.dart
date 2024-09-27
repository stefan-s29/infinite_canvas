import 'package:flutter/material.dart';

import 'canvas_config.dart';
import 'node_rect.dart';

/// A node in the [InfiniteCanvas].
class InfiniteCanvasNode<T> {
  InfiniteCanvasNode({
    required this.key,
    required CanvasConfig canvasConfig,
    required Offset offset,
    required Size size,
    required this.child,
    this.label,
    this.resizeHandlesMode = ResizeHandlesMode.disabled,
    this.allowMove = true,
    this.clipBehavior = Clip.none,
    this.value,
  })  : _canvasConfig = canvasConfig,
        _nodeRect = NodeRect.fromOffsetAndSize(offset, size).adjustToBounds(
            canvasConfig.minimumNodeSize, canvasConfig.maximumNodeSize);

  String get id => key.toString();

  final LocalKey key;

  CanvasConfig _canvasConfig;
  CanvasConfig get canvasConfig => _canvasConfig;
  set canvasConfig(CanvasConfig newConfig) {
    CanvasConfig oldConfig = _canvasConfig;
    _canvasConfig = newConfig;

    if ((newConfig.minimumNodeSize != oldConfig.minimumNodeSize ||
        newConfig.maximumNodeSize != oldConfig.maximumNodeSize)) {
      _setSize(size);
    }
  }

  NodeRect _nodeRect;
  set nodeRect(NodeRect newRect) {
    offset = newRect.topLeft;
    _setSize(newRect.size);
  }

  Size get size => _nodeRect.size;
  void _setSize(Size givenSize) {
    final resizedNodeRect =
        NodeRect.fromOffsetAndSize(_nodeRect.offset, givenSize);
    _nodeRect = resizedNodeRect.adjustToBounds(
        canvasConfig.minimumNodeSize, canvasConfig.maximumNodeSize);
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
      _setSize(size);
    }
    if (label != null) this.label = label;
  }

  void alignWithGrid(
      {PositioningSnapMode snapMode = PositioningSnapMode.closest}) {
    final currentRect = NodeRect.fromOffsetAndSize(offset, size);
    this.offset = currentRect.getClosestSnapPosition(canvasConfig.gridSize);
  }

  void resizeToFitGrid({ResizeSnapMode snapMode = ResizeSnapMode.closest}) {
    final resizedRect = _nodeRect.getRectResizedToGrid(canvasConfig.gridSize,
        canvasConfig.minimumNodeSize, canvasConfig.maximumNodeSize, snapMode);
    nodeRect = resizedRect;
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
