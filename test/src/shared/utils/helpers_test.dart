import 'dart:ui';

import 'package:infinite_canvas/src/shared/utils/helpers.dart';
import 'package:test/test.dart';

void main() {
  ///
  /// adjustEdgeToGrid
  ///

  group('adjustEdgeToGrid', () {
    test('adjustEdgeToGrid should round a float value to a multiple of 1', () {
      final adjustedEdge = adjustEdgeToGrid(7.2, 1);
      expect(adjustedEdge, 7);
    });

    test('adjustEdgeToGrid should round a float value to a multiple of 3', () {
      final adjustedEdge = adjustEdgeToGrid(7.2, 3);
      expect(adjustedEdge, 6);
    });

    test('adjustEdgeToGrid should round down a whole number to a multiple of 8',
        () {
      final adjustedEdge = adjustEdgeToGrid(19, 8);
      expect(adjustedEdge, 16);
    });

    test('adjustEdgeToGrid should round up a whole number to a multiple of 8',
        () {
      final adjustedEdge = adjustEdgeToGrid(20, 8);
      expect(adjustedEdge, 24);
    });

    test(
        'adjustEdgeToGrid should round up a whole number to a multiple of 8 with roundingMode=ceil',
        () {
      final adjustedEdge =
          adjustEdgeToGrid(19, 8, roundingMode: RoundingMode.ceil);
      expect(adjustedEdge, 24);
    });

    test(
        'adjustEdgeToGrid should round down a whole number to a multiple of 8 with roundingMode=floor',
        () {
      final adjustedEdge =
          adjustEdgeToGrid(20, 8, roundingMode: RoundingMode.floor);
      expect(adjustedEdge, 16);
    });

    test('adjustEdgeToGrid should round a negative value to a multiple of 8',
        () {
      final adjustedEdge = adjustEdgeToGrid(-19, 8);
      expect(adjustedEdge, -16);
    });

    test(
        'adjustEdgeToGrid should round up a negative value to a multiple of 8 with roundingMode=ceil',
        () {
      final adjustedEdge =
          adjustEdgeToGrid(-20, 8, roundingMode: RoundingMode.ceil);
      expect(adjustedEdge, -16);
    });

    test(
        'adjustEdgeToGrid should round down a negative value to a multiple of 8 with roundingMode=floor',
        () {
      final adjustedEdge =
          adjustEdgeToGrid(-19, 8, roundingMode: RoundingMode.floor);
      expect(adjustedEdge, -24);
    });

    test(
        'adjustEdgeToGrid should not surpass the maximum size if allowMinAndMaxSizes is false',
        () {
      final adjustedEdge = adjustEdgeToGrid(20, 8, maximum: 22);
      expect(adjustedEdge, 16);
    });

    test(
        'adjustEdgeToGrid should return the maximum size if allowMinAndMaxSizes is true',
        () {
      final adjustedEdge =
          adjustEdgeToGrid(20, 8, maximum: 22, allowMinAndMaxSizes: true);
      expect(adjustedEdge, 22);
    });

    test(
        'adjustEdgeToGrid should not go below the minimum size if allowMinAndMaxSizes is false',
        () {
      final adjustedEdge = adjustEdgeToGrid(9, 8, minimum: 10);
      expect(adjustedEdge, 16);
    });

    test(
        'adjustEdgeToGrid should return the minimum size if allowMinAndMaxSizes is true',
        () {
      final adjustedEdge =
          adjustEdgeToGrid(9, 8, minimum: 10, allowMinAndMaxSizes: true);
      expect(adjustedEdge, 10);
    });

    test(
        'adjustEdgeToGrid should prioritize the maximum size constraint if it cannot satisfy both constraints',
        () {
      final adjustedEdge = adjustEdgeToGrid(11, 8, minimum: 10, maximum: 14);
      expect(adjustedEdge, 8);
    });
  });

  ///
  /// exceedsLimit
  ///

  group('exceedsLimit', () {
    test('exceedsLimit should return false if no constraints are given', () {
      final result = exceedsLimit(42);
      expect(result, false);
    });

    test('exceedsLimit should return false if no constraints are exceeded', () {
      final result = exceedsLimit(42, minimum: 41, maximum: 43);
      expect(result, false);
    });

    test('exceedsLimit should return true if the minimum is not satisfied', () {
      final result = exceedsLimit(40, minimum: 41, maximum: 43);
      expect(result, true);
    });

    test('exceedsLimit should return true if the maximum is not satisfied', () {
      final result = exceedsLimit(44, minimum: 41, maximum: 43);
      expect(result, true);
    });
  });

  ///
  /// getConstraintDelta
  ///

  group('getConstraintDelta', () {
    test('getConstraintDelta should return 0 if no constraints are given', () {
      final result = getConstraintDelta(42);
      expect(result, 0);
    });

    test('getConstraintDelta should return 0 if no constraints are exceeded',
        () {
      final result = getConstraintDelta(42, minimum: 41, maximum: 43);
      expect(result, 0);
    });

    test('getConstraintDelta should return -1 if the minimum is not met by 1',
        () {
      final result = getConstraintDelta(40, minimum: 41, maximum: 43);
      expect(result, -1);
    });

    test(
        'getConstraintDelta should return the negative delta between the minimum and the tested value if it is too low',
        () {
      final result = getConstraintDelta(17, minimum: 41, maximum: 43);
      expect(result, -24);
    });

    test('getConstraintDelta should return 1 if the maximum is exceeded by 1',
        () {
      final result = getConstraintDelta(44, minimum: 41, maximum: 43);
      expect(result, 1);
    });

    test(
        'getConstraintDelta should return the positive delta between the maximum and the tested value if it is too high',
        () {
      final result = getConstraintDelta(79, minimum: 41, maximum: 43);
      expect(result, 36);
    });
  });

  ///
  /// exceedsSizeLimit
  ///

  group('exceedsSizeLimit', () {
    test('exceedsSizeLimit should return false if no constraints are given',
        () {
      final result = exceedsSizeLimit(const Size(200, 100));
      expect(result, false);
    });

    test('exceedsSizeLimit should return false if no constraints are exceeded',
        () {
      final result = exceedsSizeLimit(const Size(200, 100),
          minimum: const Size(199, 99), maximum: const Size(201, 101));
      expect(result, false);
    });

    test('exceedsSizeLimit should return true if the given width is too large',
        () {
      final result = exceedsSizeLimit(const Size(202, 100),
          minimum: const Size(199, 99), maximum: const Size(201, 101));
      expect(result, true);
    });

    test('exceedsSizeLimit should return true if the given height is too large',
        () {
      final result = exceedsSizeLimit(const Size(200, 102),
          minimum: const Size(199, 99), maximum: const Size(201, 101));
      expect(result, true);
    });

    test('exceedsSizeLimit should return true if the given width is too small',
        () {
      final result = exceedsSizeLimit(const Size(198, 100),
          minimum: const Size(199, 99), maximum: const Size(201, 101));
      expect(result, true);
    });

    test('exceedsSizeLimit should return true if the given height is too small',
        () {
      final result = exceedsSizeLimit(const Size(200, 98),
          minimum: const Size(199, 99), maximum: const Size(201, 101));
      expect(result, true);
    });
  });

  ///
  /// enforceBounds
  ///

  group('enforceBounds', () {
    test(
        'enforceBounds should return the given value if no constraints are given',
        () {
      final value = enforceBounds(42, null, null);
      expect(value, 42);
    });

    test(
        'enforceBounds should return the given value if it does not exceed any constraints',
        () {
      final value = enforceBounds(42, 41, 43);
      expect(value, 42);
    });

    test('enforceBounds should return the minimum if the value is too low', () {
      final value = enforceBounds(40, 41, 43);
      expect(value, 41);
    });

    test('enforceBounds should return the maximum if the value is too high',
        () {
      final value = enforceBounds(44, 41, 43);
      expect(value, 43);
    });

    test(
        'enforceBounds should return the minimum for a negative value that is too low',
        () {
      final value = enforceBounds(-40, -10, 100);
      expect(value, -10);
    });

    test(
        'enforceBounds should return the maximum for a negative value that is too high',
        () {
      final value = enforceBounds(-40, -100, -50);
      expect(value, -50);
    });
  });

  ///
  /// coverDistanceByGridEdges
  ///
  group('coverDistanceByGridEdges', () {
    test(
        'coverDistanceByGridEdges should return 0 if the given distance is 0 and keepBelowDistance=false',
        () {
      final value = coverDistanceByGridEdges(0, 32, keepBelowDistance: false);
      expect(value, 0);
    });

    test(
        'coverDistanceByGridEdges should return 0 if the given distance is 0 and keepBelowDistance=true',
        () {
      final value = coverDistanceByGridEdges(0, 32, keepBelowDistance: true);
      expect(value, 0);
    });

    test(
        'coverDistanceByGridEdges should return 1 if the distance is exactly equal to the grid edge',
        () {
      final value = coverDistanceByGridEdges(32.7, 32.7);
      expect(value, 1);
    });

    test(
        'coverDistanceByGridEdges should return -1 if the distance is the negative of the grid edge',
        () {
      final value = coverDistanceByGridEdges(-32.7, 32.7);
      expect(value, -1);
    });

    test(
        'coverDistanceByGridEdges should return 5 if the distance is exactly the grid edge x 5',
        () {
      final value = coverDistanceByGridEdges(200, 40);
      expect(value, 5);
    });

    test(
        'coverDistanceByGridEdges should return 4 if the grid edge x 4 is needed to surpass the distance',
        () {
      final value = coverDistanceByGridEdges(100, 32);
      expect(value, 4);
    });

    test(
        'coverDistanceByGridEdges should return -2 if the grid edge x -2 is needed to surpass the distance',
        () {
      final value = coverDistanceByGridEdges(-30, 16);
      expect(value, -2);
    });

    test(
        'coverDistanceByGridEdges should return 3 if the grid edge x 3 is needed to stay just below the distance',
        () {
      final value = coverDistanceByGridEdges(100, 32, keepBelowDistance: true);
      expect(value, 3);
    });

    test(
        'coverDistanceByGridEdges should return -1 if the grid edge x -1 is needed to stay just below the distance',
        () {
      final value = coverDistanceByGridEdges(-30, 16, keepBelowDistance: true);
      expect(value, -1);
    });
  });

  ///
  /// Size.isWithinBounds
  ///
  group('Size.isWithinBounds', () {
    test('Size.isWithinBounds should return true if no constraints are given',
        () {
      const size = Size(200, 100);
      expect(size.isWithinBounds(), true);
    });

    test(
        'Size.isWithinBounds should return true if no constraints are exceeded',
        () {
      const size = Size(200, 100);
      const minimum = Size(199, 99);
      const maximum = Size(201, 101);
      expect(size.isWithinBounds(min: minimum, max: maximum), true);
    });

    test('Size.isWithinBounds should return false if Size.width is too large',
        () {
      const size = Size(202, 100);
      const minimum = Size(199, 99);
      const maximum = Size(201, 101);
      expect(size.isWithinBounds(min: minimum, max: maximum), false);
    });

    test('Size.isWithinBounds should return false if Size.height is too large',
        () {
      const size = Size(200, 102);
      const minimum = Size(199, 99);
      const maximum = Size(201, 101);
      expect(size.isWithinBounds(min: minimum, max: maximum), false);
    });

    test('Size.isWithinBounds should return false if Size.width is too small',
        () {
      const size = Size(198, 100);
      const minimum = Size(199, 99);
      const maximum = Size(201, 101);
      expect(size.isWithinBounds(min: minimum, max: maximum), false);
    });

    test('Size.isWithinBounds should return false if Size.height is too small',
        () {
      const size = Size(200, 98);
      const minimum = Size(199, 99);
      const maximum = Size(201, 101);
      expect(size.isWithinBounds(min: minimum, max: maximum), false);
    });
  });

  ///
  /// Size.adjustToBounds
  ///

  group('Size.adjustToBounds', () {
    test(
        'Size.adjustToBounds should return the same size if no constraints are given',
        () {
      const size = Size(200, 100);
      final newSize = size.adjustToBounds();
      expect(newSize, size);
    });

    test(
        'Size.adjustToBounds should return the same size if it does not exceed any constraints',
        () {
      const size = Size(200, 100);
      const minimum = Size(199, 99);
      const maximum = Size(201, 101);
      final newSize = size.adjustToBounds(min: minimum, max: maximum);
      expect(newSize, size);
    });

    test(
        'Size.adjustToBounds should return the minimum width and maximum height if the respective constraints are exceeded',
        () {
      const size = Size(198, 102);
      const minimum = Size(199, 99);
      const maximum = Size(201, 101);
      final newSize = size.adjustToBounds(min: minimum, max: maximum);
      expect(newSize, const Size(199, 101));
    });

    test(
        'Size.adjustToBounds should return the maximum width and minimum height if the respective constraints are exceeded',
        () {
      const size = Size(202, 98);
      const minimum = Size(199, 99);
      const maximum = Size(201, 101);
      final newSize = size.adjustToBounds(min: minimum, max: maximum);
      expect(newSize, const Size(201, 99));
    });
  });
}
