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

part of 'package:ac_ranges/ac_ranges.dart';

// MUST use _DiscreteRange<num>, not _DiscreteRange<int> as int is not Comparable<int> but Comparable<num>

/// Represents a range of integers.
///
/// This class allows defining a range with a start and end value,
/// and whether the start and end are inclusive or exclusive.
class IntRange extends DiscreteRange<num, int> {
  /// Creates a new [IntRange] with the specified [start] and [end] values.
  ///
  /// The [startInclusive] and [endInclusive] parameters determine whether the
  /// start and end values are included in the range, respectively.
  IntRange(super.start, super.end, {bool super.startInclusive = true, super.endInclusive = false});

  /// Creates an empty [IntRange].
  IntRange._() : super._();

  /// Parses a string representation of an integer range.
  ///
  /// The input string should be in one of the following formats:
  /// * _&lbrack;int,int&rbrack;_ (inclusive start and end)
  /// * _&lbrack;int,int)_ (inclusive start, exclusive end)
  /// * _(int,int&rbrack;_ (exclusive start, inclusive end)
  /// * _(int,int)_ (exclusive start and end)
  /// * _(-infinity,infinity)_ (open range)
  /// * _(-infinity,int&rbrack;_ or _(-infinity,int)_ (open start, inclusive/exclusive end)
  /// * _&lbrack;int,infinity)_ or _(int,infinity)_ (inclusive/exclusive start, open end)
  /// 
  /// Returns a [IntRange] instance if the input is valid, otherwise returns null.
  static IntRange? parse(String? input, {bool? startInclusive, bool? endInclusive}) {
    final range = DiscreteRange._parse<num, int>(input,
        regexInfInf: regexInfInf,
        regexInfVal: regexInfVal,
        regexValInf: regexValInf,
        regexValVal: regexValVal,
        parser: (val) => int.parse(val),
        ctor: () => IntRange._(),
        startInclusive: startInclusive,
        endInclusive: endInclusive) as IntRange?;
    return range ;
  }

  // valid ranges [] incusive, () exclusive
  // [int,int], [int,int), (int,int], (int,int)
  /// Regular expression for a int number.
  static const String valRe = "[+-]?(?:0|[1-9][0-9]*)";
  /// Regular expression for a range from negative to positive infinity.
  static RegExp regexInfInf = Range._createRegex('-infinity', 'infinity');
  /// Regular expression for a range from negative infinity to a int.
  static RegExp regexInfVal = Range._createRegex('-infinity', valRe);
  /// Regular expression for a range from a int to positive infinity.
  static RegExp regexValInf = Range._createRegex(valRe, 'infinity');
  /// Regular expression for a range between two ints.
  static RegExp regexValVal = Range._createRegex(valRe, valRe);

  /// Creates a new list of [intRange] instances by excluding ranges from a source list.
  ///
  /// The [source] list contains the original ranges, and the [exceptions] list contains the ranges to exclude.
  /// Returns a new list of [intRange] instances representing the remaining ranges after exclusion.
  static List<IntRange> listExcept(List<IntRange> source, List<IntRange> exceptions) {
    return Range._listExcept(source, exceptions).map((r) => r as IntRange).toList();
  }

  /// Creates a new empty instance of the range.
  ///
  /// This method is used internally for operations that require creating a new range instance.
  /// Returns a new empty [intRange] instance.
  @override
  IntRange newInstance() => IntRange._();

  @override
  Iterator<int> get iterator => _start != null && _end != null
      ? _RangeIterator<num, int>(this)
      : throw Exception('Cannot iterate over infinite range');

  /// Returns the next value in the range.
  ///
  /// If the [value] is null, it returns null.
  /// Otherwise, it returns the next integer value after the [value].
  /// This method is used internally for iterating through the range.
  /// Returns the next integer value or null.
  @override
  num? _next(num? value) {
    return value == null ? null : value + 1;
  }

  /// Returns the previous value in the range.
  ///
  /// If the [value] is null, it returns null.
  /// Otherwise, it returns the previous integer value before the [value].
  /// This method is used internally for iterating through the range.
  @override
  num? _prev(num? value) {
    return value == null ? null : value - 1;
  }
}
