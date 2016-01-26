/**
 * Copyright (c) 2013 Saddle Development Team
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
 **/

library saddle;

import 'vec/vec.dart';
import 'index/index.dart';
import 'index/join_type.dart';
//import 'groupby/groupby.dart';
import 'ops/ops.dart';
//import 'stats/stats.dart';
//import 'util/concat.dart' show Promoter;
import 'scalar/scalar.dart' show Scalar;
//import java.io.OutputStream
//import org.saddle.mat.MatCols

/**
 * `Frame` is an immutable container for 2D data which is indexed along both axes
 * (rows, columns) by associated keys (i.e., indexes).
 *
 * The primary use case is homogeneous data, but a secondary concern is to support
 * heterogeneous data that is homogeneous ony within any given column.
 *
 * The row index, column index, and constituent value data are all backed ultimately
 * by arrays.
 *
 * `Frame` is effectively a doubly-indexed associative map whose row keys and col keys
 * each have an ordering provided by the natural (provided) order of their backing
 * arrays.
 *
 * Several factory and access methods are provided. In the following examples, assume
 * that:
 *
 * {{{
 *   val f = Frame('a'->Vec(1,2,3), 'b'->Vec(4,5,6))
 * }}}
 *
 * The `apply` method takes a row and col key returns a slice of the original Frame:
 *
 * {{{
 *   f(0,'a') == Frame('a'->Vec(1))
 * }}}
 *
 * `apply` also accepts a [[org.saddle.index.Slice]]:
 *
 * {{{
 *   f(0->1, 'b') == Frame('b'->Vec(4,5))
 *   f(0, *) == Frame('a'->Vec(1), 'b'->Vec(4))
 * }}}
 *
 * You may slice using the `col` and `row` methods respectively, as follows:
 *
 * {{{
 *   f.col('a') == Frame('a'->Vec(1,2,3))
 *   f.row(0) == Frame('a'->Vec(1), 'b'->Vec(4))
 *   f.row(0->1) == Frame('a'->Vec(1,2), 'b'->Vec(4,5))
 * }}}
 *
 * You can achieve a similar effect with `rowSliceBy` and `colSliceBy`
 *
 * The `colAt` and `rowAt` methods take an integer offset i into the Frame, and
 * return a Series indexed by the opposing axis:
 *
 * {{{
 *   f.rowAt(0) == Series('a'->1, 'b'->4)
 * }}}
 *
 * If there is a one-to-one relationship between offset i and key (ie, no duplicate
 * keys in the index), you may achieve the same effect via key as follows:
 *
 * {{{
 *   f.first(0) == Series('a'->1, 'b'->4)
 *   f.firstCol('a') == Series(1,2,3)
 * }}}
 *
 * The `at` method returns an instance of a [[org.saddle.scalar.Scalar]], which behaves
 * much like an `Option`; it can be either an instance of [[org.saddle.scalar.NA]] or a
 * [[org.saddle.scalar.Value]] case class:
 *
 * {{{
 *   f.at(0, 0) == scalar.Scalar(1)
 * }}}
 *
 * The `rowSlice` and `colSlice` methods allows slicing the Frame for locations in [i, j)
 * irrespective of the value of the keys at those locations.
 *
 * {{{
 *   f.rowSlice(0,1) == Frame('a'->Vec(1), 'b'->Vec(4))
 * }}}
 *
 * Finally, the method `raw` accesses a value directly, which may reveal the underlying
 * representation of a missing value (so be careful).
 *
 * {{{
 *   f.raw(0,0) == 1
 * }}}
 *
 * `Frame` may be used in arithmetic expressions which operate on two `Frame`s or on a
 * `Frame` and a scalar value. In the former case, the two Frames will automatically
 * align along their indexes:
 *
 * {{{
 *   f + f.shift(1) == Frame('a'->Vec(NA,3,5), 'b'->Vec(NA,9,11))
 * }}}
 *
 * @param values A sequence of Vecs which comprise the columns of the Frame
 * @param rowIx An index for the rows
 * @param colIx An index for the columns
 * @tparam RX The type of row keys
 * @tparam CX The type of column keys
 * @tparam T The type of entries in the frame
 */
