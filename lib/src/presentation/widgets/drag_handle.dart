import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';
import 'package:infinite_canvas/src/domain/model/canvas_config.dart';
import 'package:infinite_canvas/src/presentation/utils/helpers.dart';

class DragHandle extends StatefulWidget {
  final InfiniteCanvasController controller;
  final InfiniteCanvasNode node;
  final DragHandleAlignment alignment;
  final CanvasConfig canvasConfig;

  const DragHandle({
    super.key,
    required this.controller,
    required this.node,
    required this.alignment,
    required this.canvasConfig,
  });

  @override
  State<DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<DragHandle> {
  late final InfiniteCanvasController controller;
  late final InfiniteCanvasNode node;

  late Rect initialBounds;
  late Rect minimumSizeBounds;
  late Offset draggingOffset;
  late VoidCallback controllerListener;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    node = widget.node;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final al = widget.alignment;
    final canvasConfig = widget.canvasConfig;
    return Listener(
        onPointerDown: (details) {
          initialBounds = Rect.fromLTWH(node.offset.dx, node.offset.dy,
              node.size.width, node.size.height);
          minimumSizeBounds = Rect.fromLTRB(
              initialBounds.right - canvasConfig.minimumNodeSize.width,
              initialBounds.bottom - canvasConfig.minimumNodeSize.height,
              initialBounds.left + canvasConfig.minimumNodeSize.width,
              initialBounds.top + canvasConfig.minimumNodeSize.height);
          draggingOffset = Offset.zero;
        },
        onPointerUp: (details) {
          node.update(setCurrentlyResizing: false);
        },
        onPointerCancel: (details) {
          node.update(setCurrentlyResizing: false);
        },
        onPointerMove: (details) {
          if (!widget.controller.mouseDown) return;

          draggingOffset = draggingOffset + details.delta;
          Rect newBounds = initialBounds;

          if (al.isLeft) {
            newBounds = Rect.fromLTRB(
                min(minimumSizeBounds.left, newBounds.left + draggingOffset.dx),
                newBounds.top,
                newBounds.right,
                newBounds.bottom);
          }
          if (al.isTop) {
            newBounds = Rect.fromLTRB(
                newBounds.left,
                min(minimumSizeBounds.top, newBounds.top + draggingOffset.dy),
                newBounds.right,
                newBounds.bottom);
          }

          if (canvasConfig.snapResizeToGrid && (al.isLeft || al.isTop)) {
            final snappedLeft = adjustEdgeToGrid(
                newBounds.left, canvasConfig.gridSize.width,
                maximum: minimumSizeBounds.left, allowMinAndMaxSizes: false);
            final snappedTop = adjustEdgeToGrid(
                newBounds.top, canvasConfig.gridSize.height,
                maximum: minimumSizeBounds.top, allowMinAndMaxSizes: false);
            newBounds = Rect.fromLTRB(
                snappedLeft, snappedTop, newBounds.right, newBounds.bottom);
          }

          if (al.isRight) {
            newBounds = Rect.fromLTWH(
                newBounds.left,
                newBounds.top,
                max(canvasConfig.minimumNodeSize.width,
                    newBounds.width + draggingOffset.dx),
                newBounds.height);
          }
          if (al.isBottom) {
            newBounds = Rect.fromLTWH(
                newBounds.left,
                newBounds.top,
                newBounds.width,
                max(canvasConfig.minimumNodeSize.height,
                    newBounds.height + draggingOffset.dy));
          }

          if (canvasConfig.snapResizeToGrid && (al.isRight || al.isBottom)) {
            final snappedRight = adjustEdgeToGrid(
                newBounds.right, canvasConfig.gridSize.width,
                minimum: minimumSizeBounds.right);
            final snappedBottom = adjustEdgeToGrid(
                newBounds.bottom, canvasConfig.gridSize.height,
                minimum: minimumSizeBounds.bottom);
            newBounds = Rect.fromLTRB(
                newBounds.left, newBounds.top, snappedRight, snappedBottom);
          }

          node.update(
              size: newBounds.size,
              offset: newBounds.topLeft,
              setCurrentlyResizing: true);
          controller.edit(node);
        },
        child: Container(
          width: canvasConfig.dragHandleSize.width,
          height: canvasConfig.dragHandleSize.height,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            border: Border.all(
              color: colors.onSurfaceVariant,
              width: 1,
            ),
          ),
        ));
  }
}

class DragHandleAlignment {
  final Alignment alignment;

  const DragHandleAlignment(this.alignment);

  bool get isLeft => alignment.x < 0;
  bool get isRight => alignment.x > 0;
  bool get isTop => alignment.y < 0;
  bool get isBottom => alignment.y > 0;
  bool get isHorizontalCenter => alignment.x == 0;
  bool get isVerticalCenter => alignment.y == 0;
}
