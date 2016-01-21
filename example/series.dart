import 'package:dataframe/dataframe.dart';

main() {
  Series<int, double> x = vec.rand(5);

  // constructions

  new Series.fromVec(new Vec(32, 12, 9));

  new Series.fromMap({"a": 1, "b": 2, "c": 3});

  new Series(new Vec(1, 2, 3), new Index("a", "b", "c"));

  new Series.empty<String, int>();

  new Series(new Vec(1, 2, 3), new Index("c", "b", "a"));

  new Series(new Vec(1, 2, 3, 4), new Index("c", "b", "a", "b"));

  // data access
  var q = new Series(new Vec(1, 3, 2, 4), new Index("c", "b", "a", "b"));

  q.values;
  q.index;

  q.at(2);
  q.at([2, 3, 1]);

  q.keyAt(2);

  q.keyAt([2, 3, 1]);

  q.sortedIx();

  q.sorted();

  q["b"];
  q[["a", "b"]];
  q[["b", "a"]];

  q.first;
  q.last;

  q.firstKey;
  q.lastKey;

  q.reindex(Index("a", "c", "d"));
  q.reindex(["a", "c", "d"]);

  q[["a", "d"]];

  q.resetIndex();

  q.setIndex(Index("w", "x", "y", "z"));

  var s = q.sortedIx();
  s.sliceBy(["b", "c"]);

  q.slice([0, 2]);

  q.head(2);
  q.tail(2);

  // compute

  q = new Series(new Vec(1, 3, 2, 4), new Index("c", "b", "a", "b"));
  q.mapValues(_ + 1);
  q.mapIndex(_ + "x");
  q.shift(1);
  q.filter(_ > 2);
  q.filterIx(_ != "b");
//  q.filterAt { case loc => loc != 1 && loc != 3 };
  q.find(_ == 2);
//  q.findKey { case x => x == 2 || x == 3 };
//  q.findOneKey { case x => x == 2 || x == 3 };
  q.minKey;
  q.contains("a");
//  q.scanLeft(0) { case (acc, v) => acc + v };
  q.reversed;

  var m = q.mask(q.values > 2);
  m.hasNA;
  m.dropNA();
  m.pad();

  q.rolling(2, _.minKey);
  q.splitAt(2);
  q.sortedIx.splitBy("b");

  // convert
  q.toVec();
  q.toSeq();

  // groupBy
  q.groupBy.combine(_.sum);

  q.groupBy.transform((s) => s - s.mean);

  // align data
  var a = new Series(new Vec(1, 4, 2, 3), new Index("a", "b", "c", "d"));
  var b =
      new Series(new Vec(5, 2, 1, 8, 7), new Index("b", "c", "d", "e", "f"));

  a + b;

  a = new Series(new Vec(1, 4, 2), new Index("a", "b", "b"));
  b = new Series(new Vec(5, 2, 1), new Index("b", "b", "d"));

  a + b;

  // joins

  a = new Series(new Vec(1, 4, 2), new Index("a", "b", "b"));
  b = new Series(new Vec(5, 2, 1), new Index("b", "b", "d"));

  a.join(b, how = index.LeftJoin);

  a.join(b, how = index.RightJoin);

  a.join(b, how = index.InnerJoin);

  a.join(b, how = index.OuterJoin);

  // multi level indexes
  var t = new Series(
      new Vec(1, 2, 3, 4),
      new Index([
        [1, 1],
        [1, 2],
        [2, 1],
        [2, 2]
      ]));

  // pivot
  var f = t.pivot();
  f.melt();
}
