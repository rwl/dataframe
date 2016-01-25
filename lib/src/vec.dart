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

library saddle.vec;

// import scala.{specialized => spec}

import 'dart:math' as math;
import 'dart:collection';

import 'vec/vec.dart';
import 'index/index.dart';
import 'ops/ops.dart';
import 'scalar/scalar.dart';
//import 'util/concat.dart' show Promoter;
import 'util/util.dart' as util;

import 'scalar/scalar_tag.dart';
import 'stats/vec_stats.dart';
import 'vec/vec_impl.dart';
import 'array/array.dart';

// import java.io.OutputStream

/**
 * `Vec` is an immutable container for 1D homogeneous data (a "vector"). It is
 * backed by an array and indexed from 0 to length - 1.
 *
 * Several element access methods are provided.
 *
 * The `apply()` method returns a slice of the original vector:
 *
 * {{{
 *   val v = Vec(1,2,3,4)
 *   v(0) == Vec(1)
 *   v(1, 2) == Vec(2,3)
 * }}}
 *
 * The `at` method returns an instance of a [[org.saddle.scalar.Scalar]], which behaves
 * much like an `Option` in that it can be either an instance of [[org.saddle.scalar.NA]]
 * or a [[org.saddle.scalar.Value]] case class:
 *
 * {{{
 *   Vec[Int](1,2,3,na).at(0) == Scalar(1)
 *   Vec[Int](1,2,3,na).at(3) == NA
 * }}}
 *
 *
 * The method `raw` accesses the underlying value directly.
 *
 * {{{
 *   Vec(1d,2,3).raw(0) == 1d
 * }}}
 *
 * `Vec` may be used in arithemetic expressions which operate on two `Vec`s or on a
 * `Vec` and a scalar value. A few examples:
 *
 * {{{
 *   Vec(1,2,3,4) + Vec(2,3,4,5) == Vec(3,5,7,9)
 *   Vec(1,2,3,4) * 2 == Vec(2,4,6,8)
 * }}}
 *
 * Note, Vec is implicitly convertible to an array for convenience; this could be
 * abused to mutate the contents of the Vec. Try to avoid this!
 *
 * @tparam T Type of elements within the Vec
 */
abstract class Vec<
    T> /*Boolean, Int, Long, Double*/ /*extends NumericOps<Vec<T>> with Serializable*/ //extends ListBase<T>
