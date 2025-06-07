part of 'package:ac_ranges/ac_ranges.dart';


abstract class _Range<TYPE extends Comparable<TYPE>> implements Comparable<_Range> {

  /// Creates a new range with the given start and end values and inclusion flags.
  ///
  /// [start] The start value of the range.
  /// [end] The end value of the range.
  /// [startInclusive] Whether the start value is included in the range.
  /// [endInclusive] Whether the end value is included in the range.
  _Range(this._start, this._end, bool startInclusive, bool endInclusive)
      : _startInclusive = _start == null ? false : startInclusive,
        _endInclusive = _end == null ? false : endInclusive;

  /// Creates a new range with default inclusion flags (both inclusive).
  _Range._()
      : _startInclusive = true,
        _endInclusive = true;

  /// Whether the start value is included in the range.
  bool _startInclusive;

  /// The start value of the range.
  TYPE? _start;

  /// The end value of the range.
  TYPE? _end;

  /// Whether the end value is included in the range.
  bool _endInclusive;

  _Range<TYPE> newInstance();

  @override
  String toString() => _toString();

  // do not put directly to `toString()`, so it's possible to override `toString()` in subclasses
  String _toString() {
    return "${_startInclusive && _start != null ? "[" : "("}"
        "${_start ?? '-infinity'},${_end ?? 'infinity'}"
        "${_endInclusive && _end != null ? "]" : ")"}";
  }

  // if, else if blocks use following scenarios
  // 1. |-------------------| this
  //         |-----|                         that
  //
  // 2.    |-----|                         this
  //    |-------------------| that
  //
  // 3  |-------------|           this
  //                   |----------|    that
  //
  // 4            |-------------| this
  //    |--------|                       that
  //
  //  5 |-----|    |-----|         this that, that this

  /// The union of two ranges is the set of all elements that are in either range.
  ///
  /// [that] The other range to union with.
  ///
  /// Returns a list of ranges that represent the union of the two ranges.
  List<_Range<TYPE>> union(_Range<TYPE> that) {
    final List<_Range<TYPE>> result = [];
    if (isSupersetOf(that)) {
      result.add(this);
    } else if (isSubsetOf(that)) {
      result.add(that);
    } else if (_esOverlap(that) || _esAdjacent(that)) {
      result.add(newInstance()
        .._startInclusive = _startInclusive
        .._start = _start
        .._end = that._end
        .._endInclusive = that._endInclusive);
    } else if (_seOverlap(that) || _seAdjacent(that)) {
      result.add(newInstance()
        .._startInclusive = that._startInclusive
        .._start = that._start
        .._end = _end
        .._endInclusive = _endInclusive);
    } else {
      result..add(this)..add(that);
    }
    return result;
  }

  /// The difference between two ranges is the set of all elements that are in this range but not in the other range.
  ///
  /// [that] The other range to subtract.
  ///
  /// Returns a list of ranges that represent the difference between the two ranges.
  List<_Range<TYPE>> except(_Range<TYPE> that) {
    final List<_Range<TYPE>> result = [];
    //if (this.start < that.start && this.end > that.end) {
    if (isSupersetOf(that)) {
      if (_startL(that)) {
        result.add(newInstance()
          .._startInclusive = _startInclusive
          .._start = _start
          .._end = that._start
          .._endInclusive = !that._startInclusive);
      }
      if (_endG(that)) {
        result.add(newInstance()
          .._startInclusive = !that._endInclusive
          .._start = that._end
          .._end = _end
          .._endInclusive = _endInclusive);
      }
    } else if (isSubsetOf(that)) {
      // empty
    } else if (_esOverlap(that) || _esAdjacent(that)) {
      result.add(newInstance()
        .._startInclusive = _startInclusive
        .._start = _start
        .._end = that._start
        .._endInclusive = !that._startInclusive);
    } else if (_seOverlap(that) || _seAdjacent(that)) {
      result.add(newInstance()
        .._startInclusive = !that._endInclusive
        .._start = that._end
        .._end = _end
        .._endInclusive = _endInclusive);
    } else {
      result.add(this);
    }
    return result;
  }