class Frame /*[RX: ST: ORD, CX: ST: ORD, T: ST]*/ <RX, CX,
    T> /*extends NumericOps<Frame<RX, CX, T>> with Serializable*/ {
  Frame(
      /*private[saddle]*/ MatCols<T> values,
      Index<RX> rowIx,
      Index<CX> colIx) {
    require(values.numRows == rowIx.length, "Row index length is incorrect");
    require(values.numCols == colIx.length, "Col index length is incorrect");
  }

  /*private*/ Option<Mat<T>> cachedMat = null;
  /*private*/ Option<MatCols<T>> cachedRows = null;

  /**
   * Number of rows in the Frame
   */
  int get numRows => values.numRows;

  /**
   * Number of cols in the Frame
   */
  int get numCols => values.numCols;

  /**
   * Returns true if there are no values in the Frame
   */
  bool get isEmpty => (values.numRows == 0);

  /**
   * The transpose of the frame (swapping the axes)
   */
//  Frame<CX, RX, T> get T => Frame(rows(), colIx, rowIx);

  // ---------------------------------------------------------------
  // extract columns by associated key(s); ignore non-existent keys

  /**
   * Given one or more column keys, slice out the corresponding column(s)
   * @param keys Column key(s) (sequence)
   */
//  Frame<RX, CX, T> col(CX* keys) => col(keys.toArray);

  /**
   * Given a Slice of type of column key, slice out corresponding column(s)
   * @param slice Slice containing appropriate key bounds
   */
  Frame<RX, CX, T> colSlice(Slice<CX> slice) {
    var a, b = slice(colIx);
    Frame(values.slice(a, b), rowIx, colIx.sliceBy(slice));
  }

  /**
   * Given an array of column keys, slice out the corresponding column(s)
   * @param keys Array of keys
   */
  Frame<RX, CX, T> col(Array<CX> keys) {
    if (values.numCols == 0) {
      return new Frame.empty<RX, CX, T>();
    } else {
      val locs = array.filter[Int](_ != -1)(colIx(keys));
      colAt(locs);
    }
  }

  /**
   * Slice out a set of columns from the frame
   * @param from Key from which to begin slicing
   * @param to Key at which to end slicing
   * @param inclusive Whether to include 'to' key; true by default
   */
  Frame<RX, CX, T> colSliceBy(CX from, CX to, [bool inclusive = true]) {
//    val tmp = Series(values : _*).setIndex(colIx);
    val res = tmp.sliceBy(from, to, inclusive);
    Frame(res.values.toArray, rowIx, res.index);
  }

  // -----------------------------------------
  // access columns by particular location(s)

  /**
   * Access frame column at a particular integer offset
   * @param loc integer offset
   */
  Series<RX, T> colAt(int loc) => Series(values(loc), rowIx);

  /**
   * Access frame columns at a particular integer offsets
   * @param locs a sequence of integer offsets
   */
//  Frame<RX, CX, T> colAt(int* locs) => colAt(locs.toArray);

  /**
   * Access frame columns at a particular integer offsets
   * @param locs an array of integer offsets
   */
  Frame<RX, CX, T> colAtTake(Array<int> locs) {
    if (values.numCols == 0) {
      Frame.empty /*<RX, CX, T>*/ ();
    } else {
      Frame(values.take(locs), rowIx, colIx.take(locs));
    }
  }

  /**
   * Access frame columns specified by a slice
   * @param slice a slice specifier
   */
  Frame<RX, CX, T> colAtSlice(Slice<int> slice) {
    val idx = IndexIntRange(numCols);
    val pair = slice(idx);
    Frame(values.slice(pair._1, pair._2), rowIx, colIx.slice(pair._1, pair._2));
  }

  /**
   * Access frame columns between two integer offsets, [from, until)
   * @param from Beginning offset
   * @param until One past ending offset
   * @param stride Optional increment between offsets
   */
  Frame<RX, CX, T> colRange(int from, int until, [int stride = 1]) {
    val lb = math.max(0, from);
    val ub = math.min(numCols, until);
    val taker = array.range(lb, ub, stride);
    Frame(values.take(taker), rowIx, colIx.take(taker));
  }

  /**
   * Split Frame into two frames at column position c
   * @param c Position at which to split Frame
   */
  /*(Frame<RX, CX, T>, Frame<RX, CX, T>)*/ colSplitAt(int c) =>
      [colSlice(0, c), colSlice(c, numCols)];

  /**
   * Split Frame into two frames at column key k
   * @param k Key at which to split Frame
   */
  /*(Frame<RX, CX, T>, Frame<RX, CX, T>)*/ colSplitBy(CX k) =>
      colSplitAt(colIx.lsearch(k));

  // ---------------------------------------------------------------
  // extract rows by associated key(s); ignore non-existent keys

  /**
   * Given one or more row keys, slice out the corresponding row(s)
   * @param keys Row key(s) (sequence)
   */
//  Frame<RX, CX, T> row(RX* keys) => row(keys.toArray);

  /**
   * Given a Slice of type of row key, slice out corresponding row(s)
   * @param slice Slice containing appropriate key bounds
   */
  Frame<RX, CX, T> row(Slice<RX> slice) {
    val a, b = slice(rowIx);
    Frame(values.map((v) => v.slice(a, b)), rowIx.sliceBy(slice), colIx);
  }

  /**
   * Given an array of row keys, slice out the corresponding row(s)
   * @param keys Array of keys
   */
  Frame<RX, CX, T> rowTake(Array<RX> keys) {
    if (values.numRows == 0) {
      Frame.empty(); //<RX, CX, T>;
    } else {
      val locs = array.filter[Int](_ != -1)(rowIx(keys));
      rowAt(locs);
    }
  }

  /**
   * Slice out a set of rows from the frame
   * @param from Key from which to begin slicing
   * @param to Key at which to end slicing
   * @param inclusive Whether to include 'to' key; true by default
   */
  Frame<RX, CX, T> rowSliceBy(RX from, RX to, [bool inclusive = true]) {
    val start = rowIx.lsearch(from);
    val end = inclusive ? rowIx.rsearch(to) : rowIx.lsearch(to);
    Frame(
        values.map((v) => v.slice(start, end)), rowIx.slice(start, end), colIx);
  }

  // -----------------------------------------
  // access rows by particular location(s)

  /**
   * Access frame row at a particular integer offset
   * @param loc integer offset
   */
  Series<CX, T> rowAt(int loc) => Series(rows()(loc), colIx);

  /**
   * Access frame rows at a particular integer offsets
   * @param locs a sequence of integer offsets
   */
//  Frame<RX, CX, T> rowAt(int* locs) => rowAt(locs.toArray);

  /**
   * Access frame rows at a particular integer offsets
   * @param locs an array of integer offsets
   */
  Frame<RX, CX, T> rowAtTake(Array<int> locs) =>
      Frame(values.map((v) => v.take(locs)), rowIx.take(locs), colIx);

  /**
   * Access frame rows specified by a slice
   * @param slice a slice specifier
   */
  Frame<RX, CX, T> rowAtSlice(Slice<int> slice) {
    val idx = IndexIntRange(numRows);
    val pair = slice(idx);
    Frame(values.map(_.slice(pair._1, pair._2)), rowIx.slice(pair._1, pair._2),
        colIx);
  }

  /**
   * Access frame rows between two integer offsets, [from, until)
   * @param from Beginning offset
   * @param until One past ending offset
   * @param stride Optional increment between offsets
   */
  Frame<RX, CX, T> rowSlice(int from, int until, [int stride = 1]) {
    Frame(values.map((v) => v.slice(from, until, stride)),
        rowIx.slice(from, until, stride), colIx);
  }

  /**
   * Split Frame into two frames at row position r
   * @param r Position at which to split Frame
   */
  /*(Frame<RX, CX, T>, Frame<RX, CX, T>)*/ rowSplitAt(int r) =>
      [rowSlice(0, r), rowSlice(r, numRows)];

  /**
   * Split Frame into two frames at row key k
   * @param k Key at which to split Frame
   */
  /*(Frame<RX, CX, T>, Frame<RX, CX, T>)*/ rowSplitBy(RX k) =>
      rowSplitAt(rowIx.lsearch(k));

  // --------------------------------------------
  // access a two dimensional sub-block by key(s)

  /**
   * Slice frame by row and column slice specifiers
   * @param rix A row slice
   * @param cix A col slice
   */
  Frame<RX, CX, T> applySlice(Slice<RX> rix, Slice<CX> cix) =>
      col(cix).row(rix);

  /**
   * Slice frame by row slice and array of column keys
   * @param rix A row slice
   * @param cix An array of column keys
   */
  Frame<RX, CX, T> applySliceArray(Slice<RX> rix, Array<CX> cix) =>
      col(cix).row(rix);

  /**
   * Slice frame by array of row keys and a col slice
   * @param rix An array of row keys
   * @param cix A col slice
   */
  Frame<RX, CX, T> applyArraySlice(Array<RX> rix, Slice<CX> cix) =>
      col(cix).row(rix);

  /**
   * Slice from by an array of row keys and an array of col keys
   * @param rix An array of row keys
   * @param cix An array of col keys
   */
  Frame<RX, CX, T> applyArray(Array<RX> rix, Array<CX> cix) =>
      col(cix).row(rix);

  // -----------------------------------------
  // access grid by particular location(s)

  /**
   * Access a (Scalar-boxed) value from within the Frame
   * @param r Integer row offset
   * @param c Integer col offset
   */
  Scalar<T> at(int r, int c) => values.at(r, c);

  /**
   * Access a slice of the Frame by integer offsets
   * @param r Array of row offsets
   * @param c Array of col offsets
   */
  Frame<RX, CX, T> atTake(Array<int> r, Array<int> c) => rowAt(r).colAt(c);

  /**
   * Access a slice of the Frame by integer offsets
   * @param r Array of row offsets
   * @param c Integer col offset
   */
  Series<RX, T> atTakeCol(Array<int> r, int c) => rowAt(r).colAt(c);

  /**
   * Access a slice of the Frame by integer offsets
   * @param r Integer row offset
   * @param c Array of col offsets
   */
  Series<CX, T> atTakeRow(int r, Array<int> c) => colAt(c).rowAt(r);

  /**
   * Access a slice of the Frame by Slice parameters
   * @param r Slice to apply to rows
   * @param c Slice to apply to cols
   */
  Frame<RX, CX, T> atSlice(Slice<int> r, Slice<int> c) => rowAt(r).colAt(c);

  /**
   * Access the raw (unboxed) value at an offset within the Frame
   * @param r Integer row offset
   * @param c Integer col offset
   */
  T raw(int r, int c) => values(r, c);

  // -----------------------------------------
  // re-index frame; non-existent keys map to NA

  /**
   * Create a new Frame whose indexes are formed from the provided arguments, and whose values
   * are derived from the original Frame. Keys in the provided indices which do not map to
   * existing values will map to NA in the new Frame.
   * @param rix Sequence of keys to be the row index of the result Frame
   * @param cix Sequence of keys to be the col index of the result Frame
   */
  Frame<RX, CX, T> reindex(Index<RX> rix, Index<CX> cix) =>
      reindexRow(rix).reindexCol(cix);

  /**
   * Create a new Frame whose row index is formed of the provided argument, and whose values
   * are derived from the original Frame.
   * @param rix Sequence of keys to be the row index of the result Frame
   */
  Frame<RX, CX, T> reindexRow(Index<RX> rix) {
    val ixer = rowIx.getIndexer(rix);
//    ixer.map { i =>
//      Frame(values.map(v => Vec(array.take(v, i, v.scalarTag.missing))), rix, colIx)
//    } getOrElse this
  }

  /**
   * Create a new Frame whose col index is formed of the provided argument, and whose values
   * are derived from the original Frame.
   * @param cix Sequence of keys to be the col index of the result Frame
   */
  Frame<RX, CX, T> reindexCol(Index<CX> cix) {
    val ixer = colIx.getIndexer(cix);
//    ixer.map { i =>
//      Frame(values.take(i), rowIx, cix)
//    } getOrElse this
  }

  // -----------------------------------------
  // access columns by type

  /**
   * Extract columns from a heterogeneous Frame which match the provided type.
   * The result is a homogeneous frame consisting of the selected data.
   * @tparam U The type of columns to extract
   */
  Frame<RX, CX, U> colType /*[U: ST]*/ () {
    val columns, locs = values.takeType[U];
    Frame(columns, rowIx, colIx.take(locs));
  }

  /**
   * Extract columns from a heterogeneous Frame which match either of the provided
   * types. The result is a heterogeneous frame consisting of the selected data.
   * @tparam U1 First type of columns to extract
   * @tparam U2 Second type of columns to extract
   */
  Frame<RX, CX, Any> colTypeAlt /*[U1: ST, U2: ST]*/ () {
    val columns1, locs1 = values.takeType[U1];
    val columns2, locs2 = values.takeType[U2];

//    val frm = Panel(columns1 ++ columns2, rowIx, colIx.take(locs1) concat colIx.take(locs2))
    val tkr = array.argsort(array.flatten(Seq(locs1, locs2)));

    frm.colAt(tkr);
  }

  // ----------------------------------------
  // generate or use a new index

  /**
   * Create a new Frame using the current values but with the new row index. Positions
   * of the values do not change. Length of new index must be equal to number of rows.
   * @param newIx A new Index
   * @tparam Y Type of elements of new Index
   */
  Frame<Y, CX, T> setRowIndex /*[Y: ST: ORD]*/ (Index<Y> newIx) =>
      Frame(values, newIx, colIx).withMat(cachedMat);

  /**
   * Create a new Frame using the current values but with the new row index specified
   * by the column at a particular offset, and with that column removed from the frame
   * data body.
   */
  Frame<T, CX, T> withRowIndex(int col) /*(implicit ordT: ORD[T])*/ =>
      this.setRowIndex(Index(this.colAt(col).toVec)).filterAt(_ != col);

  /**
   * Overloaded method to create hierarchical index from two cols.
   */
  Frame /*<(T, T), CX, T>*/ with2RowIndex(
      int col1, int col2) /*(implicit ordT: ORD[T])*/ {
    Index /*[(T, T)]*/ newIx =
        Index.make(this.colAt(col1).toVec, this.colAt(col2).toVec);
//    this.setRowIndex(newIx).filterAt { case c => !Set(col1, col2).contains(c) }
  }

  /**
   * Map a function over the row index, resulting in a new Frame
   *
   * @param fn The function RX => Y with which to map
   * @tparam Y Result type of index, ie Index<Y>
   */
  Frame<Y, CX, T> mapRowIndex /*[Y: ST: ORD]*/ (Y fn(RX arg)) =>
      Frame(values, rowIx.map(fn), colIx).withMat(cachedMat);

  /**
   * Create a new Frame using the current values but with the new col index. Positions
   * of the values do not change. Length of new index must be equal to number of cols.
   * @param newIx A new Index
   * @tparam Y Type of elements of new Index
   */
  Frame<RX, Y, T> setColIndex /*[Y: ST: ORD]*/ (Index<Y> newIx) =>
      Frame(values, rowIx, newIx).withMat(cachedMat);

  /**
   * Create a new Frame using the current values but with the new col index specified
   * by the row at a particular offset, and with that row removed from the frame
   * data body.
   */
  Frame<RX, T, T> withColIndex(int row) /*(implicit ordT: ORD[T])*/ =>
      this.setColIndex(Index(this.rowAt(row).toVec)).rfilterAt(_ != row);

  /**
   * Overloaded method to create hierarchical index from two rows.
   */
  Frame /*<RX, (T, T), T>*/ with2ColIndex(
      int row1, int row2) /*(implicit ordT: ORD[T])*/ {
    Index /*[(T, T)]*/ newIx =
        Index.make(this.rowAt(row1).toVec, this.rowAt(row2).toVec);
//    this.setColIndex(newIx).rfilterAt { case r => !Set(row1, row2).contains(r) };
  }

  /**
   * Map a function over the col index, resulting in a new Frame
   *
   * @param fn The function CX => Y with which to map
   * @tparam Y Result type of index, ie Index<Y>
   */
  Frame<RX, Y, T> mapColIndex /*[Y: ST: ORD]*/ (Y fn(CX arg)) {
//    Frame(values, rowIx, colIx.map(fn)) withMat cachedMat;
  }

  /**
   * Create a new Frame whose values are the same, but whose row index has been changed
   * to the bound [0, numRows - 1), as in an array.
   */
  Frame<int, CX, T> resetRowIndex() {
//    Frame(values, IndexIntRange(numRows), colIx) withMat cachedMat;
  }

  /**
   * Create a new Frame whose values are the same, but whose col index has been changed
   * to the bound [0, numCols - 1), as in an array.
   */
  Frame<RX, int, T> resetColIndex() {
//    Frame(values, rowIx, IndexIntRange(numCols)) withMat cachedMat
  }

  // ----------------------------------------
  // some helpful ops

  /**
   * Extract first n rows
   *
   * @param n number of rows to extract
   */
  Frame<RX, CX, T> head(int n) => transform(_.head(n));

  /**
   * Extract last n rows
   *
   * @param n number of rows to extract
   */
  Frame<RX, CX, T> tail(int n) => transform(_.tail(n));

  /**
   * Extract first n columns
   *
   * @param n number of columns to extract
   */
  headCol(int n) => Frame(values.take(n), rowIx, colIx.head(n));

  /**
   * Extract last n columns
   *
   * @param n number of columns to extract
   */
  tailCol(int n) => Frame(values.takeRight(n), rowIx, colIx.tail(n));

  /**
   * Extract first row matching a particular key
   *
   * @param k Key to match
   */
  Series<CX, T> first(RX k) {
    val loc = rowIx.getFirst(k);
    if (loc == -1) {
      emptyRow;
    } else {
      rowAt(loc);
    }
  }

  /**
   * Extract last row matching a particular key
   *
   * @param k Key to match
   */
  Series<CX, T> last(RX k) {
    val loc = rowIx.getLast(k);
    if (loc == -1) {
      new Series.empty<CX, T>();
    } else {
      rowAt(loc);
    }
  }

  /**
   * Extract first col matching a particular key
   *
   * @param k Key to match
   */
  Series<RX, T> firstCol(CX k) {
    val loc = colIx.getFirst(k);
    if (loc == -1) {
      emptyCol;
    } else {
      colAt(loc);
    }
  }

  /**
   * Extract first col matching a particular key
   *
   * @param k Key to match
   */
  Series<RX, T> lastCol(CX k) {
    val loc = colIx.getLast(k);
    if (loc == -1) {
      emptyCol;
    } else {
      colAt(loc);
    }
  }

  /**
   * Return empty series of type equivalent to a row of frame
   *
   */
  Series<CX, T> emptyRow() => new Series.empty<CX, T>();

  /**
   * Return empty series of type equivalent to a column of frame
   *
   */
  Series<RX, T> emptyCol() => new Series.empty<RX, T>();

  /**
   * Create a new Frame whose rows are sorted according to the row
   * index keys
   */
  Frame<RX, CX, T> sortedRIx() {
    if (rowIx.isMonotonic) {
      this;
    } else {
      val taker = rowIx.argSort;
      Frame(values.map(_.take(taker)), rowIx.take(taker), colIx);
    }
  }

  /**
   * Create a new Frame whose cols are sorted according to the col
   * index keys
   */
  Frame<RX, CX, T> sortedCIx() {
    if (colIx.isMonotonic) {
      this;
    } else {
      val taker = colIx.argSort;
      Frame(values.take(taker), rowIx, colIx.take(taker));
    }
  }

  /**
   * Create a new Frame whose rows are sorted primarily on the values
   * in the first column specified in the argument list, and then on
   * the values in the next column, etc.
   * @param locs Location of columns containing values to sort on
   */
  sortedRows(int /***/ locs) /*(implicit ev: ORD[T])*/ {
    var order = array.range(0, numRows);

    var j = locs.length - 1;
    while (j >= 0) {
      val tosort = colAt(locs(j)).values.take(order);
      val reordr = Index(tosort).argSort;
      order = array.take(order, reordr, sys.error("Logic error"));
      j -= 1;
    }

    Frame(values.map(_.take(order)), rowIx.take(order), colIx);
  }

  /**
   * Create a new Frame whose cols are sorted primarily on the values
   * in the first row specified in the argument list, and then on
   * the values in the next row, etc.
   * @param locs Location of rows containing values to sort on
   */
  sortedCols(int /***/ locs) /*(implicit ev: ORD[T])*/ {
    var order = array.range(0, numCols);

    var j = locs.length - 1;
    while (j >= 0) {
      val tosort = rowAt(locs(j)).values.take(order);
      val reordr = Index(tosort).argSort;
      order = array.take(order, reordr, sys.error("Logic error"));
      j -= 1;
    }

    Frame(values.take(order), rowIx, colIx.take(order));
  }

  /**
   * Create a new Frame whose rows are sorted by the result of a function
   * acting on each row.
   * @param f Function from a single row (represented as series) to a value having an
   *          ordering
   * @tparam Q Result type of the function
   */
  Frame<RX, CX, T> sortedRowsBy /*[Q: ORD]*/ (Q f(Series<CX, T> arg)) {
    val perm = array.range(0, numRows).sortBy((int i) => f(rowAt(i)));
    rowAt(perm);
  }

  /**
   * Create a new Frame whose cols are sorted by the result of a function
   * acting on each col.
   * @param f Function from a single col (represented as series) to a value having an
   *          ordering
   * @tparam Q Result type of the function
   */
  Frame<RX, CX, T> sortedColsBy /*[Q: ORD]*/ (Q f(Series<RX, T> arg)) {
    val perm = array.range(0, numCols).sortBy((int i) => f(colAt(i)));
    colAt(perm);
  }

  /**
   * Map over each triple (r, c, v) in the Frame, returning a new frame from the resulting
   * triples.
   */
  Frame<SX, DX, U> map /*[SX: ST: ORD, DX: ST: ORD, U: ST]*/ (
      /*(SX, DX, U)*/ f(/*(RX, CX, T)*/ arg)) {
//    Series(toSeq.map(f).map { case (sx, dx, u) => ((sx, dx) -> u) } : _*).pivot
  }

  /**
   * Map over each triple (r, c, v) in the Frame, flattening results, and returning a new frame from
   * the resulting triples.
   */
  Frame<SX, DX, U> flatMap /*[SX: ST: ORD, DX: ST: ORD, U: ST]*/ (
      Traversable /*[(SX, DX, U)]*/ f(/*(RX, CX, T)*/ arg)) {
//    Series(toSeq.flatMap(f).map { case (sx, dx, u) => ((sx, dx) -> u) } : _*).pivot
  }

  /**
   * Map over the values of the Frame. Applies a function to each (non-na) value in the frame,
   * returning a new frame whose indices remain the same.
   *
   * @param f Function from T to U
   * @tparam U The type of the resulting values
   */
  Frame<RX, CX, U> mapValues /*[U: ST]*/ (U f(T arg)) =>
      Frame(values.map((v) => v.map(f)), rowIx, colIx);

  /**
   * Create a new Frame that, whenever the mask predicate function evaluates to
   * true on a value, is masked with NA
   * @param f Function from T to Boolean
   */
  Frame<RX, CX, T> maskFn(bool f(T arg)) =>
      Frame(values.map((v) => v.mask(f)), rowIx, colIx);

  /**
   * Create a new Frame whose columns follow the rule that, wherever the mask Vec is true,
   * the column value is masked with NA
   * @param m Mask Vec[Boolean]
   */
  Frame<RX, CX, T> mask(Vec<bool> m) =>
      Frame(values.map((v) => v.mask(m)), rowIx, colIx);

  /**
   * Joins two frames along both their indexes and applies a function to each pair
   * of values; when either value is NA, the result of the function is forced to be NA.
   * @param other Other Frame
   * @param rhow The type of join to effect on the rows
   * @param chow The type of join to effect on the cols
   * @param f The function to apply
   * @tparam U The type of other frame values
   * @tparam V The result type of the function
   */
  Frame<RX, CX, V> joinMap /*[U: ST, V: ST]*/ (Frame<RX, CX, U> other,
      [JoinType rhow = JoinType.LeftJoin,
      JoinType chow = JoinType.RightJoin]) /*(V f((T, U) arg))*/ {
    var l, r = align(other, rhow, chow);
//    var result = l.values.zip(r.values).map { case (v1, v2) => VecImpl.zipMap(v1, v2)(f) };
    Frame(result, l.rowIx, l.colIx);
  }

  /**
   * Map a function over each column vector and collect the results into a Frame respecting
   * the original indexes.
   * @param f Function acting on Vec[T] and producing another Vec
   * @tparam U Type of result Vec of the function
   */
  Frame<RX, CX, U> mapVec /*[U: ST]*/ (Vec<U> f(Vec<T> arg)) =>
      Frame(values.map(f), rowIx, colIx);

  /**
   * Apply a function to each column series which results in a single value, and return the
   * series of results indexed by original column index.
   * @param f Function taking a column (series) to a value
   * @tparam U The output type of the function
   */
  Series<CX, U> reduce /*[U: ST]*/ (U f(Series<RX, T> arg)) {
//    Series(Vec(values.map(v => f(Series(v, rowIx))) : _*), colIx);
  }

  /**
   * Apply a function to each column series which results in another series (having possibly
   * a different index); return new frame whose row index is the the full outer join of all
   * the intermediately produced series (fast when all series have the same index), and having
   * the original column index.
   * @param f Function to operate on each column as a series
   * @tparam U Type of values of result series of function
   * @tparam SX Type of index of result series of function
   */
  Frame<SX, CX, U> transform /*[U: ST, SX: ST: ORD]*/ (
          Series<SX, U> f(Series<RX, T> arg)) =>
      Frame(values.map((v) => f(Series(v, rowIx))), colIx);

  // groupBy functionality (on rows)

  /**
   * Construct a [[org.saddle.groupby.FrameGrouper]] with which further computations, such
   * as combine or transform, may be performed. The groups are constructed from the keys of
   * the row index, with each unique key corresponding to a group.
   */
  groupBy() => FrameGrouper(this);

  /**
   * Construct a [[org.saddle.groupby.FrameGrouper]] with which further computations, such
   * as combine or transform, may be performed. The groups are constructed from the result
   * of the function applied to the keys of the row index; each unique result of calling the
   * function on elements of the row index corresponds to a group.
   * @param fn Function from RX => Y
   * @tparam Y Type of function codomain
   */
  groupByFn /*[Y: ST: ORD]*/ (Y fn(RX arg)) =>
      FrameGrouper(this.rowIx.map(fn), this);

  /**
   * Construct a [[org.saddle.groupby.FrameGrouper]] with which further computations, such
   * as combine or transform, may be performed. The groups are constructed from the keys of
   * the provided index, with each unique key corresponding to a group.
   * @param ix Index with which to perform grouping
   * @tparam Y Type of elements of ix
   */
  groupByIndex /*[Y: ST: ORD]*/ (Index<Y> ix) => FrameGrouper(ix, this);

  // concatenate two frames together (vertically), must have same number of columns

  /**
   * Concatenate two Frame instances together (vertically) whose indexes share the same type
   * of elements, and where there exists some way to join the values of the Frames. For
   * instance, Frame[X, Y, Double] `concat` Frame[X, Y, Int] will promote Int to Double as
   * a result of the implicit existence of a Promoter[Double, Int, Double] instance.
   * The resulting row index will simply be the concatenation of the input row indexes, and
   * the column index will be the joint index (with join type specified as argument).
   *
   * @param other  Frame<RX, CX, U> to concat
   * @param pro Implicit evidence of Promoter
   * @tparam U type of other Frame values
   * @tparam V type of resulting Frame values
   */
  Frame<RX, CX, V> concat /*[U, V]*/ (Frame<RX, CX, U> other,
      [JoinType how =
          JoinType.OuterJoin]) /*(
    implicit pro: Promoter[T, U, V], mu: ST[U], md: ST[V])*/
  {
    val ixc = colIx.join(other.colIx, how);

//    val lft = ixc.lTake.map(x => values.take(x)) getOrElse values
//    val rgt = ixc.rTake.map(x => other.values.take(x)) getOrElse other.values

//    val mfn = (v: Vec[T], u: Vec[U]) => v concat u
//    val zpp = lft zip rgt
//    val dat = zpp.map { case (top, bot) => mfn(top, bot) }
//    val idx = rowIx concat other.rowIx

    Frame(dat, idx, ixc.index);
  }

  /**
   * Create Frame whose rows satisfy the rule that their keys and values are chosen
   * via a Vec[Boolean] or a Series[_, Boolean] predicate when the latter contains a
   * true value.
   * @param pred Series[_, Boolean] (or Vec[Boolean] which will implicitly convert)
   */
  Frame<RX, CX, T> where(Series<_, bool> pred) {
    val newVals = values.zipWithIndex
        .flatMap((z) => (pred.values(z._2)) ? Seq(z._1) : Seq.empty[Vec[T]]);
    val newIdx = VecImpl.where(Vec(this.colIx.toArray))(pred.values.toArray);
    Frame(newVals, rowIx, Index(newIdx));
  }

  /**
   * Shift the sequence of values relative to the row index by some offset,
   * dropping those values which no longer associate with a key, and having
   * those keys which no longer associate to a value instead map to NA.
   * @param n Number to shift
   */
  Frame<RX, CX, T> shift([int n = 1]) =>
      Frame(values.map(_.shift(n)), rowIx, colIx);

  /**
   * In each column, replaces all NA values for which there is a non-NA value at
   * a prior offset with the corresponding most-recent, non-NA value. See Vec.pad
   */
  Frame<RX, CX, T> pad() => mapVec(_.pad);

  /**
   * Same as above, but limits the number of observations padded. See Vec.padAtMost
   */
  Frame<RX, CX, T> padAtMost(int n) => mapVec(_.padAtMost(n));

  /**
   * Return Frame whose columns satisfy a predicate function operating on that
   * column
   * @param pred Predicate function from Series<RX, T> => Boolean
   */
  filter(bool pred(Series<RX, T> arg)) => where(reduce((v) => pred(v)));

  /**
   * Return Frame whose columns satisfy a predicate function operating on the
   * column index
   * @param pred Predicate function from CX => Boolean
   */
  filterIx(bool pred(CX arg)) => where(colIx.toVec.map(pred));

  /**
   * Return Frame whose columns satisfy a predicate function operating on the
   * column index offset
   * @param pred Predicate function from CX => Boolean
   */
  filterAt(bool pred(int arg)) => where(vec.range(0, numCols).map(pred));

  /**
   * Return Frame excluding any of those columns which have an NA value
   */
  Frame<RX, CX, T> dropNA() => filter((s) => !s.hasNA);

  /**
   * Produce a Frame each of whose columns are the result of executing a function
   * on a sliding window of each column series.
   * @param winSz Window size
   * @param f Function Series[X, T] => B to operate on sliding window
   * @tparam B Result type of function
   */
  Frame<RX, CX, B> rolling /*[B: ST]*/ (int winSz, B f(Series<RX, T> arg)) {
//    val tmp = values.map { v => Series(v, rowIx).rolling(winSz, f).values }
    Frame(tmp, rowIx.slice(winSz - 1, values.numRows), colIx);
  }

  /**
   * Create a Series by rolling over winSz number of rows of the Frame at a
   * time, and applying a function that takes those rows to a single value.
   *
   * @param winSz Window size to roll with
   * @param f Function taking the (sub) frame to B
   * @tparam B Result element type of Series
   */
  Series<RX, B> rollingFtoS /*[B: ST]*/ (int winSz, B f(Frame<RX, CX, T> arg)) {
    val buf = new List(numRows - winSz + 1);
    var i = winSz;
    while (i <= numRows) {
      buf[i - winSz] = f(rowSlice(i - winSz, i));
      i += 1;
    }
    Series(Vec(buf), rowIx.slice(winSz - 1, numRows));
  }

  // ----------------------------------------
  // joining

  /**
   * Perform a join with another Series<RX, T> according to the row index. The `how`
   * argument dictates how the join is to be performed:
   *
   *   - Left [[org.saddle.index.LeftJoin]]
   *   - Right [[org.saddle.index.RightJoin]]
   *   - Inner [[org.saddle.index.InnerJoin]]
   *   - Outer [[org.saddle.index.OuterJoin]]
   *
   * The result is a Frame whose row index is the result of the join, and whose column
   * index has been reset to [0, numcols], and whose values are sourced from the original
   * Frame and Series.
   *
   * @param other Series to join with
   * @param how How to perform the join
   */
  Frame<RX, int, T> joinS(Series<RX, T> other,
      [JoinType how = JoinType.LeftJoin]) {
    val indexer = rowIx.join(other.index, how);
//    val lft = indexer.lTake.map { loc => values.map(_.take(loc)) } getOrElse values
//    val rgt = indexer.rTake.map { loc => other.values.take(loc) } getOrElse other.values
//    Frame(lft :+ rgt, indexer.index, IndexIntRange(colIx.length + 1))
  }

  /**
   * Same as `joinS`, but preserve the column index, adding the specified index value,
   * `newColIx` as an index for the `other` Series.
   */
  Frame<RX, CX, T> joinSPreserveColIx(Series<RX, T> other,
      [JoinType how = JoinType.LeftJoin, CX newColIx]) {
    val resultingFrame = joinS(other, how);
    val newColIndex = colIx.concat(Index(newColIx));
    resultingFrame.setColIndex(newColIndex);
  }

  /**
   * Perform a join with another Frame<RX, CX, T> according to the row index. The `how`
   * argument dictates how the join is to be performed:
   *
   *   - Left [[org.saddle.index.LeftJoin]]
   *   - Right [[org.saddle.index.RightJoin]]
   *   - Inner [[org.saddle.index.InnerJoin]]
   *   - Outer [[org.saddle.index.OuterJoin]]
   *
   * The result is a Frame whose row index is the result of the join, and whose column
   * index has been reset to [0, M + N), where M is the number of columns in the left
   * frame and N in the right, and whose values are sourced from the original Frames.
   *
   * @param other Frame to join with
   * @param how How to perform the join
   */
  Frame<RX, int, T> join(Frame<RX, _, T> other,
      [JoinType how = JoinType.LeftJoin]) {
    val indexer = rowIx.join(other.rowIx, how);
//    val lft = indexer.lTake.map { loc => values.map(_.take(loc))} getOrElse values
//    val rgt = indexer.rTake.map { loc => other.values.map(_.take(loc))} getOrElse other.values
//    Frame(lft ++ rgt, indexer.index, IndexIntRange(colIx.length + other.colIx.length))
  }

  /**
   *  Same as `join`, but preserves column index
   */
  Frame<RX, CX, T> joinPreserveColIx(Frame<RX, CX, T> other,
      [JoinType how = JoinType.LeftJoin]) {
    val resultingFrame = join(other, how);
    val newColIndex = colIx.concat(other.colIx);
    resultingFrame.setColIndex(newColIndex);
  }

  /**
   * Same as joinS, but the values of Series to join with may be of type Any, so that the
   * resulting Frame may be heterogeneous in its column types.
   */
  Frame<RX, int, Any> joinAnyS(Series<RX, _> other,
      [JoinType how = JoinType.LeftJoin]) {
    val indexer = rowIx.join(other.index, how);
//    val lft = indexer.lTake.map { loc => values.map(_.take(loc)) } getOrElse values
//    val rgt = indexer.rTake.map { loc => other.values.take(loc) } getOrElse other.values
//    Panel(lft :+ rgt, indexer.index, IndexIntRange(colIx.length + 1))
  }

  /**
   * Same as `joinAnyS`, but preserve the column index, adding the specified index value,
   * `newColIx` as an index for the `other` Series.
   */
  Frame<RX, CX, Any> joinAnySPreserveColIx(Series<RX, _> other,
      [JoinType how = JoinType.LeftJoin, CX newColIx]) {
    val resultingFrame = joinAnyS(other, how);
    val newColIndex = colIx.concat(Index(newColIx));
    resultingFrame.setColIndex(newColIndex);
  }

  /**
   * Same as join, but the values of Frame to join with may be of type Any, so that the
   * resulting Frame may be heterogeneous in its column types.
   */
  Frame<RX, int, Any> joinAny(Frame<RX, _, _> other,
      [JoinType how = JoinType.LeftJoin]) {
    val indexer = rowIx.join(other.rowIx, how);
//    val lft = indexer.lTake.map { loc => values.map(_.take(loc))} getOrElse values
//    val rgt = indexer.rTake.map { loc => other.values.map(_.take(loc))} getOrElse other.values
//    Panel(lft ++ rgt, indexer.index, IndexIntRange(colIx.length + other.colIx.length))
  }

  /**
   *  Same as `joinAny`, but preserves column index
   */
  Frame<RX, CX, Any> joinAnyPreserveColIx(Frame<RX, CX, _> other,
      [JoinType how = JoinType.LeftJoin]) {
    val resultingFrame = joinAny(other, how);
    val newColIndex = colIx.concat(other.colIx);
    resultingFrame.setColIndex(newColIndex);
  }

  /**
   * Aligns this frame with another frame, returning the left and right frames aligned
   * to each others indexes according to the the provided parameters
   *
   * @param other Other frame to align with
   * @param rhow How to perform the join on the row indexes
   * @param chow How to perform the join on the col indexes
   */
  /*(Frame<RX, CX, T>, Frame<RX, CX, U>)*/ align /*[U: ST]*/ (
      Frame<RX, CX, U> other,
      [JoinType rhow = JoinType.OuterJoin,
      JoinType chow = JoinType.OuterJoin]) {
    val rJoin = rowIx.join(other.rowIx, rhow);
    val cJoin = colIx.join(other.colIx, chow);

    MatCols /*[T]*/ lvals =
        cJoin.lTake.map((locs) => values.take(locs)).getOrElse(values);
    MatCols /*[U]*/ rvals = cJoin.rTake
        .map((locs) => other.values.take(locs))
        .getOrElse(other.values);

//    val vecs = for (i <- 0 until lvals.length) yield {
//      val lvec: Vec[T] = rJoin.lTake.map(locs => lvals(i).take(locs)).getOrElse(lvals(i))
//      val rvec: Vec[U] = rJoin.rTake.map(locs => rvals(i).take(locs)).getOrElse(rvals(i))
//      (lvec, rvec)
//    }

    var lvecs, rvecs = vecs.unzip;

    [
      Frame(lvecs, rJoin.index, cJoin.index),
      Frame(rvecs, rJoin.index, cJoin.index)
    ];
  }

  // ------------------------------------------------
  // reshaping

  /**
   * Drop all columns from the Frame which have nothing but NA values.
   */
  Frame<RX, CX, T> squeeze() => filter((s) => !VecImpl.isAllNA(s.toVec));

  /**
   * Melt stacks the row index of arity N with the column index of arity M to form a result index
   * of arity N + M, producing a 1D Series whose values are from the original Frame as indexed by
   * the corresponding keys.
   *
   * For example, given:
   *
   * {{{
   *   Frame(1 -> Series('a' -> 1, 'b' -> 3), 2 -> Series('a' -> 2, 'b' -> 4)).melt
   * }}}
   *
   * produces:
   *
   * {{{
   * res0: org.saddle.Series[(Char, Int),Int] =
   * [4 x 1]
   *  a 1 => 1
   *    2 => 2
   *  b 1 => 3
   *    2 => 4
   * }}}
   *
   *
   * @param melter Implicit evidence for a Melter for the two indexes
   * @tparam W Output type (tuple of arity N + M)
   */
  Series<W, T> melt /*[W]*/ (/*implicit*/ Melter<RX, CX, W> melter) {
    val ix = Array.ofDim[W](numRows * numCols)(melter.tag);

    var k = 0;
    var i = 0;
    while (i < numRows) {
      var j = 0;
      while (j < numCols) {
        ix[k] = melter(rowIx.raw(i), colIx.raw(j));
        k += 1;
        j += 1;
      }
      i += 1;
    }

    /*implicit*/ val ord = melter.ord;
    /*implicit*/ val tag = melter.tag;

    new Series<W, T>(toMat.toVec, Index(ix));
  }

  /**
   * Stack pivots the innermost column labels to the innermost row labels. That is, it splits
   * a col index of tuple keys of arity N into a new col index having arity N-1 and a remaining
   * index C, and forms a new row index by stacking the existing row index with C. The
   * resulting Frame has values as in the original Frame indexed by the corresponding keys. It
   * does the reverse of unstack.
   *
   * @param splt An implicit instance of Splitter to do the splitting
   * @param stkr An implicit instance of Stacker to do the stacking
   * @tparam O1 The N-1 arity column index type
   * @tparam O2 The 1-arity type of split-out index C
   * @tparam V The type of the stacked row index
   */
  Frame<V, O1, T> stack /*[O1, O2, V]*/ (
      /*implicit*/ Splitter<CX, O1, O2> splt,
      Stacker<RX, O2, V> stkr,
      ORD<O1> ord1,
      ORD<O2> ord2,
      ST<O1> m1,
      ST<O2> m2) {
    T.unstack.T;
  }

  /**
   * Unstack pivots the innermost row labels to the innermost col labels. That is, it splits
   * a row index of tuple keys of arity N into a new row index having arity N-1 and a remaining
   * index R, and forms a new col index by stacking the existing col index with R. The
   * resulting Frame has values as in the original Frame indexed by the corresponding keys.
   *
   * For example:
   *
   * {{{
   * scala> Frame(Series(Vec(1,2,3,4), Index(('a',1),('a',2),('b',1),('b',2))), Series(Vec(5,6,7,8), Index(('a',1),('a',2),('b',1),('b',2))))
   * res1: org.saddle.Frame[(Char, Int),Int,Int] =
   * [4 x 2]
   *         0  1
   *        -- --
   * a 1 ->  1  5
   *   2 ->  2  6
   * b 1 ->  3  7
   *   2 ->  4  8
   *
   * scala> res1.unstack
   * res2: org.saddle.Frame[Char,(Int, Int),Int] =
   * [2 x 4]
   *       0     1
   *       1  2  1  2
   *      -- -- -- --
   * a ->  1  2  5  6
   * b ->  3  4  7  8
   * }}}
   *
   * @param splt An implicit instance of Splitter to do the splitting
   * @param stkr An implicit instance of Stacker to do the stacking
   * @tparam O1 The N-1 arity row index type
   * @tparam O2 The 1-arity type of split-out index R
   * @tparam V The type of the stacked col index
   */
  Frame<O1, V, T> unstack /*[O1, O2, V]*/ (
      /*implicit*/ Splitter<RX, O1, O2> splt,
      Stacker<CX, O2, V> stkr,
      ORD<O1> ord1,
      ORD<O2> ord2,
      ST<O1> m1,
      ST<O2> m2) {
    /*implicit*/ def ordV = stkr.ord;
    /*implicit*/ def clmV = stkr.tag;

    var lft,
        rgt = splt(rowIx); // lft = row index w/o pivot level; rgt = pivot level

    var rix = lft.uniques; // Final row index
    var uix = rgt.uniques;
    var cix = stkr(
        colIx, uix); // Final col index (colIx stacked w/unique pivot labels)

    var grps = IndexGrouper(rgt, sorted: false)
        .groups; // Group by pivot label. Each unique label will get its
    //   own column in the final frame.
    if (values.length > 0) {
      var len = uix.length;
      var off = 0;
      var loc = 0;

      var result = new List<Vec<T>>(cix.length); // accumulates result columns

      for (/*(_,*/ taker in grps) {
        // For each pivot label grouping,
        val gIdx = lft.take(taker); //   use group's (lft) row index labels
        val ixer = rix.join(gIdx); //   to compute map to final (rix) locations;

        for (currVec in values) {
          // For each column vec of original frame
          val vals = currVec.take(
              taker); //   take values corresponding to current pivot label
          val v = ixer.rTake
              .map(vals.take(_))
              .getOrElse(vals); //   map values to be in correspondence to rix
          result[loc] = v; //   and save vec in array.

          loc += len; // Increment offset into result array
          if (loc >= cix.length) {
            off += 1;
            loc = off;
          }
        }
      }

      new Frame<O1, V, T>(result, rix, cix);
    } else {
      new Frame.empty<O1, V, T>();
    }
  }

  /**
   * Extract the Mat embodied in the values of the Frame (dropping any indexing
   * information)
   */
  Mat<T> toMat() {
    val st = implicitly[ST[T]];
//    synchronized {
    if (cachedMat.isEmpty) {
      val m = Mat(values.numCols, values.numRows, st.concat(values)).T;
      withMat(Some(m));
    }
    cachedMat.get;
//    }
  }

  // ---------------------------------------------------------------
  // Row-wise versions of all the ops that operate on cols by default

  /**
   * See mask; operates row-wise
   */
  Frame<RX, CX, T> rmaskFn(bool f(T arg)) => T.mask(f).T;

  /**
   * See mask; operates row-wise
   */
  Frame<RX, CX, T> rmask(Vec<bool> b) => T.mask(b).T;

  /**
   * See mapVec; operates row-wise
   */
  rmapVec /*[U: ST]*/ (Vec<U> f(Vec<T> arg)) => T.mapVec(f).T;

  /**
   * See reduce; operates row-wise
   */
  Series<RX, U> rreduce /*[U: ST]*/ (U f(Series<CX, T> arg)) => T.reduce(f);

  /**
   * See transform; operates row-wise
   */
  Frame<RX, SX, U> rtransform /*[U: ST, SX: ST: ORD]*/ (
          Series<SX, U> f(Series<CX, T> arg)) =>
      T.transform(f).T;

  /**
   * See concat; operates row-wise
   */
  rconcat /*[U, V]*/ (Frame<RX, CX, U> other,
          [JoinType how =
              JoinType.OuterJoin]) /*(
    implicit wd1: Promoter[T, U, V], mu: ST[U], md: ST[V])*/
      =>
      T.concat(other.T, how).T;

  /**
   * See where; operates row-wise
   */
  Frame<RX, CX, T> rwhere(Series<_, bool> pred) {
    val predv = pred.values;
    new Frame(new MatCols(values.map((v) => v.where(predv))),
        Index(rowIx.toVec.where(predv)), colIx);
  }

  /**
   * See shift; operates col-wise
   */
  Frame<RX, CX, T> cshift([int n = 1]) => T.shift(n).T;

  /**
   * See filter; operates row-wise
   */
  rfilter(bool pred(Series<CX, T> arg)) => rwhere(rreduce((v) => pred(v)));

  /**
   * See filterIx; operates row-wise
   */
  rfilterIx(bool pred(RX arg)) => rwhere(rowIx.toVec.map(pred));

  /**
   * See filterAt; operates row-wise
   */
  rfilterAt(bool pred(int arg)) => rwhere(vec.range(0, numRows).map(pred));

  /**
   * See joinS; operates row-wise
   */
  Frame<int, CX, T> rjoinS(Series<CX, T> other,
          [JoinType how = JoinType.LeftJoin]) =>
      T.joinS(other, how).T;

  /**
   * See joinSPreserveColIx; operates row-wise
   */
  Frame<RX, CX, T> rjoinSPreserveRowIx(Series<CX, T> other,
          [JoinType how = JoinType.LeftJoin, RX newRowIx]) =>
      T.joinSPreserveColIx(other, how, newRowIx).T;

  /**
   * See join; operates row-wise
   */
  Frame<int, CX, T> rjoin(Frame<_, CX, T> other,
          [JoinType how = JoinType.LeftJoin]) =>
      T.join(other.T, how).T;

  /**
   * See joinPreserveColIx; operates row-wise
   */
  Frame<RX, CX, T> rjoinPreserveRowIx(Frame<RX, CX, T> other,
          [JoinType how = JoinType.LeftJoin]) =>
      T.joinPreserveColIx(other.T, how).T;

  /**
   * See joinAnyS; operates row-wise
   */
  Frame<int, CX, Any> rjoinAnyS(Series<CX, _> other,
          [JoinType how = JoinType.LeftJoin]) =>
      T.joinAnyS(other, how).T;

  /**
   * See joinAnySPreserveColIx; operates row-wise
   */
  Frame<RX, CX, Any> rjoinAnySPreserveRowIx(Series<CX, _> other,
          [JoinType how = JoinType.LeftJoin, RX newRowIx]) =>
      T.joinAnySPreserveColIx(other, how, newRowIx).T;

  /**
   * See joinAny; operates row-wise
   */
  Frame<int, CX, Any> rjoinAny(Frame<_, CX, _> other,
          [JoinType how = JoinType.LeftJoin]) =>
      T.joinAny(other.T, how).T;

  /**
   * See joinAnyPreserveColIx; operates row-wise
   */
  Frame<RX, CX, Any> rjoinAnyPreserveRowIx(Frame<RX, CX, _> other,
          [JoinType how = JoinType.LeftJoin]) =>
      T.joinAnyPreserveColIx(other.T, how).T;

  /**
   * See dropNA; operates row-wise
   */
  Frame<RX, CX, T> rdropNA() => rfilter((v) => !v.hasNA);

  /**
   * See squeeze; operates row-wise
   */
  Frame<RX, CX, T> rsqueeze() => rfilter((s) => !VecImpl.isAllNA(s.toVec));

  // todo: describe

  // --------------------------------------
  // for iterating over rows/cols/elements

  /**
   * Produce an indexed sequence of pairs of row index value and
   * row Series
   */
  IndexedSeq /*[(RX, Series<CX, T>)]*/ toRowSeq() {
//    for (i <- array.range(0, numRows)) yield (rowIx.raw(i), rowAt(i));
  }

  /**
   * Produce an indexed sequence of pairs of column index value and
   * column Series.
   */
  IndexedSeq /*[(CX, Series<RX, T>)]*/ toColSeq() {
//    for (i <- array.range(0, numCols)) yield (colIx.raw(i), colAt(i));
  }

  /**
   * Produce an indexed sequence of triples of values in the Frame
   * in row-major order.
   */
  IndexedSeq /*[(RX, CX, T)]*/ toSeq() {
//    (Range(0, numRows) zip rowIx.toSeq).flatMap { case(i, rx) =>
//      rowAt(i).toSeq.map { case (cx, t) =>
//        (rx, cx, t)
//      }
//    }
  }

  // ------------------------------------------------------
  // internal contiguous caching of row data for efficiency

  /*private*/ Frame<RX, CX, T> withMat(Option<Mat<T>> m) {
    cachedMat = m;
    this;
  }

  /*private*/ MatCols<T> rows() {
    if (cachedRows.isEmpty) {
      cachedRows = Some(toMat.rows());
    }
    cachedRows.get;
  }

  // --------------------------------------
  // pretty-printing

  @override
  String toString() => stringify();

  /**
   * Creates a string representation of Frame
   * @param nrows Max number of rows to include
   * @param ncols Max number of rows to include
   */
  String stringify([int nrows = 10, int ncols = 10]) {
    val buf = new StringBuffer();

    if (numCols == 0 || numRows == 0) {
      buf.append("Empty Frame");
    } else {
      buf.append("[%d x %d]\n".format(numRows, numCols));

      val rhalf = nrows / 2;

//      val maxf = (a: List[Int], b: List[String]) => (a zip b).map(v => math.max(v._1, v._2.length))

      // calc row index width
      val rsca = rowIx.scalarTag;
      val rarr = rowIx.toArray;
      val rinit = rsca.strList(rarr(0)).map(_.length);
      val rlens =
          util.grab(rarr, rhalf).map(rsca.strList(_)).foldLeft(rinit)(maxf);
      val maxrl = rlens.sum + (rlens.length - 1);

      // calc each col str width
      val clens = MatCols.colLens(values, numCols, ncols);

      val csca = colIx.scalarTag;
//      clen(int c) => clens(c) max {
//        val lst = csca.strList(colIx.raw(c)).map(_.length)
//        if (lst.length > 0) lst.max else 0
//      }

//      var prevColMask = clens.map((x) => (x._1, false));   // recalls whether we printed a column's label at level L-1
      var prevColLabel = ""; // recalls previous column's label at level L

      // build columns header
//      createColHeader(int l) => (int c) => {
//        val labs = csca.strList(colIx.raw(c));
//        val currLab = labs(l);
//
//        val fmt = "%" + clen(c) + "s ";
//        val res = if (l == labs.length - 1 || currLab != prevColLabel || prevColMask.get(c).getOrElse(false)) {
//          prevColMask = prevColMask.updated(c, true)
//          currLab.formatted(fmt)
//        }
//        else {
//          prevColMask = prevColMask.updated(c, false)
//          "".formatted(fmt)
//        }
//        prevColLabel = currLab
//        res
//      }

      colBreakStr() {
        prevColLabel = "";
        " " * 5;
      }

      var spacer = " " * (maxrl + 4);

      var sz = colIx.scalarTag.strList(colIx.raw(0)).size;
      for (i in range(sz)) {
        buf.append(spacer);
        buf.append(
            util.buildStr(ncols, numCols, createColHeader(i), colBreakStr));
        buf.append("\n");
      }

      def createColDivide(int c) => "-" * clen(c) + " ";

      buf.append(spacer);
      buf.append(util.buildStr(ncols, numCols, createColDivide));
      buf.append("\n");

      // for building row labels
//      def enumZip[A, B](a: List[A], b: List[B]): List[(Int, A, B)] =
//        for ( v <- (a.zipWithIndex zip b) ) yield (v._1._2, v._1._1, v._2)

      val prevRowLabels =
          Array.fill(rowIx.scalarTag.strList(rowIx.raw(0)).size)("");
//      resetRowLabels(int k) { for (i <- k until prevRowLabels.length) prevRowLabels(i) = "" }

      createIx(int r) {
        val vls = rsca.strList(rowIx.raw(r));
//        val lst = for ( (i, l, v) <- enumZip(rlens, vls)) yield {
//          val fmt = "%" + l + "s"
//          val res = if (i == vls.length - 1 || prevRowLabels(i) != v) {
//            resetRowLabels(i+1)
//            v.formatted(fmt)
//          } else "".formatted(fmt)
//          prevRowLabels(i) = v
//          res
//        }
        lst.mkString(" ");
      }

      // for building frame entries
      createVals(int r) {
//        val elem = (col: Int) => "%" + clen(col) + "s " format values(col).scalarTag.show(values(r, col))
        util.buildStr(ncols, numCols, elem) + "\n";
      }

      rowBreakStr() {
        resetRowLabels(0);
        "...\n";
      }

      // now build row strings
//      buf.append(util.buildStr(nrows, numRows, (r: Int) => createIx(r) + " -> " + createVals(r), rowBreakStr) )
    }
    buf.toString();
  }

  /**
   * Pretty-printer for Frame, which simply outputs the result of stringify.
   * @param nrows Number of rows to display
   * @param ncols Number of cols to display
   */
//  print([int nrows = 10, int ncols = 10, OutputStream stream = System.out]) {
//    stream.write(stringify(nrows, ncols).getBytes);
//  }

  @override
  int hashCode() =>
      values.hashCode() * 31 * 31 + rowIx.hashCode() * 31 + colIx.hashCode();

  @override
  bool equals(other) {
//    other match {
//      case f: Frame[_, _, _] => (this eq f) || rowIx == f.rowIx && colIx == f.colIx && values == f.values
//      case _ => false
//    }
  }
//}

//object Frame extends BinOpFrame {
  // --------------------------------
  // stats implicits

  /**
   * Enrich a Frame to provide statistical methods
   */
  /*implicit*/ frameToStats /*[RX, CX, T: ST]*/ (Frame<RX, CX, T> f) =>
      new FrameStats<RX, CX, T>(f);

  // --------------------------------
  // instantiations

  /**
   * Factory method to create an empty Frame
   * @tparam RX Type of row keys
   * @tparam CX Type of col keys
   * @tparam T Type of values
   */
  factory Frame.empty() /*[RX: ST: ORD, CX: ST: ORD, T: ST]: Frame<RX, CX, T>*/ =>
      new Frame<RX, CX, T>(
          new MatCols.empty<T>(), new Index.empty<RX>(), new Index.empty<CX>());

  // --------------------------------
  // Construct using sequence of vectors

  /**
   * Factory method to create a Frame from a sequence of Vec objects
   */
  /*Frame<int, int, T>*/ factory Frame.seq(Iterable<Vec<T>> values) {
    if (values.isEmpty) {
      return empty(); //[Int, Int, T]
    } else {
      val asIdxSeq = values.toIndexedSeq();
      apply(asIdxSeq, IndexIntRange(asIdxSeq(0).length),
          IndexIntRange(asIdxSeq.length));
    }
  }

  /**
   * Factory method to create a Frame from a sequence of Vec objects,
   * a row index, and a column index.
   */
  factory Frame.vecsIndex(
      Seq<Vec<T>> values, Index<RX> rowIx, Index<CX> colIx) {
    if (values.isEmpty) {
      return empty(); //[RX, CX, T];
    } else {
//      return new Frame<RX, CX, T>(MatCols[T](values : _*), rowIx, colIx)
    }
  }

  /**
   * Factory method to create a Frame from a sequence of Vec objects
   * and a column index.
   */
  factory Frame.column /*[CX: ST: ORD, T: ST]*/ (
      Seq<Vec<T>> values, Index<CX> colIx) {
    if (values.isEmpty) {
      return empty(); //[Int, CX, T];
    } else {
      val asIdxSeq = values.toIndexedSeq();
      apply(asIdxSeq, IndexIntRange(asIdxSeq(0).length), colIx);
    }
  }

  /**
   * Factory method to create a Frame from tuples whose first element is
   * the column label and the second is a Vec of values.
   */
//  def apply[CX: ST: ORD, T: ST](values: (CX, Vec[T])*): Frame[Int, CX, T] = {
//    val asIdxSeq = values.map(_._2).toIndexedSeq
//    val idx = Index(values.map(_._1).toArray)
//    asIdxSeq.length match {
//      case 0 => empty[Int, CX, T]
//      case _ => Frame(asIdxSeq, IndexIntRange(asIdxSeq(0).length), idx)
//    }
//  }

  // --------------------------------
  // Construct using sequence of series

  // dummy type, extra implicit parameter allows us to disambiguate the following
  // overloaded apply method
//  private type ID[T] = T => T

  /**
   * Factory method to create a Frame from a sequence of Series. The row labels
   * of the result are the outer join of the indexes of the series provided.
   */
  factory Frame.series /*[RX: ST: ORD, T: ST: ID]*/ (
      Iterable<Series<RX, T>> values) {
    val asIdxSeq = values.toIndexedSeq;
    switch (asIdxSeq.length) {
      case 0:
        return empty(); //[RX, Int, T]
      case 1:
        return new Frame(
            asIdxSeq.map(_.values), asIdxSeq(0).index, IndexIntRange(1));
      default:
        val init =
            Frame(IndexedSeq(asIdxSeq(0).values), asIdxSeq(0).index, Array(0));
        val temp = asIdxSeq.tail.foldLeft(init)(_.joinS(_, OuterJoin));
        Frame(temp.values, temp.rowIx, IndexIntRange(temp.numCols));
    }
  }

  /**
   * Factory method to create a Frame from a sequence of series, also specifying
   * the column index to use. The row labels of the result are the outer join of
   * the indexes of the series provided.
   */
  factory Frame.seriesCol /*[RX: ST: ORD, CX: ST: ORD, T: ST]*/ (
      Seq<Series<RX, T>> values, Index<CX> colIx) /*: Frame<RX, CX, T>*/ {
    var asIdxSeq = values.toIndexedSeq();
    switch (asIdxSeq.length) {
      case 0:
        return empty(); //[RX, CX, T]
      case 1:
        return new Frame(asIdxSeq.map(_.values), asIdxSeq(0).index, colIx);
      default:
        val init = Frame(Seq(asIdxSeq(0).values), asIdxSeq(0).index, Index(0));
        val temp = values.tail.foldLeft(init)(_.joinS(_, OuterJoin));
        Frame(temp.values, temp.rowIx, colIx);
    }
  }

  /**
   * Factory method to create a Frame from a sequence of tuples, where the
   * first element of the tuple is a column label, and the second a series
   * of values. The row labels of the result are the outer join of the
   * indexes of the series provided.
   */
//  def apply[RX: ST: ORD, CX: ST: ORD, T: ST](
//    values: (CX, Series<RX, T>)*): Frame<RX, CX, T> = {
//    val asIdxSeq = values.map(_._2).toIndexedSeq
//    val idx = Index(values.map(_._1).toArray)
//    asIdxSeq.length match {
//      case 0 => empty[RX, CX, T]
//      case 1 => Frame(asIdxSeq.map(_.values), asIdxSeq(0).index, idx)
//      case _ => {
//        val init = Frame(Seq(asIdxSeq(0).values), asIdxSeq(0).index, Array(0))
//        val temp = asIdxSeq.tail.foldLeft(init)(_.joinS(_, OuterJoin))
//        Frame(temp.values, temp.rowIx, idx)
//      }
//    }
//  }

  // --------------------------------
  // Construct using matrix

  /**
   * Build a Frame from a provided Mat
   */
  static Frame<int, int, dynamic> frameFromMat(Mat<T> values) => new Frame(
      values,
      new IndexIntRange(values.numRows),
      new IndexIntRange(values.numCols));

  /**
   * Build a Frame from a provided Mat, row index, and col index
   */
  static frameFromMatIndex /*[RX: ST: ORD, CX: ST: ORD, T: ST]*/ (
      Mat<T> mat, Index<RX> rowIx, Index<CX> colIx) {
    if (mat.length == 0) {
      return empty(); //[RX, CX, T]
    } else {
      return new Frame<RX, CX, T>(mat.cols(), rowIx, colIx)
          .withMat(new Some(mat));
    }
  }
}