//    extends Object with VecStats<T>
{
//  void set length(int newLength) { l.length = newLength; }
//  int get length => l.length;
  T operator [](int index) => raw(index);
//  void operator []=(int index, T value) { l[index] = value; }

  /**
   * The number of elements in the container                                                  F
   */
  int length;

  /**
   * A ScalarTag in the type of the elements of the Vec
   */
  ScalarTag<T> scalarTag;

  /**
   * Danger - could expose internal NA's
   *
   * Access an element by location. This is made private because the internal
   * representation might contain primitive NA's that need to be boxed so that
   * they aren't utilized unknowingly in calculations.
   */
  /*private[saddle]*/ T apply_(int loc);

  /**
   * Set to true when the vec is shifted over the backing array
   */
  /*protected*/ bool needsCopy = false;

  // ----------
  // get values

  /**
   * Access a boxed element of a Vec[A] at a single location
   * @param loc offset into Vec
   */
  Scalar<T> at(int loc) {
    /*implicit*/ var st = scalarTag;
    return new Scalar(apply_(loc), st);
  }

  /**
   * Access an unboxed element of a Vec[A] at a single location
   * @param loc offset into Vec
   */
  T raw(int loc) => apply_(loc);

  /**
   * Slice a Vec at a sequence of locations, e.g.
   *
   * val v = Vec(1,2,3,4,5)
   * v(1,3) == Vec(2,4)
   *
   * @param locs locations at which to slice
   */
  // Vec<T> apply(int* locs) => take(locs.toArray)

  /**
   * Slice a Vec at a sequence of locations, e.g.
   *
   * val v = Vec(1,2,3,4,5)
   * v(Array(1,3)) == Vec(2,4)
   *
   * @param locs locations at which to slice
   */
  Vec<T> apply(List<int> locs) => take(locs);

  /**
   * Slice a Vec at a bound of locations, e.g.
   *
   * val v = Vec(1,2,3,4,5)
   * v(1->3) == Vec(2,3,4)
   *
   * @param rng evaluates to IRange
   */
//  Vec<T> apply(Slice<int> rng) {
//    val idx  = new IndexIntRange(length);
//    val pair = rng(idx);
//    slice(pair._1, pair._2);
//  }

  /**
   * Access the first element of a Vec[A], or NA if length is zero
   */
  Scalar<T> get first {
    /*implicit*/ var st = scalarTag;
    return length > 0 ? new Scalar(apply_(0), st) : NA;
  }

  /**
   * Access the last element of a Vec[A], or NA if length is zero
   */
  Scalar<T> get last {
    /*implicit*/ var st = scalarTag;
    return length > 0 ? new Scalar(apply_(length - 1), st) : NA;
  }

  // ----------

  /**
   * Return copy of backing array
   */
  List<T> get contents => copy().toArray();

  /**
   * Return first n elements
   * @param n Number of elements to access
   */
  Vec<T> head(int n) => slice(0, n);

  /**
   * Return last n elements
   * @param n Number of elements to access
   */
  Vec<T> tail(int n) => slice(length - n, length);

  /**
   * True if and only if number of elements is zero
   */
  bool get isEmpty => length == 0;

  /**
   * Equivalent to slicing operation; e.g.
   *
   * {{{
   *   val v = Vec(1,2,3)
   *   v.take(0,1) == v(0,1)
   * }}}
   *
   * @param locs Location of elements to take
   */
  Vec<T> take(List<int> locs);

  /**
   * The complement of the take operation; slice out
   * elements NOT specified in list.
   *
   * @param locs Location of elements not to take
   */
  Vec<T> without(List<int> locs);

  /**
   * Returns Vec whose locations corresponding to true entries in the
   * boolean input mask vector are set to NA
   *
   * @param m Mask vector of Vec[Boolean]
   */
  Vec<T> mask(Vec<bool> m) =>
      VecImpl.mask(this, m, scalarTag.missing()); //(scalarTag);

  /**
   * Returns Vec whose locations are NA where the result of the
   * provided function evaluates to true
   *
   * @param f A function taking an element and returning a Boolean
   */
  Vec<T> maskFn(bool f(T elem)) =>
      VecImpl.maskFn(this, f, scalarTag.missing()); //(scalarTag);

  /**
   * Concatenate two Vec instances together, where there exists some way to
   * join the type of elements. For instance, Vec[Double] concat Vec[Int]
   * will promote Int to Double as a result of the implicit existence of an
   * instance of Promoter[Double, Int, Double]
   *
   * @param v  Vec[B] to concat
   * @param wd Implicit evidence of Promoter[A, B, C]
   * @param mc Implicit evidence of ST[C]
   * @tparam B type of other Vec elements
   * @tparam C type of resulting Vec elements
   */
  Vec /*<C>*/ concat /*[B, C]*/ (
      Vec /*<B>*/ v) /*(implicit wd: Promoter[T, B, C], mc: ST[C])*/;

  /**
   * Additive inverse of Vec with numeric elements
   *
   */
  Vec<T> operator -();

  // Must implement specialized methods independently of specialized class, workaround to
  // https://issues.scala-lang.org/browse/SI-5281

  /**
   * Map a function over the elements of the Vec, as in scala collections library
   */
  Vec /*<B>*/ map /*<@spec(Boolean, Int, Long, Double) B: ST>*/ (
      dynamic f(T arg), ScalarTag scb);

  /**
   * Maps a function over elements of the Vec and flattens the result.
   */
  Vec /*<B>*/ flatMap /*<Boolean, Int, Long, Double) B : ST>*/ (
      Vec /*<B>*/ f(T arg), ScalarTag sb);

  /**
   * Left fold over the elements of the Vec, as in scala collections library
   */
  /*B*/ dynamic foldLeft /*<Boolean, Int, Long, Double) B: ST>*/ (
      /*B*/ init,
      f(arg1, T arg2)) /*(f: (B, T)*/;

  /**
   * Left scan over the elements of the Vec, as in scala collections library
   */
//  def scanLeft[@spec(Boolean, Int, Long, Double) B: ST](init: B)(f: (B, T) => B): Vec[B]
  Vec /*<B>*/ scanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
      /*B*/ init,
      dynamic f(arg1, T arg2),
      ScalarTag sb) /*(B f(B, T))*/;

  /**
   * Filtered left fold over the elements of the Vec, as in scala collections library
   */
  /*B*/ filterFoldLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
      bool pred(T arg),
      init,
      dynamic f(arg1, T arg2)) /*(B init)(B f(B arg, T arg))*/;

  /**
   * Filtered left scan over elements of the Vec, as in scala collections library
   */
  Vec /*<B>*/ filterScanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
      bool pred(T arg),
      init,
      dynamic f(arg1, T arg2),
      ScalarTag sb) /*(B init)(B f(B arg, T arg))*/;

  /**
   * Left fold that folds only while the test condition holds true. As soon as the condition function yields
   * false, the fold returns.
   *
   * @param cond Function whose signature is the same as the fold function, except that it evaluates to Boolean
   */
  /*B*/ dynamic foldLeftWhile /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
      /*B*/ init,
      dynamic f(arg1, T arg2),
      bool cond(
          arg1, T arg2)) /*(B f(B arg, T arg))(bool cond(B arg, T arg2))*/;

  /**
   * Zips Vec with another Vec and applies a function to the paired elements. If either of the pair is NA, the
   * result is forced to NA.
   *
   * @param other Vec[B]
   * @param f Function (A, B) => C
   * @tparam B Parameter of other Vec
   * @tparam C Result of function
   */
  Vec /*<C>*/ zipMap /*[@spec(Int, Long, Double) B: ST,
             @spec(Boolean, Int, Long, Double) C: ST]*/
  (Vec /*<B>*/ other, /*C*/ f(T arg1, arg2), ScalarTag sc); //(C f(T, B));

  /**
   * Drop the elements of the Vec which are NA
   */
  Vec<T> dropNA();

  /**
   * Return true if there is an NA value in the Vec
   */
  bool get hasNA;

  /**
   * Execute a (side-effecting) operation on each (non-NA) element in the vec
   * @param op operation to execute
   */
  void foreach(op(T arg)) {
    return VecImpl.foreach(this, op); //(scalarTag);
  }

  /**
   * Execute a (side-effecting) operation on each (non-NA) element in vec which satisfies
   * some predicate.
   * @param pred Function A => Boolean
   * @param op Side-effecting function
   */
  void forall(bool pred(T arg), op(arg)) /*(Unit op(T arg))*/ {
    return VecImpl.forall(this, pred, op); //(scalarTag);
  }

  /**
   * Return Vec of integer locations (offsets) which satisfy some predicate
   * @param pred Predicate function from A => Boolean
   */
  Vec<int> find(bool pred(T arg)) => VecImpl.find(this, pred); //(scalarTag);

  /**
   * Return first integer location which satisfies some predicate, or -1 if there is none
   * @param pred Predicate function from A => Boolean
   */
  int findOne(bool pred(T arg)) => VecImpl.findOne(this, pred); //, scalarTag);

  /**
   * Return true if there exists some element of the Vec which satisfies the predicate function
   * @param pred Predicate function from A => Boolean
   */
  bool exists(bool pred(T arg)) => findOne(pred) != -1;

  /**
   * Return Vec whose elements satisfy a predicate function
   * @param pred Predicate function from A => Boolean
   */
  Vec<T> filter(bool pred(T arg)) => VecImpl.filter(this, pred); //(scalarTag);

  /**
   * Return vec whose offets satisfy a predicate function
   * @param pred Predicate function from Int => Boolean
   */
  Vec<T> filterAt(bool pred(int arg)) =>
      VecImpl.filterAt(this, pred); //(scalarTag);

  /**
   * Return Vec whose elements are selected via a Vec of booleans (where that Vec holds the value true)
   * @param pred Predicate vector: Vec[Boolean]
   */
  Vec<T> where(Vec<bool> pred) =>
      VecImpl.where(this, pred.toArray()); //(scalarTag);

  /**
   * Produce a Vec whose entries are the result of executing a function on a sliding window of the
   * data.
   * @param winSz Window size
   * @param f Function Vec[A] => B to operate on sliding window
   * @tparam B Result type of function
   */
  Vec /*<B>*/ rolling /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
      int winSz, dynamic f(Vec<T> arg), ScalarTag sb);

  /**
   * Yield a Vec whose elements have been sorted (in ascending order)
   * @param ev evidence of Ordering[A]
   */
  Vec<T> sorted(/*implicit ORD<T> ev, ST<T> st*/) =>
      take(array.argsort(toArray(), scalarTag));

  /**
   * Yield a Vec whose elements have been reversed from their original order
   */
  Vec<T> get reversed {
    /*implicit*/ var tag = scalarTag;
    return new Vec(array.reverse(toArray()), tag);
  }

  /**
   * Creates a view into original vector from an offset up to, but excluding,
   * another offset. Data is not copied.
   *
   * @param from Beginning offset
   * @param until One past ending offset
   * @param stride Increment within slice
   */
  Vec<T> slice(int from, int until, [int stride = 1]);

  /**
   * Creates a view into original vector from an offset up to, and including,
   * another offset. Data is not copied.
   *
   * @param from Beginning offset
   * @param to Ending offset
   * @param stride Increment within slice
   */
  Vec<T> sliceBy(int from, int to, [int stride = 1]) =>
      slice(from, to + stride, stride);

  /**
   * Split Vec into two Vecs at position i
   * @param i Position at which to split Vec
   */
  SplitAt<T> splitAt(int i) => new SplitAt._(slice(0, i), slice(i, length));

  /**
   * Creates a view into original Vec, but shifted so that n
   * values at the beginning or end of the Vec are NA's. Data
   * is not copied.
   *
   * @param n Number of offsets to shift
   */
  Vec<T> shift(int n);

  /**
   * Replaces all NA values for which there is a non-NA value at a lower offset
   * with the corresponding highest-offset, non-NA value. E.g,
   *
   * {{{
   *   Vec(1, 2, NA, 3, NA).pad == Vec(1, 2, 2, 3, 3)
   *   Vec(NA, 1, 2, NA).pad == Vec(NA, 1, 2, 2)
   * }}}
   *
   */
  Vec<T> pad() => VecImpl.pad(this); //(scalarTag);

  /**
   * Replaces all NA values for which there is a non-NA value at a lower offset
   * with the corresponding highest-offset, non-NA value; but looking back only
   * at most N positions.
   *
   * {{{
   *   Vec(1, 2, NA, 3, NA).padAtMost(1) == Vec(1, 2, 2, 3, 3)
   *   Vec(NA, 1, 2, NA).padAtMost(1) == Vec(NA, 1, 2, 2)
   *   Vec(1, NA, NA, 3, NA).padAtMost(1) == Vec(1, 1, NA, 3, 3)
   * }}}
   *
   */
  Vec<T> padAtMost(int n) => VecImpl.pad(this, n); //(scalarTag);

  /**
   * Fills NA values in vector with result of a function which acts on the index of
   * the particular NA value found
   *
   * @param f A function from Int => A; yields value for NA value at ith position
   */
  Vec<T> fillNA(T f(int arg)) => VecImpl.vecfillNA(this, f); //(scalarTag);

  /**
   * Converts Vec to an indexed sequence (default implementation is immutable.Vector)
   *
   */
