# Changelog

## 3.0.14

- Added comprehensive tests for iteration over `IntRange` and `DateRange`
- Extended `ac_ranges_example.dart` with examples of all range types

## 3.0.13

- Make abstract classes `Range` and `DiscreteRange` public
- Update the LICENSE file and put license notices to sources.
- Enhance README with detailed usage and contribution info.

## 3.0.12

- Remove `_NumRange` abstraction
- Introduce `_DiscreteRange` for better hierarchy clarity, and simplify range logic in `DoubleRange`, `IntRange`, and `DateRange`
- Centralize range parsing logic in `_Range` and `_DiscreteRange`
- Simplify `parse` methods, and unify regex definitions in `DoubleRange`, `IntRange`, and `DateRange`

## 3.0.11

- Enhance equality comparison
- Add tests for all types of ranges

## 3.0.10

- Update `intl` package to 0.20

## 3.0.9

- Add documentation to classes and methods

## 3.0.8

- Generally available public release
