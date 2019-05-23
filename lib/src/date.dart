part of ranges;

///
///  DataRangeConverter annotation
///  use with the DataRange members
///  e.g.
///  @JsonKey(name: 'date_range')
///  @DateRangeConverter()
///  DateRange dateRange;
///
class DateRangeConverter implements JsonConverter<DateRange, Object> {

  const DateRangeConverter();

  @override
  DateRange fromJson(Object json) {
    return DateRange.parse(json as String);
  }

  @override
  String toJson(DateRange range) {
    return range.toString();
  }
}

///
///  DataRangesConverter annotation
///  use with the List of DataRange members
///  e.g.
///  @JsonKey(name: 'date_ranges')
///  @DateRangesConverter()
///  List<DateRange> dateRanges;
///
class DateRangesConverter implements JsonConverter<List<DateRange>, Object> {

  const DateRangesConverter();

  @override
  List<DateRange> fromJson(Object json) {
    return (json as List).map((input) => DateRange.parse(input as String)).toList();
  }

  @override
  List<String> toJson(List<DateRange> ranges) {
    return ranges.map((DateRange range) => range.toString()).toList();
  }
}

class DateRange extends _Range<DateTime> {

  DateRange(DateTime start, DateTime end, {bool startInclusive = true, bool endInclusive = false}) :
        super(start, end, startInclusive, endInclusive, true);

  DateRange._() : super._(true);

  factory DateRange.parse(String input, {bool startInclusive, bool endInclusive}) {
    final Match match = regex.firstMatch(input);
    final DateRange dr = DateRange._();
    if (match != null) {
      dr._startInclusive = match.group(1) == "[";
      dr._start = DateTime.parse(match.group(2) + "T00:00:00Z");
      dr._end = DateTime.parse(match.group(3) + "T00:00:00Z");
      dr._endInclusive = match.group(4) == "]";
      dr._overrideInclusion(startInclusive, endInclusive);
    }
    return dr;
  }

  // valid ranges [] incusive, () exclusive
  // [date,date], [date,date), (date, date], (date, date)
  static const String dateRe = "[0-9]{4}-[0-9]{2}-[0-9]{2}";
  static RegExp regex = RegExp("([\\(\\[])\\s*($dateRe)\\s*,\\s*($dateRe)\\s*([\\]\\)])");

  @override
  String toString() {
    final DateFormat df = DateFormat('yyyy-MM-dd');
    return "${_startInclusive ? "[" : "("}${df.format(_start)},${df.format(_end)}${_endInclusive ? "]" : ")"}";
  }

  @override
  _Range<DateTime> newInstance() {
    return DateRange._();
  }

  @override
  DateTime _next(DateTime value) {
    return value.add(Duration(days: 1));
  }

  @override
  DateTime _prev(DateTime value) {
    return value.subtract(Duration(days: 1));
  }

  /// DO NOT CALL initializeDateFormatting() HERE!!!!
  ///  initializeDateFormatting() is an async call (Future) and can cause troubles in AngularDart (AD)
  ///  as it causes a change to be detected and AD will loop forever
  ///
  ///  Init Date Formatting locale in caller's call before calling DateRange.format(), e.g.
  ///  initializeDateFormatting()
  ///   .then((_) => daterange.format("{{start}} - {{end}}", "E dd.MM.", locale: "cs_CZ");
  String format(String fmt, String dateFormat, {String locale, String inclusiveTag, String exclusiveTag}) {
    final DateFormat df = DateFormat(dateFormat, locale);
    String buffer = fmt
        .replaceAll("{{start}}", df.format(_start) +
        (_startInclusive
          ? inclusiveTag != null ? inclusiveTag : ""
          : exclusiveTag != null ? exclusiveTag : ""))
        .replaceAll("{{end}}", df.format(_end) +
        (_endInclusive
          ? inclusiveTag != null  ? inclusiveTag : ""
          : exclusiveTag != null ? exclusiveTag : ""));
    return buffer;
  }

}
