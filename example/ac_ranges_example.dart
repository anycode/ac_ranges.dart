
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

import 'package:ac_ranges/ac_ranges.dart';

main() {
  print("=== DATE RANGE EXAMPLES ===");
  _dateRangeExamples();

  print("\n=== INT RANGE EXAMPLES ===");
  _intRangeExamples();

  print("\n=== DOUBLE RANGE EXAMPLES ===");
  _doubleRangeExamples();
}

void _dateRangeExamples() {
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
  for (var x in drex1) {
    drex2.addAll(x.except(dre3).map((x) => x as DateRange).toList());
  }
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

void _intRangeExamples() {
  // Základní IntRange operace
  final IntRange ir1 = IntRange(1, 10);
  final IntRange ir2 = IntRange(5, 15);
  final IntRange ir3 = IntRange(20, 25);
  final IntRange ir4 = IntRange(10, 20, startInclusive: false);
  final IntRange ir5 = IntRange(8, 12, endInclusive: true);

  print("Basic IntRange operations:");
  print("union $ir1 + $ir2 = ${ir1 + ir2}");
  print("except $ir1 - $ir2 = ${ir1 - ir2}");
  print("intersect $ir1 * $ir2 = ${ir1 * ir2}");

  print("Non-overlapping ranges:");
  print("union $ir1 + $ir3 = ${ir1 + ir3}");
  print("except $ir1 - $ir3 = ${ir1 - ir3}");
  print("intersect $ir1 * $ir3 = ${ir1 * ir3}");

  print("Contains tests:");
  print("$ir1 contains 5 = ${ir1.contains(5)}");
  print("$ir1 contains 10 = ${ir1.contains(10)}");
  print("$ir1 contains 15 = ${ir1.contains(15)}");
  print("$ir5 contains 12 = ${ir5.contains(12)}"); // endInclusive test

  print("Relationship tests:");
  print("$ir1 overlaps $ir2 = ${ir1.overlaps(ir2)}");
  print("$ir1 overlaps $ir3 = ${ir1.overlaps(ir3)}");
  print("$ir1 isAdjacentTo $ir4 = ${ir1.isAdjacentTo(ir4)}");

  print("Iteration over IntRange $ir1:");
  for (int i in ir1) {
    print("value: $i");
    if (i > 5) break; // Omezíme výstup
  }

  // Nekonečné ranges
  final IntRange iri1 = IntRange(null, 10);
  final IntRange iri2 = IntRange(5, null);
  final IntRange iri3 = IntRange(null, null);

  print("Infinite ranges:");
  print("$iri1 contains -100 = ${iri1.contains(-100)}");
  print("$iri1 contains 15 = ${iri1.contains(15)}");
  print("$iri2 contains 100 = ${iri2.contains(100)}");
  print("$iri2 contains 3 = ${iri2.contains(3)}");
  print("$iri3 contains 999999 = ${iri3.contains(999999)}");

  // Parsing
  final IntRange? irp1 = IntRange.parse('[1,10)');
  final IntRange? irp2 = IntRange.parse('(5,15]');
  print("Parsed ranges:");
  print("Parsed '[1,10)' = $irp1");
  print("Parsed '(5,15]' = $irp2");
  print("$irp1 * $irp2 = ${irp1! * irp2!}");
}

void _doubleRangeExamples() {
  // Základní DoubleRange operace
  final DoubleRange dr1 = DoubleRange(1.0, 10.5);
  final DoubleRange dr2 = DoubleRange(5.2, 15.7);
  final DoubleRange dr3 = DoubleRange(20.1, 25.8);
  final DoubleRange dr4 = DoubleRange(10.5, 20.1, startInclusive: false);
  final DoubleRange dr5 = DoubleRange(8.3, 12.7, endInclusive: true);

  print("Basic DoubleRange operations:");
  print("union $dr1 + $dr2 = ${dr1 + dr2}");
  print("except $dr1 - $dr2 = ${dr1 - dr2}");
  print("intersect $dr1 * $dr2 = ${dr1 * dr2}");

  print("Non-overlapping ranges:");
  print("union $dr1 + $dr3 = ${dr1 + dr3}");
  print("except $dr1 - $dr3 = ${dr1 - dr3}");
  print("intersect $dr1 * $dr3 = ${dr1 * dr3}");

  print("Contains tests:");
  print("$dr1 contains 5.5 = ${dr1.contains(5.5)}");
  print("$dr1 contains 10.5 = ${dr1.contains(10.5)}");
  print("$dr1 contains 15.0 = ${dr1.contains(15.0)}");
  print("$dr5 contains 12.7 = ${dr5.contains(12.7)}"); // endInclusive test

  print("Relationship tests:");
  print("$dr1 overlaps $dr2 = ${dr1.overlaps(dr2)}");
  print("$dr1 overlaps $dr3 = ${dr1.overlaps(dr3)}");
  print("$dr1 isAdjacentTo $dr4 = ${dr1.isAdjacentTo(dr4)}");

  // Precision tests
  final DoubleRange drp1 = DoubleRange(0.1, 0.2);
  final DoubleRange drp2 = DoubleRange(0.15, 0.25);
  print("Precision tests:");
  print("$drp1 * $drp2 = ${drp1 * drp2}");
  print("$drp1 contains 0.15 = ${drp1.contains(0.15)}");

  // Nekonečné ranges
  final DoubleRange dri1 = DoubleRange(null, 10.5);
  final DoubleRange dri2 = DoubleRange(5.2, null);
  final DoubleRange dri3 = DoubleRange(null, null);

  print("Infinite ranges:");
  print("$dri1 contains -100.7 = ${dri1.contains(-100.7)}");
  print("$dri1 contains 15.3 = ${dri1.contains(15.3)}");
  print("$dri2 contains 100.9 = ${dri2.contains(100.9)}");
  print("$dri2 contains 3.1 = ${dri2.contains(3.1)}");
  print("$dri3 contains 999999.999 = ${dri3.contains(999999.999)}");

  // Parsing
  final DoubleRange? drpa1 = DoubleRange.parse('[1.5,10.7)');
  final DoubleRange? drpa2 = DoubleRange.parse('(5.2,15.1]');
  print("Parsed ranges:");
  print("Parsed '[1.5,10.7)' = $drpa1");
  print("Parsed '(5.2,15.1]' = $drpa2");
  print("$drpa1 * $drpa2 = ${drpa1! * drpa2!}");

  // Subset/Superset tests
  final DoubleRange drs1 = DoubleRange(1.0, 10.0);
  final DoubleRange drs2 = DoubleRange(2.5, 7.5);
  print("Subset/Superset tests:");
  print("$drs2 isSubsetOf $drs1 = ${drs2.isSubsetOf(drs1)}");
  print("$drs1 isSupersetOf $drs2 = ${drs1.isSupersetOf(drs2)}");
}