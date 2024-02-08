part of 'package:ac_ranges/ac_ranges.dart';

abstract class _NumRange extends _Range<num> {
  // ignore: avoid_positional_boolean_parameters
  _NumRange(num start, num end, bool startInclusive, bool endInclusive, bool finite) :
        super(start, end, startInclusive, endInclusive, finite);
  _NumRange._(bool finite) : super._(finite);

  @override
  String toString() {
    return "${_startInclusive && _start != null ? "[" : "("}${_start == null ? '-infinity' : _start},${_end == null ? 'infinity' : _end}${_endInclusive && _end != null ? "]" : ")"}";
  }
}
