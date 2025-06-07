/*
 * Copyright 2025 Martin Edlman - Anycode <ac@anycode.dev>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:ac_ranges/ac_ranges.dart';
import 'package:test/test.dart';

void main() {
  group('IntRange tests', () {
    test('constructor', () {
      final range = IntRange(1, 10);
      expect(range.start(), 1);
      expect(range.end(), 10);
      expect(range.startInclusive, isTrue);
      expect(range.endInclusive, isFalse);
    });

    test('constructor - inclusive/exclusive options', () {
      final range1 = IntRange(1, 10, startInclusive: false, endInclusive: true);
      expect(range1.startInclusive, isFalse);
      expect(range1.endInclusive, isTrue);

      final range2 = IntRange(1, 10, startInclusive: true, endInclusive: true);
      expect(range2.startInclusive, isTrue);
      expect(range2.endInclusive, isTrue);

      final range3 = IntRange(1, 10, startInclusive: false, endInclusive: false);
      expect(range3.startInclusive, isFalse);
      expect(range3.endInclusive, isFalse);
    });

    test('parse - standard ranges', () {
      // Inclusive start, exclusive end
      final range1 = IntRange.parse('[1,10)');
      expect(range1!.start(), 1);
      expect(range1.end(), 10);
      expect(range1.startInclusive, isTrue);
      expect(range1.endInclusive, isFalse);

      // Exclusive start, inclusive end
      final range2 = IntRange.parse('(5,15]');
      expect(range2!.start(), 5);
      expect(range2.end(), 15);
      expect(range2.startInclusive, isFalse);
      expect(range2.endInclusive, isTrue);

      // Both inclusive
      final range3 = IntRange.parse('[20,30]');
      expect(range3!.start(), 20);
      expect(range3.end(), 30);
      expect(range3.startInclusive, isTrue);
      expect(range3.endInclusive, isTrue);

      // Both exclusive
      final range4 = IntRange.parse('(40,50)');
      expect(range4!.start(), 40);
      expect(range4.end(), 50);
      expect(range4.startInclusive, isFalse);
      expect(range4.endInclusive, isFalse);

      // Negative numbers
      final range5 = IntRange.parse('[-10,0)');
      expect(range5!.start(), -10);
      expect(range5.end(), 0);
      expect(range5.startInclusive, isTrue);
      expect(range5.endInclusive, isFalse);
    });

    test('parse - infinity ranges', () {
      // Full infinity range
      final infiniteRange = IntRange.parse('(-infinity,infinity)');
      expect(infiniteRange!.start(), isNull);
      expect(infiniteRange.end(), isNull);
      expect(infiniteRange.startInclusive, isFalse);
      expect(infiniteRange.endInclusive, isFalse);

      // From negative infinity to value
      final negInfRange = IntRange.parse('(-infinity,10]');
      expect(negInfRange!.start(), isNull);
      expect(negInfRange.end(), 10);
      expect(negInfRange.startInclusive, isFalse);
      expect(negInfRange.endInclusive, isTrue);

      // From value to infinity
      final posInfRange = IntRange.parse('[5,infinity)');
      expect(posInfRange!.start(), 5);
      expect(posInfRange.end(), isNull);
      expect(posInfRange.startInclusive, isTrue);
      expect(posInfRange.endInclusive, isFalse);
    });

    test('parse - invalid input', () {
      expect(IntRange.parse(null), isNull);
      expect(IntRange.parse(''), isNull);
      expect(IntRange.parse('invalid'), isNull);
      expect(IntRange.parse('[10]'), isNull);
      expect(IntRange.parse('[a,b)'), isNull);
    });

    test('contains', () {
      final range = IntRange(5, 10);

      // Values outside the range
      expect(range.contains(4), isFalse);
      expect(range.contains(10), isFalse); // exclusive end
      expect(range.contains(11), isFalse);

      // Values inside the range
      expect(range.contains(5), isTrue); // inclusive start
      expect(range.contains(7), isTrue);
      expect(range.contains(9), isTrue);

      // Test with different inclusion settings
      final range2 = IntRange(5, 10, startInclusive: false, endInclusive: true);
      expect(range2.contains(5), isFalse); // exclusive start
      expect(range2.contains(6), isTrue);
      expect(range2.contains(10), isTrue); // inclusive end
    });

    test('overlaps', () {
      final range1 = IntRange(5, 15);
      final range2 = IntRange(10, 20);
      final range3 = IntRange(20, 30);
      final range4 = IntRange(0, 3);

      // Overlapping ranges
      expect(range1.overlaps(range2), isTrue);
      expect(range2.overlaps(range1), isTrue);

      // Non-overlapping ranges
      expect(range1.overlaps(range3), isFalse);
      expect(range1.overlaps(range4), isFalse);

      // Adjacent ranges (touching but not overlapping due to exclusive end)
      expect(range2.overlaps(range3), isFalse);

      // Test with infinite ranges
      final infiniteRange = IntRange.parse('(-infinity,infinity)')!;
      expect(infiniteRange.overlaps(range1), isTrue);
      expect(range1.overlaps(infiniteRange), isTrue);
    });

    test('intersection', () {
      final range1 = IntRange(5, 15);
      final range2 = IntRange(10, 20);
      final range3 = IntRange(20, 30);

      // Overlapping ranges
      final intersection1 = range1.intersect(range2);
      expect(intersection1!.start(), 10);
      expect(intersection1.end(), 15);

      // Non-overlapping ranges
      final intersection2 = range1.intersect(range3);
      expect(intersection2, isNull);

      // Test with infinite ranges
      final infiniteRange = IntRange.parse('(-infinity,infinity)')!;
      final intersection3 = infiniteRange.intersect(range1);
      expect(intersection3!.start(), 5);
      expect(intersection3.end(), 15);
    });

    test('toString', () {
      final range1 = IntRange(1, 10);
      expect(range1.toString(), '[1,10)');

      final range2 = IntRange(5, 15, startInclusive: false, endInclusive: true);
      expect(range2.toString(), '(5,15]');

      final range3 = IntRange(20, 30, startInclusive: true, endInclusive: true);
      expect(range3.toString(), '[20,30]');

      final range4 = IntRange(40, 50, startInclusive: false, endInclusive: false);
      expect(range4.toString(), '(40,50)');

      final infiniteRange = IntRange.parse('(-infinity,infinity)')!;
      expect(infiniteRange.toString(), '(-infinity,infinity)');
    });

    test('listExcept', () {
      final sources = [
        IntRange(1, 10),
        IntRange(20, 30),
        IntRange(40, 50)
      ];
      final exceptions = [
        IntRange(5, 25)
      ];

      final result = IntRange.listExcept(sources, exceptions);
      expect(result.length, 3);

      expect(result[0].start(), 1);
      expect(result[0].end(), 5);

      expect(result[1].start(), 25);
      expect(result[1].end(), 30);

      expect(result[2].start(), 40);
      expect(result[2].end(), 50);
    });

    test('equality', () {
      final range1 = IntRange(1, 10);
      final range2 = IntRange(1, 10);
      final range3 = IntRange(2, 10);
      final range4 = IntRange(1, 11);
      final range5 = IntRange(1, 10, startInclusive: false);
      final range6 = IntRange(1, 10, endInclusive: true);

      expect(range1 == range2, isTrue);
      expect(range1 == range3, isFalse);
      expect(range1 == range4, isFalse);
      expect(range1 == range5, isFalse);
      expect(range1 == range6, isFalse);
    });
  });
}