/**
 * Convenience constructors for a Frame[RX, CX, Any] that accept arbitrarily-typed Vectors
 * and Series as constructor parameters, leaving their internal representations unchanged.
 */
class Panel {
  /**
   * Factory method to create an empty Frame whose columns have type Any
   * @tparam RX Type of row keys
   * @tparam CX Type of col keys
   */
  static Frame<RX, CX, Any> empty() /*[RX: ST: ORD, CX: ST: ORD]*/ =>
      new Frame<RX, CX, Any>(
          MatCols.empty(), new Index.empty<RX>(), new Index.empty<CX>());

  // --------------------------------
  // Construct using sequence of vectors

  /**
   * Factory method to create a Frame from a sequence of Vec objects
   */
  static Frame<int, int, Any> vecs(/*Vec[_]**/ values) {
    if (values.isEmpty) {
      return empty(); //[Int, Int]
    } else {
      val asIdxSeq = values.toIndexedSeq();
      return apply(asIdxSeq, IndexIntRange(asIdxSeq(0).length),
          IndexIntRange(asIdxSeq.length));
    }
  }

  /**
   * Factory method to create a Frame from a sequence of Vec objects,
   * a row index, and a column index.
   */
  static Frame /*[RX, CX, Any]*/ vecsIndex /*[RX: ST: ORD, CX: ST: ORD]*/ (
      Seq<Vec /*[_]*/ > values, Index<RX> rowIx, Index<CX> colIx) {
    val anySeq = values.toIndexedSeq();
    if (values.isEmpty) {
      return empty(); //[RX, CX]
    } else {
      return new Frame(toSeqVec(anySeq), rowIx, colIx);
    }
  }

