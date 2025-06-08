import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';
import 'package:infinite_canvas/src/shared/model/drag_handle_alignment.dart';

import 'clipper.dart';
import 'drag_handle.dart';

class NodeRenderer extends StatelessWidget {
  const NodeRenderer({
    super.key,
    required this.node,
    required this.controller,
    required this.dragHandleSize,
  });

  final InfiniteCanvasNode node;
  final InfiniteCanvasController controller;
  final Size dragHandleSize;

  static const double borderInset = 2;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;
    final showCornerHandles = node.resizeHandlesMode.containsCornerHandles &&
        controller.isSelected(node.key);
    final showEdgeHandles = node.resizeHandlesMode.containsEdgeHandles &&
        controller.isSelected(node.key);
    return SizedBox.fromSize(
      size: node.size,
      child: Stack(clipBehavior: Clip.none, children: [
        if (node.label != null)
          Positioned(
            top: -25,
            left: 0,
            child: Text(
              node.label!,
              style: fonts.bodyMedium?.copyWith(
                color: colors.onSurface,
                shadows: [
                  Shadow(
                    offset: const Offset(0.8, 0.8),
                    blurRadius: 3,
                    color: colors.surface,
                  ),
                ],
              ),
            ),
          ),
        if (controller.isSelected(node.key) || controller.isHovered(node.key))
          Positioned(
            top: -borderInset,
            left: -borderInset,
            right: -borderInset,
            bottom: -borderInset,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: controller.isSelected(node.key)
                        ? colors.primary
                        : colors.outline,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        Positioned.fill(
          key: key,
          child: node.clipBehavior != Clip.none
              ? ClipRect(
                  clipper: Clipper(node.rect),
                  clipBehavior: node.clipBehavior,
                  child: node.child,
                )
              : node.child,
        ),
        if (showCornerHandles) ...[
          _buildDragHandle(Alignment.bottomRight),
          _buildDragHandle(Alignment.bottomLeft),
          _buildDragHandle(Alignment.topRight),
          _buildDragHandle(Alignment.topLeft),
        ],
        if (showEdgeHandles) ...[
          _buildDragHandle(Alignment.centerLeft),
          _buildDragHandle(Alignment.centerRight),
          _buildDragHandle(Alignment.topCenter),
          _buildDragHandle(Alignment.bottomCenter),
        ],
      ]),
    );
  }

  Positioned _buildDragHandle(Alignment alignment) {
    final dragHandleAlignment = DragHandleAlignment(alignment);
    return Positioned(
        left: dragHandleAlignment.isLeft
            ? 0
            : dragHandleAlignment.isHorizontalCenter
                ? node.size.width / 2 - dragHandleSize.width / 2
                : null,
        right: dragHandleAlignment.isRight ? 0 : null,
        top: dragHandleAlignment.isTop
            ? 0
            : dragHandleAlignment.isVerticalCenter
                ? node.size.height / 2 - dragHandleSize.height / 2
                : null,
        bottom: dragHandleAlignment.isBottom ? 0 : null,
        child: DragHandle(
          controller: controller,
          node: node,
          alignment: dragHandleAlignment,
          canvasConfig: controller.canvasConfig,
        ));
  }
}
