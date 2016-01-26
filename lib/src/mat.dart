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

import 'dart:math' as math;
import 'package:quiver/iterables.dart' show range;

//import 'mat/mat.dart';
import 'scalar/scalar.dart' show Scalar;
import 'scalar/scalar_tag.dart' show ScalarTag;
//import 'ops/ops.dart' show BinOpMat, NumericOps;
//import scala.{specialized => spec}
//import java.io.OutputStream
//import 'index.dart' show IndexIntRange, Slice;
import 'index/slice.dart' show Slice;
import 'vec.dart';
import 'util/util.dart' as util;

/**
 * `Mat` is an immutable container for 2D homogeneous data (a "matrix"). It is
 * backed by a single array. Data is stored in row-major order.
 *
 * Several element access methods are provided.
 *
 * The `at` method returns an instance of a [[org.saddle.scalar.Scalar]], which behaves
 * much like an `Option` in that it can be either an instance of [[org.saddle.scalar.NA]]
 * or a [[org.saddle.scalar.Value]] case class:
 *
 * {{{
 *   val m = Mat(2,2,Array(1,2,3,4))
 *   m.at(0,0) == Value(1)
 * }}}
 *
 * The method `raw` accesses the underlying value directly.
 *
 * {{{
 *   val m = Mat(2,2,Array(1,2,3,4))
 *   m.raw(0,0) == 1d
 * }}}
 *
 * `Mat` may be used in arithemetic expressions which operate on two `Mat`s or on a
 * `Mat` and a primitive value. A fe examples:
 *
 * {{{
 *   val m = Mat(2,2,Array(1,2,3,4))
 *   m * m == Mat(2,2,Array(1,4,9,16))
 *   m dot m == Mat(2,2,Array(7d,10,15,22))
 *   m * 3 == Mat(2, 2, Array(3,6,9,12))
 * }}}
 *
 * Note, Mat is generally compatible with EJML's DenseMatrix. It may be convenient
 * to induce this conversion to do more complex linear algebra, or to work with a
 * mutable data structure.
 *
 * @tparam A Type of elements within the Mat
 */
