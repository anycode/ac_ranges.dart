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

// MUST use _Range<num>, not _Range<double> as double is not Comparable<double> but Comparable<num>

/// Represents a range of double values.
///
/// This class allows defining a range with a start and end value,
/// and whether the start and end are inclusive or exclusive.
class DoubleRange extends Range<num> {
  /// Creates a new [DoubleRange] instance.
  ///
  /// The [start] and [end] parameters define the range's boundaries.
  /// [startInclusive] determines if the start value is included in the range (defaults to true).
  /// [endInclusive] determines if the end value is included in the range (defaults to false).
  DoubleRange(double start, double end, {bool startInclusive = true, bool endInclusive = false})
      : super(start, end, startInclusive, endInclusive);

  /// Creates a new empty [DoubleRange] instance.
  ///
  /// This constructor is used internally for parsing.
  DoubleRange._() : super._();

  /// Parses a string representation of a double range.
  ///
  /// The input string should be in one of the following formats:
  /// * _&lbrack;double,double&rbrack;_ (inclusive start and end)
  /// * _&lbrack;double,double)_ (inclusive start, exclusive end)
  /// * _(double,double&rbrack;_ (exclusive start, inclusive end)
  /// * _(double,double)_ (exclusive start and end)
  /// * _(-infinity,infinity)_ (open range)
  /// * _(-infinity,double&rbrack;_ or _(-infinity,double)_ (open start, inclusive/exclusive end)
  /// * _&lbrack;double,infinity)_ or _(double,infinity)_ (inclusive/exclusive start, open end)
  ///
  /// Returns a [DoubleRange] instance if the input is valid, otherwise returns null.
  static DoubleRange? parse(String? input, {bool? startInclusive, bool? endInclusive}) {
    final range = Range._parse<num>(input,
        regexInfInf: regexInfInf,
        regexInfVal: regexInfVal,
        regexValInf: regexValInf,
        regexValVal: regexValVal,
        parser: (val) => double.parse(val),
        ctor: () => DoubleRange._(),
        startInclusive: startInclusive,
        endInclusive: endInclusive) as DoubleRange?;
    return range;
  }

  /// Regular expression for a double number.
  static const String valRe = "[+-]?(?:0|[1-9][0-9]*)(?:\\.[0-9]+(?:[eE][-+]?[0-9]+)?)?";
  /// Regular expression for a range from negative to positive infinity.
  static RegExp regexInfInf = Range._createRegex('-infinity', 'infinity');
  /// Regular expression for a range from negative infinity to a double.
  static RegExp regexInfVal = Range._createRegex('-infinity', valRe);
  /// Regular expression for a range from a double to positive infinity.
  static RegExp regexValInf = Range._createRegex(valRe, 'infinity');
  /// Regular expression for a range between two doubles.
  static RegExp regexValVal = Range._createRegex(valRe, valRe);

  /// Creates a new list of [DoubleRange] instances by excluding ranges from a source list.
  ///
  /// The [source] list contains the original ranges, and the [exceptions] list contains the ranges to exclude.
  /// Returns a new list of [DoubleRange] instances representing the remaining ranges after exclusion.
  static List<DoubleRange> listExcept(List<DoubleRange> source, List<DoubleRange> exceptions) {
    return Range._listExcept(source, exceptions).map((r) => r as DoubleRange).toList();
  }

  /// Creates a new empty instance of the range.
  ///
  /// This method is used internally for operations that require creating a new range instance.
  /// Returns a new empty [DoubleRange] instance.
  @override
  DoubleRange newInstance() => DoubleRange._();

}
