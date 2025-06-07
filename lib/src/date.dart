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

/// Represents a range of dates.
///
/// This class extends [Range] and provides specific functionality for
/// working with date ranges. It supports inclusive and exclusive boundaries,
/// parsing from string representations, and formatting date ranges.
class DateRange extends DiscreteRange<DateTime> {
  /// Creates a new [DateRange] instance.
  ///
  /// The [start] and [end] parameters define the boundaries of the range.
  /// If [start] or [end] is null, it represents negative or positive infinity, respectively.
  ///
  /// [startInclusive] determines whether the start date is included in the range.
  /// [endInclusive] determines whether the end date is included in the range.
  ///
  /// The time part of the start and end dates is ignored, and only the date part is considered.
  DateRange(DateTime? start, DateTime? end, {bool startInclusive = true, bool endInclusive = false})
      : super(start == null ? null : DateTime.utc(start.year, start.month, start.day),
            end == null ? null : DateTime.utc(end.year, end.month, end.day), startInclusive, endInclusive);

  DateRange._() : super._();

  /// Parses a string representation of a date range.
  ///
  /// The [input] string should be in one of the following formats:
  ///
  /// * _&lbrack;date,date&rbrack;_ (inclusive start and end)
  /// * _&lbrack;date,date)_ (inclusive start, exclusive end)
  /// * _(date,date&rbrack;_ (exclusive start, inclusive end)
  /// * _(date,date)_ (exclusive start and end)
  /// * _(-infinity,infinity)_ (open range)
  /// * _(-infinity,date&rbrack;_ or _(-infinity,date)_ (open start, inclusive/exclusive end)
  /// * _&lbrack;date,infinity)_ or _(date,infinity)_ (inclusive/exclusive start, open end)
  ///
  /// The [startInclusive] and [endInclusive] parameters can be used to override the inclusivity of the start and end dates.
  /// If not provided, the inclusivity is determined from the input string.
  ///
  /// Example:
  /// ```dart
  /// DateRange.parse("[2023-01-01,2023-01-31]"); // Inclusive start and end
  /// DateRange.parse("[2023-01-01,2023-01-31)", startInclusive: false); // Exclusive start, exclusive end
  /// DateRange.parse("(-infinity,2023-01-31]"); // Open start, inclusive end
  /// DateRange.parse("[2023-01-01,infinity)"); // Inclusive start, open end
  /// DateRange.parse("(-infinity,infinity)"); // Open range
  /// ```
  ///
  /// Returns a [DateRange] object representing the parsed date range, or null if the input string is invalid.
  static DateRange? parse(String? input, {bool? startInclusive, bool? endInclusive}) {
    final range = DiscreteRange._parse<DateTime>(input,
        regexInfInf: regexInfInf,
        regexInfVal: regexInfVal,
        regexValInf: regexValInf,
        regexValVal: regexValVal,
        parser: (val) => DateTime.parse("${val}T00:00:00Z"),
        ctor: () => DateRange._(),
        startInclusive: startInclusive,
        endInclusive: endInclusive) as DateRange?;
    return range;
  }

  /// Regular expression for a date.
  static const String valRe = "[0-9]{4}-[0-9]{2}-[0-9]{2}";
  /// Regular expression for a range from negative to positive infinity.
  static RegExp regexInfInf = Range._createRegex('-infinity', 'infinity');
  /// Regular expression for a range from negative infinity to a date.
  static RegExp regexInfVal = Range._createRegex('-infinity', valRe);
  /// Regular expression for a range from a date to positive infinity.
  static RegExp regexValInf = Range._createRegex(valRe, 'infinity');
  /// Regular expression for a range between two dates.
  static RegExp regexValVal = Range._createRegex(valRe, valRe);