abstract class Mat<
    A> /*[@spec(Boolean, Int, Long, Double)*/ /*extends NumericOps<Mat<A>>
    with Serializable*/
{
  ScalarTag<A> scalarTag;

  /**
   * Returns number of rows in the matrix shape
   *
   */
  int numRows;

  /**
   * Returns number of columns in the matrix shape
   *
   */
  int numCols;

  /**
   * Returns total number of entries in the matrix
   *
   */
  int get length => numRows * numCols;

  /**
   * Returns true if rows == cols
   *
   */
  bool get isSquare => numCols == numRows;

  /**
   * Returns true if the matrix is empty
   *
   */
  bool get isEmpty => length == 0;

  /**
   * Return unboxed value of matrix at an offset from zero in row-major order
   *
   * @param i index
   */
  A rawFlat(int i) => applyFlat_(i);

  /**
   * Return unboxed value of matrix at row/column
   *
   * @param r row index
   * @param c col index
   */
  A raw(int r, int c) => apply_(r, c);

  /**
   * Return scalar value of matrix at offset from zero in row-major order
   *
   * @param i index
   */
  Scalar<A> atFlat(int i) /*(implicit st: ScalarTag[A])*/ {
    return new Scalar(rawFlat(i), scalarTag);
  }

  /**
   * Return scalar value of Mat at at row/column
   * @param r row index
   * @param c col index
   */
  Scalar<A> at(int r, int c) /*(implicit st: ScalarTag[A])*/ {
    return new Scalar(raw(r, c), scalarTag);
  }

  /**
   * Access a slice of the Mat by integer offsets
   * @param r Array of row offsets
   * @param c Array of col offsets
   */
  Mat<A> atTake(List<int> r, List<int> c) /*(implicit st: ScalarTag[A])*/ {
    return rowTake(r).colTake(c);
  }

  /**
   * Access a slice of the Mat by integer offsets
   * @param r Array of row offsets
   * @param c Integer col offset
   */
  Vec<A> atCol(List<int> r, int c) /*(implicit st: ScalarTag[A])*/ {
    return rowTake(r).col(c);
  }

  /**
   * Access a slice of the Mat by integer offsets
   * @param r Integer row offset
   * @param c Array of col offsets
   */
  Vec<A> atRow(int r, List<int> c) /*(implicit st: ScalarTag[A])*/ {
    return colTake(c).row(r);
  }

  /**
   * Access a slice of the Mat by Slice parameters
   * @param r Slice to apply to rows
   * @param c Slice to apply to cols
   */
  Mat<A> atSlice(Slice<int> r, Slice<int> c) /*(implicit st: ScalarTag[A])*/ =>
      rowSlice(r).colSlice(c);

  /**
   * Returns (a copy of) the contents of matrix as a single array in
   * row-major order
   *
   */
  List<A> get contents => toVec().toArray();

  // Must implement specialized methods using non-specialized subclasses as workaround to
  // https://issues.scala-lang.org/browse/SI-5281

  /**
   * Maps a function over each element in the matrix
   */
  Mat map /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (dynamic f(arg));

  /**
   * Changes the shape of matrix without changing the underlying data
   */
  Mat<A> reshape(int r, int c);

  /**
   * Transpose of original matrix
   */
  Mat<A> transpose();

  /**
   * Transpose of original matrix
   */
  Mat<A> get T => transpose();

  /**
   * Create Mat comprised of same values in specified rows
   */
  Mat<A> takeRows(List<int> locs);

  /**
   * Create Mat comprised of same values in specified rows
   */
//  def takeRows(locs: Int*): Mat[A] = takeRows(locs.toArray)

  /**
   * Create Mat comprised of same values in specified columns
   */
  Mat<A> takeCols(List<int> locs) => T.takeRows(locs).T;

  /**
   * Create Mat comprised of same values in specified columns
   */
//  def takeCols(locs: Int*): Mat[A] = takeCols(locs.toArray)

  /**
   * Create Mat comprised of same values without the specified rows
   *
   * @param locs Row locations to exclude
   */
  Mat<A> withoutRows(List<int> locs);

  /**
   * Create Mat comprised of same values without the specified rows
   *
   * @param locs Row locations to exclude
   */
//  def withoutRows(locs: Int*): Mat[A] = withoutRows(locs.toArray)

  /**
   * Create Mat comprised of same values without the specified columns
   *
   * @param locs Col locations to exclude
   */
  Mat<A> withoutCols(List<int> locs) => T.withoutRows(locs).T;

  /**
   * Create Mat comprised of same values without the specified columns
   *
   * @param locs Col locations to exclude
   */
//  def withoutCols(locs: Int*): Mat[A] = withoutCols(locs.toArray)

  /**
   * Yields row indices where row has some NA value
   */
  Set<int> rowsWithNA(/*implicit ST<A> ev*/) {
    var builder = new Set<int>(); //.newBuilder[Int];
    var i = 0;
    while (i < numRows) {
      if (row(i).hasNA) builder.add(i);
      i += 1;
    }
    return builder;
  }

  /**
   * Yields column indices where column has some NA value
   */
  Set<int> colsWithNA(/*implicit ST<A> ev*/) => T.rowsWithNA();

  /**
   * Yields a matrix without those rows that have NA
   */
  Mat<A> dropRowsWithNA(/*implicit ST<A> ev*/) =>
      withoutRows(rowsWithNA().toList());

  /**
   * Yields a matrix without those cols that have NA
   */
  Mat<A> dropColsWithNA(/*implicit ST<A> ev*/) =>
      withoutCols(colsWithNA().toList());

  /**
   * Returns a specific column of the Mat as a Vec
   *
   * @param c Column index
   */
  Vec<A> col(int c) /*(implicit ev: ST<A>)*/ {
//    assert(c >= 0 && c < numCols, "Array index %d out of bounds" format c);
    return flattenT().slice(c * numRows, (c + 1) * numRows);
  }

  /**
   * Access Mat columns at a particular integer offsets
   * @param locs a sequence of integer offsets
   */
//  Mat<A> col(int* locs)(implicit ev: ST<A>): Mat[A] = takeCols(locs.toArray)

  /**
   * Access Mat columns at a particular integer offsets
   * @param locs an array of integer offsets
   */
  Mat<A> colTake(List<int> locs) /*(implicit ev: ST<A>)*/ => takeCols(locs);

  /**
   * Access mat columns specified by a slice
   * @param slice a slice specifier
   */
  Mat<A> colSlice(Slice<int> slice) {
    var res = slice(new IndexIntRange(numCols));
    return takeCols(range(res[0], res[1]).toList());
  }

  /**
   * Returns columns of Mat as an indexed sequence of Vec instances
   */
  Iterable<Vec<A>> cols() /*(implicit ev: ST<A>)*/ =>
      range(0, numCols).map(col);

  /**
   * Returns columns of Mat as an indexed sequence of Vec instances
   */
  Iterable<Vec<A>> colsTake(Iterable<int> seq) /*(implicit ev: ST<A>)*/ =>
      seq.map(col); // _);

  /**
   * Returns a specific row of the Mat as a Vec
   *
   * @param r Row index
   */
  Vec<A> row(int r) /*(implicit ev: ST<A>)*/ {
    if (r < 0 || r >= numRows) {
      throw new ArgumentError("Array index $r out of bounds");
    }
    return flatten().slice(r * numCols, (r + 1) * numCols);
  }

  /**
   * Access Mat rows at a particular integer offsets
   * @param locs a sequence of integer offsets
   */
//  Mat<A> row(int* locs)(implicit ev: ST<A>): Mat[A] = takeRows(locs.toArray)

  /**
   * Access Mat rows at a particular integer offsets
   * @param locs an array of integer offsets
   */
  Mat<A> rowTake(List<int> locs) /*(implicit ev: ST<A>)*/ => takeRows(locs);

  /**
   * Access Mat rows specified by a slice
   * @param slice a slice specifier
   */
  Mat<A> rowSlice(Slice<int> slice) {
    var res = slice(new IndexIntRange(numCols));
    return takeRows(range(res[0], res[1]).toList());
  }

  /**
   * Returns rows of matrix as an indexed sequence of Vec instances
   */
  Iterable<Vec<A>> rows() /*(implicit ev: ST<A>)*/ =>
      range(0, numRows).map(row);

  /**
   * Returns rows of matrix as an indexed sequence of Vec instances
   */
  Iterable<Vec<A>> rowsTake(Iterable<int> seq) /*(implicit ev: ST<A>)*/ =>
      seq.map(row); // _)

  /**
   * Multiplies this matrix against another
   *
   */
  Mat<double> mult /*[B]*/ (
      Mat /*<B>*/ m) /*(implicit evA: NUM[A], evB: NUM[B])*/ {
    if (numCols != m.numRows) {
      var errMsg =
          "Cannot multiply ($numRows $numCols) x (${m.numRows} ${m.numCols})";
      throw new ArgumentError(errMsg);
    }

    return MatMath.mult(this, m);
  }

  /**
   * Rounds elements in the matrix (which must be numeric) to
   * a significance level
   *
   * @param sig Significance level to round to (e.g., 2 decimal places)
   */
  Mat<double> roundTo([int sig = 2]) /*(implicit ev: NUM[A])*/ {
    var pwr = math.pow(10, sig);
    rounder(x) => (scalarTag.toDouble(x) * pwr).round() / pwr;
    return map(rounder);
  }

  /**
   * Concatenate all rows into a single row-wise Vec instance
   */
  Vec<A> toVec();

  /*private Option<*/ Vec<A> flatCache = null;

  /*private*/ Vec<A> flatten(/*implicit ST<A> st*/) {
    if (flatCache == null) {
      flatCache = toVec();
    }
    return flatCache;
  }

  /*private Option<*/ Vec<A> flatCacheT = null;

  /*private*/ Vec<A> flattenT(/*implicit ST<A> st*/) {
    if (flatCacheT == null) {
      flatCacheT = T.toVec();
    }
    return flatCacheT;
  }

  // access like vector in row-major order
  /*private[saddle]*/ A applyFlat_(int i);

  // implement access like matrix(i, j)
  /*private[saddle]*/ A apply_(int r, int c);

  // use with caution, may not return copy
  /*private[saddle]*/ List<A> toArray_();

  // use with caution, may not return copy
  /*private[saddle]*/ List<double> toDoubleArray_(/*implicit NUM<A> ev*/);

  /**
   * Creates a string representation of Mat
   * @param nrows Max number of rows to include
   * @param ncols Max number of cols to include
   */
  String stringify([int nrows = 8, int ncols = 8]) {
    var halfr = nrows ~/ 2;
    var halfc = ncols ~/ 2;

    var buf = new StringBuffer();
    buf.write("[$numRows x $numCols]\n");

    /*implicit*/ var st = scalarTag;

    maxStrLen(int a, String b) => math.max(a, b.length);
    maxColLen(Vec<A> c) => c
        .head(halfr)
        .concat(c.tail(halfr))
        .map(scalarTag.show, st)
        .foldLeft(0, maxStrLen);
    var colIdx = util.grab(range(0, numCols), halfc);
    var lenSeq = colIdx.map((c) => range(c, maxColLen(col(c))));
    Map lenMap; // = lenSeq.toMap.withDefault(_ => 1);

    // function to build a row
    createRow(int r) {
      var buf = new StringBuffer();
      strFn(int col) {
        var l = lenMap[col];
//        return "%${ l > 0 ? l : 1 }s " scalarTag.show(apply_(r, col));
        return "${scalarTag.show(apply_(r, col))} ";
      }
      buf.write(util.buildStr(ncols, numCols, strFn));
      buf.write("\n");
      return buf.toString();
    }

    // build all rows
    buf.write(util.buildStr(nrows, numRows, createRow, () => "...\n"));
    return buf.toString();
  }

  @override
  String toString() => stringify();

  /**
   * Pretty-printer for Mat, which simply outputs the result of stringify.
   * @param nrows Number of elements to display
   */
//  print([int nrows = 8, int ncols = 8, OutputStream stream = System.out]) {
//    stream.write(stringify(nrows, ncols).getBytes);
//  }

  /** Default hashcode is simple rolling prime multiplication of sums of hashcodes for all values. */
  @override
  int get hashCode => toVec().foldLeft(1, (a, b) => a * 31 + b.hashCode);

  /**
   * Row-by-row equality check of all values.
   * NB: to avoid boxing, overwrite in child classes
   */
  @override
  bool operator ==(o) {
    if (o is Mat) {
      var rv = o as Mat;
      if (identical(this, rv)) {
        return true;
      } else if (numRows != rv.numRows || numCols != rv.numCols) {
        return false;
      } else {
        var i = 0;
        bool eq = true;
        while (eq && i < length) {
          eq = eq &&
              (applyFlat_(i) == rv.applyFlat_(i) ||
                  this.scalarTag.isMissing(applyFlat_(i)) &&
                      rv.scalarTag.isMissing(rv.applyFlat_(i)));
          i += 1;
        }
        return eq;
      }
    } else {
      return false;
    }
  }
//}

//class Mat extends BinOpMat {

  /**
   * Factory method to create a new Mat from raw materials
   * @param rows Number of rows in Mat
   * @param cols Number of cols in Mat
   * @param arr A 1D array of backing data in row-major order
   * @tparam T Type of data in array
   */
  factory Mat(int rows, int cols, List<A> arr,
      ScalarTag<A> st) /*(implicit st: ST[T])*/ {
    var r = (rows == 0 || cols == 0) ? 0 : rows;
    var c = (rows == 0 || cols == 0) ? 0 : rows;
    var a = (rows == 0 || cols == 0) ? [] : arr;
    return st.makeMat(r, c, a);
  }

  /**
   * Allows implicit promoting from a Mat to a Frame instance
   * @param m Mat instance
   * @tparam T The type of elements in Mat
   */
//  implicit def matToFrame[T: ST](m: Mat[T]) = Frame(m)

  /**
   * Factory method to create an empty Mat
   * @tparam T Type of Mat
   */
  factory Mat.empty /*[T: ST]*/ (ScalarTag<A> st) => new Mat<A>(0, 0, [], st);

  /**
   * Factory method to create an zero Mat (all zeros)
   * @param numRows Number of rows in Mat
   * @param numCols Number of cols in Mat
   * @tparam T Type of elements in Mat
   */
  factory Mat /*[T: ST]*/ .zero(int numRows, int numCols, ScalarTag<A> st) =>
      new Mat<A>(numRows, numCols, new List<A>(numRows * numCols), st);

  /**
   * Factory method to create a Mat from an array of arrays. Each inner array
   * will become a column of the new Mat instance.
   * @param values Array of arrays, each of which is to be a column
   * @tparam T Type of elements in inner array
   */
  factory Mat /*[T: ST]*/ .fromList(List<List<A>> values, ScalarTag<A> st) =>
      st.makeMatFromVecs(values.map((a) => new Vec(a, st)), st);

  /**
   * Factory method to create a Mat from an array of Vec. Each inner Vec
   * will become a column of the new Mat instance.
   * @param values Array of Vec, each of which is to be a column
   * @tparam T Type of elements in Vec
   */
  factory Mat.fromVecs /*[T: ST]*/ (List<Vec<A>> values, ScalarTag<A> st) =>
      st.makeMatFromVecs(values, st);

  /**
   * Factory method to create a Mat from a sequence of Vec. Each inner Vec
   * will become a column of the new Mat instance.
   * @param values Sequence of Vec, each of which is to be a column
   * @tparam T Type of elements in array
   */
//  def apply[T: ST](values: Vec[T]*): Mat[T] = implicitly[ST[T]].makeMat(values.toArray)

  /**
   * Factory method to create an identity matrix; ie with ones along the
   * diagonal and zeros off-diagonal.
   * @param n The width of the square matrix
   */
  static Mat<double> ident(int n) => mat.ident(n);
}
