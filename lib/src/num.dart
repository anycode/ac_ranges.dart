part of 'package:ac_ranges/ac_ranges.dart';

abstract class _NumRange extends _Range<num> {
  /// Creates a new range of numbers.
  /// [start] and [end] are the start and end of the range.
  /// [startInclusive] and [endInclusive] are whether the start and end are inclusive.
  /// [discrete] is whether the range is discrete (finite).
  // ignore: avoid_positional_boolean_parameters
  _NumRange(num start, num end, bool startInclusive, bool endInclusive, bool discrete) :
        super(start, end, startInclusive, endInclusive, discrete);
  _NumRange._(bool discrete) : super._(discrete);

  @override
  String toString() {
    return "${_startInclusive && _start != null ? "[" : "("}"
        "${_start ?? '-infinity'},${_end ?? 'infinity'}"
        "${_endInclusive && _end != null ? "]" : ")"}";
  }
}