  /// The intersection of two ranges is the set of all elements that are in both ranges.
  ///
  /// [that] The other range to intersect with.
  ///
  /// Returns a range that represents the intersection of the two ranges, or null if the ranges do not intersect.
  _Range<TYPE>? intersect(_Range<TYPE> that) {
    _Range<TYPE>? result = newInstance();
    //if (this.start <= that.star && this.end >= that.end) {
    if (isSupersetOf(that)) {
      result = that;
    } else if (isSubsetOf(that)) {
      result = this;
    } else if (_esOverlap(that) || _esAdjacent(that)) {
      result
        .._startInclusive = that._startInclusive
        .._start = that._start
        .._end = _end
        .._endInclusive = _endInclusive;
    } else if (_seOverlap(that) || _seAdjacent(that)) {
      result
        .._startInclusive = _startInclusive
        .._start = _start
        .._end = that._end
        .._endInclusive = that._endInclusive;
    } else {
      result = null;
    }
    return result;
  }

  /*
    A (this) is a subset of B (that) in these cases,
    * As = A.start, Ae = A.end, A[ = A.startInclusive, A( = ! A.startInclusive, A] = A.endInclusive, A) ! A.endInclusive
    1. not strict (is subset or equal)
        ( As > Bs || As = Bs && B[ ) && ( Ae < Be || Ae = Be && B] )
    2. strict (cannot equal)
       ( As > Bs || As = Bs && A( && B[ ) && (Ae < Be || Ae = Be && A) && B] )
   */
  /// Evaluate whether this range is a subset of another.
  ///
  /// [that] The other range to compare to.
  /// [strict] Whether to consider strict subset (not equal).
  ///
  /// Returns true if this range is a subset of the other range, false otherwise.
  bool isSubsetOf(_Range<TYPE> that, {bool strict = false}) =>
      !strict && _startGE(that) && _endLE(that) || strict && _startG(that) && _endL(that);

  /// Evaluate whether this range is a superset of another.
  ///
  /// [that] The other range to compare to.
  /// [strict] Whether to consider strict superset (not equal).
  ///
  /// Returns true if this range is a superset of the other range, false otherwise.
  bool isSupersetOf(_Range<TYPE> that, {bool strict = false}) => that.isSubsetOf(this, strict: strict);

  // A (this)  contains E (element) if
  // ( E > As || E == As && A[ ) && ( E < Ae || E = Ae && A] )
  /// Detect whether this range contains an element.
  ///
  /// [that] The other range to check whether it's contained in this range.
  ///
  /// Returns true if this range contains single value, false otherwise.
  bool contains(Object? obj) {
    if (obj is! TYPE) return false;
    final int startCmp = _start?.compareTo(obj) ?? -1; // -infinity is less than any value
    final int endCmp = _end?.compareTo(obj) ?? 1; // infinity is greater than any value
    return (startCmp == -1 || startCmp == 0 && _startInclusive) && (endCmp == 1 || endCmp == 0 && _endInclusive);
  }

  /// Test whether this range is adjacent to another range. The ranges are adjacent
  /// if the end of this range is the same as the start of the other range or vice versa.
  ///
  /// * _A---&rbrack;&lbrack;---B_ are adjacent for any range
  /// * _A---&rbrack;(---B_ are adjacent for any range
  /// * _A---)&lbrack;---B_ are adjacent for any range
  /// * _A---)(---B_ are NOT adjacent for any range
  /// * _A---&rbrack;+1&lbrack;---B_ are adjacent for discrete range (integers, dates)
  ///
  /// [that] The other range to compare to.
  ///
  /// Returns true if this range is adjacent to the other range, false otherwise.
  bool isAdjacentTo(_Range<TYPE> that) {
    return _seAdjacent(that) || _esAdjacent(that);
  }

  /// Check whether this range overlaps with another range.
  ///
  /// [that] The other range to compare to.
  ///
  /// Returns true if this range overlaps with the other range, false otherwise.
  bool overlaps(_Range<TYPE> that) {
    return _seOverlap(that) || _esOverlap(that);
  }

  /// Operator for the union of this range and another range.
  ///
  /// [that] The other range to union with.
  ///
  /// Returns a list of ranges that represent the union of the two ranges.
  List<_Range<TYPE>> operator +(_Range<TYPE> that) => union(that);

