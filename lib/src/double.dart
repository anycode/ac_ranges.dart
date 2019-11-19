part of ranges;

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

  static List<DoubleRange> listExcept(List<DoubleRange> source, List<DoubleRange> exceptions) {
    return _Range._listExcept(source, exceptions).map((r) => r as DoubleRange).toList();
  }

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
