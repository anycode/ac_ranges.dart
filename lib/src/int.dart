part of ranges;

class IntRange extends _NumRange {

  IntRange(int start, int end, {bool startInclusive = true, bool endInclusive = false}) :
        super(start, end, startInclusive, endInclusive, true);

  IntRange._() : super._(true);

  factory IntRange.parse(String input, {bool startInclusive, bool endInclusive}) {
    final IntRange ir = IntRange._();
    Match match;
    // int - date range
    match = regexValVal.firstMatch(input);
    if (match != null) {
      ir._startInclusive = match.group(1) == "[";
      ir._start = int.parse(match.group(2));
      ir._end = int.parse(match.group(4));
      ir._endInclusive = match.group(6) == "]";
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
    // -infinity - date range
    match = regexInfVal.firstMatch(input);
    if (match != null) {
      ir._startInclusive = false; // infinity is always open
      ir._start = null;
      ir._end = int.parse(match.group(4));
      ir._endInclusive = match.group(4) == "]";
      ir._overrideInclusion(null, endInclusive);
      return ir;
    }
    // date - infinity range
    match = regexValInf.firstMatch(input);
    if (match != null) {
      ir._startInclusive = match.group(1) == "[";
      ir._start = int.parse(match.group(2));
      ir._end = null;
      ir._endInclusive = false; // infinity is always open
      ir._overrideInclusion(startInclusive, null);
      return ir;
    }
    return null;
  }

  // valid ranges [] incusive, () exclusive
  // [date,date], [date,date), (date, date], (date, date)
  static const String intRe = "[+-]?(0|[1-9][0-9]*)";
  static RegExp regexInfInf = RegExp("([\\(\\[])\\s*(-infinity)\\s*,\\s*(infinity)\\s*([\\]\\)])");
  static RegExp regexInfVal = RegExp("([\\(\\[])\\s*(-infinity)\\s*,\\s*($intRe)\\s*([\\]\\)])");
  static RegExp regexValInf = RegExp("([\\(\\[])\\s*($intRe)\\s*,\\s*(infinity)\\s*([\\]\\)])");
  static RegExp regexValVal = RegExp("([\\(\\[])\\s*($intRe)\\s*,\\s*($intRe)\\s*([\\]\\)])");

  @override
  _Range<num> newInstance() {
    return IntRange._();
  }

  @override
  num _next(num value) {
    return value == null ? null : value + 1;
  }

  @override
  num _prev(num value) {
    return value == null ? null : value - 1;
  }

}