  /// Operator for the difference between this range and another range.
  ///
  /// [that] The other range to subtract.
  ///
  /// Returns a list of ranges that represent the difference between the two ranges.
  List<_Range<TYPE>> operator -(_Range<TYPE> that) => except(that);

  /// Operator for the intersection of this range and another range.
  ///
  /// [that] The other range to intersect with.
  ///
  /// Returns a range that represents the intersection of the two ranges, or null if the ranges do not intersect.
  _Range<TYPE>? operator *(_Range<TYPE> that) => intersect(that);

  /// Ranges are equal if they have same start and end dates and inclusions.
  ///
  /// ```dart
  /// // same values and inclusions
  /// IntRange.parse('[2,10)') == IntRange(2,10);
  /// // same values BUT 10 in included in parsed range, but excluded in other
  /// IntRange.parse('[2,10]') != IntRange(2,10);
  /// // same values and inclusions
  /// IntRange.parse('[2,10]') == IntRange(2,10, endInclusive: true);
  /// ```
  @override
  bool operator ==(Object that) => that is _Range<TYPE> && this.compareTo(that) == 0;

  int _startCmp(_Range<TYPE> other, [bool otherIsStart = true]) {
    TYPE? thisVal = start();
    TYPE? otherVal = otherIsStart ? other.start() : other.end();
    if (! otherIsStart && (thisVal == null || otherVal == null)) {
      // other is end date and thisVal is null (-infinity) and/or otherVal is null (+infinity)
      // so thisVal is always less than otherVal
      return -1;
    } else if (thisVal == null && otherVal == null) {
      // if both are null (= -infinity) so they're equal
      return 0;
    } else if (thisVal == null) {
      // if thisVal is null (= -infinity) it's always less
      return -1;
    } else if (otherVal == null) {
      // if otherVal is null (= -infinity), thisVal is always bigger
      return 1;
    } else {
      // finally compare thisVal and otherVal (both are not null)
      int cmp = thisVal.compareTo(otherVal);
      // if both starts have different values, return the comparison result
      if(cmp != 0) {
        return cmp;
      }
      // otherwise check inclusions depending on `otherIsStart`
      if(otherIsStart) {
        // both values are start of ranges
        if(_startInclusive == other._startInclusive) {
          // same inclusion means equal
          return 0;
        } else {
          // it this is inclusive (other exclusive), this is less
          return _startInclusive ? -1 : 1;
        }
      } else {
        // if start of this and end of other are inclusive, values are equal,
        // otherwise start of this is always bigger than end of other
        return _startInclusive && other._endInclusive ? 0 : 1;
      }
    }
  }

  // ignore: unused_element
  bool _startE(_Range<TYPE> that) => _startCmp(that) == 0;

  bool _startL(_Range<TYPE> that) => _startCmp(that) == -1;

  bool _startLE(_Range<TYPE> that) => _startCmp(that) != 1;

  bool _startG(_Range<TYPE> that) => _startCmp(that) == 1;

  bool _startGE(_Range<TYPE> that) => _startCmp(that) != -1;

  int _endCmp(_Range<TYPE> other, [bool otherIsEnd = true]) {
    TYPE? thisVal = end();
    TYPE? otherVal = otherIsEnd ? other.end() : other.start();
    if (! otherIsEnd && (thisVal == null || otherVal == null)) {
      // other is start date and thisVal is null (infinity) and/or otherVal is null (-infinity)
      // so thisVal is always bigger than otherVal
      return 1;
    } else if (thisVal == null && otherVal == null) {
      // if both are null (= infinity) so they're equal
      return 0;
    } else if (thisVal == null) {
      // if thisVal is null (= infinity) it's always bigger
      return 1;
    } else if (otherVal == null) {
      // if otherVal is null (= infinity), thisVal is always less
      return -1;
    } else {
      // finally compare thisVal and otherVal (both are not null)
      int cmp = thisVal.compareTo(otherVal);
      // if both ends have different values, return the comparison result
      if(cmp != 0) {
        return cmp;
      }
      // otherwise check inclusions depending on `otherIsEnd`
      if(otherIsEnd) {
        // both values are end of ranges
        if(_endInclusive == other._endInclusive) {
          // same inclusion means equal
          return 0;
        } else {
          // it this is inclusive (other exclusive), this is bigger
          return _endInclusive ? 1 : -1;
        }
      } else {
        // if end of this and start of other are inclusive, values are equal,
        // otherwise end of this is always less than start of other
        return _endInclusive && other._startInclusive ? 0 : -1;
      }
    }
  }