  /**
   * Factory method to create a Frame from a sequence of Vec objects
   * and a column index.
   */
  static Frame /*[Int, CX, Any]*/ vecCol /*[CX: ST: ORD]*/ (
      Seq<Vec /*[_]*/ > values, Index<CX> colIx) {
    if (values.isEmpty) {
      return empty(); //[Int, CX]
    } else {
      var asIdxSeq = values.toIndexedSeq();
      return new Frame(asIdxSeq, IndexIntRange(asIdxSeq(0).length), colIx);
    }
  }

  static /*private*/ IndexedSeq<Vec<Any>> toSeqVec(Seq<Vec /*[_]*/ > anySeq) =>
      anySeq.toIndexedSeq.asInstanceOf[IndexedSeq[Vec[Any]]];

  /**
   * Factory method to create a Frame from tuples whose first element is
   * the column label and the second is a Vec of values.
   */
//  def apply[CX: ST: ORD, T: ST](
//    values: (CX, Vec[_])*): Frame[Int, CX, Any] = {
//    val asIdxSeq = values.map(_._2).toIndexedSeq
//    val idx = Index(values.map(_._1).toArray)
//    asIdxSeq.length match {
//      case 0 => empty[Int, CX]
//      case _ => Frame(toSeqVec(asIdxSeq), IndexIntRange(asIdxSeq(0).length), idx)
//    }
//  }

