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

//import 'util/concat.dart' show Promoter;
import 'ops/ops.dart';
import 'vec/vec.dart';
//import 'stats/stats.dart';
import 'index/index.dart';
import 'index/join_type.dart';
//import 'groupby/groupby.dart';
import 'scalar/scalar.dart';
//import java.io.OutputStream
//import 'mat/mat_cols.dart' show MatCols;

/**
 * `Series` is an immutable container for 1D homogeneous data which is indexed by a
 * an associated sequence of keys.
 *
 * Both the index and value data are backed by arrays.
 *
 * `Series` is effectively an associative map whose keys have an ordering provided by
 * the natural (provided) order of the backing array.
 *
 * Several element access methods are provided.
 *
 * The `apply` method returns a slice of the original Series:
 *
 * {{{
 *   val s = Series(Vec(1,2,3,4), Index('a','b','b','c'))
 *   s('a') == Series('a'->1)
 *   s('b') == Series('b'->2, 'b'->3)
 * }}}
 *
 * Other ways to slice a series involve implicitly constructing an [[org.saddle.index.Slice]]
 * object and passing it to the Series apply method:
 *
 * {{{
 *   s('a'->'b') == Series('a'->1, 'b'->2, 'b'->3)
 *   s(* -> 'b') == Series('a'->1, 'b'->2, 'b'->3)
 *   s('b' -> *) == Series('b'->2, 'b'->3, 'c'->4)
 *   s(*) == s
 * }}}
 *
 * The `at` method returns an instance of a [[org.saddle.scalar.Scalar]], which behaves
 * much like an `Option` in that it can be either an instance of [[org.saddle.scalar.NA]]
 * or a [[org.saddle.scalar.Value]] case class:
 *
 * {{{
 *   s.at(0) == Scalar(1)
 * }}}
 *
 * The `slice` method allows slicing the Series for locations in [i, j) irrespective of
 * the value of the keys at those locations.
 *
 * {{{
 *   s.slice(2,4) == Series('b'->3, 'c'->4)
 * }}}
 *
 * To slice explicitly by labels, use the `sliceBy` method, which is inclusive of the
 * key boundaries:
 *
 * {{{
 *   s.sliceBy('b','c') == Series('b'->3, 'c'->4)
 * }}}
 *
 * The method `raw` accesses the value directly, which may reveal the underlying representation
 * of a missing value (so be careful).
 *
 * {{{
 *   s.raw(0) == 1
 * }}}
 *
 * `Series` may be used in arithmetic expressions which operate on two `Series` or on a
 * `Series` and a scalar value. In the former case, the two Series will automatically
 * align along their indexes. A few examples:
 *
 * {{{
 *   s * 2 == Series('a'->2, 'b'->4, ... )
 *   s + s.shift(1) == Series('a'->NA, 'b'->3, 'b'->5, ...)
 * }}}
 *
 * @param values Vec backing the values in the Series
 * @param index Index backing the keys in the Series
 * @tparam X Type of elements in the index, for which there must be an implicit Ordering and ST
 * @tparam T Type of elements in the values array, for which there must be an implicit ST
 */