  /// Returns a list of [DateRange] objects that represent the difference between the [source] and [exceptions] lists.
  ///
  /// This method calculates the ranges that are in the [source] list but not in the [exceptions] list.
  ///
  /// [source] The list of [DateRange] objects to subtract from.
  /// [exceptions] The list of [DateRange] objects to subtract.
  /// Returns a new list of [DateRange] objects representing the difference.
  static List<DateRange> listExcept(List<DateRange> source, List<DateRange> exceptions) {
    return Range._listExcept(source, exceptions).map((r) => r as DateRange).toList();
  }

  /// Returns a string representation of the date range.
  ///
  /// The format is _&lbrack;start,end&rbrack;_ for inclusive start and end, _&lbrack;start,end)_ for inclusive start and exclusive end,
  /// _(start,end&rbrack;_ for exclusive start and inclusive end, and _(start,end)_ for exclusive start and end.
  @override
  String toString() {
    final DateFormat df = DateFormat('yyyy-MM-dd');
    return "${_startInclusive && _start != null ? "[" : "("}${_start == null ? '-infinity' : df.format(_start!)},${_end == null ? 'infinity' : df.format(_end!)}${_endInclusive && _end != null ? "]" : ")"}";
  }

  /// Creates a new instance of [DateRange].
  ///
  /// This method is used internally by the [Range] class to create new instances of the same type.
  @override
  DateRange newInstance() => DateRange._();

  /// Returns the next date after the given [value].
  ///
  /// If [value] is null, returns null.
  /// Otherwise, returns the next day after [value].
  @override
  DateTime? _next(DateTime? value) {
    return value?.add(Duration(days: 1));
  }

  /// Returns the previous date before the given [value].
  ///
  /// If [value] is null, returns null.
  /// Otherwise, returns the previous day before [value].
  @override
  DateTime? _prev(DateTime? value) {
    return value?.subtract(Duration(days: 1));
  }

  /// Formats the date range into a string using the specified format.
  ///
  /// The [fmt] parameter is a template string that can contain the placeholders `{{start}}` and `{{end}}`.
  /// These placeholders will be replaced with the formatted start and end dates, respectively.
  ///
  /// The [dateFormat] parameter specifies the format for the dates using the `DateFormat` class.
  ///
  /// The [locale] parameter specifies the locale for formatting the dates.
  ///
  /// The [inclusiveTag] and [exclusiveTag] parameters are used to indicate whether the start and end dates are inclusive or exclusive.
  /// If not provided, no tag is added.
  ///
  /// The [startInclusive] and [endInclusive] parameters can be used to override the default inclusivity of the range.
  ///
  /// Example:
  /// ```dart
  /// DateRange(DateTime(2023, 1, 1), DateTime(2023, 1, 3), startInclusive: true, endInclusive: false)
  ///   .format("Range: {{start}} - {{end}}", "dd.MM.yyyy", inclusiveTag: "[", exclusiveTag: ")");
  /// // Output: "Range: [01.01.2023 - 03.01.2023)"
  /// ```
  ///
  /// Note: initializeDateFormatting() should be called before using this method.
  ///
  ///  Init Date Formatting locale in caller's call before calling DateRange.format(), e.g.
  ///  ```dart
  ///  initializeDateFormatting()
  ///   .then((_) => daterange.format("{{start}} - {{end}}", "E dd.MM.", locale: "cs_CZ");
  ///  ```
  String format(String fmt, String dateFormat, {String? locale, String? inclusiveTag, String? exclusiveTag,
    bool? startInclusive, bool? endInclusive}) {
    final DateFormat df = DateFormat(dateFormat, locale);
    final DateTime? s = start(inclusive: startInclusive ?? _startInclusive);
    final DateTime? e = end(inclusive: endInclusive ?? _endInclusive);
    String buffer = fmt
        .replaceAll(
            '{{start}}',
            s == null
                ? ''
                : df.format(s) +
                    (startInclusive ??_startInclusive
                        ? inclusiveTag ?? ''
                        : exclusiveTag ?? ''))
        .replaceAll(
            '{{end}}',
            e == null
                ? ''
                : df.format(e) +
                    (endInclusive ??_endInclusive
                        ? inclusiveTag ?? ''
                        : exclusiveTag ?? ''));
    return buffer;
  }
}