  // ignore: unused_element
  bool _endE(_Range<TYPE> that) => _endCmp(that) == 0;

  bool _endL(_Range<TYPE> that) => _endCmp(that) == -1;

  bool _endLE(_Range<TYPE> that) => _endCmp(that) != 1;

  bool _endG(_Range<TYPE> that) => _endCmp(that) == 1;

  // ignore: unused_element
  bool _endGE(_Range<TYPE> that) => _endCmp(that) != -1;

  // Adjacency
  // ranges A and B are adjacent if A.end and B.start are not null and
  // either A.end and B.start are equal and at least one is inclusive
  // A---][---B OK
  // A---](---B OK
  // A---)[---B OK
  // A---)(---B NOK
  // doesn't consider reverse adjacency
  static bool _adjacent<TYPE extends Comparable<TYPE>>(_Range<TYPE> a, _Range<TYPE> b) {
    return a._end != null && b._start != null && a._endCmp(b, false) == 0;
  }

  bool _esAdjacent(_Range<TYPE> that) {
    return _adjacent(this, that);
  }

  bool _seAdjacent(_Range<TYPE> that) {
    return _adjacent(that, this);
  }

  // Overlap
  // ranges overlap if A.start <= B.start and A.end >= B.start
  // A [-------]
  // B      [-------]
  // doesn't consider reverse overlap
  static bool _overlap<TYPE extends Comparable<TYPE>>(_Range<TYPE> a, _Range<TYPE> b) {
    final cmp = a._endCmp(b, false);
    return a._startLE(b) && (cmp == 1 || cmp == 0 && a._endInclusive && b._startInclusive);
  }

  bool _esOverlap(_Range<TYPE> that) {
    return _overlap(this, that);
  }

  bool _seOverlap(_Range<TYPE> that) {
    return _overlap(that, this);
  }

  /// Returns the start value of the range, optionally with inclusion overridden.
  TYPE? start({bool? inclusive}) => _start;

  /// Returns the end value of the range, optionally with inclusion overridden.
  TYPE? end({bool? inclusive}) => _end;

  bool get startInclusive => _startInclusive;
  bool get endInclusive => _endInclusive;

  static List<_Range<TYPE>> _listExcept<TYPE extends Comparable<TYPE>>(List<_Range<TYPE>> source, List<_Range<TYPE>> exceptions) {
    List<_Range<TYPE>> ranges = [...source];
    for (final er in exceptions) {
      final List<_Range<TYPE>> tmpRanges = [];
      for (final sr in ranges) {
        tmpRanges.addAll(sr.except(er));
      }
      ranges = tmpRanges;
    }
    return ranges;
  }

  /// Compares this range to another range. First compare starts of the ranges. If start
  /// of this range is less than the start of the other, return -1, if it's greater, return 1.
  /// If both starts are equal, compare ends of the ranges.
  ///
  /// [other] The other range to compare to.
  ///
  /// Returns a negative integer, zero, or a positive integer as this range is less than,
  /// equal to, or greater than the other range.
  @override
  int compareTo(_Range other) {
    int startCmp = _startCmp(other as _Range<TYPE>);
    return startCmp != 0 ? startCmp : _endCmp(other);
  }

  @override
  int get hashCode => _start.hashCode ^ _end.hashCode ^ _startInclusive.hashCode ^ _endInclusive.hashCode;
}

abstract class _DiscreteRange<TYPE extends Comparable<TYPE>> extends _Range<TYPE> with IterableMixin<TYPE> {

  /// Creates a new discrete range with the given start and end values and inclusion flags.
  ///
  /// [start] The start value of the range.
  /// [end] The end value of the range.
  /// [startInclusive] Whether the start value is included in the range.
  /// [endInclusive] Whether the end value is included in the range.
  _DiscreteRange(super.start, super.end, super.startInclusive, super.endInclusive);

  /// Creates a new range with default inclusion flags (both inclusive).
  _DiscreteRange._() : super._();

