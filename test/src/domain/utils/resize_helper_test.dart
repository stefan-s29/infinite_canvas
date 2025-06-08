import 'package:flutter/cupertino.dart';
import 'package:infinite_canvas/src/domain/model/node_rect.dart';
import 'package:infinite_canvas/src/domain/utils/resize_helper.dart';
import 'package:infinite_canvas/src/shared/model/drag_handle_alignment.dart';
import 'package:test/test.dart';

void main() {
  group('ResizeHelper with a 16x16 grid', () {
    const gridSize = Size(16, 16);
    const minimumNodeSize = Size(10, 10);
    const maximumNodeSize = Size(200, 100);
    final resizeHelper = ResizeHelper(
        gridSize, minimumNodeSize, maximumNodeSize, ResizeSnapMode.closest);

    test(
        'ResizeHelper.minimumSizeOnGrid should be the lowest multiples of the grid edge sizes above the minimum node size',
        () {
      expect(resizeHelper.minimumSizeOnGrid, const Size(16, 16));
    });

    test(
        'ResizeHelper.maximumSizeOnGrid should be the highest multiples of the grid edge sizes below the maximum node size',
        () {
      expect(resizeHelper.maximumSizeOnGrid, const Size(192, 96));
    });

    test(
        'ResizeHelper.getRectResizedToGrid should snap all borders of a NodeRect to the grid',
        () {
      final originalRect = NodeRect.fromLTRB(70, -50, -10, -100);
      final newRect = resizeHelper.getRectResizedToGrid(originalRect);
      expect(newRect, NodeRect.fromLTRB(64, -48, -16, -96));
    });

    group('snapping with different modes', () {
      test(
          'ResizeHelper.getRectResizedToGrid should snap all borders of a NodeRect to the closest grid line',
          () {
        final otherResizeHelper = ResizeHelper(
            gridSize, minimumNodeSize, maximumNodeSize, ResizeSnapMode.closest);
        final originalRect = NodeRect.fromLTRB(70, -100, 100, -50);
        final newRect = otherResizeHelper.getRectResizedToGrid(originalRect);
        expect(newRect, NodeRect.fromLTRB(64, -96, 96, -48));
      });

      test(
          'ResizeHelper.getRectResizedToGrid should snap all borders of a NodeRect to the grid by growing',
          () {
        final otherResizeHelper = ResizeHelper(
            gridSize, minimumNodeSize, maximumNodeSize, ResizeSnapMode.grow);
        final originalRect = NodeRect.fromLTRB(70, -100, 100, -50);
        final newRect = otherResizeHelper.getRectResizedToGrid(originalRect);
        expect(newRect, NodeRect.fromLTRB(64, -112, 112, -48));
      });

      test(
          'ResizeHelper.getRectResizedToGrid should snap all borders of a NodeRect to the grid by shrinking',
          () {
        final otherResizeHelper = ResizeHelper(
            gridSize, minimumNodeSize, maximumNodeSize, ResizeSnapMode.shrink);
        final originalRect = NodeRect.fromLTRB(70, -100, 100, -50);
        final newRect = otherResizeHelper.getRectResizedToGrid(originalRect);
        expect(newRect, NodeRect.fromLTRB(80, -96, 96, -64));
      });
    });
  });

  group(
      'snapping with constraints on a 32x16 grid, all edges equally changeable',
      () {
    const gridSize = Size(32, 16);
    const minimumNodeSize = Size(100, 20);
    const maximumNodeSize = Size(200, 100);
    final resizeHelper = ResizeHelper(
        gridSize, minimumNodeSize, maximumNodeSize, ResizeSnapMode.closest);

    test(
        'ResizeHelper.minimumSizeOnGrid should be the lowest multiples of the grid edge sizes above the minimum node size',
        () {
      expect(resizeHelper.minimumSizeOnGrid, const Size(128, 32));
    });

    test(
        'ResizeHelper.maximumSizeOnGrid should be the highest multiples of the grid edge sizes below the maximum node size',
        () {
      expect(resizeHelper.maximumSizeOnGrid, const Size(192, 96));
    });

    test(
        'ResizeHelper.getRectResizedToGrid should respect the minimum node size while snapping',
        () {
      // left/right adjusted to grid (32): -32 / 0
      // 32 - 0 < 100 -> need to extend the rectangle to a width of 128 (4 x 32)
      // Move right from 0 to 96
      //
      // top/bottom adjusted to grid (16): 16 / 16
      // 16 - 16 < 20 -> need to extend the rectangle to a width of 32 (2 x 16)
      // Move bottom from 16 to 48
      final originalRect = NodeRect.fromLTRB(-30, 20, 10, 21);
      final newRect = resizeHelper.getRectResizedToGrid(originalRect);
      expect(newRect, NodeRect.fromLTRB(-32, 16, 96, 48));
    });

    test(
        'ResizeHelper.getRectResizedToGrid should respect the maximum node size while snapping',
        () {
      // left/right adjusted to grid (32): -64 / 192
      // 192 -(-64) > 200 -> need to shrink the rectangle to a width of 192 (6 x 32)
      // Move right from 192 to 128
      // TODO left should move because -60 is closer to 0 than 200 is to 128
      //
      // top/bottom adjusted to grid (16): 32 / 144
      // 144 - 32 > 100 -> need to shrink the rectangle to a height of 96 (6 x 16)
      // Move bottom from 144 to 128
      final originalRect = NodeRect.fromLTRB(-60, 30, 200, 150);
      final newRect = resizeHelper.getRectResizedToGrid(originalRect);
      expect(newRect, NodeRect.fromLTRB(-64, 32, 128, 128));
    });
  });

  group(
      'snapping with constraints on a 32x16 grid, only left and top edges changeable',
      () {
    const gridSize = Size(32, 16);
    const minimumNodeSize = Size(100, 20);
    const maximumNodeSize = Size(200, 100);
    final resizeHelper = ResizeHelper(
        gridSize, minimumNodeSize, maximumNodeSize, ResizeSnapMode.closest,
        changeableEdges: const DragHandleAlignment(Alignment.topLeft));

    // TODO fix test
    test(
        'ResizeHelper.getRectResizedToGrid should respect the minimum node size while snapping',
        () {
      final originalRect = NodeRect.fromLTRB(-30, 20, 10, 21);
      final newRect = resizeHelper.getRectResizedToGrid(originalRect);
      expect(newRect, NodeRect.fromLTRB(-32, 16, 96, 48));
    });

    // TODO fix test
    test(
        'ResizeHelper.getRectResizedToGrid should respect the maximum node size while snapping',
        () {
      // left/right adjusted to grid (32): -64 / 192
      // 192 -(-64) > 200 -> need to shrink the rectangle to a width of 192 (6 x 32)
      // Move left from -64 to 0
      //
      // top/bottom adjusted to grid (16): 32 / 144
      // 144 - 32 > 100 -> need to shrink the rectangle to a height of 96 (6 x 16)
      // Move bottom from 144 to 128
      final originalRect = NodeRect.fromLTRB(-60, 30, 200, 150);
      final newRect = resizeHelper.getRectResizedToGrid(originalRect);
      expect(newRect, NodeRect.fromLTRB(0, 48, 192, 144));
    });
  });
}
