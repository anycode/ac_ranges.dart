part of ranges;

///
///  DataRangeConverter annotation
///  use with the DataRange members
///  e.g.
///  @JsonKey(name: 'date_range')
///  @DateRangeConverter()
///  DateRange dateRange;
///
class DateRangeConverter implements JsonConverter<DateRange, String> {

  const DateRangeConverter();

  @override
  DateRange fromJson(String json) {
    return DateRange.parse(json);
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
class DateRangesConverter implements JsonConverter<List<DateRange>, List<String>> {

  const DateRangesConverter();

  @override
  List<DateRange> fromJson(List<String> json) {
    return (json).map((input) => DateRange.parse(input)).toList();
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
    if(input == null) return null;
    final DateRange dr = DateRange._();
    Match match;
    // date - date range
    match = regexValVal.firstMatch(input);
    if (match != null) {
      dr._startInclusive = match.group(1) == "[";
      dr._start = DateTime.parse(match.group(2) + "T00:00:00Z");
      dr._end = DateTime.parse(match.group(3) + "T00:00:00Z");
      dr._endInclusive = match.group(4) == "]";
      dr._overrideInclusion(startInclusive, endInclusive);
      return dr;
    }
    // -infinity - infinity range
    match = regexInfInf.firstMatch(input);
    if (match != null) {
      dr._startInclusive = false; // infinity is always open
      dr._start = null;
      dr._end = null;
      dr._endInclusive = false; // infinity is always open
      return dr;
    }
    // -infinity - date range
    match = regexInfVal.firstMatch(input);
    if (match != null) {
      dr._startInclusive = false; // infinity is always open
      dr._start = null;
      dr._end = DateTime.parse(match.group(3) + "T00:00:00Z");
      dr._endInclusive = match.group(4) == "]";
      dr._overrideInclusion(null, endInclusive);
      return dr;
    }
    // date - infinity range
    match = regexValInf.firstMatch(input);
    if (match != null) {
      dr._startInclusive = match.group(1) == "[";
      dr._start = DateTime.parse(match.group(2) + "T00:00:00Z");
      dr._end = null;
      dr._endInclusive = false; // infinity is always open
      dr._overrideInclusion(startInclusive, null);
      return dr;
    }
    return null;
  }

  // valid ranges [] incusive, () exclusive
  // [date,date], [date,date), (date, date], (date, date)
  static const String dateRe = "[0-9]{4}-[0-9]{2}-[0-9]{2}";
  static RegExp regexInfInf = RegExp("([\\(\\[])\\s*(-infinity)\\s*,\\s*(infinity)\\s*([\\]\\)])");
  static RegExp regexInfVal = RegExp("([\\(\\[])\\s*(-infinity)\\s*,\\s*($dateRe)\\s*([\\]\\)])");
  static RegExp regexValInf = RegExp("([\\(\\[])\\s*($dateRe)\\s*,\\s*(infinity)\\s*([\\]\\)])");
  static RegExp regexValVal = RegExp("([\\(\\[])\\s*($dateRe)\\s*,\\s*($dateRe)\\s*([\\]\\)])");

  @override
  String toString() {
    final DateFormat df = DateFormat('yyyy-MM-dd');
    return "${_startInclusive && _start != null ? "[" : "("}${_start == null ? '-infinity' : df.format(_start)},${_end == null ? 'infinity' : df.format(_end)}${_endInclusive && _end != null ? "]" : ")"}";
  }

  @override
  _Range<DateTime> newInstance() {
    return DateRange._();
  }

  @override
  DateTime _next(DateTime value) {
    return value?.add(Duration(days: 1));
  }

  @override
  DateTime _prev(DateTime value) {
    return value?.subtract(Duration(days: 1));
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