  // A (this)  contains E (element) if
  // ( E > As || E == As && A[ ) && ( E < Ae || E = Ae && A] )
  /// Detect whether this range contains an element.
  ///
  /// [that] The other range to check whether it's contained in this range.
  ///
  /// Returns true if this range contains single value, false otherwise.
  @override
  bool contains(Object? obj) => super.contains(obj);

  // call super (_Range) _toString, otherwise Iterable toString() is called
  // Mixins have higher priority and super.toString() would call Iterable.toString()
  @override
  String toString() => super._toString();

  /// Returns an iterator over the elements in this range.
  /// Throws an exception if the range is not discrete or is infinite.
  @override
  Iterator<TYPE> get iterator => _start != null && _end != null
      ? _RangeIterator<TYPE>(this)
      : throw Exception('Cannot iterate over infinite range');

  /// If [inclusive] is provided and differs from the current start inclusion,
  /// the start value is adjusted to the next or previous value accordingly.
  ///
  /// [inclusive] Optional. If provided, overrides the start inclusion.
  ///
  /// Returns the start value of the range, optionally with inclusion overridden.
  @override
  TYPE? start({bool? inclusive}) =>
      _start == null || inclusive == null || _startInclusive == inclusive
          ? _start
          : inclusive
          ? _next(_start)
          : _prev(_start);

  /// If [inclusive] is provided and differs from the current end inclusion,
  /// the end value is adjusted to the next or previous value accordingly.
  ///
  /// [inclusive] Optional. If provided, overrides the end inclusion.
  ///
  /// Returns the end value of the range, optionally with inclusion overridden.
  @override
  TYPE? end({bool? inclusive}) =>
      _end == null || inclusive == null || _endInclusive == inclusive
          ? _end
          : inclusive
          ? _prev(_end)
          : _next(_end);

  TYPE? _next(TYPE? value);
  TYPE? _prev(TYPE? value);

  void _overrideInclusion(bool? startInclusive, bool? endInclusive) {
    if (startInclusive != null && startInclusive != _startInclusive) {
      // override start inclusion
      // change to next value for ( -> [  and change to prev value for [ -> (
      _start = startInclusive ? _next(_start) : _prev(_start);
      _startInclusive = startInclusive;
    }
    if (endInclusive != null && endInclusive != _endInclusive) {
      // override end inclusion
      // change to prev value for ) -> ]  and change to next value for ] -> )
      _end = endInclusive ? _prev(_end) : _next(_end);
      _endInclusive = endInclusive;
    }
  }

  // Adjacency, similar to Range._adjacent, but takes in account ranges which are closed
  // on the end of one and on the start of the other and these two values are just one
  // value from each other.

  // ranges A and B are adjacent if A.end and B.start are not null and
  // either A.end and B.start are equal and at least one is inclusive
  // A---][---B OK
  // A---](---B OK
  // A---)[---B OK
  // A---)(---B NOK
  // or A and B are discrete (int, date) and A.end and B.start are inclusive and are adjacent
  // A---]+1[---B OK
  // doesn't consider reverse adjacency
  static bool _adjacent<TYPE extends Comparable<TYPE>>(_DiscreteRange<TYPE> a, _DiscreteRange<TYPE> b) {
    return (a._end != null && b._start != null) &&
        ((a._endCmp(b, false) == 0) ||
            (a._next(a.end())!.compareTo(b.start()!) == 0 && a._endInclusive && b._startInclusive));
  }

  @override
  bool _esAdjacent(_Range<TYPE> that) {
    return _adjacent(this, that as _DiscreteRange<TYPE>);
  }

  @override
  bool _seAdjacent(_Range<TYPE> that) {
    return _adjacent(that as _DiscreteRange<TYPE>, this);
  }
}


/// An iterator over the elements in a discrete range.
///
/// [TYPE] The type of the elements in the range.
class _RangeIterator<TYPE extends Comparable<TYPE>> implements Iterator<TYPE> {
  final _DiscreteRange<TYPE> _range;
  TYPE _element;
  bool _moveNext = false;

  _RangeIterator(this._range) : _element = _range.start(inclusive: true)!;

  @override
  TYPE get current => _element;

  @override
  bool moveNext() {
    if(_moveNext) {
      // do not move to next element yet to return the first one
      _element = _range._next(_element)!;
    } else {
      _moveNext = true;
    }
    return _element.compareTo(_range.end(inclusive: true)!) <= 0;
  }
}
