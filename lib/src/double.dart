part of 'package:ac_ranges/ac_ranges.dart';

// MUST use _Range<num>, not _Range<double> as double is not Comparable<double> but Comparable<num>

/// Represents a range of double values.
///
/// This class allows defining a range with a start and end value,
/// and whether the start and end are inclusive or exclusive.
class DoubleRange extends _Range<num> {
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
  static DoubleRange? parse(String? input) {
    if (input == null) return null;
    final DoubleRange ir = DoubleRange._();
    Match? match;
    match = regexValVal.firstMatch(input);
    // double - double range
    if (match != null) {
      ir._startInclusive = match.group(1) == "[";
      ir._start = double.parse(match.group(2)!);
      ir._end = double.parse(match.group(3)!);
      ir._endInclusive = match.group(4) == "]";
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
    // -infinity - double range
    match = regexInfVal.firstMatch(input);
    if (match != null) {
      ir._startInclusive = false;
      ir._start = null;
      ir._end = double.parse(match.group(3)!);
      ir._endInclusive = match.group(4) == "]";
      return ir;
    }
    // double - infinity range
    match = regexValInf.firstMatch(input);
    if (match != null) {
      ir._startInclusive = match.group(1) == "[";
      ir._start = double.parse(match.group(2)!);
      ir._end = null;
      ir._endInclusive = false;
      return ir;
    }
    return null;
  }

  /// Regular expression for a double number.
  static const String doubleRe = "[+-]?(?:0|[1-9][0-9]*)(?:\\.[0-9]+(?:[eE][-+]?[0-9]+)?)?";
  /// Regular expression for a range from negative to positive infinity.
  static RegExp regexInfInf = RegExp("([\\(\\[])\\s*(-infinity)\\s*,\\s*(infinity)\\s*([\\]\\)])");
  /// Regular expression for a range from negative infinity to a double.
  static RegExp regexInfVal = RegExp("([\\(\\[])\\s*(-infinity)\\s*,\\s*($doubleRe)\\s*([\\]\\)])");
  /// Regular expression for a range from a double to positive infinity.
  static RegExp regexValInf = RegExp("([\\(\\[])\\s*($doubleRe)\\s*,\\s*(infinity)\\s*([\\]\\)])");
  /// Regular expression for a range between two doubles.
  static RegExp regexValVal = RegExp("([\\(\\[])\\s*($doubleRe)\\s*,\\s*($doubleRe)\\s*([\\]\\)])");

  /// Creates a new list of [DoubleRange] instances by excluding ranges from a source list.
  ///
  /// The [source] list contains the original ranges, and the [exceptions] list contains the ranges to exclude.
  /// Returns a new list of [DoubleRange] instances representing the remaining ranges after exclusion.
  static List<DoubleRange> listExcept(List<DoubleRange> source, List<DoubleRange> exceptions) {
    return _Range._listExcept(source, exceptions).map((r) => r as DoubleRange).toList();
  }

  /// Creates a new empty instance of the range.
  ///
  /// This method is used internally for operations that require creating a new range instance.
  /// Returns a new empty [DoubleRange] instance.
  @override
  _Range<num> newInstance() {
    return DoubleRange._();
  }

}
