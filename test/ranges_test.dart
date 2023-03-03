import 'package:ranges/ranges.dart';
import 'package:test/test.dart';

void main() {
  group('DateRanges tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('toString()', () {
      String a = "[2019-01-01,2019-02-10)";
      final DateRange? drp = DateRange.parse(a);
      String b = drp.toString();
      print("string $a => DateRange.toString() => $b");
      expect(b, a);
    });

    test('except', () {
      final DateRange dre1 = DateRange(DateTime(2019, 12, 28), DateTime(2020, 04, 01));
      final DateRange dre2 = DateRange(DateTime(2019, 12, 28), DateTime(2020, 01, 04));
      final DateRange dre3 = DateRange(DateTime(2020, 01, 06), DateTime(2020, 01, 11));
      final List<DateRange> drex1 = dre1.except(dre2).cast<DateRange>();
      final List<DateRange> drex2 = [];
      drex1.forEach((DateRange x) => drex2.addAll(x.except(dre3).cast<DateRange>()));
      print("$dre1 exclude $dre2 = $drex1");
      print("$dre1 exclude $dre2 exclude $dre3 = $drex2");
      expect(drex1, [DateRange(DateTime(2020,01,04), DateTime(2020,04,01))]);
      expect(drex2, [
        DateRange(DateTime(2020,01,04), DateTime(2020,01,06)),
        DateRange(DateTime(2020,01,11), DateTime(2020,04,01))
      ]);
    });

    test('operators + - *', () {
      final DateRange dr1 = DateRange(DateTime(2019, 01, 01), DateTime(2019, 02, 28));
      final DateRange dr2 = DateRange(DateTime(2019, 02, 01), DateTime(2019, 03, 28));
      final DateRange dr3 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 28));

      print("union $dr1 + $dr2 = ${dr1 + dr2}");
      print("except $dr1 - $dr2 = ${dr1 - dr2}");
      print("intersect $dr1 * $dr2 = ${dr1 * dr2}");
      expect(dr1 + dr2, [DateRange.parse('[2019-01-01,2019-03-28)')]);
      expect(dr1 - dr2, [DateRange.parse('[2019-01-01,2019-02-01)')]);
      expect(dr1 * dr2, DateRange.parse('[2019-02-01,2019-02-28)'));

      print("union $dr1 + $dr3 = ${dr1 + dr3}");
      print("except $dr1 - $dr3 = ${dr1 - dr3}");
      print("intersect $dr1 * $dr3 = ${dr1 * dr3}");
      expect(dr1 + dr3, [
        DateRange.parse('[2019-01-01,2019-02-28)'),
        DateRange.parse('[2019-04-01,2019-04-28)')
      ]);
      expect(dr1 - dr3, [DateRange.parse('[2019-01-01,2019-02-28)')]);
      expect(dr1 * dr3, null);
    });

    test('subset, superset', () {
      final DateRange dr3 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 28));
      final DateRange dr4 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 8), endInclusive: true);

      print("$dr3 sub $dr4 = ${dr3.isSubsetOf(dr4)}");
      print("$dr3 sup $dr4 = ${dr3.isSupersetOf(dr4)}");
      expect(dr3.isSubsetOf(dr4), false);
      expect(dr3.isSupersetOf(dr4), true);

      final DateRange drs1e = DateRange(DateTime(2019, 04, 01), DateTime(2019, 05, 16));
      final DateRange drs1i = DateRange(DateTime(2019, 04, 01), DateTime(2019, 05, 15), endInclusive: true);
      final DateRange drs2 = DateRange(DateTime(2019, 05, 13), DateTime(2019, 05, 15), endInclusive: true);
      final DateRange drs3 = DateRange(DateTime(2019, 05, 13), DateTime(2019, 05, 16));
      print("$drs2 subset $drs1e = ${drs2.isSubsetOf(drs1e)}");
      print("$drs3 subset $drs1e = ${drs3.isSubsetOf(drs1e)}");
      print("$drs2 subset $drs1i = ${drs2.isSubsetOf(drs1i)}");
      expect(drs2.isSubsetOf(drs1e), true);
      expect(drs3.isSubsetOf(drs1e), true);
      expect(drs2.isSubsetOf(drs1i), true);
    });

    test('adjacent', () {
      final DateRange dr3 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 28));
      final DateRange dr4 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 8), endInclusive: true);
      final DateRange dr5 = DateRange(DateTime(2019, 04, 08), DateTime(2019, 05, 11));
      final DateRange dr6 = DateRange(DateTime(2019, 04, 09), DateTime(2019, 05, 11));
      final DateRange dr7 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 8));
      final DateRange dr8 = DateRange(DateTime(2019, 04, 09), DateTime(2019, 05, 11), startInclusive: false);

      print("$dr3 adj $dr4 = ${dr3.isAdjacentTo(dr4)}");
      print("$dr4 adj $dr5 = ${dr4.isAdjacentTo(dr5)}");
      print("$dr4 adj $dr6 = ${dr4.isAdjacentTo(dr6)}");
      print("$dr7 adj $dr6 = ${dr7.isAdjacentTo(dr6)}");
      print("$dr7 adj $dr8 = ${dr7.isAdjacentTo(dr8)}");

      expect(dr3.isAdjacentTo(dr4), false);
      expect(dr4.isAdjacentTo(dr5), true);
      expect(dr4.isAdjacentTo(dr6), true);
      expect(dr7.isAdjacentTo(dr6), false);
      expect(dr7.isAdjacentTo(dr8), false);
    });

    test('over', () {
      // dro1                  [---------]
      // dro2,3       [------] [-------]
      // dro4,5      [---]                [---]
      // dro6,7      [--]                    [--]
      // dro8                     [----]
      final DateRange dro1 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 30), endInclusive: true);
      final DateRange dro2 = DateRange(DateTime(2019, 03, 15), DateTime(2019, 04, 15), endInclusive: true);
      final DateRange dro3 = DateRange(DateTime(2019, 04, 15), DateTime(2019, 05, 15), endInclusive: true);
      final DateRange dro4 = DateRange(DateTime(2019, 03, 15), DateTime(2019, 04, 01), endInclusive: true);
      final DateRange dro5 = DateRange(DateTime(2019, 04, 30), DateTime(2019, 05, 15), endInclusive: true);
      final DateRange dro6 = DateRange(DateTime(2019, 03, 15), DateTime(2019, 03, 31), endInclusive: true);
      final DateRange dro7 = DateRange(DateTime(2019, 05, 01), DateTime(2019, 05, 15), endInclusive: true);
      final DateRange dro8 = DateRange(DateTime(2019, 04, 05), DateTime(2019, 05, 25), endInclusive: true);

      print("$dro1 over $dro2 = ${dro1.overlaps(dro2)}");
      print("$dro2 over $dro1 = ${dro2.overlaps(dro1)}");
      print("$dro1 over $dro3 = ${dro1.overlaps(dro3)}");
      print("$dro3 over $dro1 = ${dro3.overlaps(dro1)}");
      print("$dro1 over $dro4 = ${dro1.overlaps(dro4)}");
      print("$dro4 over $dro1 = ${dro4.overlaps(dro1)}");
      print("$dro1 over $dro5 = ${dro1.overlaps(dro5)}");
      print("$dro5 over $dro1 = ${dro5.overlaps(dro1)}");
      print("$dro1 over $dro6 = ${dro1.overlaps(dro6)}");
      print("$dro6 over $dro1 = ${dro6.overlaps(dro1)}");
      print("$dro1 over $dro7 = ${dro1.overlaps(dro7)}");
      print("$dro7 over $dro1 = ${dro7.overlaps(dro1)}");
      print("$dro1 over $dro8 = ${dro1.overlaps(dro8)}");
      print("$dro8 over $dro1 = ${dro8.overlaps(dro1)}");

      expect(dro1.overlaps(dro2), true);
      expect(dro2.overlaps(dro2), true);
      expect(dro1.overlaps(dro3), true);
      expect(dro3.overlaps(dro1), true);
      expect(dro1.overlaps(dro4), true);
      expect(dro4.overlaps(dro1), true);
      expect(dro1.overlaps(dro5), true);
      expect(dro5.overlaps(dro1), true);
      expect(dro1.overlaps(dro6), false);
      expect(dro6.overlaps(dro1), false);
      expect(dro1.overlaps(dro7), false);
      expect(dro7.overlaps(dro1), false);
      expect(dro1.overlaps(dro8), true);
      expect(dro8.overlaps(dro1), true);

    });

    test('iteration', () {
      final DateRange iter1 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 7));
      print("Iterate [) range $iter1");
      final result = <DateTime>[];
      for (DateTime dt in iter1) {
        print("iteration date $dt");
        result.add(dt);
      }
      expect(result, [
        DateTime.utc(2019,04,01),
        DateTime.utc(2019,04,02),
        DateTime.utc(2019,04,03),
        DateTime.utc(2019,04,04),
        DateTime.utc(2019,04,05),
        DateTime.utc(2019,04,06),
      ]);

      result.clear();
      final DateRange iter2 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 7), endInclusive: true);
      print("Iterate [] range $iter2");
      for (DateTime dt in iter2) {
        print("iteration date $dt");
        result.add(dt);
      }
      expect(result, [
        DateTime.utc(2019,04,01),
        DateTime.utc(2019,04,02),
        DateTime.utc(2019,04,03),
        DateTime.utc(2019,04,04),
        DateTime.utc(2019,04,05),
        DateTime.utc(2019,04,06),
        DateTime.utc(2019,04,07),
      ]);

      result.clear();
      final DateRange iter3 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 7), startInclusive: false);
      print("Iterate () range $iter3");
      for (DateTime dt in iter3) {
        print("iteration date $dt");
        result.add(dt);
      }
      expect(result, [
        DateTime.utc(2019,04,02),
        DateTime.utc(2019,04,03),
        DateTime.utc(2019,04,04),
        DateTime.utc(2019,04,05),
        DateTime.utc(2019,04,06),
      ]);

      result.clear();
      final DateRange iter4 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 7), startInclusive: false, endInclusive: true);
      print("Iterate (] range $iter4");
      for (DateTime dt in iter4) {
        print("iteration date $dt");
        result.add(dt);
      }
      expect(result, [
        DateTime.utc(2019,04,02),
        DateTime.utc(2019,04,03),
        DateTime.utc(2019,04,04),
        DateTime.utc(2019,04,05),
        DateTime.utc(2019,04,06),
        DateTime.utc(2019,04,07),
      ]);

      print("First of $iter1 is ${iter1.first}");
      print("Last of $iter1 is ${iter1.last}");
      expect(iter1.first, DateTime.utc(2019,04,01));
      expect(iter1.last, DateTime.utc(2019,04,06));
    });
  });

  group('Numeric Ranges tests', () {
  });

  // other ranges tests

}