//  IndexedSeq<T> toSeq() => toArray.toIndexedSeq;

  /**
   * Returns a Vec whose backing array has been copied
   */
  /*protected*/ Vec<T> copy();

  /*private[saddle]*/ List<T> toArray();

  /*private[saddle]*/ List<double> toDoubleArray(/*implicit NUM<T> na*/) {
    var arr = toArray();
    var buf = new List<double>(arr.length);
    var i = 0;
    while (i < arr.length) {
      buf[i] = scalarTag.toDouble(arr[i]);
      i += 1;
    }
    return buf;
  }

  /** Default hashcode is simple rolling prime multiplication of sums of hashcodes for all values. */
  @override
  int get hashCode {
//    return toArray().fold(1, (a, b) => a * 31 + b.hashCode);
    return foldLeft(1, (a, b) => a * 31 + b.hashCode);
  }

  /**
   * Default equality does an iterative, element-wise equality check of all values.
   *
   * NB: to avoid boxing, is overwritten in child classes
   */
//  @override
  bool operator ==(o) {
    if (o is Vec) {
      Vec rv = o;
      if (identical(this, rv)) {
        return true;
      } else if (this.length != rv.length) {
        return false;
      } else {
        var i = 0;
        var eq = true;
        while (eq && i < this.length) {
          eq = eq &&
              (this[i] == rv[i] ||
                  this.scalarTag.isMissing(this[i]) &&
                      rv.scalarTag.isMissing(rv[i]));
          i += 1;
        }
        return eq;
      }
    } else {
      return false;
    }
  }

  /**
   * Creates a string representation of Vec
   * @param len Max number of elements to include
   */
  String stringify([int len = 10]) {
//    var half = len ~/ 2;

    var buf = new StringBuffer();

//    /*implicit*/ var st = scalarTag;

//    var maxf = (int a, String b) => math.max(a, b.length);

    if (length == 0) {
      buf.write("Empty Vec");
    } else {
      buf.write("[$length x 1]\n");
//      var vlen = (head(half).concat(tail(half)))
//          .map(scalarTag.show, st)
//          .foldLeft(0, maxf);

//      String createRow(int r) => ("%" + { (vlen > 0) ? vlen : 1 } + "s\n").format(scalarTag.show(apply(r)))
      String createRow(int r) => "${scalarTag.show(this[r])}\n";
      buf.write(util.buildStr(len, length, createRow, () => " ... \n"));
    }

    return buf.toString();
  }

  /**
   * Pretty-printer for Vec, which simply outputs the result of stringify.
   * @param len Number of elements to display
   */
