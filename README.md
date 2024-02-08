# ac_ranges 

A library for manipulating ranges of various types - date, int, double

## Usage

A simple usage example: (see `ranges_test.dart` for more)

    import 'package:ac_ranges/ac_ranges.dart';

    main() {
      String a = "[2019-01-01,2019-02-10)";
      final DateRange? drp = DateRange.parse(a);
      String b = drp.toString();
      print("string $a => DateRange.toString() => $b");
    }
