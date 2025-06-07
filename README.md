# ac_ranges

[![pub package](https://img.shields.io/pub/v/ac_ranges.svg)](https://pub.dev/packages/ac_ranges)
[![license](https://img.shields.io/badge/license-Apache%202-blue)](https://github.com/anycode/ac_ranges/blob/main/LICENSE)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://dart.dev/guides/language/effective-dart)

A Dart library for creating, manipulating, and parsing ranges of various comparable types, including `DateTime`, `int`, and `double`. Supports operations like checking for containment, overlaps, and unions.

## Features

*   Create ranges for `DateTime`, `int`, and `double`.
*   Parse string representations of ranges (e.g., `"[2019-01-01,2019-02-10)"`).
*   Check if a value is contained within a range.
*   Determine if two ranges overlap.
*   Calculate the union or intersection of ranges (where applicable).
*   Support for inclusive/exclusive bounds.
*   Extensible for custom comparable types.

## Getting started

To use this package, add `ac_ranges` as a dependency in your `pubspec.yaml` file.


Then, run `dart pub get` or `flutter pub get`.

## Usage

The ranges use Postgres-like syntax for bounds, `[start, end]` for range
including both bounding values, `(start, end)` for range excluding both
bounding values, or combination of these `(start, end]`, `[start, end)`.

Range can be created by constructor, e.g. `IntRange(1, 10)` which creates same
range as `IntRange.parse('[1,10]')`. By default, both values are inclusive.
Optionally the inclusion can be specified  
`IntRange(1, 10, endInclusive: false)`, which creates same
range as `IntRange.parse('[1,10)'])`.

Ranges can be finite `(start, end)` or infinite `(-infinity, end)`,
`(start, infinity)`, `(-infinity, infinity)`

Discrete finite ranges (of int and date) can be iterated over. 

A simple usage example: (see `example/ranges_example.dart` for more)

Here's a simple example of parsing a date range and printing it:

    import 'package:ac_ranges/ac_ranges.dart';

    main() {
      String a = "[2019-01-01,2019-02-10)";
      final DateRange? drp = DateRange.parse(a);
      String b = drp.toString();
      print("string $a => DateRange.toString() => $b");
    }

For more detailed examples, please see the `example/` directory and 
the tests in `test/` directory`.

## Additional information

*   **Repository:** https://github.com/anycode/ac_ranges.dart
*   **Issue tracker:** https://github.com/anycode/ac_ranges.dart/issues <!-- TODO: Update with your actual issue tracker URL -->
*   **API Reference:** https://pub.dev/documentation/ac_ranges/latest/

We welcome contributions! Please feel free to submit a pull request or open an issue.