import 'package:ranges/ranges.dart';

main() {
  final DateRange dr1 = DateRange(DateTime(2019, 01, 01), DateTime(2019, 02, 28));
  final DateRange dr2 = DateRange(DateTime(2019, 02, 01), DateTime(2019, 03, 28));
  final DateRange dr3 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 28));
  final DateRange dr4 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 8), endInclusive: true);
  final DateRange dr5 = DateRange(DateTime(2019, 04, 08), DateTime(2019, 05, 11));
  final DateRange dr6 = DateRange(DateTime(2019, 04, 09), DateTime(2019, 05, 11));
  final DateRange dr7 = DateRange(DateTime(2019, 04, 01), DateTime(2019, 04, 8));
  final DateRange dr8 = DateRange(DateTime(2019, 04, 09), DateTime(2019, 05, 11), startInclusive: false);
  final DateTime dt1a = DateTime(2018, 12, 31);
  final DateTime dt1b = DateTime(2019, 01, 05);
  final DateTime dt1c = DateTime(2019, 03, 01);
  final DateTime dt2 = DateTime(2019, 04, 08);

  print("union $dr1 + $dr2 = ${dr1 + dr2}");
  print("except $dr1 - $dr2 = ${dr1 - dr2}");
  print("intersect $dr1 * $dr2 = ${dr1 * dr2}");

  print("union $dr1 + $dr3 = ${dr1 + dr3}");
  print("except $dr1 - $dr3 = ${dr1 - dr3}");
  print("intersect $dr1 * $dr3 = ${dr1 * dr3}");

  print("$dr1 contains $dt1a = ${dr1.contains(dt1a)}");
  print("$dr1 contains $dt1b = ${dr1.contains(dt1b)}");
  print("$dr1 contains $dt1c = ${dr1.contains(dt1c)}");
  print("$dr4 contains $dt2 = ${dr4.contains(dt2)}");
  print("$dr7 contains $dt2 = ${dr7.contains(dt2)}");

  print("$dr3 sub $dr4 = ${dr3.isSubsetOf(dr4)}");
  print("$dr3 sup $dr4 = ${dr3.isSupersetOf(dr4)}");
  print("$dr3 adj $dr4 = ${dr3.isAdjacentTo(dr4)}");
  print("$dr3 over $dr4 = ${dr3.overlaps(dr4)}");

  print("$dr4 adj $dr5 = ${dr4.isAdjacentTo(dr5)}");
  print("$dr4 adj $dr6 = ${dr4.isAdjacentTo(dr6)}");

  print("$dr7 adj $dr6 = ${dr7.isAdjacentTo(dr6)}");
  print("$dr7 adj $dr8 = ${dr7.isAdjacentTo(dr8)}");

  print("Iterate range $dr1");
  for (DateTime dt in dr1) {
    print("iteration date $dt");
  }

  final DateRange dri1 = DateRange(null, DateTime(2019, 05, 11));
  final DateRange dri2 = DateRange(DateTime(2019, 05, 10), null);
  final DateRange dri3 = DateRange(null, null);

  print("union $dri1 + $dri2 = ${dri1 + dri2}");
  print("except $dri1 - $dri2 = ${dri1 - dri2}");
  print("intersect $dri1 * $dri2 = ${dri1 * dri2}");
  print("except $dri3 - $dr4 = ${dri3 - dr4}");

  print("$dri1 contains $dt1a = ${dri1.contains(dt1a)}");
  print("$dri1 contains $dt1b = ${dri1.contains(dt1b)}");
  print("$dri1 contains $dt1c = ${dri1.contains(dt1c)}");
  print("$dri2 contains $dt1a = ${dri2.contains(dt1a)}");
  print("$dri2 contains $dt1b = ${dri2.contains(dt1b)}");
  print("$dri2 contains $dt1c = ${dri2.contains(dt1c)}");
  print("$dri3 contains $dt1a = ${dri3.contains(dt1a)}");
  print("$dri3 contains $dt1b = ${dri3.contains(dt1b)}");
  print("$dri3 contains $dt1c = ${dri3.contains(dt1c)}");

  final DateRange drx1 = DateRange(DateTime(2020, 02, 15), DateTime(2020, 02, 22));
  final DateRange drx2 = DateRange(DateTime(2020, 02, 15), DateTime(2020, 02, 18));
  print("$drx2 is subset of $drx1 = ${drx2.isSubsetOf(drx1)}");

  final DateRange dre1 = DateRange(DateTime(2019, 12, 28), DateTime(2020, 04, 01));
  final DateRange dre2 = DateRange(DateTime(2019, 12, 28), DateTime(2020, 01, 04));
  final DateRange dre3 = DateRange(DateTime(2020, 01, 04), DateTime(2020, 01, 11));
  final List<DateRange> drex1 = dre1.except(dre2).map((x) => x as DateRange).toList();
  final List<DateRange> drex2 = [];
  drex1.forEach((DateRange x) => drex2.addAll(x.except(dre3).map((x) => x as DateRange).toList()));
  print("$dre1 exclude $dre2 = $drex1");
  print("$drex1 exclude $dre3 = $drex2");

  final List<DateRange> drl1 = [
    DateRange(DateTime(2019, 12, 22), DateTime(2020, 02, 01)),
    DateRange(DateTime(2020, 03, 01), DateTime(2020, 04, 01)),
  ];
  final List<DateRange> drl2 = [
    DateRange(DateTime(2019, 12, 25), DateTime(2019, 12, 27)),
    DateRange(DateTime(2020, 01, 03), DateTime(2020, 01, 08)),
    DateRange(DateTime(2020, 01, 22), DateTime(2020, 01, 25)),
  ];
  final List<DateRange> drl3 = DateRange.listExcept(drl1, drl2);
  print("listExcept($drl1, $drl2) = $drl3");

  // A [2020-02-29,2020-03-08), B [2020-02-29,2020-03-07), B.subset(A)
  final DateRange? drak1 = DateRange.parse('[2020-02-29,2020-03-07)');
  final DateRange? drak2 = DateRange.parse('[2020-02-29,2020-03-08)');
  print("$drak1.isSubsetOf($drak2) = ${drak1?.isSubsetOf(drak2!)}");
  print("$drak2.isSupersetOf($drak1) = ${drak2?.isSupersetOf(drak1!)}");
}
