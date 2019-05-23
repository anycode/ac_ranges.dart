part of ranges;

///
///  DoubleRangeConverter annotation
///  use with the DoubleRange members
///  e.g.
///  @JsonKey(name: 'double_range')
///  @DoubleRangeConverter()
///  DoubleRange doubleRange;
///
class DoubleRangeConverter implements JsonConverter<DoubleRange, Object> {

  const DoubleRangeConverter();

  @override
  DoubleRange fromJson(Object json) {
    return DoubleRange.parse(json as String);
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
class DoubleRangesConverter implements JsonConverter<List<DoubleRange>, Object> {

  const DoubleRangesConverter();

  @override
  List<DoubleRange> fromJson(Object json) {
    return (json as List).map((input) => DoubleRange.parse(input as String)).toList();
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
    final Match match = regex.firstMatch(input);
    final DoubleRange ir = DoubleRange._();
    if (match != null) {
      ir._startInclusive = match.group(1) == "[";
      ir._start = double.parse(match.group(2));
      ir._end = double.parse(match.group(6));
      ir._endInclusive = match.group(10) == "]";
    }
    return ir;
  }

  // valid ranges [] incusive, () exclusive
  // [date,date], [date,date), (date, date], (date, date)
  static const String doubleRe = "[+-]?(0|[1-9][0-9]*)(\\.[0-9]+([eE][-+]?[0-9]+)?)?";
  static RegExp regex = RegExp("([\\(\\[])\\s*($doubleRe)\\s*,\\s*($doubleRe)\\s*([\\]\\)])");

  @override
  String toString() {
    return "${_startInclusive ? "[" : "("}$_start,$_end${_endInclusive ? "]" : ")"}";
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
