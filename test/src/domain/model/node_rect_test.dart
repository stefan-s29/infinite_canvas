import 'dart:ui';

import 'package:infinite_canvas/infinite_canvas.dart';
import 'package:infinite_canvas/src/domain/utils/edge_type.dart';
import 'package:infinite_canvas/src/shared/model/changeable_edges.dart';
import 'package:test/test.dart';

void main() {
  group('NodeRect', () {
    final nodeRect = NodeRect.fromLTRB(-10, 16, 190, 48);

    test(
        'NodeRect should be comparable to another object by its 4 bounds properties',
        () {
      final otherNodeRect = NodeRect.fromLTRB(-10, 16, 190, 48);
      expect(otherNodeRect == nodeRect, true);
    });

    test(
        'NodeRect should order given horizontal and vertical bounds so that right and bottom are above left and top respectively',
        () {
      final otherNodeRect = NodeRect.fromLTRB(10, 2, -20, -8);
      expect(otherNodeRect.left, -20);
      expect(otherNodeRect.top, -8);
      expect(otherNodeRect.right, 10);
      expect(otherNodeRect.bottom, 2);
    });

    group('Constructors', () {
      test('NodeRect should be creatable by passing width and height', () {
        final otherNodeRect = NodeRect.fromLTWH(-10, 16, 200, 32);
        expect(otherNodeRect.right, nodeRect.right);
        expect(otherNodeRect.bottom, nodeRect.bottom);
      });

      test('NodeRect should be creatable from a Rect object', () {
        const rect = Rect.fromLTRB(-10, 16, 190, 48);
        final otherNodeRect = NodeRect.fromRect(rect);
        expect(otherNodeRect.left, -10);
        expect(otherNodeRect.top, 16);
        expect(otherNodeRect.right, 190);
        expect(otherNodeRect.bottom, 48);
      });

      test('NodeRect should be creatable from an offset and a size', () {
        const offset = Offset(-10, 16);
        const size = Size(200, 32);
        final otherNodeRect = NodeRect.fromOffsetAndSize(offset, size);
        expect(otherNodeRect.left, -10);
        expect(otherNodeRect.top, 16);
        expect(otherNodeRect.right, 190);
        expect(otherNodeRect.bottom, 48);
      });
    });

    group('Getters', () {
      test('NodeRect.width should return the correct width', () {
        expect(nodeRect.width, 200);
      });

      test('NodeRect.height should return the correct height', () {
        expect(nodeRect.height, 32);
      });

      test(
          'NodeRect.offset should return an Offset object with the correct coordinates',
          () {
        final offset = nodeRect.offset;
        expect(offset.dx, -10);
        expect(offset.dy, 16);
      });

      test('NodeRect.size should return a Size object with the correct size',
          () {
        final size = nodeRect.size;
        expect(size.width, 200);
        expect(size.height, 32);
      });

      test(
          'NodeRect.topLeft should return an Offset object with the correct topLeft coordinates',
          () {
        final offset = nodeRect.topLeft;
        expect(offset.dx, -10);
        expect(offset.dy, 16);
      });

      test(
          'NodeRect.topRight should return an Offset object with the correct topRight coordinates',
          () {
        final offset = nodeRect.topRight;
        expect(offset.dx, 190);
        expect(offset.dy, 16);
      });

      test(
          'NodeRect.bottomLeft should return an Offset object with the correct bottomLeft coordinates',
          () {
        final offset = nodeRect.bottomLeft;
        expect(offset.dx, -10);
        expect(offset.dy, 48);
      });

      test(
          'NodeRect.bottomRight should return an Offset object with the correct bottomRight coordinates',
          () {
        final offset = nodeRect.bottomRight;
        expect(offset.dx, 190);
        expect(offset.dy, 48);
      });
    });

    test(
        'NodeRect.toRect() should return a Rect object with the correct bounds',
        () {
      final rect = nodeRect.toRect();
      expect(rect.left, -10);
      expect(rect.top, 16);
      expect(rect.right, 190);
      expect(rect.bottom, 48);
    });

    group('copyWith()', () {
      test(
          'copyWith() should return an identical copy if no arguments are passed',
          () {
        final copiedRect = nodeRect.copyWith();
        expect(copiedRect.left, nodeRect.left);
        expect(copiedRect.top, nodeRect.top);
        expect(copiedRect.right, nodeRect.right);
        expect(copiedRect.bottom, nodeRect.bottom);
      });

      test(
          'copyWith() should return a copy where only selected bounds are changed',
          () {
        final copiedRect = nodeRect.copyWith(top: -55, right: 777);
        expect(copiedRect.left, nodeRect.left);
        expect(copiedRect.top, -55);
        expect(copiedRect.right, 777);
        expect(copiedRect.bottom, nodeRect.bottom);
      });

      test(
          'the result of copyWith() should order the horizontal and vertical coordinates correctly',
          () {
        final copiedRect = nodeRect.copyWith(left: 200, bottom: -25);
        expect(copiedRect.left, 190);
        expect(copiedRect.top, -25);
        expect(copiedRect.right, 200);
        expect(copiedRect.bottom, 16);
      });
    });

    group('transform()', () {
      test(
          'transform() should return an identical copy of the object if transformer is the identity function',
          () {
        transformer(double val, EdgeType edgeType) => val;
        final transformedRect = nodeRect.transform(transformer);
        expect(transformedRect.left, nodeRect.left);
        expect(transformedRect.top, nodeRect.top);
        expect(transformedRect.right, nodeRect.right);
        expect(transformedRect.bottom, nodeRect.bottom);
      });

      test(
          'transform() should apply the transformer function to all bounds if all of them are changeable',
          () {
        transformer(double val, EdgeType edgeType) => val * 3;
        const changedEdges = ChangeableEdges.all;
        final transformedRect =
            nodeRect.transform(transformer, changedEdges: changedEdges);

        expect(transformedRect.left, -30);
        expect(transformedRect.top, 48);
        expect(transformedRect.right, 570);
        expect(transformedRect.bottom, 144);
      });

      test(
          'transform() should only apply the transformer function to changeable bounds',
          () {
        transformer(double val, EdgeType edgeType) => val * 3;
        const changedEdges =
            ChangeableEdges(left: false, top: true, right: true, bottom: false);
        final transformedRect =
            nodeRect.transform(transformer, changedEdges: changedEdges);
        expect(transformedRect.left, -10);
        expect(transformedRect.top, 48);
        expect(transformedRect.right, 570);
        expect(transformedRect.bottom, 48);
      });

      test(
          'the result of the transform() function should order the horizontal and vertical coordinates correctly',
          () {
        transformer(double val, EdgeType edgeType) => val * -3;
        const changedEdges = ChangeableEdges.all;
        final transformedRect =
            nodeRect.transform(transformer, changedEdges: changedEdges);

        expect(transformedRect.left, -570);
        expect(transformedRect.top, -144);
        expect(transformedRect.right, 30);
        expect(transformedRect.bottom, -48);
      });

      test(
          'transform() should correctly assign the leftOrTop parameter of the transformer function',
          () {
        transformer(double val, EdgeType edgeType) =>
            edgeType.isLeftOrTop ? val + 5 : val / 2;
        const changedEdges = ChangeableEdges.all;
        final transformedRect =
            nodeRect.transform(transformer, changedEdges: changedEdges);
        expect(transformedRect.left, -5);
        expect(transformedRect.top, 21);
        expect(transformedRect.right, 95);
        expect(transformedRect.bottom, 24);
      });

      test(
          'transform() should correctly assign the horizontal parameter of the transformer function',
          () {
        transformer(double val, EdgeType edgeType) =>
            edgeType.isHorizontal ? val * 4 : val - 16;
        const changedEdges = ChangeableEdges.all;
        final transformedRect =
            nodeRect.transform(transformer, changedEdges: changedEdges);
        expect(transformedRect.left, -40);
        expect(transformedRect.top, 0);
        expect(transformedRect.right, 760);
        expect(transformedRect.bottom, 32);
      });
    });
  });
}
