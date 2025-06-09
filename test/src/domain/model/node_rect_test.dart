import 'dart:ui';

import 'package:infinite_canvas/infinite_canvas.dart';
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

    test('NodeRect.size should return a Size object with the correct size', () {
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

    test(
        'NodeRect.toRect() should return a Rect object with the correct bounds',
        () {
      final rect = nodeRect.toRect();
      expect(rect.left, -10);
      expect(rect.top, 16);
      expect(rect.right, 190);
      expect(rect.bottom, 48);
    });

    test(
        'NodeRect.copyWith() should return an identical copy if no arguments are passed',
        () {
      final copiedRect = nodeRect.copyWith();
      expect(copiedRect.left, nodeRect.left);
      expect(copiedRect.top, nodeRect.top);
      expect(copiedRect.right, nodeRect.right);
      expect(copiedRect.bottom, nodeRect.bottom);
    });

    test(
        'NodeRect.copyWith() should return a copy where only selected bounds are changed',
        () {
      final copiedRect = nodeRect.copyWith(top: -55, right: 777);
      expect(copiedRect.left, nodeRect.left);
      expect(copiedRect.top, -55);
      expect(copiedRect.right, 777);
      expect(copiedRect.bottom, nodeRect.bottom);
    });
  });
}
