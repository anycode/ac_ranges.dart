import 'package:ac_ranges/ac_ranges.dart';
import 'package:test/test.dart';

void main() {
  group('DoubleRange tests', () {
    test('constructor', () {
      final range = DoubleRange(1.5, 10.5);
      expect(range.start(), 1.5);
      expect(range.end(), 10.5);
      expect(range.startInclusive, isTrue);
      expect(range.endInclusive, isFalse);
    });

    test('constructor - inclusive/exclusive options', () {
      final range1 = DoubleRange(1.5, 10.5, startInclusive: false, endInclusive: true);
      expect(range1.startInclusive, isFalse);
      expect(range1.endInclusive, isTrue);

      final range2 = DoubleRange(1.5, 10.5, startInclusive: true, endInclusive: true);
      expect(range2.startInclusive, isTrue);
      expect(range2.endInclusive, isTrue);

      final range3 = DoubleRange(1.5, 10.5, startInclusive: false, endInclusive: false);
      expect(range3.startInclusive, isFalse);
      expect(range3.endInclusive, isFalse);
    });

    test('parse - standard ranges', () {
      // Inclusive start, exclusive end
      final range1 = DoubleRange.parse('[1.5,10.5)');
      expect(range1!.start(), 1.5);
      expect(range1.end(), 10.5);
      expect(range1.startInclusive, isTrue);
      expect(range1.endInclusive, isFalse);

      // Exclusive start, inclusive end
      final range2 = DoubleRange.parse('(5.5,15.5]');
      expect(range2!.start(), 5.5);
      expect(range2.end(), 15.5);
      expect(range2.startInclusive, isFalse);
      expect(range2.endInclusive, isTrue);

      // Both inclusive
      final range3 = DoubleRange.parse('[20.5,30.5]');
      expect(range3!.start(), 20.5);
      expect(range3.end(), 30.5);
      expect(range3.startInclusive, isTrue);
      expect(range3.endInclusive, isTrue);

      // Both exclusive
      final range4 = DoubleRange.parse('(40.5,50.5)');
      expect(range4!.start(), 40.5);
      expect(range4.end(), 50.5);
      expect(range4.startInclusive, isFalse);
      expect(range4.endInclusive, isFalse);

      // Negative numbers
      final range5 = DoubleRange.parse('[-10.5,0.0)');
      expect(range5!.start(), -10.5);
      expect(range5.end(), 0.0);
      expect(range5.startInclusive, isTrue);
      expect(range5.endInclusive, isFalse);

      // Scientific notation
      final range6 = DoubleRange.parse('[1.5e2,3.0e2)');
      expect(range6!.start(), 150.0);
      expect(range6.end(), 300.0);
    });

    test('parse - infinity ranges', () {
      // Full infinity range
      final infiniteRange = DoubleRange.parse('(-infinity,infinity)');
      expect(infiniteRange!.start(), isNull);
      expect(infiniteRange.end(), isNull);
      expect(infiniteRange.startInclusive, isFalse);
      expect(infiniteRange.endInclusive, isFalse);

      // From negative infinity to value
      final negInfRange = DoubleRange.parse('(-infinity,10.5]');
      expect(negInfRange!.start(), isNull);
      expect(negInfRange.end(), 10.5);
      expect(negInfRange.startInclusive, isFalse);
      expect(negInfRange.endInclusive, isTrue);

      // From value to infinity
      final posInfRange = DoubleRange.parse('[5.5,infinity)');
      expect(posInfRange!.start(), 5.5);
      expect(posInfRange.end(), isNull);
      expect(posInfRange.startInclusive, isTrue);
      expect(posInfRange.endInclusive, isFalse);
    });

    test('parse - invalid input', () {
      expect(DoubleRange.parse(null), isNull);
      expect(DoubleRange.parse(''), isNull);
      expect(DoubleRange.parse('invalid'), isNull);
      expect(DoubleRange.parse('[10.5]'), isNull);
      expect(DoubleRange.parse('[a,b)'), isNull);
    });

    test('contains', () {
      final range = DoubleRange(5.5, 10.5);

      // Values outside the range
      expect(range.contains(4.5), isFalse);
      expect(range.contains(10.5), isFalse); // exclusive end
      expect(range.contains(11.5), isFalse);

      // Values inside the range
      expect(range.contains(5.5), isTrue); // inclusive start
      expect(range.contains(7.5), isTrue);
      expect(range.contains(9.5), isTrue);

      // Test with different inclusion settings
      final range2 = DoubleRange(5.5, 10.5, startInclusive: false, endInclusive: true);
      expect(range2.contains(5.5), isFalse); // exclusive start
      expect(range2.contains(6.5), isTrue);
      expect(range2.contains(10.5), isTrue); // inclusive end
    });

    test('overlaps', () {
      final range1 = DoubleRange(5.5, 15.5);
      final range2 = DoubleRange(10.5, 20.5);
      final range3 = DoubleRange(20.5, 30.5);
      final range4 = DoubleRange(0.5, 3.5);

      // Overlapping ranges
      expect(range1.overlaps(range2), isTrue);
      expect(range2.overlaps(range1), isTrue);

      // Non-overlapping ranges
      expect(range1.overlaps(range3), isFalse);
      expect(range1.overlaps(range4), isFalse);

      // Adjacent ranges (touching but not overlapping due to exclusive end)
      expect(range2.overlaps(range3), isFalse);

      // Test with infinite ranges
      final infiniteRange = DoubleRange.parse('(-infinity,infinity)')!;
      expect(infiniteRange.overlaps(range1), isTrue);
      expect(range1.overlaps(infiniteRange), isTrue);
    });

    test('intersection', () {
      final range1 = DoubleRange(5.5, 15.5);
      final range2 = DoubleRange(10.5, 20.5);
      final range3 = DoubleRange(20.5, 30.5);

      // Overlapping ranges
      final intersection1 = range1.intersect(range2);
      expect(intersection1!.start(), 10.5);
      expect(intersection1.end(), 15.5);

      // Non-overlapping ranges
      final intersection2 = range1.intersect(range3);
      expect(intersection2, isNull);

      // Test with infinite ranges
      final infiniteRange = DoubleRange.parse('(-infinity,infinity)')!;
      final intersection3 = infiniteRange.intersect(range1);
      expect(intersection3!.start(), 5.5);
      expect(intersection3.end(), 15.5);
    });

    test('toString', () {
      final range1 = DoubleRange(1.5, 10.5);
      expect(range1.toString(), '[1.5,10.5)');

      final range2 = DoubleRange(5.5, 15.5, startInclusive: false, endInclusive: true);
      expect(range2.toString(), '(5.5,15.5]');

      final range3 = DoubleRange(20.5, 30.5, startInclusive: true, endInclusive: true);
      expect(range3.toString(), '[20.5,30.5]');

      final range4 = DoubleRange(40.5, 50.5, startInclusive: false, endInclusive: false);
      expect(range4.toString(), '(40.5,50.5)');

      final infiniteRange = DoubleRange.parse('(-infinity,infinity)')!;
      expect(infiniteRange.toString(), '(-infinity,infinity)');
    });

    test('listExcept', () {
      final sources = [
        DoubleRange(1.0, 10.0),
        DoubleRange(20.0, 30.0),
        DoubleRange(40.0, 50.0)
      ];
      final exceptions = [
        DoubleRange(5.0, 25.0)
      ];

      final result = DoubleRange.listExcept(sources, exceptions);
      expect(result.length, 3);

      expect(result[0].start(), 1.0);
      expect(result[0].end(), 5.0);

      expect(result[1].start(), 25.0);
      expect(result[1].end(), 30.0);

      expect(result[2].start(), 40.0);
      expect(result[2].end(), 50.0);
    });

    test('equality', () {
      final range1 = DoubleRange(1.5, 10.5);
      final range2 = DoubleRange(1.5, 10.5);
      final range3 = DoubleRange(2.5, 10.5);
      final range4 = DoubleRange(1.5, 11.5);
      final range5 = DoubleRange(1.5, 10.5, startInclusive: false);
      final range6 = DoubleRange(1.5, 10.5, endInclusive: true);

      expect(range1 == range2, isTrue);
      expect(range1 == range3, isFalse);
      expect(range1 == range4, isFalse);
      expect(range1 == range5, isFalse);
      expect(range1 == range6, isFalse);
    });
  });
}
