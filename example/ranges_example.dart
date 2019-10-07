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

	print("union $dr1 + $dr2 = ${dr1 + dr2}");
	print("except $dr1 - $dr2 = ${dr1 - dr2}");
	print("intersect $dr1 * $dr2 = ${dr1 * dr2}");

	print("union $dr1 + $dr3 = ${dr1 + dr3}");
	print("except $dr1 - $dr3 = ${dr1 - dr3}");
	print("intersect $dr1 * $dr3 = ${dr1 * dr3}");

	print("$dr3 sub $dr4 = ${dr3.isSubsetOf(dr4)}");
	print("$dr3 sup $dr4 = ${dr3.isSupersetOf(dr4)}");
	print("$dr3 adj $dr4 = ${dr3.isAdjacentTo(dr4)}");
	print("$dr3 over $dr4 = ${dr3.overlaps(dr4)}");

	print("$dr4 adj $dr5 = ${dr4.isAdjacentTo(dr5)}");
	print("$dr4 adj $dr6 = ${dr4.isAdjacentTo(dr6)}");

	print("$dr7 adj $dr6 = ${dr7.isAdjacentTo(dr6)}");
	print("$dr7 adj $dr8 = ${dr7.isAdjacentTo(dr8)}");

	print("Iterate range $dr1");
	for(DateTime dt in dr1) {
		print("iteration date $dt");
	}

	final DateRange dr9 = DateRange(null, DateTime(2019, 05, 11));

}
