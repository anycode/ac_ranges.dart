part of 'package:ac_ranges/ac_ranges.dart';

/// Represents a range of integers.
///
/// This class allows defining a range with a start and end value,
/// and whether the start and end are inclusive or exclusive.
class IntRange extends _NumRange {
  /// Creates a new [IntRange] with the specified [start] and [end] values.
  ///
  /// The [startInclusive] and [endInclusive] parameters determine whether the
  /// start and end values are included in the range, respectively.
  IntRange(int start, int end, {bool startInclusive = true, bool endInclusive = false})
      : super(start, end, startInclusive, endInclusive, true);

  /// Creates an empty [IntRange].
  IntRange._() : super._(true);

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
    if (input == null) return null;
    final IntRange ir = IntRange._();
    Match? match;
    // int - int range
    match = regexValVal.firstMatch(input);
    if (match != null) {
      ir._startInclusive = match.group(1) == "[";
      ir._start = int.parse(match.group(2)!);
      ir._end = int.parse(match.group(3)!);
      ir._endInclusive = match.group(4) == "]";
      ir._overrideInclusion(startInclusive, endInclusive);
      return ir;
    }
    // -infinity - infinity range
    match = regexInfInf.firstMatch(input);
    if (match != null) {
      ir._startInclusive = false; // infinity is always open
      ir._start = null;
      ir._end = null;
      ir._endInclusive = false; // infinity is always open
      return ir;
    }
    // -infinity - int range
    match = regexInfVal.firstMatch(input);
    if (match != null) {
      ir._startInclusive = false; // infinity is always open
      ir._start = null;
      ir._end = int.parse(match.group(3)!);
      ir._endInclusive = match.group(4) == "]";
      ir._overrideInclusion(null, endInclusive);
      return ir;
    }
    // int - infinity range
    match = regexValInf.firstMatch(input);
    if (match != null) {
      ir._startInclusive = match.group(1) == "[";
      ir._start = int.parse(match.group(2)!);
      ir._end = null;
      ir._endInclusive = false; // infinity is always open
      ir._overrideInclusion(startInclusive, null);
      return ir;
    }
    return null;
  }

  // valid ranges [] incusive, () exclusive
  // [int,int], [int,int), (int,int], (int,int)
  /// Regular expression for a int number.
  static const String intRe = "[+-]?(?:0|[1-9][0-9]*)";
  /// Regular expression for a range from negative to positive infinity.
  static RegExp regexInfInf = RegExp("([\\(\\[])\\s*(-infinity)\\s*,\\s*(infinity)\\s*([\\]\\)])");
  /// Regular expression for a range from negative infinity to a int.
  static RegExp regexInfVal = RegExp("([\\(\\[])\\s*(-infinity)\\s*,\\s*($intRe)\\s*([\\]\\)])");
  /// Regular expression for a range from a int to positive infinity.
  static RegExp regexValInf = RegExp("([\\(\\[])\\s*($intRe)\\s*,\\s*(infinity)\\s*([\\]\\)])");
  /// Regular expression for a range between two ints.
  static RegExp regexValVal = RegExp("([\\(\\[])\\s*($intRe)\\s*,\\s*($intRe)\\s*([\\]\\)])");

  /// Creates a new list of [intRange] instances by excluding ranges from a source list.
  ///
  /// The [source] list contains the original ranges, and the [exceptions] list contains the ranges to exclude.
  /// Returns a new list of [intRange] instances representing the remaining ranges after exclusion.
  static List<IntRange> listExcept(List<IntRange> source, List<IntRange> exceptions) {
    return _Range._listExcept(source, exceptions).map((r) => r as IntRange).toList();
  }

  /// Creates a new empty instance of the range.
  ///
  /// This method is used internally for operations that require creating a new range instance.
  /// Returns a new empty [intRange] instance.
  @override
  _Range<num> newInstance() {
    return IntRange._();
  }

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