class Series<X,
    T extends ScalarTag> /*[X: ST: ORD, T: ST] extends NumericOps<Series<X, T>> with Serializable*/ {
  Series(Vec<T> values, Index<X> index) {
//    require(values.length == index.length,
//         "Values length %d != index length %d" format (values.length, index.length));
  }

  /**
   * The length shared by both the index and the values array
   */
  int get length => values.length;

  /**
   * True if and only if number of elements is zero
   */
  bool get isEmpty => (values.length == 0);

  // access values by location(s)

  /**
   * Access an unboxed element of a Series at a single location
   * @param loc offset into Series
   */
  T raw(int loc) => values(loc);

  /**
   * Access a boxed element of a Series at a single location
   * @param loc offset into Series
   */
  Scalar<T> at(int loc) => values(loc);

  /**
   * Access multiple locations of a Series, returning a new Series comprising those locations
   * @param locs Array of int offsets into Series
   */
  Series<X, T> atTake(Array<int> locs) => take(locs);

  /**
   * Access multiple locations of a Series, returning a new Series comprising those locations
   * @param locs Sequence of Int
   */
//  Series<X, T> at(int* locs) => take(locs.toArray);

  /**
   * Get the first value of the Series
   */
  Scalar<T> get first => values.first;

  /**
   * Get the first value of the Series whose key matches that provided
   * @param key Key on which to match
   */
  Scalar<T> firstValue(X key) {
    val loc = index.getFirst(key);
    if (loc == -1) {
      NA;
    } else {
      at(loc);
    }
  }

  /**
   * Alias for `first`. If a key exists, get the value associated with the first
   * occurence of that key.
   * @return
   */
  Scalar<T> get(X key) {
    val loc = index.getFirst(key);
    if (loc == -1) {
      NA;
    } else {
      at(loc);
    }
  }

  /**
   * Get the last value of the Series
   */
  Scalar<T> get last => values.last;

  /**
   * Get the last value of the Series whose key matches that provided
   * @param key Key on which to match
   */
  Scalar<T> lastValue(X key) {
    val loc = index.getLast(key);
    if (loc == -1) {
      NA;
    } else {
      at(loc);
    }
  }

  // access index keys by location(s)

  /**
   * Access a boxed element of a Series index at a single location
   * @param loc offset into Series
   */
  Scalar<X> keyAt(int loc) => index.raw(loc);

  /**
   * Access a multiple locations of a Series index, returning a new Index
   * @param locs array of int offset into Index
   */
  Index<X> keyAtTake(Array<int> locs) => index.take(locs);

  /**
   * Access a multiple locations of a Series index, returning a new Index
   * @param locs Sequence of int offsets into Index
   */
//  Index<X> keyAt(Int* locs) => index.take(locs.toArray);

  /**
   * Get the first key of the Series
   */
  Scalar<X> get firstKey => index.first;

  /**
   * Get the last key of the Series
   */
  Scalar<X> get lastKey => index.last;

  // extract values by associated key(s); ignore non-existent keys

  /**
   * Extract a Series corresponding to those keys provided. Returns a new Series
   * whose key-value pairs maintain the original ordering.
   * @param keys Array of keys
   */
  Series<X, T> apply(Array<X> keys) => take(index(keys));

  /**
   * Extract a Series corresponding to those keys provided. Returns a new Series
   * whose key-value pairs maintain the original ordering.
   * @param keys Sequence of keys
   */
//  Series<X, T> apply(X* keys) => apply(keys.toArray);

  /**
   * Extract a Series whose keys respect the Slice provided. Returns a new Series
   * whose key-value pairs maintain the original ordering.
   * @param slice Slice
   */
  Series<X, T> applySlice(Slice<X> slice) => sliceBy(slice);

  // re-index series; non-existent keys map to NA

  /**
   * Create a new Series whose index is the provided argument, and whose values
   * are derived from the original Series.
   * @param newIx Index of the result series
   */
  Series<X, T> reindex(Index<X> newIx) {
    val ixer = index.getIndexer(newIx);
    ixer.map((a) => Series(values.take(a), newIx)).getOrElse(this);
  }

  /**
   * Create a new Series whose index formed of the provided argument, and whose values
   * are derived from the original Series.
   * @param keys Sequence of keys to be the index of the result series
   */
//  Series<X, T> reindex(X* keys) => reindex(Index(keys.toArray));

  // make new index

  /**
   * Create a new Series using the current values but with the new index. Positions
   * of the values do not change.
   * @param newIx A new Index
   * @tparam Y Type of elements of new Index
   */
  Series<Y, T> setIndex /*[Y: ST: ORD]*/ (Index<Y> newIx) =>
      Series(values, newIx);

  /**
   * Create a new Series whose values are the same, but whose Index has been changed
   * to the bound [0, length - 1), as in an array.
   */
  Series<int, T> resetIndex() => Series(values, IndexIntRange(values.length));

  /**
   * Map a function over the index, resulting in a new Series
   *
   * @param fn The function X => Y with which to map
   * @tparam Y Result type of index, ie Index[Y]
   */
  Series<Y, T> mapIndex /*[Y: ST: ORD]*/ (Y fn(X arg)) =>
      Series(values, index.map(fn));

  /**
   * Concatenate two Series instances together whose indexes share the same type of
   * element, and where there exists some way to join the values of the Series. For
   * instance, Series[X, Double] `concat` Series[X, Int] will promote Int to Double as
   * a result of the implicit existence of a Promoter[Double, Int, Double] instance.
   * The result Index will simply be the concatenation of the two input Indexes.
   *
   * @param other  Series[X, B] to concat
   * @param pro Implicit evidence of Promoter[A, B, C]
   * @param md Implicit evidence of ST[C]
   * @tparam U type of other Series Values
   * @tparam V type of resulting Series values
   */
//  def concat[U, V](other: Series[X, U])(implicit pro: Promoter[T, U, V], md: ST[V]): Series[X, V] =
//    Series(values concat other.values, index concat other.index)

  /**
   * Additive inverse of Series with numeric elements
   */
  Series<X, T> operator -() => Series(-values, index);

  // slicing

  /**
   * Creates a view into original Series from one key up to (inclusive by default)
   * another key. Data is not copied. Series index must be sorted.
   * @param from Beginning offset key
   * @param to Ending offset key
   */
  Series<X, T> sliceByRange(X from, X to, [bool inclusive = true]) {
    val start = index.lsearch(from);
    val end = inclusive ? index.rsearch(to) : index.lsearch(to);
    Series(values.slice(start, end), index.slice(start, end));
  }

  /**
   * Creates a view into original Series from one key through another key as
   * specified in the bound argument. Data is not copied. Series index must be
   * sorted.
   * @param rng An IRange which computes the bound locations
   */
  Series<X, T> sliceBy(Slice<X> rng) {
    val start, end = rng(index);
    Series(values.slice(start, end), index.slice(start, end));
  }

  /**
   * Creates a view into original Series from one int offset until (exclusive)
   * another offset. Data is not copied.
   * @param from Beginning offset
   * @param until Ending offset
   */
  Series<X, T> slice(int from, int until, [int stride = 1]) {
    Series(values.slice(from, until, stride), index.slice(from, until, stride));
  }

  /**
   * Given int offets to take, form a new series from the keys and values found
   * at those offsets.
   * @param locs Array of int offsets
   */
  Series<X, T> take(Array<int> locs) =>
      Series(values.take(locs), index.take(locs));

  /**
   * Extract at most the first n elements of the Series
   * @param n Number of elements to extract
   */
  head(int n) => Series(values.head(n), index.head(n));

  /**
   * Extract at most the last n elements of the Series
   * @param n number to extract
   */
  tail(int n) => Series(values.tail(n), index.tail(n));

  /**
   * Shift the sequence of values relative to the index by some offset,
   * dropping those values which no longer associate with a key, and having
   * those keys which no longer associate to a value instead map to NA.
   * @param n Number to shift
   */
  Series<X, T> shift([int n = 1]) => Series(values.shift(n), index);

  /**
   * Replaces all NA values for which there is a non-NA value at a prior offset
   * with the corresponding most-recent, non-NA value. E.g,
   *
   * {{{
   *   Series(1, 2, NA, 3, NA).pad == Series(1, 2, 2, 3, 3)
   *   Series(NA, 1, 2, NA).pad == Series(NA, 1, 2, 2)
   * }}}
   *
   */
  Series<X, T> pad() => Series(values.pad, index);

  /**
   * Same as above, but limits the amount of padding to N observations.
   *
   * {{{
   *   Series(1, 2, NA, NA, 3).padAtMost(1) == Series(1, 2, 2, NA, 3)
   * }}}
   *
   */
  Series<X, T> padAtMost(int n) => Series(values.padAtMost(n), index);

  /**
   * Fills NA values in series with result of a function which acts on the index of
   * the particular NA value found
   *
   * @param f A function X => A to be applied at NA location
   */
  Series<X, T> fillNA(T f(X arg)) =>
      Series(VecImpl.seriesfillNA(index.toVec, values)(f), index);

  /**
   * Creates a Series having the same values but excluding all key/value pairs in
   * which the value is NA.
   */
  Series<X, T> dropNA() => filter(values.scalarTag.notMissing);

  /**
   * Return true if there is at least one NA value in the Series
   */
  bool get hasNA => toVec.hasNA;

  // filtering

  /**
   * Create a new Series that, wherever the mask Vec is true, is masked with NA
   * @param m Mask Vec[Boolean]
   */
  Series<X, T> mask(Vec<bool> m) => Series(values.mask(m), index);

  /**
   * Create a new Series that, whenever the mask predicate function evaluates to
   * true on a value, is masked with NA
   * @param f Function from T to Boolean
   */
  Series<X, T> maskFn(bool f(T arg)) => Series(values.mask(f), index);

  /**
   * Create a new Series that, whenever the mask predicate function evaluates to
   * true on a key, is masked with NA
   * @param f Function from X to Boolean
   */
  Series<X, T> maskIx(bool f(X arg)) => mask(index.toVec.map(f));

  /**
   * Return Series whose values satisfy a predicate function
   * @param pred Predicate function from T => Boolean
   */
  Series<X, T> filter(bool pred(T arg)) => where(values.map(pred));

  /**
   * Return Series whose index keys satisfy a predicate function
   * @param pred Predicate function from X => Boolean
   */
  Series<X, T> filterIx(bool pred(X arg)) => where(index.toVec.map(pred));

  /**
   * Return Series whose offets satisfy a predicate function
   * @param pred Predicate function from Int => Boolean
   */
  filterAt(bool pred(int arg)) =>
      Series(values.filterAt(pred), Index(index.toVec.filterAt(pred)));

  /**
   * Return Series whose keys and values are chosen via a Vec[Boolean] or a
   * Series[_, Boolean] where the latter contains a true value.
   * @param pred Series[_, Boolean] (or Vec[Boolean] which will implicitly convert)
   */
  Series<X, T> where(Series /*[_, Boolean]*/ pred) {
    val newVals = VecImpl.where(this.values)(pred.values.toArray);
    val newIdx = VecImpl.where(index.toVec)(pred.values.toArray);
    Series(newVals, Index(newIdx));
  }

  // searching

  /**
   * Search for the int offsets where the values of the Series satisfy a predicate
   * function.
   * @param pred Function from T to Boolean
   */
  Vec<int> find(bool pred(T arg)) => values.find(pred);

  /**
   * Search for the keys of the Series index whose corresponding values satisfy a
   * predicate function.
   * @param pred Function from T to Boolean
   */
  Index<X> findKey(bool pred(T arg)) => index.take(find(pred));

  /**
   * Find the first int offset (or -1 if none) where a value of the Series satisfies
   * a predicate function.
   * @param pred Function from T to Boolean
   */
  int findOne(bool pred(T arg)) => values.findOne(pred);

  /**
   * Find the first key (or NA if none) where a value of the Series satisfies
   * a predicate function.
   * @param pred Function from T to Boolean
   */
  Scalar<X> findOneKey(bool pred(T arg)) {
    val loc = findOne(pred);
    if (loc == -1) {
      NA;
    } else {
      keyAt(loc);
    }
  }

  /**
   * Return key corresponding to minimum value in series
   */
  Scalar<X> minKey(/*implicit*/ NUM<T> num_, ORD<T> ord) {
//    array.argmin(values.toArray) match {
//      case -1     => NA
//      case _  @ i => index.at(i)
//    }
  }

  /**
   * Return key corresponding to maximum value in series
   */
  Scalar<X> maxKey(/*implicit*/ NUM<T> num_, ORD<T> ord) {
//    array.argmax(values.toArray) match {
//      case -1     => NA
//      case _  @ i => index.at(i)
//    }
  }

  /**
   * Returns true if the index of the Series contains the key
   * @param key The key to check
   */
  bool contains(X key) => index.contains(key);

  /**
   * Return true if there exists some element of the Series which satisfies the predicate function
   * @param pred Predicate function from T => Boolean
   */
  bool exists(bool pred(T arg)) => findOne(pred) != -1;

  // manipulating

  /**
   * Map over the key-value pairs of the Series, resulting in a new Series. Applies a
   * function to each pair of values in the series.
   *
   * @param f Function from (X,T) to (Y,U)
   * @tparam Y The type of the resulting index
   * @tparam U The type of the resulting values
   */
  Series<Y, U> map /*[Y: ST: ORD, U: ST]*/ (/*(Y, U)*/ f(/*(X, T)*/ arg)) =>
      Series(toSeq.map(f)); // : _*)

  /**
   * Map and then flatten over the key-value pairs of the Series, resulting in a new Series.
   */
  Series<Y, U> flatMap /*[Y: ST: ORD, U: ST]*/ (
          Traversable /*<(Y, U)>*/ f(/*(X, T)*/ arg)) =>
      Series(toSeq.flatMap(f)); // : _*)

  /**
   * Map over the values of the Series, resulting in a new Series. Applies a function
   * to each (non-na) value in the series, returning a new series whose index remains
   * the same.
   *
   * @param f Function from T to U
   * @tparam U The type of the resulting values
   */
  Series<X, U> mapValues /*[U: ST]*/ (U f(T arg)) =>
      Series(values.map(f), index);

  /**
   * Left scan over the values of the Series, as in scala collections library, but
   * with the resulting series having the same index. Note, differs from standard left
   * scan because initial value is not retained in result.
   *
   * @param init Initial value of scan
   * @param f Function taking (U, T) to U
   * @tparam U Result type of function
   */
  scanLeft /*[U: ST]*/ (U init) /*(U f((U, T) arg))*/ =>
      Series(values.scanLeft(init)(f), index);

  // safe cast operation

  /**
   * Join two series on their index and apply a function to each paired value; when either
   * value is NA, the result of the function is forced to be NA.
   * @param other Other series
   * @param how The type of join to effect
   * @param f The function to apply
   * @tparam U Type of other series values
   * @tparam V The result type of the function
   */
  Series<X, V> joinMap /*[U: ST, V: ST]*/ (Series<X, U> other,
      [JoinType how = JoinType.LeftJoin]) /*(V f((T, U) arg))*/ {
    var l, r = align(other, how);
    Series(VecImpl.zipMap(l.values, r.values)(f), l.index);
  }

  /**
   * Create a new Series whose key/value entries are sorted according to the values of the Series.
   * @param ev Implicit evidence of ordering for T
   */
  Series<X, T> sorted(/*implicit*/ ORD<T> ev) =>
      take(array.argsort(values.toArray));

  /**
   * Create a new Series whose key/value entries are sorted according to the keys (index values).
   */
  Series<X, T> sortedIx() => (index.isMonotonic) ? this : take(index.argSort);

  /**
   * Create a new Series whose values and index keys are both in reversed order
   */
  Series<X, T> get reversed => Series(values.reversed, index.reversed);

  /**
   * Construct a [[org.saddle.groupby.SeriesGrouper]] with which further computations, such
   * as combine or transform, may be performed. The groups are constructed from the keys of
   * the index, with each unique key corresponding to a group.
   */
  SeriesGrouper<X, X, T> groupBy() => SeriesGrouper(this);

  /**
   * Construct a [[org.saddle.groupby.SeriesGrouper]] with which further computations, such
   * as combine or transform, may be performed. The groups are constructed from the result
   * of the function applied to the keys of the Index; each unique result of calling the
   * function on elements of the Index corresponds to a group.
   * @param fn Function from X => Y
   * @tparam Y Type of function codomain
   */
  SeriesGrouper<Y, X, T> groupByFn /*[Y: ST: ORD]*/ (Y fn(X arg)) =>
      SeriesGrouper(this.index.map(fn), this);

  /**
   * Construct a [[org.saddle.groupby.SeriesGrouper]] with which further computations, such
   * as combine or transform, may be performed. The groups are constructed from the keys of
   * the provided index, with each unique key corresponding to a group.
   * @param ix Index with which to perform grouping
   * @tparam Y Type of elements of ix
   */
  SeriesGrouper<Y, X, T> groupByIndex /*[Y: ST: ORD]*/ (Index<Y> ix) =>
      SeriesGrouper(ix, this);

  /**
   * Produce a Series whose values are the result of executing a function on a sliding window of
   * the data.
   * @param winSz Window size
   * @param f Function Series<X, T> => B to operate on sliding window
   * @tparam B Result type of function
   */
  Series<X, B> rolling /*[B: ST]*/ (int winSz, B f(Series<X, T> arg)) {
    if (winSz <= 0) {
      new Series.empty<X, B>();
    } else {
      val len = values.length;
      val win = (winSz > len) ? len : winSz;
      val buf = new Array /*[B]*/ (len - win + 1);
      var i = win;
      while (i <= len) {
        buf[i - win] = f(slice(i - win, i));
        i += 1;
      }
      Series(Vec(buf), index.slice(win - 1, len));
    }
  }

  /**
   * Split Series into two series at position i
   * @param i Position at which to split Series
   */
  /*(Series<X, T>, Series<X, T>)*/ splitAt(int i) =>
      [slice(0, i), slice(i, length)];

  /**
   * Split Series into two series at key x
   * @param k Key at which to split Series
   */
  /*(Series<X, T>, Series<X, T>)*/ splitBy(X k) => splitAt(index.lsearch(k));

  // ----------------------------
  // reshaping

  /**
   * Pivot splits an index of tuple keys of arity N into a row index having arity N-1 and a
   * column index, producing a 2D Frame whose values are from the original Series as indexed
   * by the corresponding keys.
   *
   * To recover the original Series, the melt method of Frame may be used.
   *
   * For example, given:
   *
   * {{{
   *   Series(Vec(1,2,3,4), Index(('a',1),('a',2),('b',1),('b',2)))
   *   res0: org.saddle.Series[(Char, Int),Int] =
   *   [4 x 1]
   *    a 1 => 1
   *      2 => 2
   *    b 1 => 3
   *      2 => 4
   * }}}
   *
   * the pivot command does the following:
   *
   * {{{
   *   res0.pivot
   *   res1: org.saddle.Frame[Char,Int,Int] =
   *   [2 x 2]
   *          1  2
   *         -- --
   *    a =>  1  2
   *    b =>  3  4
   * }}}
   *
   * @param split Implicit evidence of a Splitter for the index
   * @param ord1 Implicit evidence of an ordering for O1
   * @param ord2 Implicit evidence of an ordering for O2
   * @param m1 Implicit evidence of a ST for O1
   * @param m2 Implicit evidence of a ST for O2
   * @tparam O1 Output row index
   * @tparam O2 Output col index
   */
  Frame<O1, O2, T> pivot /*[O1, O2]*/ (/*implicit*/ Splitter<X, O1, O2> split,
      ORD<O1> ord1, ORD<O2> ord2, ST<O1> m1, ST<O2> m2) {
    val lft, rgt = split(index);

    val rix = lft.uniques;
    val cix = rgt.uniques;

    val grpr = IndexGrouper(rgt, sorted: false);
    val grps =
        grpr.groups; // Group by pivot label. Each unique label will get its
    //  own column
    if (length == 0) {
      new Frame.empty<O1, O2, T>();
    } else {
      var loc = 0;
      val result =
          Array.ofDim[Vec[T]](cix.length); // accumulates result columns

      for (var /*(k, taker)*/ arg in grps) {
        // For each pivot label grouping,
        val gIdx = lft.take(taker); //   use group's (lft) row index labels
        val ixer = rix.join(gIdx); //   to compute map to final (rix) locations;
        val vals = values
            .take(taker); // Take values corresponding to current pivot label
        val v = ixer.rTake
            .map(vals.take(_))
            .getOrElse(vals); //   map values to be in correspondence to rix
        result[loc] = v; //   and save resulting col vec in array.
        loc += 1; // Increment offset into result array
      }

      Frame(result, rix, Index(grpr.keys));
    }
  }

  // ----------------------------
  // joining

  /**
   * Perform a join with another Series<X, T> according to its index. The `how`
   * argument dictates how the join is to be performed:
   *
   *   - Left [[org.saddle.index.LeftJoin]]
   *   - Right [[org.saddle.index.RightJoin]]
   *   - Inner [[org.saddle.index.InnerJoin]]
   *   - Outer [[org.saddle.index.OuterJoin]]
   *
   * The result is a Frame whose index is the result of the join, and whose column
   * index is {0, 1}, and whose values are sourced from the original Series.
   *
   * @param other Series to join with
   * @param how How to perform the join
   */
  Frame<X, Int, T> join(Series<X, T> other,
      [JoinType how = JoinType.LeftJoin]) {
    val indexer = this.index.join(other.index, how);
//    val lseq = indexer.lTake.map(this.values.take(_)) getOrElse this.values;
//    val rseq = indexer.rTake.map(other.values.take(_)) getOrElse other.values;
    Frame(MatCols(lseq, rseq), indexer.index, Array(0, 1));
  }

  /**
   * Perform a (heterogeneous) join with another Series[X, _] according to its index.
   * The values of the other Series do not need to have the same type. The result is
   * a Frame whose index is the result of the join, and whose column index is {0, 1},
   * and whose values are sourced from the original Series.
   *
   * @param other Series to join with
   * @param how How to perform the join
   */
  Frame<X, int, Any> hjoin(Series<X, _> other,
      [JoinType how = JoinType.LeftJoin]) {
    val indexer = this.index.join(other.index, how);
//    val lft = indexer.lTake.map(this.values.take(_)) getOrElse this.values;
//    val rgt = indexer.rTake.map(other.values.take(_)) getOrElse other.values;
    Panel(Seq(lft, rgt), indexer.index, IndexIntRange(2));
  }

  /**
   * Perform a join with a Frame[X, _, T] according to its row index. The values of
   * the other Frame must have the same type as the Series. The result is a Frame
   * whose row index is the result of the join, and whose column index is [0, N),
   * corresponding to the number of columns of the frame plus 1, and whose values
   * are sourced from the original Series and Frame.
   *
   * @param other Frame[X, Any, T]
   * @param how How to perform the join
   */
  Frame<X, int, T> joinF(Frame<X, _, T> other,
      [JoinType how = JoinType.LeftJoin]) {
    val tmpFrame = other.joinS(this, how);
//    Frame(tmpFrame.values.last +: tmpFrame.values.slice(0, tmpFrame.values.length - 1),
//          tmpFrame.rowIx, IndexIntRange(other.colIx.length + 1));
  }

  /**
   * Perform a (heterogeneous) join with a Frame[X, _, _] according to its row index.
   * The values of the other Frame do not need to have the same type. The result is
   * a Frame whose row index is the result of the join, and whose column index is
   * [0, N), corresponding to the number of columns of the frame plus 1, and whose
   * values are sourced from the original Series and Frame.
   *
   * @param other Frame[X, Any, Any]
   * @param how How to perform the join
   */
  Frame<X, Int, Any> hjoinF(Frame<X, _, _> other,
      [JoinType how = JoinType.LeftJoin]) {
    val tmpFrame = other.joinAnyS(this, how);
//    Panel(tmpFrame.values.last +: tmpFrame.values.slice(0, tmpFrame.values.length - 1),
//          tmpFrame.rowIx, IndexIntRange(other.colIx.length + 1))
  }

  /**
   * Aligns this series with another series, returning the two series aligned
   * to each others indexes according to the the provided parameter
   *
   * @param other Other series to align with
   * @param how How to perform the join on the indexes
   */
  /*(Series<X, T>, Series[X, U])*/ align /*[U: ST]*/ (Series<X, U> other,
      [JoinType how = JoinType.LeftJoin]) {
    val indexer = this.index.join(other.index, how);
//    val lseq = indexer.lTake.map(this.values.take(_)) getOrElse this.values;
//    val rseq = indexer.rTake.map(other.values.take(_)) getOrElse other.values;
    return [Series(lseq, indexer.index), Series(rseq, indexer.index)];
  }

  // ----------------------------
  // proxy

  /**
   * Fill series NA's with values using a secondary series
   *
   * @param proxy The series containing the values to use
   */
  Series<X, T> proxyWith(
      Series<X, T> proxy) /*(implicit T fn(org.saddle.scalar.NA.type arg))*/ {
    require(proxy.index.isUnique, "Proxy index must be unique");

    this.fillNA((key) {
      val loc = proxy.index.getFirst(key);
      val res = (loc == -1) ? NA : proxy.raw(loc);
      return res;
    });
  }

  // ----------------------------
  // conversions

  /**
   * Convert Series to a Vec, by dropping the index.
   */
  Vec<T> toVec() => values;

  /**
   * Convert Series to an indexed sequence of (key, value) pairs.
   */
  IndexedSeq /*[(X, T)]*/ toSeq() => index.toSeq; // zip values.toSeq;

  String stringify([int len = 10]) {
    val half = len / 2;

    val buf = new StringBuffer();

    if (length == 0) {
      buf.write("Empty Series");
    } else {
//      buf.append("[%d x 1]\n" format length)

      val maxf = (List<int> a, List<String> b) =>
          null; //(a zip b).map(v => v._1.max(v._2.length))

      val isca = index.scalarTag;
      val vidx = index.toVec;
//      val idxHf = { vidx.head(half) concat vidx.tail(half) }
      val ilens = idxHf
          .map(isca.strList(_))
          .foldLeft(isca.strList(vidx(0)).map(_.length))(maxf);

      val vsca = values.scalarTag;
//      val vlHf = { values.head(half) concat values.tail(half) }
      val vlen =
          vlHf.map(vsca.show(_)).foldLeft(2)((a, b) => math.max(a, b.length));

      List /*[(Int, A, B)]*/ enumZip /*[A, B]*/ (List<A> a, List<B> b) {
//        for ( v <- (a.zipWithIndex zip b) ) yield (v._1._2, v._1._1, v._2)
      }

      val sz = isca.strList(index.raw(0)).size;

      val prevRowLabels = Array.fill(sz)("");
      resetRowLabels(int k) {
//        for (i <- k until prevRowLabels.length) prevRowLabels(i) = ""
      }

      createIx(int r) {
        val vls = isca.strList(index.raw(r));
//        val lst = for ((i, l, v) <- enumZip(ilens, vls)) yield {
//          val fmt = "%" + l + "s"
//          val res = if (i == vls.length - 1 || prevRowLabels(i) != v) {
//            resetRowLabels(i+1)
//            v.formatted(fmt)
//          }
//          else "".formatted(fmt)
//          prevRowLabels(i) = v
//          res
//        }
        lst.mkString(" ");
      }

      createVal(int r) => ("%" + vlen + "s\n").format(vsca.show(values.raw(r)));

//      buf.append(util.buildStr(len, length,
//      (int i) => createIx(i) + " -> " + createVal(i), { resetRowLabels(0); " ... \n" }));
    }

    buf.toString();
  }

  /**
   * Pretty-printer for Series, which simply outputs the result of stringify.
   * @param len Number of elements to display
   */
//  print([int len = 10, OutputStream stream = System.out]) {
//    stream.write(stringify(len).getBytes);
//  }

  @override
  int hashCode() => values.hashCode() * 31 + index.hashCode();

  @override
  bool equals(other) {
//    other match {
//      case s: Series[_, _] => (this eq s) || (length == s.length) && index == s.index && values == s.values
//      case _ => false
//    }
  }

  @override
  String toString() => stringify();
//}

//class Series extends BinOpSeries {
  // stats implicits

//  type Vec2Stats[T] = Vec[T] => VecStats[T]
//  type Vec2RollingStats[T] = Vec[T] => VecRollingStats[T]
//  type Vec2ExpandingStats[T] = Vec[T] => VecExpandingStats[T]
//
//  type Series2Stats[T] = Series[_, T] => VecStats[T]

  /**
   * Enrich Series with basic stats
   * @param s Series[_, T]
   */
  static /*implicit*/ VecStats<T> seriesToStats /*[T: Vec2Stats]*/ (
          Series /*[_, T]*/ s) =>
      implicitly[Vec2Stats /*[T]*/].apply(s.values);

  /**
   * Enrich Series with rolling stats
   * @param s Series[_, T]
   */
  static /*implicit*/ SeriesRollingStats<X,
      T> seriesToRollingStats /*[X: ST: ORD, T: Vec2RollingStats: ST]*/ (
          Series<X, T> s) =>
      new SeriesRollingStats<X, T>(s);

  /**
   * Enrich Series with expanding stats
   * @param s Series[_, T]
   */
  static /*implicit*/ SeriesExpandingStats<X,
      T> seriesToExpandingStats /*[X: ST: ORD, T: Vec2ExpandingStats: ST]*/ (
          Series<X, T> s) =>
      new SeriesExpandingStats /*[X, T]*/ (s);

  /**
   * Implicitly allow Series to be treated as a single-column Frame
   *
   * @param s Series to promote
   * @tparam X Type of Index
   * @tparam T Type of values Vec
   */
  static /*implicit*/ Frame<X, Int, T> serToFrame /*[X: ST: ORD, T: ST]*/ (
          Series<X, T> s) =>
      Frame(s);

  // some pimped-on logic methods. scala.Function1 is not specialized on
  // Boolean input. not sure I care to work around this

  /**
   * Enrich Boolean Series with logic methods; see definition of companion
   * object of [[org.saddle.Vec]].
   * @param v Series[_, Boolean]
   */
  static /*implicit*/ serToBoolLogic(Series /*[_, Boolean]*/ v) =>
      new Vec.vecToBoolLogic(v.toVec);

  // factory methods

  /**
   * Factory method to create an empty Series
   * @tparam X Type of keys
   * @tparam T Type of values
   */
  factory Series.empty /*[X: ST: ORD, T: ST]*/ () =>
      new Series<X, T>(new Vec.empty<T>(), new Index.empty<X>());

  /**
   * Factory method to create a Series from a Vec and an Index
   * @param values a Vec of values
   * @param index an index of keys
   * @tparam X Type of keys
   * @tparam T Type of values
   */
  factory Series.vecIndex /*[X: ST: ORD, T: ST]*/ (
          Vec<T> values, Index<X> index) =>
      new Series<X, T>(values, index);

  /**
   * Factory method to create a Series from a Vec; keys are integer offsets
   * @param values a Vec of values
   * @tparam T Type of values
   */
  factory Series.vec /*[T: ST]*/ (Vec<T> values) /*Series[Int, T]*/ =>
      new Series<Int, T>(values, new IndexIntRange(values.length));

  /**
   * Factory method to create a Series from a sequence of values; keys are integer offsets
   * @param values a sequence of values
   * @tparam T Type of values
   */
  factory Series.values /*[T: ST]*/ (List<T> values) /*: Series[Int, T]*/ =>
      new Series<Int, T>(Vec(values), new IndexIntRange(values.length));

  /**
   * Factory method to create a Series from a sequence of key/value pairs
   * @param values a sequence of (key -> value) tuples
   * @tparam T Type of value
   * @tparam X Type of key
   */
//  def apply[X: ST: ORD, T: ST](values: (X, T)*): Series<X, T> =
//    new Series<X, T>(Vec(values.map(_._2).toArray), Index(values.map(_._1).toArray))
}
