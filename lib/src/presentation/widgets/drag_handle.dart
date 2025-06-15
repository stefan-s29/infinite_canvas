import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';
import 'package:infinite_canvas/src/domain/utils/resize_helper.dart';
import 'package:infinite_canvas/src/shared/model/changeable_edges.dart';

class DragHandle extends StatefulWidget {
  final InfiniteCanvasController controller;
  final InfiniteCanvasNode node;
  final ChangeableEdges alignment;
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

  late NodeRect initialNodeRect;
  late NodeRect minimumSizeBounds;
  late NodeRect maximumSizeBounds;
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
    final dhAlignment = widget.alignment;
    final canvasConfig = widget.canvasConfig;
    return Listener(
        onPointerDown: (details) {
          initialNodeRect = node.nodeRect.copyWith();
          minimumSizeBounds = NodeRect.fromLTRB(
              initialNodeRect.right - canvasConfig.minimumNodeSize.width,
              initialNodeRect.bottom - canvasConfig.minimumNodeSize.height,
              initialNodeRect.left + canvasConfig.minimumNodeSize.width,
              initialNodeRect.top + canvasConfig.minimumNodeSize.height);
          maximumSizeBounds = NodeRect.fromLTRB(
              initialNodeRect.right - canvasConfig.maximumNodeSize.width,
              initialNodeRect.bottom - canvasConfig.maximumNodeSize.height,
              initialNodeRect.left + canvasConfig.maximumNodeSize.width,
              initialNodeRect.top + canvasConfig.maximumNodeSize.height);
          draggingOffset = Offset.zero;
        },
        onPointerUp: (details) {
          node.update(canvasConfig, setCurrentlyResizing: false);
        },
        onPointerCancel: (details) {
          node.update(canvasConfig, setCurrentlyResizing: false);
        },
        onPointerMove: (details) {
          if (!widget.controller.mouseDown) return;

          draggingOffset = draggingOffset + details.delta;
          NodeRect newNodeRect =
              initialNodeRect.resize(draggingOffset, dhAlignment);
          if (canvasConfig.snapResizeToGrid) {
            final resizeHelper = ResizeHelper(
                canvasConfig.gridSize,
                canvasConfig.minimumNodeSize,
                canvasConfig.maximumNodeSize,
                ResizeSnapMode.closest,
                changeableEdges: dhAlignment);
            newNodeRect = resizeHelper.getRectResizedToGrid(newNodeRect);
          } else {
            newNodeRect = newNodeRect.adjustToBounds(
                canvasConfig.minimumNodeSize, canvasConfig.maximumNodeSize,
                moveLeftEdge: dhAlignment.left, moveTopEdge: dhAlignment.top);
          }

          node.update(canvasConfig,
              size: newNodeRect.size,
              offset: newNodeRect.topLeft,
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