//  void print([int len = 10, OutputStream stream /*= System.out*/]) {
//    stream.write(stringify(len).getBytes);
//  }

  @override
  toString() => stringify();
//}

//class Vec extends BinOpVec with VecStatsImplicits with VecBoolEnricher {
  // **** constructions

  Vec.internal();

  /**
   * Factory method to create a Vec from an array of elements
   *
   * @param arr Array
   * @tparam T Type of elements in array
   */
  factory Vec /*<T> apply <T>*/ (
          List<T> arr, ScalarTag<T> st) /*(implicit ST[T] st)*/ =>
      st.makeVec(arr);

  /**
   * Factory method to create a Vec from a sequence of elements. For example,
   *
   * {{{
   *   Vec(1,2,3)
   *   Vec(Seq(1,2,3) : _*)
   * }}}
   *
   * @param values Sequence
   * @tparam T Type of elements in Vec
   */
//  Vec<T> apply/*[T: ST]*/(T* values) => Vec(values.toArray)

  /**
   * Creates an empty Vec of type T.
   *
   * @tparam T Vec type parameter
   */
  factory Vec.empty(ScalarTag<T> st) /*[T: ST]*/ => new Vec([], st);

  // **** conversions

  // Vec is isomorphic to array

  /**
   * A Vec may be implicitly converted to an array. Use responsibly;
   * please do not circumvent immutability of Vec class!
   * @param s Vec
   * @tparam T Type parameter of Vec
   */
//  /*implicit*/ vecToArray /*[T]*/ (Vec<T> s) => s.toArray;

  /**
   * An array may be implicitly converted to a Vec.
   * @param arr Array
   * @tparam T Type parameter of Array
   */
//  /*implicit*/ arrayToVec /*[T: ST]*/ (List<T> arr) => new Vec(arr);

  /**
   * A Vec may be implicitly ''widened'' to a Vec.
   *
   * @param s Vec to widen to Series
   * @tparam A Type of elements in Vec
   */
//  /*implicit*/ vecToSeries /*[A: ST]*/ (Vec<A> s) => Series(s);

  /**
   * A Vec may be implicitly converted to a single column Mat
   */
//  /*implicit*/ Mat /*<A>*/ vecToMat /*[A: ST]*/ (Vec /*<A>*/ s) => new Mat(s);
}

class SplitAt<T> {
  final Vec<T> v1, v2;
  SplitAt._(this.v1, this.v2);
}
