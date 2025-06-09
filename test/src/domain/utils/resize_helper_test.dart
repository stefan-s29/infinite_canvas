import 'package:flutter/cupertino.dart';
import 'package:infinite_canvas/src/domain/model/node_rect.dart';
import 'package:infinite_canvas/src/domain/utils/resize_helper.dart';
import 'package:infinite_canvas/src/shared/model/changeable_edges.dart';
import 'package:test/test.dart';

void main() {
  group('ResizeHelper with a 16x16 grid', () {
    const gridSize = Size(16, 16);
    const minimumNodeSize = Size(10, 10);
    const maximumNodeSize = Size(200, 100);
    final resizeHelper = ResizeHelper(
        gridSize, minimumNodeSize, maximumNodeSize, ResizeSnapMode.closest);

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
        'ResizeHelper.getRectResizedToGrid should respect the minimum node size while snapping',
        () {
      // left/right adjusted to grid (32): -32 / 0
      // 32 - 0 < 100 -> need to enlarge the rectangle
      // Either move left to -128 (128 - 0 > 100) or move right to 96 (96 -(-32) > 100)
      // 10 is closer to 96 than -30 is to -128
      // Move left from -30 to -32 (snap to grid)
      // Move right from 0 to 96 (enlarge while staying on grid)
      //
      // top/bottom adjusted to grid (16): 16 / 16
      // 16 - 16 < 20 -> need to enlarge the rectangle
      // Either move top to -16 (16 -(-16) > 20) or move bottom to 48 (48 - 16 > 20)
      // 21 is closer to 48 than 20 is to -16
      // Move top from 20 to 16 (snap to grid)
      // Move bottom from 21 to 48 (enlarge and snap to grid)
      final originalRect = NodeRect.fromLTRB(-30, 20, 10, 21);
      final newRect = resizeHelper.getRectResizedToGrid(originalRect);
      expect(newRect, NodeRect.fromLTRB(-32, 16, 96, 48));
    });

    test(
        'ResizeHelper.getRectResizedToGrid should respect the maximum node size while snapping',
        () {
      // left/right adjusted to grid (32): -64 / 192
      // 192 -(-64) > 200 -> need to shrink the rectangle
      // Either move left to 0 (192 - 0 < 200) or move right to 128 (128 -(-64) < 200)
      // -60 is closer to 0 than 192 is to 128
      // Move left from -60 to 0 (shrink and snap to grid)
      // Move right from 200 to 192 (snap to grid)
      //
      // top/bottom adjusted to grid (16): 32 / 144
      // 144 - 32 > 100 -> need to shrink the rectangle
      // Either move top to 48 (144 - 48 < 100) or move bottom to 128 (128 - 32 < 100)
      // 48 is closer to 30 than 150 is to 128
      // Move top from 30 to 48 (shrink and snap to grid)
      // Move bottom from 150 to 144 (snap to grid)
      final originalRect = NodeRect.fromLTRB(-60, 30, 200, 150);
      final newRect = resizeHelper.getRectResizedToGrid(originalRect);
      expect(newRect, NodeRect.fromLTRB(0, 48, 192, 144));
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
        changeableEdges: const ChangeableEdges(
            left: true, top: true, right: false, bottom: false));

    test(
        'ResizeHelper.getRectResizedToGrid should respect the minimum node size while snapping, only changing the left and top edges',
        () {
      // left adjusted to grid (32): -32
      // 10 -(-32) < 100 -> need to enlarge the rectangle
      // Move left from -30 to -96 (right edge not changeable)
      //
      // top adjusted to grid (16): 16
      // 21 - 16 < 20 -> need to enlarge the rectangle
      // Move top from 20 to 0 (bottom edge not changeable)
      final originalRect = NodeRect.fromLTRB(-30, 20, 10, 21);
      final newRect = resizeHelper.getRectResizedToGrid(originalRect);
      expect(newRect, NodeRect.fromLTRB(-96, 0, 10, 21));
    });

    test(
        'ResizeHelper.getRectResizedToGrid should respect the maximum node size while snapping',
        () {
      // left adjusted to grid (32): -64
      // 200 -(-64) > 200 -> need to shrink the rectangle
      // Move left from -60 to 0 (right edge not changeable)
      //
      // top adjusted to grid (16): 32
      // 150 - 32 > 100 -> need to shrink the rectangle
      // Move top from 30 to 64 (bottom edge not changeable)
      final originalRect = NodeRect.fromLTRB(-60, 30, 200, 150);
      final newRect = resizeHelper.getRectResizedToGrid(originalRect);
      expect(newRect, NodeRect.fromLTRB(0, 64, 200, 150));
    });
  });
}