  // --------------------------------
  // Construct using sequence of series

  static /*private*/ toSeqSeries /*[RX]*/ (Seq<Series /*[RX, _]*/ > anySeq) =>
      anySeq.toIndexedSeq.asInstanceOf[IndexedSeq[Series /*[RX, Any]*/]];

  /**
   * Factory method to create a Frame from a sequence of Series. The row labels
   * of the result are the outer join of the indexes of the series provided.
   */
  static Frame /*[RX, Int, Any]*/ series /*[RX: ST: ORD]*/ (
      Iterable<Series /*[RX, _]**/ > values) {
    val asIdxSeq = toSeqSeries(values);
    switch (asIdxSeq.length) {
      case 0:
        return empty(); //[RX, Int]
      case 1:
        return new Frame(
            asIdxSeq.map(_.values), asIdxSeq(0).index, IndexIntRange(1));
      default:
        val init = Frame(Seq(asIdxSeq(0).values), asIdxSeq(0).index, Array(0));
        val temp = asIdxSeq.tail.foldLeft(init)(_.joinS(_, OuterJoin));
        Frame(temp.values, temp.rowIx, IndexIntRange(temp.numCols));
    }
  }

  /**
   * Factory method to create a Frame from a sequence of series, also specifying
   * the column index to use. The row labels of the result are the outer join of
   * the indexes of the series provided.
   */
  static Frame /*[RX, CX, Any]*/ seriesCol /*[RX: ST: ORD, CX: ST: ORD]*/ (
      Seq<Series /*[RX, _]*/ > values, Index<CX> colIx) {
    val asIdxSeq = toSeqSeries(values);
    switch (asIdxSeq.length) {
      case 0:
        return empty(); //[RX, CX]
      case 1:
        return new Frame(asIdxSeq.map(_.values), asIdxSeq(0).index, colIx);
      default:
        val init = Frame(Seq(asIdxSeq(0).values), asIdxSeq(0).index, Index(0));
        val temp = asIdxSeq.tail.foldLeft(init)(_.joinS(_, OuterJoin));
        Frame(temp.values, temp.rowIx, colIx);
    }
  }

  /**
   * Factory method to create a Frame from a sequence of tuples, where the
   * first element of the tuple is a column label, and the second a series
   * of values. The row labels of the result are the outer join of the
   * indexes of the series provided.
   */
//  def apply[RX: ST: ORD, CX: ST: ORD](
//    values: (CX, Series[RX, _])*): Frame[RX, CX, Any] = {
//    val asIdxSeq = toSeqSeries(values.map(_._2))
//    val idx = Index(values.map(_._1).toArray)
//    asIdxSeq.length match {
//      case 0 => empty[RX, CX]
//      case 1 => Frame(asIdxSeq.map(_.values), asIdxSeq(0).index, idx)
//      case _ => {
//        val init = Frame(Seq(asIdxSeq(0).values), asIdxSeq(0).index, Array(0))
//        val temp = asIdxSeq.tail.foldLeft(init)(_.joinS(_, OuterJoin))
//        Frame(temp.values, temp.rowIx, idx)
//      }
//    }
//  }
}
