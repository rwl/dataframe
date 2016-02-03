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

library saddle.frame;

import 'dart:math' as math;

import 'package:quiver/iterables.dart' show zip, range, IndexedValue, enumerate;

import 'index.dart';
import 'mat.dart';
import 'vec.dart';
import 'series.dart';

import 'array/array.dart';
import 'index/join_type.dart';
import 'index/slice.dart';
import 'index/splitter.dart';
import 'index/stacker.dart';
import 'index/index_int_range.dart';
import 'groupby/frame_grouper.dart';
import 'groupby/index_grouper.dart';
//import 'ops/ops.dart';
//import 'stats/stats.dart';
//import 'util/concat.dart' show Promoter;
import 'scalar/scalar.dart';
import 'scalar/scalar_tag.dart';
import 'scalar/scalar_tag_any.dart';
//import java.io.OutputStream
//import org.saddle.mat.MatCols
import 'mat/mat_cols.dart';
import 'vec/vec_impl.dart';
import 'vec/vec.dart' as vec;
import 'util/util.dart' as util;
import 'stats/frame_stats.dart';

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
  /*private[saddle]*/ MatCols<T> values;
  Index<RX> rowIx;
  Index<CX> colIx;

  Frame(this.values, this.rowIx, this.colIx) {
    if (values.numRows != rowIx.length) {
      throw new ArgumentError("Row index length is incorrect");
    }
    if (values.numCols != colIx.length) {
      throw new ArgumentError("Col index length is incorrect");
    }
  }

  /*private Option<*/ Mat<T> cachedMat = null;
  /*private Option<*/ MatCols<T> cachedRows = null;

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
  Frame<CX, RX, T> transpose() => new Frame(rows(), colIx, rowIx);

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
    List res = slice(colIx);
    return new Frame(
        values. /*slice*/ sublist(res[0], res[1]), rowIx, colIx.sliceBy(slice));
  }

  /**
   * Given an array of column keys, slice out the corresponding column(s)
   * @param keys Array of keys
   */
  Frame<RX, CX, T> col(List<CX> keys) {
    if (values.numCols == 0) {
      return new Frame<RX, CX, T>.empty(
          rowIx.scalarTag, colIx.scalarTag, values.scalarTag);
    } else {
      var locs = array.filter /*[Int]*/ ((a) => a != -1, colIx(keys));
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
    var tmp = Series.fromList(values, new ScalarTagAny<Vec>()).setIndex(colIx);
    var res = tmp.sliceByRange(from, to, inclusive);
    return new Frame(res.values.toArray, rowIx, res.index);
  }

  // -----------------------------------------
  // access columns by particular location(s)

  /**
   * Access frame column at a particular integer offset
   * @param loc integer offset
   */
  Series<RX, T> colAt(int loc) => new Series(values[loc], rowIx);

  /**
   * Access frame columns at a particular integer offsets
   * @param locs a sequence of integer offsets
   */
//  Frame<RX, CX, T> colAt(int* locs) => colAt(locs.toArray);

  /**
   * Access frame columns at a particular integer offsets
   * @param locs an array of integer offsets
   */
  Frame<RX, CX, T> colAtTake(List<int> locs) {
    if (values.numCols == 0) {
      return new Frame.empty /*<RX, CX, T>*/ (
          rowIx.scalarTag, colIx.scalarTag, values.scalarTag);
    } else {
      return new Frame(values.take(locs), rowIx, colIx.take(locs));
    }
  }

  /**
   * Access frame columns specified by a slice
   * @param slice a slice specifier
   */
  Frame<RX, CX, T> colAtSlice(Slice<int> slice) {
    var idx = new IndexIntRange(numCols);
    List pair = slice(idx);
    return new Frame(values.sublist /*slice*/ (pair[0], pair[1]), rowIx,
        colIx.slice(pair[0], pair[1]));
  }

  /**
   * Access frame columns between two integer offsets, [from, until)
   * @param from Beginning offset
   * @param until One past ending offset
   * @param stride Optional increment between offsets
   */
  Frame<RX, CX, T> colSliceRange(int from, int until, [int stride = 1]) {
    var lb = math.max(0, from);
    var ub = math.min(numCols, until);
    var taker = array.range(lb, ub, stride);
    return new Frame(values.take(taker), rowIx, colIx.take(taker));
  }

  /**
   * Split Frame into two frames at column position c
   * @param c Position at which to split Frame
   */
  SplitFrame<RX, CX, T> /*(Frame<RX, CX, T>, Frame<RX, CX, T>)*/ colSplitAt(
          int c) =>
      new SplitFrame<RX, CX, T>._(
          colSliceRange(0, c), colSliceRange(c, numCols));

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
  Frame<RX, CX, T> rowSlice(Slice<RX> slice) {
    List res = slice(rowIx);
    return new Frame(values.map((v) => v.slice(res[0], res[1])),
        rowIx.sliceBy(slice), colIx);
  }

  /**
   * Given an array of row keys, slice out the corresponding row(s)
   * @param keys Array of keys
   */
  Frame<RX, CX, T> row(List<RX> keys) {
    if (values.numRows == 0) {
      return new Frame.empty(
          rowIx.scalarTag, colIx.scalarTag, values.scalarTag); //<RX, CX, T>;
    } else {
      var locs = array.filter /*[Int]*/ ((i) => i != -1, rowIx(keys));
      return rowAtTake(locs);
    }
  }

  /**
   * Slice out a set of rows from the frame
   * @param from Key from which to begin slicing
   * @param to Key at which to end slicing
   * @param inclusive Whether to include 'to' key; true by default
   */
  Frame<RX, CX, T> rowSliceBy(RX from, RX to, [bool inclusive = true]) {
    var start = rowIx.lsearch(from);
    var end = inclusive ? rowIx.rsearch(to) : rowIx.lsearch(to);
    return new Frame(
        values.map((v) => v.slice(start, end)), rowIx.slice(start, end), colIx);
  }

  // -----------------------------------------
  // access rows by particular location(s)

  /**
   * Access frame row at a particular integer offset
   * @param loc integer offset
   */
  Series<CX, T> rowAt(int loc) => new Series(rows()[loc], colIx);

  /**
   * Access frame rows at a particular integer offsets
   * @param locs a sequence of integer offsets
   */
//  Frame<RX, CX, T> rowAt(int* locs) => rowAt(locs.toArray);

  /**
   * Access frame rows at a particular integer offsets
   * @param locs an array of integer offsets
   */
  Frame<RX, CX, T> rowAtTake(List<int> locs) =>
      new Frame(values.map((v) => v.take(locs)), rowIx.take(locs), colIx);

  /**
   * Access frame rows specified by a slice
   * @param slice a slice specifier
   */
  Frame<RX, CX, T> rowAtSlice(Slice<int> slice) {
    var idx = new IndexIntRange(numRows);
    List pair = slice(idx);
    return new Frame(values.map((v) => v.slice(pair[0], pair[1])),
        rowIx.slice(pair[0], pair[1]), colIx);
  }

  /**
   * Access frame rows between two integer offsets, [from, until)
   * @param from Beginning offset
   * @param until One past ending offset
   * @param stride Optional increment between offsets
   */
  Frame<RX, CX, T> rowSliceRange(int from, int until, [int stride = 1]) {
    return new Frame(values.map((v) => v.slice(from, until, stride)),
        rowIx.slice(from, until, stride), colIx);
  }

  /**
   * Split Frame into two frames at row position r
   * @param r Position at which to split Frame
   */
  SplitFrame<RX, CX, T> /*(Frame<RX, CX, T>, Frame<RX, CX, T>)*/ rowSplitAt(
          int r) =>
      new SplitFrame<RX, CX, T>._(
          rowSliceRange(0, r), rowSliceRange(r, numRows));

  /**
   * Split Frame into two frames at row key k
   * @param k Key at which to split Frame
   */
  SplitFrame<RX, CX, T> /*(Frame<RX, CX, T>, Frame<RX, CX, T>)*/ rowSplitBy(
          RX k) =>
      rowSplitAt(rowIx.lsearch(k));

  // --------------------------------------------
  // access a two dimensional sub-block by key(s)

  /**
   * Slice frame by row and column slice specifiers
   * @param rix A row slice
   * @param cix A col slice
   */
  Frame<RX, CX, T> applySlice(Slice<RX> rix, Slice<CX> cix) =>
      colSlice(cix).rowSlice(rix);

  /**
   * Slice frame by row slice and array of column keys
   * @param rix A row slice
   * @param cix An array of column keys
   */
  Frame<RX, CX, T> applySliceArray(Slice<RX> rix, List<CX> cix) =>
      col(cix).rowSlice(rix);

  /**
   * Slice frame by array of row keys and a col slice
   * @param rix An array of row keys
   * @param cix A col slice
   */
  Frame<RX, CX, T> applyArraySlice(List<RX> rix, Slice<CX> cix) =>
      colSlice(cix).row(rix);

  /**
   * Slice from by an array of row keys and an array of col keys
   * @param rix An array of row keys
   * @param cix An array of col keys
   */
  Frame<RX, CX, T> applyArray(List<RX> rix, List<CX> cix) => col(cix).row(rix);

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
  Frame<RX, CX, T> atTake(List<int> r, List<int> c) =>
      rowAtTake(r).colAtTake(c);

  /**
   * Access a slice of the Frame by integer offsets
   * @param r Array of row offsets
   * @param c Integer col offset
   */
  Series<RX, T> atTakeCol(List<int> r, int c) => rowAtTake(r).colAt(c);

  /**
   * Access a slice of the Frame by integer offsets
   * @param r Integer row offset
   * @param c Array of col offsets
   */
  Series<CX, T> atTakeRow(int r, List<int> c) => colAtTake(c).rowAt(r);

  /**
   * Access a slice of the Frame by Slice parameters
   * @param r Slice to apply to rows
   * @param c Slice to apply to cols
   */
  Frame<RX, CX, T> atSlice(Slice<int> r, Slice<int> c) =>
      rowAtSlice(r).colAtSlice(c);

  /**
   * Access the raw (unboxed) value at an offset within the Frame
   * @param r Integer row offset
   * @param c Integer col offset
   */
  T raw(int r, int c) => values.apply_(r, c);

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
    var ixer = rowIx.getIndexer(rix);
    if (ixer == null) {
      return this;
    }
    return new Frame(
        values.map((v) =>
            new Vec(array.take(v, ixer, v.scalarTag.missing), v.scalarTag)),
        rix,
        colIx);
  }

  /**
   * Create a new Frame whose col index is formed of the provided argument, and whose values
   * are derived from the original Frame.
   * @param cix Sequence of keys to be the col index of the result Frame
   */
  Frame<RX, CX, T> reindexCol(Index<CX> cix) {
    var ixer = colIx.getIndexer(cix);
    if (ixer == null) {
      return this;
    }
    return new Frame(values.take(ixer), rowIx, cix);
  }

  // -----------------------------------------
  // access columns by type

  /**
   * Extract columns from a heterogeneous Frame which match the provided type.
   * The result is a homogeneous frame consisting of the selected data.
   * @tparam U The type of columns to extract
   */
  Frame /*<RX, CX, U>*/ colType /*[U: ST]*/ (ScalarTag bSt) {
    var tt = values.takeType(bSt); //[U];
    return new Frame(tt.vecs, rowIx, colIx.take(tt.i));
  }

  /**
   * Extract columns from a heterogeneous Frame which match either of the provided
   * types. The result is a heterogeneous frame consisting of the selected data.
   * @tparam U1 First type of columns to extract
   * @tparam U2 Second type of columns to extract
   */
  Frame /*<RX, CX, Any>*/ colTypeAlt /*[U1: ST, U2: ST]*/ (
      ScalarTag bSt1, ScalarTag bSt2) {
    var /*columns1, locs1*/ tt1 = values.takeType(bSt1); //[U1];
    var /*columns2, locs2*/ tt2 = values.takeType(bSt2); //[U2];

    var frm = Panel.vecsIndex(tt1.vecs..addAll(tt2.vecs), rowIx,
        colIx.take(tt1.i).concat(colIx.take(tt2.i)));
    var tkr = array.argsort(array.flatten([tt1.i, tt2.i]), ScalarTag.stInt);

    return frm.colAt(tkr);
  }

  // ----------------------------------------
  // generate or use a new index

  /**
   * Create a new Frame using the current values but with the new row index. Positions
   * of the values do not change. Length of new index must be equal to number of rows.
   * @param newIx A new Index
   * @tparam Y Type of elements of new Index
   */
  Frame /*<Y, CX, T>*/ setRowIndex /*[Y: ST: ORD]*/ (Index /*<Y>*/ newIx) =>
      new Frame(values, newIx, colIx).withMat(cachedMat);

  /**
   * Create a new Frame using the current values but with the new row index specified
   * by the column at a particular offset, and with that column removed from the frame
   * data body.
   */
  Frame /*<T, CX, T>*/ withRowIndex(int col) /*(implicit ordT: ORD[T])*/ => this
      .setRowIndex(
          new Index(this.colAt(col).toVec().toArray(), values.scalarTag))
      .filterAt((i) => i != col);

  /**
   * Overloaded method to create hierarchical index from two cols.
   */
  Frame /*<(T, T), CX, T>*/ with2RowIndex(
      int col1, int col2) /*(implicit ordT: ORD[T])*/ {
    Index /*[(T, T)]*/ newIx =
        Index.make([this.colAt(col1).toVec(), this.colAt(col2).toVec()]);
    return this.setRowIndex(newIx).filterAt((c) => ![col1, col2].contains(c));
  }

  /**
   * Map a function over the row index, resulting in a new Frame
   *
   * @param fn The function RX => Y with which to map
   * @tparam Y Result type of index, ie Index<Y>
   */
  Frame /*<Y, CX, T>*/ mapRowIndex /*[Y: ST: ORD]*/ (
          /*Y*/ dynamic fn(RX arg),
          ScalarTag sy) =>
      new Frame(values, rowIx.map(fn, sy), colIx).withMat(cachedMat);

  /**
   * Create a new Frame using the current values but with the new col index. Positions
   * of the values do not change. Length of new index must be equal to number of cols.
   * @param newIx A new Index
   * @tparam Y Type of elements of new Index
   */
  Frame /*<RX, Y, T>*/ setColIndex /*[Y: ST: ORD]*/ (Index /*<Y>*/ newIx) =>
      new Frame(values, rowIx, newIx).withMat(cachedMat);

  /**
   * Create a new Frame using the current values but with the new col index specified
   * by the row at a particular offset, and with that row removed from the frame
   * data body.
   */
  Frame<RX, T, T> withColIndex(int row) /*(implicit ordT: ORD[T])*/ => this
      .setColIndex(
          new Index(this.rowAt(row).toVec().toArray(), values.scalarTag))
      .rfilterAt((i) => i != row);

  /**
   * Overloaded method to create hierarchical index from two rows.
   */
  Frame /*<RX, (T, T), T>*/ with2ColIndex(
      int row1, int row2) /*(implicit ordT: ORD[T])*/ {
    Index /*[(T, T)]*/ newIx =
        new Index.make(this.rowAt(row1).toVec(), this.rowAt(row2).toVec());
//    this.setColIndex(newIx).rfilterAt { case r => !Set(row1, row2).contains(r) };
    this
        .setColIndex(newIx)
        .rfilterAt((r) => !new Set.from([row1, row2]).contains(r));
  }

  /**
   * Map a function over the col index, resulting in a new Frame
   *
   * @param fn The function CX => Y with which to map
   * @tparam Y Result type of index, ie Index<Y>
   */
  Frame /*<RX, Y, T>*/ mapColIndex /*[Y: ST: ORD]*/ (
      /*Y*/ dynamic fn(CX arg),
      ScalarTag sy) {
    return new Frame(values, rowIx, colIx.map(fn, sy)).withMat(cachedMat);
  }

  /**
   * Create a new Frame whose values are the same, but whose row index has been changed
   * to the bound [0, numRows - 1), as in an array.
   */
  Frame<int, CX, T> resetRowIndex() {
    return new Frame(values, new IndexIntRange(numRows), colIx)
        .withMat(cachedMat);
  }

  /**
   * Create a new Frame whose values are the same, but whose col index has been changed
   * to the bound [0, numCols - 1), as in an array.
   */
  Frame<RX, int, T> resetColIndex() {
    return new Frame(values, rowIx, new IndexIntRange(numCols))
        .withMat(cachedMat);
  }

  // ----------------------------------------
  // some helpful ops

  /**
   * Extract first n rows
   *
   * @param n number of rows to extract
   */
  Frame<RX, CX, T> head(int n) => transform((s) => s.head(n));

  /**
   * Extract last n rows
   *
   * @param n number of rows to extract
   */
  Frame<RX, CX, T> tail(int n) => transform((s) => s.tail(n));

  /**
   * Extract first n columns
   *
   * @param n number of columns to extract
   */
  headCol(int n) => new Frame.vecsIndex(
      values.sublist(0, n), rowIx, colIx.head(n), values.scalarTag);

  /**
   * Extract last n columns
   *
   * @param n number of columns to extract
   */
  tailCol(int n) =>
      new Frame(values.sublist(values.length - n), rowIx, colIx.tail(n));

  /**
   * Extract first row matching a particular key
   *
   * @param k Key to match
   */
  Series<CX, T> first(RX k) {
    var loc = rowIx.getFirst(k);
    if (loc == -1) {
      return emptyRow();
    } else {
      return rowAt(loc);
    }
  }

  /**
   * Extract last row matching a particular key
   *
   * @param k Key to match
   */
  Series<CX, T> last(RX k) {
    var loc = rowIx.getLast(k);
    if (loc == -1) {
      return new Series<CX, T>.empty(values.scalarTag, colIx.scalarTag);
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
    var loc = colIx.getFirst(k);
    if (loc == -1) {
      return emptyCol();
    } else {
      return colAt(loc);
    }
  }

  /**
   * Extract first col matching a particular key
   *
   * @param k Key to match
   */
  Series<RX, T> lastCol(CX k) {
    var loc = colIx.getLast(k);
    if (loc == -1) {
      return emptyCol();
    } else {
      return colAt(loc);
    }
  }

  /**
   * Return empty series of type equivalent to a row of frame
   *
   */
  Series<CX, T> emptyRow() =>
      new Series<CX, T>.empty(values.scalarTag, colIx.scalarTag);

  /**
   * Return empty series of type equivalent to a column of frame
   *
   */
  Series<RX, T> emptyCol() =>
      new Series<RX, T>.empty(values.scalarTag, rowIx.scalarTag);

  /**
   * Create a new Frame whose rows are sorted according to the row
   * index keys
   */
  Frame<RX, CX, T> sortedRIx() {
    if (rowIx.isMonotonic) {
      return this;
    } else {
      var taker = rowIx.argSort();
      return new Frame(
          values.map((v) => v.take(taker)), rowIx.take(taker), colIx);
    }
  }

  /**
   * Create a new Frame whose cols are sorted according to the col
   * index keys
   */
  Frame<RX, CX, T> sortedCIx() {
    if (colIx.isMonotonic) {
      return this;
    } else {
      var taker = colIx.argSort;
      return new Frame(values.take(taker), rowIx, colIx.take(taker));
    }
  }

  /**
   * Create a new Frame whose rows are sorted primarily on the values
   * in the first column specified in the argument list, and then on
   * the values in the next column, etc.
   * @param locs Location of columns containing values to sort on
   */
  sortedRows(List<int> /***/ locs) /*(implicit ev: ORD[T])*/ {
    var order = array.range(0, numRows);

    var j = locs.length - 1;
    while (j >= 0) {
      var tosort = colAt(locs[j]).values.take(order);
      var reordr = new Index(tosort.toArray(), values.scalarTag).argSort();
      order = array.take(order, reordr, () => throw "Logic error");
      j -= 1;
    }

    return new Frame(
        values.map((v) => v.take(order)), rowIx.take(order), colIx);
  }

  /**
   * Create a new Frame whose cols are sorted primarily on the values
   * in the first row specified in the argument list, and then on
   * the values in the next row, etc.
   * @param locs Location of rows containing values to sort on
   */
  sortedCols(List<int> /***/ locs) /*(implicit ev: ORD[T])*/ {
    var order = array.range(0, numCols);

    var j = locs.length - 1;
    while (j >= 0) {
      var tosort = rowAt(locs[j]).values.take(order);
      var reordr = new Index(tosort.toArray(), values.scalarTag).argSort();
      order = array.take(order, reordr, () => throw "Logic error");
      j -= 1;
    }

    return new Frame(values.takeAll(order), rowIx, colIx.take(order));
  }

  /**
   * Create a new Frame whose rows are sorted by the result of a function
   * acting on each row.
   * @param f Function from a single row (represented as series) to a value having an
   *          ordering
   * @tparam Q Result type of the function
   */
  Frame<RX, CX, T> sortedRowsBy /*[Q: ORD]*/ (
      /*Q*/ dynamic f(Series<CX, T> arg)) {
    List<int> perm = array.range(0, numRows)
      ..sort((int i, int j) => f(rowAt(i)).compareTo(rowAt(j)));
    return rowAtTake(perm);
  }

  /**
   * Create a new Frame whose cols are sorted by the result of a function
   * acting on each col.
   * @param f Function from a single col (represented as series) to a value having an
   *          ordering
   * @tparam Q Result type of the function
   */
  Frame<RX, CX, T> sortedColsBy /*[Q: ORD]*/ (
      /*Q*/ dynamic f(Series<RX, T> arg)) {
    List<int> perm = array.range(0, numCols)
      ..sort((int i, int j) => f(colAt(i)).compareTo(f(colAt(j))));
    return colAtTake(perm);
  }

  /**
   * Map over each triple (r, c, v) in the Frame, returning a new frame from the resulting
   * triples.
   */
  Frame /*<SX, DX, U>*/ map /*[SX: ST: ORD, DX: ST: ORD, U: ST]*/ (
      util.Tuple3 /*(SX, DX, U)*/ f(/*(RX, CX, T)*/ arg),
      ScalarTag scx,
      ScalarTag sct) {
    return new Series.fromTuples(
        toSeq().map(f).map((tup) {
          var sx = tup.value1, dx = tup.value2, u = tup.value3;
          return (sx, dx) => u;
        } /*: _**/),
        scx,
        sct).pivot();
  }

  /**
   * Map over each triple (r, c, v) in the Frame, flattening results, and returning a new frame from
   * the resulting triples.
   */
  Frame /*<SX, DX, U>*/ flatMap /*[SX: ST: ORD, DX: ST: ORD, U: ST]*/ (
      Iterable<util.Tuple3> /*Traversable[(SX, DX, U)]*/ f(
          /*(RX, CX, T)*/ arg),
      ScalarTag scx,
      ScalarTag sct) {
    return new Series.fromTuples(
        toSeq().flatMap(f).map((tup) {
          var sx = tup.value1, dx = tup.value2, u = tup.value3;
          return (sx, dx) => u;
        }),
        scx,
        sct).pivot();
  }

  /**
   * Map over the values of the Frame. Applies a function to each (non-na) value in the frame,
   * returning a new frame whose indices remain the same.
   *
   * @param f Function from T to U
   * @tparam U The type of the resulting values
   */
  Frame /*<RX, CX, U>*/ mapValues /*[U: ST]*/ (
          /*U*/ dynamic f(T arg),
          ScalarTag su) =>
      new Frame(values.map((v) => v.map(f, su)), rowIx, colIx);

  /**
   * Create a new Frame that, whenever the mask predicate function evaluates to
   * true on a value, is masked with NA
   * @param f Function from T to Boolean
   */
  Frame<RX, CX, T> maskFn(bool f(T arg)) =>
      new Frame(values.map((v) => v.maskFn(f)), rowIx, colIx);

  /**
   * Create a new Frame whose columns follow the rule that, wherever the mask Vec is true,
   * the column value is masked with NA
   * @param m Mask Vec[Boolean]
   */
  Frame<RX, CX, T> mask(Vec<bool> m) =>
      new Frame(values.map((v) => v.mask(m)), rowIx, colIx);

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
  Frame<RX, CX, dynamic> joinMap /*[U: ST, V: ST]*/ (
      Frame<RX, CX, dynamic> other, dynamic f(arg1, arg2), ScalarTag stv,
      [JoinType rhow = JoinType.LeftJoin,
      JoinType chow = JoinType.RightJoin]) /*(V f((T, U) arg))*/ {
    var algn = align(other, rhow, chow);
    var result = zip([algn.left.values, algn.right.values]).map((z) {
      return VecImpl.zipMap(z[0], z[1], f, stv);
    });
    return new Frame(result, algn.left.rowIx, algn.left.colIx);
  }

  /**
   * Map a function over each column vector and collect the results into a Frame respecting
   * the original indexes.
   * @param f Function acting on Vec[T] and producing another Vec
   * @tparam U Type of result Vec of the function
   */
  Frame /*<RX, CX, U>*/ mapVec /*[U: ST]*/ (Vec /*<U>*/ f(Vec<T> arg)) =>
      new Frame(values.map(f), rowIx, colIx);

  /**
   * Apply a function to each column series which results in a single value, and return the
   * series of results indexed by original column index.
   * @param f Function taking a column (series) to a value
   * @tparam U The output type of the function
   */
  Series /*<CX, U>*/ reduce /*[U: ST]*/ (
      /*U*/ dynamic f(Series<RX, T> arg),
      ScalarTag su) {
//    return new Series(new Vec(values.map((v) => f(new Series(v, rowIx))) : _*), colIx);
    return new Series(
        new Vec(values.map((v) => f(new Series(v, rowIx))), su), colIx);
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
  Frame /*<SX, CX, U>*/ transform /*[U: ST, SX: ST: ORD]*/ (
      Series /*<SX, U>*/ f(Series<RX, T> arg), ScalarTag srx, ScalarTag stu) {
    return new Frame.seriesCol(
        values.map((v) => f(new Series(v, rowIx))), colIx, srx, stu);
  }

  // groupBy functionality (on rows)

  /**
   * Construct a [[org.saddle.groupby.FrameGrouper]] with which further computations, such
   * as combine or transform, may be performed. The groups are constructed from the keys of
   * the row index, with each unique key corresponding to a group.
   */
  FrameGrouper groupBy() => new FrameGrouper.fromFrame(this);

  /**
   * Construct a [[org.saddle.groupby.FrameGrouper]] with which further computations, such
   * as combine or transform, may be performed. The groups are constructed from the result
   * of the function applied to the keys of the row index; each unique result of calling the
   * function on elements of the row index corresponds to a group.
   * @param fn Function from RX => Y
   * @tparam Y Type of function codomain
   */
  FrameGrouper groupByFn /*[Y: ST: ORD]*/ (
          /*Y*/ dynamic fn(RX arg),
          ScalarTag sy) =>
      new FrameGrouper(this.rowIx.map(fn, sy), this);

  /**
   * Construct a [[org.saddle.groupby.FrameGrouper]] with which further computations, such
   * as combine or transform, may be performed. The groups are constructed from the keys of
   * the provided index, with each unique key corresponding to a group.
   * @param ix Index with which to perform grouping
   * @tparam Y Type of elements of ix
   */
  FrameGrouper groupByIndex /*[Y: ST: ORD]*/ (Index /*<Y>*/ ix) =>
      new FrameGrouper(ix, this);

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
  Frame /*<RX, CX, V>*/ concat /*[U, V]*/ (Frame /*<RX, CX, U>*/ other,
      [JoinType how =
          JoinType.OuterJoin]) /*(
    implicit pro: Promoter[T, U, V], mu: ST[U], md: ST[V])*/
  {
    var ixc = colIx.join(other.colIx, how);

    var lft = ixc.lTake != null ? ixc.lTake.map((x) => values.take(x)) : values;
    var rgt = ixc.rTake != null
        ? ixc.rTake.map((x) => other.values.take(x))
        : other.values;

    mfn(Vec<T> v, Vec /*<U>*/ u) => v.concat(u);
    var dat = zip([lft, rgt]).map((z) {
      /*case*/
      var top = z[0];
      var bot = z[1];
      return mfn(top, bot);
    });
    var idx = rowIx.concat(other.rowIx);

    return new Frame(dat, idx, ixc.index);
  }

  /**
   * Create Frame whose rows satisfy the rule that their keys and values are chosen
   * via a Vec[Boolean] or a Series[_, Boolean] predicate when the latter contains a
   * true value.
   * @param pred Series[_, Boolean] (or Vec[Boolean] which will implicitly convert)
   */
  Frame<RX, CX, T> where(Series<dynamic, bool> pred) {
    var newVals = util.flatten(enumerate(values)
        .map((iv) => (pred.values[iv.index]) ? [iv.value] : []));
    var newIdx = VecImpl.where(
        new Vec(this.colIx.toArray_(), colIx.scalarTag), pred.values.toArray());
    return new Frame(newVals, rowIx, new Index.fromVec(newIdx));
  }

  /**
   * Shift the sequence of values relative to the row index by some offset,
   * dropping those values which no longer associate with a key, and having
   * those keys which no longer associate to a value instead map to NA.
   * @param n Number to shift
   */
  Frame<RX, CX, T> shift([int n = 1]) =>
      new Frame(values.map((v) => v.shift(n)), rowIx, colIx);

  /**
   * In each column, replaces all NA values for which there is a non-NA value at
   * a prior offset with the corresponding most-recent, non-NA value. See Vec.pad
   */
  Frame<RX, CX, T> pad() => mapVec((v) => v.pad());

  /**
   * Same as above, but limits the number of observations padded. See Vec.padAtMost
   */
  Frame<RX, CX, T> padAtMost(int n) => mapVec((v) => v.padAtMost(n));

  /**
   * Return Frame whose columns satisfy a predicate function operating on that
   * column
   * @param pred Predicate function from Series<RX, T> => Boolean
   */
  filter(bool pred(Series<RX, T> arg)) =>
      where(reduce((v) => pred(v), ScalarTag.stBool));

  /**
   * Return Frame whose columns satisfy a predicate function operating on the
   * column index
   * @param pred Predicate function from CX => Boolean
   */
  Frame<RX, CX, T> filterIx(bool pred(CX arg)) =>
      where(Series.fromVec(colIx.toVec().map(pred, ScalarTag.stBool)));

  /**
   * Return Frame whose columns satisfy a predicate function operating on the
   * column index offset
   * @param pred Predicate function from CX => Boolean
   */
  filterAt(bool pred(int arg)) =>
      where(Series.fromVec(vec.vrange(0, numCols).map(pred, ScalarTag.stBool)));

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
  Frame /*<RX, CX, B>*/ rolling /*[B: ST]*/ (
      int winSz, /*B*/ dynamic f(Series<RX, T> arg), ScalarTag scb) {
    var tmp =
        values.map((v) => new Series(v, rowIx).rolling(winSz, f, scb).values);
    return new Frame(tmp, rowIx.slice(winSz - 1, values.numRows), colIx);
  }

  /**
   * Create a Series by rolling over winSz number of rows of the Frame at a
   * time, and applying a function that takes those rows to a single value.
   *
   * @param winSz Window size to roll with
   * @param f Function taking the (sub) frame to B
   * @tparam B Result element type of Series
   */
  Series /*<RX, B>*/ rollingFtoS /*[B: ST]*/ (
      int winSz, /*B*/ dynamic f(Frame<RX, CX, T> arg), ScalarTag scb) {
    var buf = new List(numRows - winSz + 1);
    var i = winSz;
    while (i <= numRows) {
      buf[i - winSz] = f(rowSliceRange(i - winSz, i));
      i += 1;
    }
    return new Series(new Vec(buf, scb), rowIx.slice(winSz - 1, numRows));
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
    var indexer = rowIx.join(other.index, how);
    var lft = indexer.lTake != null
        ? values.map((v) => v.take(indexer.lTake))
        : values;
    var rgt =
        indexer.rTake != null ? other.values.take(indexer.rTake) : other.values;
    return new Frame(
        lft /*:*/ + rgt, indexer.index, new IndexIntRange(colIx.length + 1));
  }

  /**
   * Same as `joinS`, but preserve the column index, adding the specified index value,
   * `newColIx` as an index for the `other` Series.
   */
  Frame<RX, CX, T> joinSPreserveColIx(Series<RX, T> other,
      [JoinType how = JoinType.LeftJoin, CX newColIx]) {
    var resultingFrame = joinS(other, how);
    var newColIndex = colIx.concat(new Index([newColIx], colIx.scalarTag));
    return resultingFrame.setColIndex(newColIndex);
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
  Frame<RX, int, T> join(Frame<RX, dynamic, T> other,
      [JoinType how = JoinType.LeftJoin]) {
    var indexer = rowIx.join(other.rowIx, how);
    var lft = indexer.lTake != null
        ? values.map((v) => v.take(indexer.lTake))
        : values;
    var rgt = indexer.rTake != null
        ? other.values.map((v) => v.take(indexer.rTake))
        : other.values;
    return new Frame(lft..addAll(rgt), indexer.index,
        new IndexIntRange(colIx.length + other.colIx.length));
  }

  /**
   *  Same as `join`, but preserves column index
   */
  Frame<RX, CX, T> joinPreserveColIx(Frame<RX, CX, T> other,
      [JoinType how = JoinType.LeftJoin]) {
    var resultingFrame = join(other, how);
    var newColIndex = colIx.concat(other.colIx);
    return resultingFrame.setColIndex(newColIndex);
  }

  /**
   * Same as joinS, but the values of Series to join with may be of type Any, so that the
   * resulting Frame may be heterogeneous in its column types.
   */
  Frame<RX, int, dynamic> joinAnyS(Series<RX, dynamic> other,
      [JoinType how = JoinType.LeftJoin]) {
    var indexer = rowIx.join(other.index, how);
    var lft = indexer.lTake != null
        ? values.map((v) => v.take(indexer.lTake))
        : values;
    var rgt =
        indexer.rTake != null ? other.values.take(indexer.rTake) : other.values;
    return Panel.vecsIndex(
        lft /*:*/ + rgt, indexer.index, new IndexIntRange(colIx.length + 1));
  }

  /**
   * Same as `joinAnyS`, but preserve the column index, adding the specified index value,
   * `newColIx` as an index for the `other` Series.
   */
  Frame<RX, CX, dynamic> joinAnySPreserveColIx(Series<RX, dynamic> other,
      [JoinType how = JoinType.LeftJoin, CX newColIx]) {
    var resultingFrame = joinAnyS(other, how);
    var newColIndex = colIx.concat(new Index([newColIx], colIx.scalarTag));
    return resultingFrame.setColIndex(newColIndex);
  }

  /**
   * Same as join, but the values of Frame to join with may be of type Any, so that the
   * resulting Frame may be heterogeneous in its column types.
   */
  Frame<RX, int, dynamic> joinAny(Frame<RX, dynamic, dynamic> other,
      [JoinType how = JoinType.LeftJoin]) {
    var indexer = rowIx.join(other.rowIx, how);
    var lft = indexer.lTake != null
        ? values.map((v) => v.take(indexer.lTake))
        : values;
    var rgt = indexer.rTake != null
        ? other.values.map((v) => v.take(indexer.rTake))
        : other.values;
    return Panel.vecsIndex(lft..addAll(rgt), indexer.index,
        new IndexIntRange(colIx.length + other.colIx.length));
  }

  /**
   *  Same as `joinAny`, but preserves column index
   */
  Frame<RX, CX, dynamic> joinAnyPreserveColIx(Frame<RX, CX, dynamic> other,
      [JoinType how = JoinType.LeftJoin]) {
    var resultingFrame = joinAny(other, how);
    var newColIndex = colIx.concat(other.colIx);
    return resultingFrame.setColIndex(newColIndex);
  }

  /**
   * Aligns this frame with another frame, returning the left and right frames aligned
   * to each others indexes according to the the provided parameters
   *
   * @param other Other frame to align with
   * @param rhow How to perform the join on the row indexes
   * @param chow How to perform the join on the col indexes
   */
  AlignedFrame /*(Frame<RX, CX, T>, Frame<RX, CX, U>)*/ align /*[U: ST]*/ (
      Frame /*<RX, CX, U>*/ other,
      [JoinType rhow = JoinType.OuterJoin,
      JoinType chow = JoinType.OuterJoin]) {
    var rJoin = rowIx.join(other.rowIx, rhow);
    var cJoin = colIx.join(other.colIx, chow);

    MatCols /*[T]*/ lvals =
        cJoin.lTake != null ? values.takeAll(cJoin.lTake) : values;
    MatCols /*[U]*/ rvals =
        cJoin.rTake != null ? other.values.takeAll(cJoin.rTake) : other.values;

    var lvecs = range(lvals.length).map((i) {
      return rJoin.lTake != null ? lvals[i].take(rJoin.lTake) : lvals[i];
    });
    var rvecs = range(rvals.length).map((i) {
      return rJoin.rTake != null ? rvals[i].take(rJoin.rTake) : rvals[i];
    });

    return new AlignedFrame._(new Frame(lvecs, rJoin.index, cJoin.index),
        new Frame(rvecs, rJoin.index, cJoin.index));
  }

  // ------------------------------------------------
  // reshaping

  /**
   * Drop all columns from the Frame which have nothing but NA values.
   */
  Frame<RX, CX, T> squeeze() => filter((s) => !VecImpl.isAllNA(s.toVec()));

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
  Series /*<W, T>*/ melt /*[W]*/ (/*implicit*/ Melter<RX, CX, W> melter) {
    var ix = new List.generate(numRows * numCols, (_) => melter.tag);

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

    /*implicit*/ var ord = melter.ord;
    /*implicit*/ var tag = melter.tag;

    return new Series /*<W, T>*/ (toMat().toVec(), new Index(ix, tag));
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
  Frame /*<V, O1, T>*/ stack /*[O1, O2, V]*/ (
      /*implicit*/ Splitter /*<CX, O1, O2>*/ splt,
      Stacker /*<RX, O2, V>*/ stkr,
      /*ORD<O1>*/ ord1,
      /*ORD<O2>*/ ord2,
      /*ST<O1>*/ m1,
      /*ST<O2>*/ m2) {
    return transpose().unstack(splt, stkr, ord1, ord2, m1, m2).transpose();
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
  Frame /*<O1, V, T>*/ unstack /*[O1, O2, V]*/ (
      /*implicit*/ Splitter /*<RX, O1, O2>*/ splt,
      Stacker /*<CX, O2, V>*/ stkr,
      /*ORD<O1>*/ ord1,
      /*ORD<O2>*/ ord2,
      /*ST<O1>*/ m1,
      /*ST<O2>*/ m2) {
//    /*implicit*/ ordV() => stkr.ord;
//    /*implicit*/ clmV() => stkr.tag;

    var sp =
        splt.call(rowIx); // lft = row index w/o pivot level; rgt = pivot level

    var rix = sp.left.uniques(); // Final row index
    var uix = sp.right.uniques();
    var cix = stkr.call(
        colIx, uix); // Final col index (colIx stacked w/unique pivot labels)

    var grps = new IndexGrouper(sp.right, false)
        .groups; // Group by pivot label. Each unique label will get its
    //   own column in the final frame.
    if (values.length > 0) {
      var len = uix.length;
      var off = 0;
      var loc = 0;

      var result = new List<Vec<T>>(cix.length); // accumulates result columns

      for (var /*(_,*/ taker in grps) {
        // For each pivot label grouping,
        var gIdx =
            sp.left.take(taker.taker); //   use group's (lft) row index labels
        var ixer = rix.join(gIdx); //   to compute map to final (rix) locations;

        for (var currVec in values) {
          // For each column vec of original frame
          var vals = currVec.take(
              taker.taker); //   take values corresponding to current pivot label
          var v = ixer.rTake != null
              ? vals.take(ixer.rTake)
              : vals; //   map values to be in correspondence to rix
          result[loc] = v; //   and save vec in array.

          loc += len; // Increment offset into result array
          if (loc >= cix.length) {
            off += 1;
            loc = off;
          }
        }
      }

      return new Frame /*<O1, V, T>*/ (result, rix, cix);
    } else {
      return new Frame.empty /*<O1, V, T>*/ (m1, stkr.tag, values.scalarTag);
    }
  }

  /**
   * Extract the Mat embodied in the values of the Frame (dropping any indexing
   * information)
   */
  Mat<T> toMat() {
    var st = values.scalarTag; //implicitly[ST[T]];
//    synchronized {
    if (cachedMat.isEmpty) {
      var m = new Mat(
          values.numCols, values.numRows, st.concat(values).toArray(), st).T;
      withMat(m); //Some(m));
    }
    return cachedMat; //.get;
//    }
  }

  // ---------------------------------------------------------------
  // Row-wise versions of all the ops that operate on cols by default

  /**
   * See mask; operates row-wise
   */
  Frame<RX, CX, T> rmaskFn(bool f(T arg)) => transpose().maskFn(f).transpose();

  /**
   * See mask; operates row-wise
   */
  Frame<RX, CX, T> rmask(Vec<bool> b) => transpose().mask(b).transpose();

  /**
   * See mapVec; operates row-wise
   */
  rmapVec /*[U: ST]*/ (Vec /*<U>*/ f(Vec<T> arg)) =>
      transpose().mapVec(f).transpose();

  /**
   * See reduce; operates row-wise
   */
  Series /*<RX, U>*/ rreduce /*[U: ST]*/ (
          /*U*/ dynamic f(Series<CX, T> arg),
          ScalarTag stu) =>
      transpose().reduce(f, stu);

  /**
   * See transform; operates row-wise
   */
  Frame /*<RX, SX, U>*/ rtransform /*[U: ST, SX: ST: ORD]*/ (
          Series /*<SX, U>*/ f(Series<CX, T> arg),
          ScalarTag srx,
          ScalarTag stu) =>
      transpose().transform(f, srx, stu).transpose();

  /**
   * See concat; operates row-wise
   */
  Frame<RX, CX, T> rconcat /*[U, V]*/ (Frame /*<RX, CX, U>*/ other,
      [JoinType how = JoinType.OuterJoin]) {
    /*(
    implicit wd1: Promoter[T, U, V], mu: ST[U], md: ST[V])*/
    return transpose().concat(other.transpose(), how).transpose();
  }

  /**
   * See where; operates row-wise
   */
  Frame<RX, CX, T> rwhere(Series<dynamic, bool> pred) {
    var predv = pred.values;
    return new Frame(
        new MatCols(values.map((v) => v.where(predv)), values.scalarTag),
        new Index.fromVec(rowIx.toVec().where(predv)),
        colIx);
  }

  /**
   * See shift; operates col-wise
   */
  Frame<RX, CX, T> cshift([int n = 1]) => transpose().shift(n).transpose();

  /**
   * See filter; operates row-wise
   */
  rfilter(bool pred(Series<CX, T> arg)) =>
      rwhere(rreduce((v) => pred(v), ScalarTag.stBool));

  /**
   * See filterIx; operates row-wise
   */
  rfilterIx(bool pred(RX arg)) =>
      rwhere(Series.fromVec(rowIx.toVec().map(pred, ScalarTag.stBool)));

  /**
   * See filterAt; operates row-wise
   */
  rfilterAt(bool pred(int arg)) => rwhere(
      Series.fromVec(vec.vrange(0, numRows).map(pred, ScalarTag.stBool)));

  /**
   * See joinS; operates row-wise
   */
  Frame<int, CX, T> rjoinS(Series<CX, T> other,
          [JoinType how = JoinType.LeftJoin]) =>
      transpose().joinS(other, how).transpose();

  /**
   * See joinSPreserveColIx; operates row-wise
   */
  Frame<RX, CX, T> rjoinSPreserveRowIx(Series<CX, T> other,
          [JoinType how = JoinType.LeftJoin, RX newRowIx]) =>
      transpose().joinSPreserveColIx(other, how, newRowIx).transpose();

  /**
   * See join; operates row-wise
   */
  Frame<int, CX, T> rjoin(Frame<dynamic, CX, T> other,
          [JoinType how = JoinType.LeftJoin]) =>
      transpose().join(other.transpose(), how).transpose();

  /**
   * See joinPreserveColIx; operates row-wise
   */
  Frame<RX, CX, T> rjoinPreserveRowIx(Frame<RX, CX, T> other,
          [JoinType how = JoinType.LeftJoin]) =>
      transpose().joinPreserveColIx(other.transpose(), how).transpose();

  /**
   * See joinAnyS; operates row-wise
   */
  Frame<int, CX, dynamic> rjoinAnyS(Series<CX, dynamic> other,
          [JoinType how = JoinType.LeftJoin]) =>
      transpose().joinAnyS(other, how).transpose();

  /**
   * See joinAnySPreserveColIx; operates row-wise
   */
  Frame<RX, CX, dynamic> rjoinAnySPreserveRowIx(Series<CX, dynamic> other,
          [JoinType how = JoinType.LeftJoin, RX newRowIx]) =>
      transpose().joinAnySPreserveColIx(other, how, newRowIx).transpose();

  /**
   * See joinAny; operates row-wise
   */
  Frame<int, CX, dynamic> rjoinAny(Frame<dynamic, CX, dynamic> other,
          [JoinType how = JoinType.LeftJoin]) =>
      transpose().joinAny(other.transpose(), how).transpose();

  /**
   * See joinAnyPreserveColIx; operates row-wise
   */
  Frame<RX, CX, dynamic> rjoinAnyPreserveRowIx(Frame<RX, CX, dynamic> other,
          [JoinType how = JoinType.LeftJoin]) =>
      transpose().joinAnyPreserveColIx(other.transpose(), how).transpose();

  /**
   * See dropNA; operates row-wise
   */
  Frame<RX, CX, T> rdropNA() => rfilter((v) => !v.hasNA);

  /**
   * See squeeze; operates row-wise
   */
  Frame<RX, CX, T> rsqueeze() => rfilter((s) => !VecImpl.isAllNA(s.toVec()));

  // todo: describe

  // --------------------------------------
  // for iterating over rows/cols/elements

  /**
   * Produce an indexed sequence of pairs of row index value and
   * row Series
   */
  Iterable<FramePair<RX, CX, T>> /*[(RX, Series<CX, T>)]*/ toRowSeq() {
    return array.range(0, numRows).map((i) {
      return new FramePair._(rowIx.raw(i), rowAt(i));
    });
  }

  /**
   * Produce an indexed sequence of pairs of column index value and
   * column Series.
   */
  Iterable<FramePair<CX, RX, T>> /*[(CX, Series<RX, T>)]*/ toColSeq() {
    return array.range(0, numCols).map((i) {
      return new FramePair._(colIx.raw(i), colAt(i));
    });
  }

  /**
   * Produce an indexed sequence of triples of values in the Frame
   * in row-major order.
   */
  Iterable<FrameTriple<RX, CX, T>> /*[(RX, CX, T)]*/ toSeq() {
    return util.flatten(zip([range(0, numRows), rowIx.toSeq()]).map((z) {
      var i = z[0], rx = z[1];
      return rowAt(i).toSeq().map((tup) {
        var cx = tup.value1, t = tup.value2;
        return new FrameTriple._(rx, cx, t);
      });
    }));
  }

  // ------------------------------------------------------
  // internal contiguous caching of row data for efficiency

  /*private*/ Frame<RX, CX, T> withMat(/*Option<*/ Mat<T> m) {
    cachedMat = m;
    return this;
  }

  /*private*/ MatCols<T> rows() {
    if (cachedRows == null) {
      cachedRows = toMat().rows();
    }
    return cachedRows; //.get;
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
    var buf = new StringBuffer();

    if (numCols == 0 || numRows == 0) {
      buf.write("Empty Frame");
    } else {
      buf.write("[$numRows x $numCols]\n");

      var rhalf = nrows ~/ 2;

      maxf(List<int> a, List<String> b) =>
          zip([a, b]).map((v) => math.max(v[0], v[1].length));

      // calc row index width
      var rsca = rowIx.scalarTag;
      var rarr = rowIx.toArray_();
      var rinit = rsca.strList(rarr(0)).map((s) => s.length);
      var rlens = util.grab(rarr, rhalf).map(rsca.strList).fold(rinit, maxf);
      var maxrl = rlens.sum + (rlens.length - 1);

      // calc each col str width
      var clens = MatCols.colLens(values, numCols, ncols);

      var csca = colIx.scalarTag;
      clen(int c) {
        var lst = csca.strList(colIx.raw(c)).map((x) => x.length);
        return math.max(clens[c], lst.length > 0 ? lst.reduce(math.max) : 0);
      }

      // recalls whether we printed a column's label at level L-1
      var prevColMask = new Map.fromIterable(clens.keys, value: (_) => false);
      String prevColLabel = ""; // recalls previous column's label at level L

      // build columns header
      createColHeader(int l) => (int c) {
            var labs = csca.strList(colIx.raw(c));
            String currLab = labs(l);

            var res;
            if (l == labs.length - 1 ||
                currLab != prevColLabel ||
                (prevColMask[c] ?? false)) {
              prevColMask[c] = true;
              res = "$currLab ".padLeft(clen(c));
            } else {
              prevColMask[c] = false;
              res = " ".padLeft(clen(c));
            }
            prevColLabel = currLab;
            return res;
          };

      colBreakStr() {
        prevColLabel = "";
        return " " * 5;
      }

      var spacer = " " * (maxrl + 4);

      var sz = colIx.scalarTag.strList(colIx.raw(0)).length;
      for (var i in range(sz)) {
        buf.write(spacer);
        buf.write(
            util.buildStr(ncols, numCols, createColHeader(i), colBreakStr));
        buf.write("\n");
      }

      createColDivide(int c) => "-" * clen(c) + " ";

      buf.write(spacer);
      buf.write(util.buildStr(ncols, numCols, createColDivide));
      buf.write("\n");

      // for building row labels
      List<util.Tuple3> /*[(Int, A, B)]*/ enumZip /*[A, B]*/ (List a, List b) {
        return zip([enumerate(a), b]).map((l) {
          IndexedValue iv = l[0];
          return new util.Tuple3(iv.index, iv.value, l[1]);
        }).toList();
      }

      var prevRowLabels = new List.generate(
          rowIx.scalarTag.strList(rowIx.raw(0)).length, (_) => "");
      resetRowLabels(int k) {
        for (var i in range(k, prevRowLabels.length)) {
          prevRowLabels[i] = "";
        }
      }

      createIx(int r) {
        var vls = rsca.strList(rowIx.raw(r));
        var lst = enumZip(rlens, vls).map((tup) {
          int i = tup.value1, l = tup.value2;
          String v = tup.value3;
          String res;
          if (i == vls.length - 1 || prevRowLabels(i) != v) {
            resetRowLabels(i + 1);
            res = v.padLeft(l);
          } else {
            res = "".padLeft(l);
          }
          prevRowLabels[i] = v;
          return res;
        }).toList();
        return lst.join(" ");
      }

      // for building frame entries
      String createVals(int r) {
        var elem = (int col) => values[col]
            .scalarTag
            .show(values.apply_(r, col))
            .padLeft(clen(col));
        return util.buildStr(ncols, numCols, elem) + "\n";
      }

      String rowBreakStr() {
        resetRowLabels(0);
        return "...\n";
      }

      // now build row strings
      buf.write(util.buildStr(nrows, numRows,
          (int r) => createIx(r) + " -> " + createVals(r), rowBreakStr));
    }
    return buf.toString();
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
      values.hashCode * 31 * 31 + rowIx.hashCode * 31 + colIx.hashCode;

  @override
  bool operator ==(other) {
    if (other is Frame) {
      var f = other as Frame;
      if (identical(this, f)) {
        return true;
      } else if (rowIx == f.rowIx && colIx == f.colIx && values == f.values) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
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
  factory Frame.empty(
          ScalarTag<RX> srx,
          ScalarTag<CX> scx,
          ScalarTag<
              T> st) /*[RX: ST: ORD, CX: ST: ORD, T: ST]: Frame<RX, CX, T>*/ =>
      new Frame<RX, CX, T>(new MatCols<T>.empty(st), new Index<RX>.empty(srx),
          new Index<CX>.empty(scx));

  // --------------------------------
  // Construct using sequence of vectors

  /**
   * Factory method to create a Frame from a sequence of Vec objects
   */
  /*Frame<int, int, T>*/ factory Frame.fromVecs(
      Iterable<Vec<T>> values, ScalarTag<T> st) {
    if (values.isEmpty) {
      return new Frame.empty(
          ScalarTag.stInt, ScalarTag.stInt, st); //[Int, Int, T]
    } else {
      var asIdxSeq = values; //.toIndexedSeq();
      return new Frame(asIdxSeq, new IndexIntRange(asIdxSeq(0).length),
          new IndexIntRange(asIdxSeq.length));
    }
  }

  /**
   * Factory method to create a Frame from a sequence of Vec objects,
   * a row index, and a column index.
   */
  factory Frame.vecsIndex(Iterable<Vec<T>> values, Index<RX> rowIx,
      Index<CX> colIx, ScalarTag<T> st) {
    if (values.isEmpty) {
      return new Frame.empty(
          rowIx.scalarTag, colIx.scalarTag, st); //[RX, CX, T];
    } else {
      return new Frame<RX, CX, T>(
          new MatCols<T>(values /*: _**/, st), rowIx, colIx);
    }
  }

  /**
   * Factory method to create a Frame from a sequence of Vec objects
   * and a column index.
   */
  factory Frame.column /*[CX: ST: ORD, T: ST]*/ (
      Iterable<Vec<T>> values, Index<CX> colIx, ScalarTag<T> st) {
    if (values.isEmpty) {
      return new Frame.empty(
          ScalarTag.stInt, colIx.scalarTag, st); //[Int, CX, T];
    } else {
      var asIdxSeq = values; //.toIndexedSeq();
      return new Frame(asIdxSeq, new IndexIntRange(asIdxSeq(0).length), colIx);
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
      Iterable<Series<RX, T>> values, ScalarTag srx, ScalarTag st) {
    var asIdxSeq = values; //.toIndexedSeq;
    switch (asIdxSeq.length) {
      case 0:
        return new Frame.empty(srx, ScalarTag.stInt, st); //[RX, Int, T]
      case 1:
        return new Frame(asIdxSeq.map((i) => i.values), asIdxSeq(0).index,
            new IndexIntRange(1));
      default:
        var init = new Frame(
            /*new IndexedSeq(*/ asIdxSeq(0).values,
            asIdxSeq(0).index,
            []);
        var temp =
            asIdxSeq.tail.fold(init, (a, b) => a.joinS(b, JoinType.OuterJoin));
        return new Frame(
            temp.values, temp.rowIx, new IndexIntRange(temp.numCols));
    }
  }

  /**
   * Factory method to create a Frame from a sequence of series, also specifying
   * the column index to use. The row labels of the result are the outer join of
   * the indexes of the series provided.
   */
  factory Frame.seriesCol /*[RX: ST: ORD, CX: ST: ORD, T: ST]*/ (
      Iterable<Series<RX, T>> values,
      Index<CX> colIx,
      ScalarTag srx,
      ScalarTag st) /*: Frame<RX, CX, T>*/ {
    var asIdxSeq = values; //.toIndexedSeq();
    switch (asIdxSeq.length) {
      case 0:
        return new Frame.empty(srx, colIx.scalarTag, st); //[RX, CX, T]
      case 1:
        return new Frame(
            asIdxSeq.map((i) => i.values), asIdxSeq(0).index, colIx);
      default:
        var init = new Frame(
            /*Seq(*/ asIdxSeq(0).values,
            asIdxSeq(0).index,
            new Index(0));
        var temp =
            values.tail.fold(init, (a, b) => a.joinS(b, JoinType.OuterJoin));
        return new Frame(temp.values, temp.rowIx, colIx);
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
  static Frame<int, int, dynamic> fromMat(Mat<T> values) => new Frame(values,
      new IndexIntRange(values.numRows), new IndexIntRange(values.numCols));

  /**
   * Build a Frame from a provided Mat, row index, and col index
   */
  static frameFromMatIndex /*[RX: ST: ORD, CX: ST: ORD, T: ST]*/ (
      Mat /*<T>*/ mat, Index /*<RX>*/ rowIx, Index /*<CX>*/ colIx) {
    if (mat.length == 0) {
      return new Frame.empty(
          rowIx.scalarTag, colIx.scalarTag, mat.scalarTag); //[RX, CX, T]
    } else {
      return new Frame /*<RX, CX, T>*/ (mat.cols(), rowIx, colIx)
          .withMat(/*Some(*/ mat);
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
  static Frame /*<RX, CX, Any>*/ empty(ScalarTag srx, ScalarTag scx,
          ScalarTag st) /*[RX: ST: ORD, CX: ST: ORD]*/ =>
      new Frame /*<RX, CX, Any>*/ (
          new MatCols.empty(st), new Index.empty(srx), new Index.empty(scx));

  // --------------------------------
  // Construct using sequence of vectors

  /**
   * Factory method to create a Frame from a sequence of Vec objects
   */
  static Frame /*<int, int, Any>*/ fromVecs(Iterable<Vec> /*Vec[_]**/ values) {
    if (values.isEmpty) {
      return empty(
          ScalarTag.stInt, ScalarTag.stInt, ScalarTag.stAny); //[Int, Int]
    } else {
      var asIdxSeq = values; //.toIndexedSeq();
      return apply(asIdxSeq, new IndexIntRange(asIdxSeq(0).length),
          new IndexIntRange(asIdxSeq.length));
    }
  }

  /**
   * Factory method to create a Frame from a sequence of Vec objects,
   * a row index, and a column index.
   */
  static Frame /*[RX, CX, Any]*/ vecsIndex /*[RX: ST: ORD, CX: ST: ORD]*/ (
      Iterable<Vec /*[_]*/ > values,
      Index /*<RX>*/ rowIx,
      Index /*<CX>*/ colIx) {
    var anySeq = values; //.toIndexedSeq();
    if (values.isEmpty) {
      return empty(
          rowIx.scalarTag, colIx.scalarTag, ScalarTag.stAny); //[RX, CX]
    } else {
      return new Frame(toSeqVec(anySeq), rowIx, colIx);
    }
  }

  /**
   * Factory method to create a Frame from a sequence of Vec objects
   * and a column index.
   */
  static Frame /*[Int, CX, Any]*/ vecCol /*[CX: ST: ORD]*/ (
      Iterable<Vec /*[_]*/ > values, Index /*<CX>*/ colIx) {
    if (values.isEmpty) {
      return empty(
          ScalarTag.stInt, colIx.scalarTag, ScalarTag.stAny); //[Int, CX]
    } else {
      var asIdxSeq = values; //.toIndexedSeq();
      return new Frame(asIdxSeq, new IndexIntRange(asIdxSeq(0).length), colIx);
    }
  }

  static /*private IndexedSeq*/ Iterable<Vec /*<Any>*/ > toSeqVec(
          Iterable<Vec /*[_]*/ > anySeq) =>
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

  static /*private*/ toSeqSeries /*[RX]*/ (
          Iterable<Series /*[RX, _]*/ > anySeq) =>
      anySeq.toIndexedSeq.asInstanceOf[IndexedSeq[Series /*[RX, Any]*/]];

  /**
   * Factory method to create a Frame from a sequence of Series. The row labels
   * of the result are the outer join of the indexes of the series provided.
   */
  static Frame /*[RX, Int, Any]*/ fromSeries /*[RX: ST: ORD]*/ (
      Iterable<Series /*[RX, _]**/ > values, ScalarTag srx) {
    var asIdxSeq = toSeqSeries(values);
    switch (asIdxSeq.length) {
      case 0:
        return empty(srx, ScalarTag.stInt, ScalarTag.stAny); //[RX, Int]
      case 1:
        return new Frame(asIdxSeq.map((i) => i.values), asIdxSeq(0).index,
            new IndexIntRange(1));
      default:
        var init =
            new Frame(/*Seq(*/ asIdxSeq(0).values, asIdxSeq(0).index, [0]);
        var temp = asIdxSeq.tail
            .foldLeft(init, (a, b) => a.joinS(b, JoinType.OuterJoin));
        return Frame(temp.values, temp.rowIx, new IndexIntRange(temp.numCols));
    }
  }

  /**
   * Factory method to create a Frame from a sequence of series, also specifying
   * the column index to use. The row labels of the result are the outer join of
   * the indexes of the series provided.
   */
  static Frame /*[RX, CX, Any]*/ seriesCol /*[RX: ST: ORD, CX: ST: ORD]*/ (
      Iterable<Series /*[RX, _]*/ > values,
      Index /*<CX>*/ colIx,
      ScalarTag srx) {
    var asIdxSeq = toSeqSeries(values);
    switch (asIdxSeq.length) {
      case 0:
        return empty(colIx.scalarTag, srx, ScalarTag.stAny); //[RX, CX]
      case 1:
        return new Frame(
            asIdxSeq.map((i) => i.values), asIdxSeq(0).index, colIx);
      default:
        var init = new Frame(
            /*Seq(*/ asIdxSeq(0).values,
            asIdxSeq(0).index,
            new Index(0));
        var temp = asIdxSeq.tail
            .foldLeft(init, (a, b) => a.joinS(b, JoinType.OuterJoin));
        return new Frame(temp.values, temp.rowIx, colIx);
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

class SplitFrame<RX, CX, T> {
  final Frame<RX, CX, T> left, right;
  SplitFrame._(this.left, this.right);
}

class AlignedFrame<RX, CX, T, U> {
  final Frame<RX, CX, T> left;
  final Frame<RX, CX, U> right;
  AlignedFrame._(this.left, this.right);
}

class FramePair<A, B, T> {
  final A index;
  final Series<B, T> value;
  FramePair._(this.index, this.value);
}

class FrameTriple<RX, CX, T> {
  final RX row;
  final CX col;
  final T value;
  FrameTriple._(this.row, this.col, this.value);
}
