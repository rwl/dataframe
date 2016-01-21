import 'package:dataframe/dataframe.dart';

main() {
  val v = Vec(1, 2); // given the following
  val u = Vec(3, 4);
  val s = Series({"a": 1, "b": 2});
  val t = Series({"b": 3, "c": 4});

  new Frame(v, u); // two-column frame

  new Frame({"x": v, "y": u}); // with column index

  new Frame(s, t); // aligned along rows

  new Frame({"x": s, "y": t}); // with column index

  new Frame(new Seq(s, t), new Index("x", "y")); // explicit column index

  new Frame(new Seq(v, u), new Index(0, 1),
      new Index("x", "y")); // row & col indexes specified explicitly

  new Frame(new Seq(v, u), new Index("a", "b")); // col index specified

  var p = new Panel(new Vec(1, 2, 3), new Vec("a", "b", "c"));

  p.colType[Int];
  p.colType[[Int, String]];

//  f.emptyRow();
//  f.emptyCol();

  // set or reset the index
  var f = Frame({"x": s, "y": t});

  f.setRowIndex(Index(10, 20));
  f.setColIndex(Index("p", "q"));
  f.resetRowIndex();
  f.resetColIndex();

  // index transformation
//  f.mapRowIndex { case rx => ... }
//  f.mapColIndex { case cx => ... }

  // extract data
  f.rowAt(2); // extract row at offset 2, as Series
  f.rowAt(1, 2); // extract frame of rows 1 & 2
  f.rowAt(range(1, 2)); // extract frame of rows 1 & 2

  f.colAt(1); // extract col at offset 1, as Series
  f.colAt(0, 1); // extract frame of cols 1 & 2
  f.colAt(range(0, 1)); // extract frame of cols 1 & 2

  f.at(1, 1); // Scalar value
  f.at([1, 2], 0); // extract rows 1,2 of column 0
  f.at(range(0, 1), 1); // extract rows 0,1 of column 1
  f.at(range(0, 1), range(0, 1)); // extract rows 0,1 of columns 0, 1

  // slicing
  f.colSlice(0, 1); // frame slice consisting of column 0
  f.rowSlice(0, 3, 2); // row slice from 0 until 3, striding by 2

  // select data using keys
  f.row("a"); // row series 'a', with all columns
  f.col("x"); // col series 'x', with all rows
  f.row("a", "c"); // select two rows
  f.row({"a": "b"}); // slice two rows (index must be sorted)
  f.row(new Vec("a", "c")); // another way to select

  f.rowSliceBy("a", "b", inclusive: false);
  f.colSliceBy("x", "x", inclusive: true);

  f("a", "x"); // extract a one-element frame by keys
  f({"a": "b"}, "x"); // two-row, one-column frame
  f(new Vec("a", "c"), "x"); // same as above, but extracting, not slicing

  // split
  f.colSplitAt(1); // split into two frames at column 1
  f.colSplitBy("y");

  f.rowSplitAt(1);
  f.rowSplitBy("b");

  // extract rows or columns
  f.head(2); // operates on rows
  f.tail(2);
  f.headCol(1); // operates on cols
  f.tailCol(1);

  f.first("b"); // first row indexed by "b" key
  f.last("b"); // last row indexed by "b" key
  f.firstCol("x");
  f.lastCol("x");

//  f.filter { case s => s.mean > 2.0 }  // any column whose series satisfies predicate
//  f.filterIx { case x => x == "x" }    // col where index matches key "x"
  f.where(new Vec(false, true)); // extract second column

  // NaN
  f.dropNA();
  f.rdropNA();

  // operations
  f + 1;
  f * f;
  val g = new Frame({
    "y": new Series({"b": 5, "d": 10})
  });
  f + g; // one non-NA entry, ("b", "y", 8)

  // joinMap
//  f.joinMap(g, rhow=index.LeftJoin, chow=index.LeftJoin) { case (x, y) => x + y }

  // align one frame to another
  var fNew, gNew = f.align(g, rhow: index.LeftJoin, chow: index.OuterJoin);

  // sort
  f.sortedRIx(); // sorted by row index
  f.sortedCIx(); // sorted by col index
  f.sortedRows(0, 1); // sort rows by (primary) col 0 and (secondary) col 1
  f.sortedCols(1, 0); // sort cols by (primary) row 1 and (secondary) row 0

//  f.sortedRowsBy { case r => r.at(0) }   // sort rows by first element of row
//  f.sortedColsBy { case c => c.at(0) }   // sort cols by first element of col

  // mapping functions
//  f.mapValues { case t => t + 1 }        // add one to each element of frame
//  f.mapVec { case v => v.demeaned }      // map over each col vec of the frame
//  f.reduce { case s => s.mean }          // collapse each col series to a single value
//  f.transform { case s => s.reversed }   // transform each series; outerjoin results

  // mask
  f.mask((x) => x > 2); // mask out values > 2
  f.mask(new Vec(false, true, true)); // mask out rows 1 & 2 (keep row 0)

  f
      .mask(new Vec(true, false, false))
      .rsqueeze(); // drop rows containing NA values
  f.rmask(new Vec(false, true)).squeeze(); // takes "x" column

  // groupBy
  f
      .groupBy(_ == "a")
      .combine(_.count); // # obs in each column that have/not row key "a"
  f
      .groupBy(_ == "a")
      .transform(_.demeaned); // contrived, but you get the idea hopefully!

  // join
  f.join(g, how = index.LeftJoin); // left joins on row index, drops col indexes
  f.join(s, how = index.LeftJoin); // implicitly promotes s to Frame
  f.joinS(s, how = index.LeftJoin); // use Series directly

  s.joinF(g, how = index.LeftJoin);

  // reshaping
  f.melt();
//  f.melt.mapRowIndex { case (a, b) => (b, a) } colAt(0) pivot
//  f.mapColIndex { case c => (1, c) } stack
//  f.mapRowIndex { case r => (1, r) } unstack
}
