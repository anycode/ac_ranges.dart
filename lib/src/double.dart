part of ranges;

///
///  DoubleRangeConverter annotation
///  use with the DoubleRange members
///  e.g.
///  @JsonKey(name: 'double_range')
///  @DoubleRangeConverter()
///  DoubleRange doubleRange;
///
class DoubleRangeConverter implements JsonConverter<DoubleRange, String> {

  const DoubleRangeConverter();

  @override
  DoubleRange fromJson(String json) {
    return DoubleRange.parse(json);
  }

  @override
  String toJson(DoubleRange range) {
    return range.toString();
  }
}

///
///  DoubleRangesConverter annotation
///  use with the List of DoubleRange members
///  e.g.
///  @JsonKey(name: 'double_ranges')
///  @DoubleRangesConverter()
///  List<DoubleRange> doubleRanges;
///
class DoubleRangesConverter implements JsonConverter<List<DoubleRange>, List<String>> {

  const DoubleRangesConverter();

  @override
  List<DoubleRange> fromJson(List<String> json) {
    return (json).map((input) => DoubleRange.parse(input)).toList();
  }

  @override
  List<String> toJson(List<DoubleRange> ranges) {
    return ranges.map((DoubleRange range) => range.toString()).toList();
  }
}

class DoubleRange extends _NumRange {

  DoubleRange(double start, double end, {bool startInclusive = true, bool endInclusive = false}) :
        super(start, end, startInclusive, endInclusive, false);

  DoubleRange._() : super._(false);

  factory DoubleRange.parse(String input) {
    final DoubleRange ir = DoubleRange._();
    Match match;
    match = regexValVal.firstMatch(input);
    // double - double range
    if (match != null) {
      ir._startInclusive = match.group(1) == "[";
      ir._start = double.parse(match.group(2));
      ir._end = double.parse(match.group(6));
      ir._endInclusive = match.group(10) == "]";
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
      ir._end = double.parse(match.group(6));
      ir._endInclusive = match.group(10) == "]";
      return ir;
    }
    // double - infinity range
    match = regexValInf.firstMatch(input);
    if (match != null) {
      ir._startInclusive = match.group(1) == "[";
      ir._start = double.parse(match.group(2));
      ir._end = null;
      ir._endInclusive = false;
      return ir;
    }
    return null;
  }

  // valid ranges [] incusive, () exclusive
  // [date,date], [date,date), (date, date], (date, date)
  static const String doubleRe = "[+-]?(0|[1-9][0-9]*)(\\.[0-9]+([eE][-+]?[0-9]+)?)?";
  static RegExp regexInfInf = RegExp("([\\(\\[])\\s*(-infinity)\\s*,\\s*(infinity)\\s*([\\]\\)])");
  static RegExp regexInfVal = RegExp("([\\(\\[])\\s*(-infinity)\\s*,\\s*($doubleRe)\\s*([\\]\\)])");
  static RegExp regexValInf = RegExp("([\\(\\[])\\s*($doubleRe)\\s*,\\s*(infinity)\\s*([\\]\\)])");
  static RegExp regexValVal = RegExp("([\\(\\[])\\s*($doubleRe)\\s*,\\s*($doubleRe)\\s*([\\]\\)])");

  @override
  _Range<num> newInstance() {
    return DoubleRange._();
  }

  // double has no next/prev values
  @override
  num _next(num value) {
    return value;
  }

  @override
  num _prev(num value) {
    return value;
  }

}
