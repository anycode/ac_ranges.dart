part of ranges;

class DateRange extends _Range<DateTime> {
  DateRange(DateTime? start, DateTime? end, {bool startInclusive = true, bool endInclusive = false})
      : super(start == null ? null : DateTime.utc(start.year, start.month, start.day),
            end == null ? null : DateTime.utc(end.year, end.month, end.day), startInclusive, endInclusive, true);

  DateRange._() : super._(true);

  static DateRange? parse(String? input, {bool? startInclusive, bool? endInclusive}) {
    if (input == null) return null;
    final DateRange dr = DateRange._();
    Match? match;
    // date - date range
    match = regexValVal.firstMatch(input);
    if (match != null) {
      dr._startInclusive = match.group(1) == "[";
      dr._start = DateTime.parse(match.group(2)! + "T00:00:00Z");
      dr._end = DateTime.parse(match.group(3)! + "T00:00:00Z");
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
      dr._end = DateTime.parse(match.group(3)! + "T00:00:00Z");
      dr._endInclusive = match.group(4) == "]";
      dr._overrideInclusion(null, endInclusive);
      return dr;
    }
    // date - infinity range
    match = regexValInf.firstMatch(input);
    if (match != null) {
      dr._startInclusive = match.group(1) == "[";
      dr._start = DateTime.parse(match.group(2)! + "T00:00:00Z");
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

  static List<DateRange> listExcept(List<DateRange> source, List<DateRange> exceptions) {
    return _Range._listExcept(source, exceptions).map((r) => r as DateRange).toList();
  }

  @override
  String toString() {
    final DateFormat df = DateFormat('yyyy-MM-dd');
    return "${_startInclusive && _start != null ? "[" : "("}${_start == null ? '-infinity' : df.format(_start!)},${_end == null ? 'infinity' : df.format(_end!)}${_endInclusive && _end != null ? "]" : ")"}";
  }

  @override
  _Range<DateTime> newInstance() {
    return DateRange._();
  }

  @override
  DateTime? _next(DateTime? value) {
    return value?.add(Duration(days: 1));
  }

  @override
  DateTime? _prev(DateTime? value) {
    return value?.subtract(Duration(days: 1));
  }

  /// DO NOT CALL initializeDateFormatting() HERE!!!!
  ///  initializeDateFormatting() is an async call (Future) and can cause troubles in AngularDart (AD)
  ///  as it causes a change to be detected and AD will loop forever
  ///
  ///  Init Date Formatting locale in caller's call before calling DateRange.format(), e.g.
  ///  initializeDateFormatting()
  ///   .then((_) => daterange.format("{{start}} - {{end}}", "E dd.MM.", locale: "cs_CZ");
  String format(String fmt, String dateFormat, {String? locale, String? inclusiveTag, String? exclusiveTag}) {
    final DateFormat df = DateFormat(dateFormat, locale);
    final DateTime? s = start(inclusive: true);
    final DateTime? e = end(inclusive: true);
    String buffer = fmt
        .replaceAll(
            '{{start}}',
            s == null
                ? ''
                : df.format(s) +
                    (_startInclusive
                        ? inclusiveTag != null
                            ? inclusiveTag
                            : ''
                        : exclusiveTag != null
                            ? exclusiveTag
                            : ''))
        .replaceAll(
            '{{end}}',
            e == null
                ? ''
                : df.format(e) +
                    (_endInclusive
                        ? inclusiveTag != null
                            ? inclusiveTag
                            : ''
                        : exclusiveTag != null
                            ? exclusiveTag
                            : ''));
    return buffer;
  }
}
