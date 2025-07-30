/*
 * Copyright 2025 Martin Edlman - Anycode <ac@anycode.dev>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

part of 'package:ac_ranges/ac_ranges.dart';

abstract class Range<TYPE extends Comparable<TYPE>> implements Comparable<Range> {

  /// Creates a new range with the given start and end values and inclusion flags.
  ///
  /// [start] The start value of the range.
  /// [end] The end value of the range.
  /// [startInclusive] Whether the start value is included in the range.
  /// [endInclusive] Whether the end value is included in the range.
  Range(this._start, this._end, {bool startInclusive = true, bool endInclusive = false})
      : _startInclusive = _start == null ? false : startInclusive,
        _endInclusive = _end == null ? false : endInclusive;

  /// Creates a new range with default inclusion flags (both inclusive).
  Range._()
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

  Range<TYPE> newInstance();

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
  List<Range<TYPE>> union(Range<TYPE> that) {
    final List<Range<TYPE>> result = [];
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
  List<Range<TYPE>> except(Range<TYPE> that) {
    final List<Range<TYPE>> result = [];
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
  Range<TYPE>? intersect(Range<TYPE> that) {
    Range<TYPE>? result = newInstance();
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
  bool isSubsetOf(Range<TYPE> that, {bool strict = false}) =>
      !strict && _startGE(that) && _endLE(that) || strict && _startG(that) && _endL(that);

  /// Evaluate whether this range is a superset of another.
  ///
  /// [that] The other range to compare to.
  /// [strict] Whether to consider strict superset (not equal).
  ///
  /// Returns true if this range is a superset of the other range, false otherwise.
  bool isSupersetOf(Range<TYPE> that, {bool strict = false}) => that.isSubsetOf(this, strict: strict);

  // A (this)  contains E (element) if
  // ( E > As || E == As && A[ ) && ( E < Ae || E = Ae && A] )
  /// Detect whether this range contains an element.
  ///
  /// [that] The other range to check whether it's contained in this range.
  ///
  /// Returns true if this range contains single value, false otherwise.
  bool contains(Object? obj) => _contains(obj);

  // do not put directly to `contains(Object?)`, so it's possible to override `contains(Object?)` in subclasses
  bool _contains(Object? obj) {
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
  bool isAdjacentTo(Range<TYPE> that) {
    return _seAdjacent(that) || _esAdjacent(that);
  }

  /// Check whether this range overlaps with another range.
  ///
  /// [that] The other range to compare to.
  ///
  /// Returns true if this range overlaps with the other range, false otherwise.
  bool overlaps(Range<TYPE> that) {
    return _seOverlap(that) || _esOverlap(that);
  }

  /// Operator for the union of this range and another range.
  ///
  /// [that] The other range to union with.
  ///
  /// Returns a list of ranges that represent the union of the two ranges.
  List<Range<TYPE>> operator +(Range<TYPE> that) => union(that);

  /// Operator for the difference between this range and another range.
  ///
  /// [that] The other range to subtract.
  ///
  /// Returns a list of ranges that represent the difference between the two ranges.
  List<Range<TYPE>> operator -(Range<TYPE> that) => except(that);

  /// Operator for the intersection of this range and another range.
  ///
  /// [that] The other range to intersect with.
  ///
  /// Returns a range that represents the intersection of the two ranges, or null if the ranges do not intersect.
  Range<TYPE>? operator *(Range<TYPE> that) => intersect(that);

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
  bool operator ==(Object that) => that is Range<TYPE> && this.compareTo(that) == 0;

  int _startCmp(Range<TYPE> other, [bool otherIsStart = true]) {
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
  bool _startE(Range<TYPE> that) => _startCmp(that) == 0;

  bool _startL(Range<TYPE> that) => _startCmp(that) == -1;

  bool _startLE(Range<TYPE> that) => _startCmp(that) != 1;

  bool _startG(Range<TYPE> that) => _startCmp(that) == 1;

  bool _startGE(Range<TYPE> that) => _startCmp(that) != -1;

  int _endCmp(Range<TYPE> other, [bool otherIsEnd = true]) {
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
  bool _endE(Range<TYPE> that) => _endCmp(that) == 0;

  bool _endL(Range<TYPE> that) => _endCmp(that) == -1;

  bool _endLE(Range<TYPE> that) => _endCmp(that) != 1;

  bool _endG(Range<TYPE> that) => _endCmp(that) == 1;

  // ignore: unused_element
  bool _endGE(Range<TYPE> that) => _endCmp(that) != -1;

  // Adjacency
  // ranges A and B are adjacent if A.end and B.start are not null and
  // either A.end and B.start are equal and at least one is inclusive
  // A---][---B OK
  // A---](---B OK
  // A---)[---B OK
  // A---)(---B NOK
  // doesn't consider reverse adjacency
  static bool _adjacent<TYPE extends Comparable<TYPE>>(Range<TYPE> a, Range<TYPE> b) {
    return a._end != null && b._start != null && a._endCmp(b, false) == 0;
  }

  bool _esAdjacent(Range<TYPE> that) {
    return _adjacent(this, that);
  }

  bool _seAdjacent(Range<TYPE> that) {
    return _adjacent(that, this);
  }

  // Overlap
  // ranges overlap if A.start <= B.start and A.end >= B.start
  // A [-------]
  // B      [-------]
  // doesn't consider reverse overlap
  static bool _overlap<TYPE extends Comparable<TYPE>>(Range<TYPE> a, Range<TYPE> b) {
    final cmp = a._endCmp(b, false);
    return a._startLE(b) && (cmp == 1 || cmp == 0 && a._endInclusive && b._startInclusive);
  }

  bool _esOverlap(Range<TYPE> that) {
    return _overlap(this, that);
  }

  bool _seOverlap(Range<TYPE> that) {
    return _overlap(that, this);
  }

  /// Returns the start value of the range, optionally with inclusion overridden.
  TYPE? start({bool? inclusive}) => _start;

  /// Returns the end value of the range, optionally with inclusion overridden.
  TYPE? end({bool? inclusive}) => _end;

  bool get startInclusive => _startInclusive;
  bool get endInclusive => _endInclusive;

  static List<Range<TYPE>> _listExcept<TYPE extends Comparable<TYPE>>(List<Range<TYPE>> source, List<Range<TYPE>> exceptions) {
    List<Range<TYPE>> ranges = [...source];
    for (final er in exceptions) {
      final List<Range<TYPE>> tmpRanges = [];
      for (final sr in ranges) {
        tmpRanges.addAll(sr.except(er));
      }
      ranges = tmpRanges;
    }
    return ranges;
  }

  static Range? _parse<TYPE extends Comparable<TYPE>>(String? input, {
    required RegExp regexInfInf,
    required RegExp regexInfVal,
    required RegExp regexValInf,
    required RegExp regexValVal,
    required TYPE? Function(String) parser,
    required Range<TYPE> Function() ctor,
    bool? startInclusive,
    bool? endInclusive,
  }) {
    if (input == null) return null;
    final Range dr = ctor();
    Match? match;
    // date - date range
    match = regexValVal.firstMatch(input);
    if (match != null) {
      dr._startInclusive = match.group(1) == "[";
      dr._start = parser(match.group(2)!);
      dr._end = parser(match.group(3)!);
      dr._endInclusive = match.group(4) == "]";
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
      dr._end = parser(match.group(3)!);
      dr._endInclusive = match.group(4) == "]";
      return dr;
    }
    // date - infinity range
    match = regexValInf.firstMatch(input);
    if (match != null) {
      dr._startInclusive = match.group(1) == "[";
      dr._start = parser(match.group(2)!);
      dr._end = null;
      dr._endInclusive = false; // infinity is always open
      return dr;
    }
    return null;
  }

  static RegExp _createRegex(String startRe, String endRe) {
    return RegExp("([\\(\\[])\\s*($startRe)\\s*,\\s*($endRe)\\s*([\\]\\)])");
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
  int compareTo(Range other) {
    int startCmp = _startCmp(other as Range<TYPE>);
    return startCmp != 0 ? startCmp : _endCmp(other);
  }

  @override
  int get hashCode => _start.hashCode ^ _end.hashCode ^ _startInclusive.hashCode ^ _endInclusive.hashCode;
}

abstract class DiscreteRange<CTYPE extends Comparable<CTYPE>, ITYPE extends CTYPE> extends Range<CTYPE> with IterableMixin<ITYPE> {

  /// Creates a new discrete range with the given start and end values and inclusion flags.
  ///
  /// [start] The start value of the range.
  /// [end] The end value of the range.
  /// [startInclusive] Whether the start value is included in the range.
  /// [endInclusive] Whether the end value is included in the range.
  DiscreteRange(super.start, super.end, {super.startInclusive = true, super.endInclusive = false});

  /// Creates a new range with default inclusion flags (both inclusive).
  DiscreteRange._() : super._();

  // A (this)  contains E (element) if
  // ( E > As || E == As && A[ ) && ( E < Ae || E = Ae && A] )
  /// Detect whether this range contains an element.
  ///
  /// [that] The other range to check whether it's contained in this range.
  ///
  /// Returns true if this range contains single value, false otherwise.
  @override
  bool contains(Object? obj) => super._contains(obj);

  // call super (_Range) _toString, otherwise Iterable toString() is called
  // Mixins have higher priority and super.toString() would call Iterable.toString()
  @override
  String toString() => super._toString();

  /// Returns an iterator over the elements in this range.
  /// Throws an exception if the range is not discrete or is infinite.
  @override
  Iterator<ITYPE> get iterator => _start != null && _end != null
      ? _RangeIterator<CTYPE, ITYPE>(this)
      : throw Exception('Cannot iterate over infinite range');

  /// If [inclusive] is provided and differs from the current start inclusion,
  /// the start value is adjusted to the next or previous value accordingly.
  ///
  /// [inclusive] Optional. If provided, overrides the start inclusion.
  ///
  /// Returns the start value of the range, optionally with inclusion overridden.
  @override
  CTYPE? start({bool? inclusive}) =>
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
  CTYPE? end({bool? inclusive}) =>
      _end == null || inclusive == null || _endInclusive == inclusive
          ? _end
          : inclusive
          ? _prev(_end)
          : _next(_end);

  CTYPE? _next(CTYPE? value);
  CTYPE? _prev(CTYPE? value);

  static DiscreteRange? _parse<CTYPE extends Comparable<CTYPE>, ITYPE extends CTYPE>(String? input, {
    required RegExp regexInfInf,
    required RegExp regexInfVal,
    required RegExp regexValInf,
    required RegExp regexValVal,
    required CTYPE? Function(String) parser,
    required DiscreteRange<CTYPE, ITYPE> Function() ctor,
    bool? startInclusive,
    bool? endInclusive,
  }) {
    final range = Range._parse<CTYPE>(input,
        regexInfInf: regexInfInf,
        regexInfVal: regexInfVal,
        regexValInf: regexValInf,
        regexValVal: regexValVal,
        parser: parser,
        ctor: ctor,
        startInclusive: startInclusive,
        endInclusive: endInclusive) as DiscreteRange?;
    if (range != null) {
      range._overrideInclusion(startInclusive, endInclusive);
    }
    return range;
  }


  void _overrideInclusion(bool? startInclusive, bool? endInclusive) {
    if (_start != null && startInclusive != null && startInclusive != _startInclusive) {
      // override start inclusion
      // change to next value for ( -> [  and change to prev value for [ -> (
      _start = startInclusive ? _next(_start) : _prev(_start);
      _startInclusive = startInclusive;
    }
    if (_end != null && endInclusive != null && endInclusive != _endInclusive) {
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
  static bool _adjacent<CTYPE extends Comparable<CTYPE>, ITYPE extends CTYPE>(DiscreteRange<CTYPE, ITYPE> a, DiscreteRange<CTYPE, ITYPE> b) {
    return (a._end != null && b._start != null) &&
        ((a._endCmp(b, false) == 0) ||
            (a._next(a.end())!.compareTo(b.start()!) == 0 && a._endInclusive && b._startInclusive));
  }

  @override
  bool _esAdjacent(Range<CTYPE> that) {
    return _adjacent(this, that as DiscreteRange<CTYPE, ITYPE>);
  }

  @override
  bool _seAdjacent(Range<CTYPE> that) {
    return _adjacent(that as DiscreteRange<CTYPE, ITYPE>, this);
  }
}


/// An iterator over the elements in a discrete range.
///
/// [CTYPE] The type of the elements in the range.
class _RangeIterator<CTYPE extends Comparable<CTYPE>, ITYPE extends CTYPE> implements Iterator<ITYPE> {
  final DiscreteRange<CTYPE, ITYPE> _range;
  CTYPE _element;
  bool _moveNext = false;

  _RangeIterator(this._range) : _element = _range.start(inclusive: true)!;

  @override
  ITYPE get current => _element as ITYPE;

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
