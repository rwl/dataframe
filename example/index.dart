import 'package:dataframe/dataframe.dart';

main() {
  new Index("a", "b", "c"); // from seq of values
  new Index(new Vec("a", "b", "c")); // from vec
  new Index(new Array("a", "b", "c")); // from array

  // multi-level index
  new Index.make(new Vec(1, 2, 3), new Vec("a", "b", "c"));

  var x = Index("a", "a", "b", "b", "c", "c");
  x.next("a"); // returns "b"
  x.prev("b"); // returns "a"

  new Index.make(bizEoms, datetime(2013, 1, 1), datetime(2013, 5, 1));

  new RRule(MONTHLY).withInterval(2).counting(5).from(new DateTime(2013, 1, 1));

  weeklyOn(FR).withInterval(2).from(new DateTime(2013, 1, 1)).take(5).toList();

  conform(weeklyOn(FR), datetime(2013, 1, 1), forward = false);
}
