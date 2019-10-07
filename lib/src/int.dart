part of ranges;

///
///  IntRangeConverter annotation
///  use with the IntRange members
///  e.g.
///  @JsonKey(name: 'int_range')
///  @IntRangeConverter()
///  IntRange intRange;
///
class IntRangeConverter implements JsonConverter<IntRange, String> {

  const IntRangeConverter();

  @override
  IntRange fromJson(String json) {
    return IntRange.parse(json);
  }

  @override
  String toJson(IntRange range) {
    return range.toString();
  }
}

///
///  IntRangesConverter annotation
///  use with the List of IntRange members
///  e.g.
///  @JsonKey(name: 'int_ranges')
///  @IntRangesConverter()
///  List<IntRange> intRanges;
///
class IntRangesConverter implements JsonConverter<List<IntRange>, List<String>> {

  const IntRangesConverter();

  @override
  List<IntRange> fromJson(List<String> json) {
    return (json).map((input) => IntRange.parse(input)).toList();
  }

  @override
  List<String> toJson(List<IntRange> ranges) {
    return ranges.map((IntRange range) => range.toString()).toList();
  }
}

class IntRange extends _NumRange {

  IntRange(int start, int end, {bool startInclusive = true, bool endInclusive = false}) :
        super(start, end, startInclusive, endInclusive, true);

  IntRange._() : super._(true);

  factory IntRange.parse(String input, {bool startInclusive, bool endInclusive}) {
    final Match match = regex.firstMatch(input);
    final IntRange ir = IntRange._();
    if (match != null) {
      ir._startInclusive = match.group(1) == "[";
      ir._start = int.parse(match.group(2));
      ir._end = int.parse(match.group(4));
      ir._endInclusive = match.group(6) == "]";
      ir._overrideInclusion(startInclusive, endInclusive);
    }
    return ir;
  }

  // valid ranges [] incusive, () exclusive
  // [date,date], [date,date), (date, date], (date, date)
  static const String intRe = "[+-]?(0|[1-9][0-9]*)";
  static RegExp regex = RegExp("([\\(\\[])\\s*($intRe)\\s*,\\s*($intRe)\\s*([\\]\\)])");

  @override
  String toString() {
    return "${_startInclusive ? "[" : "("}$_start,$_end${_endInclusive ? "]" : ")"}";
  }

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

