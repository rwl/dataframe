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

library saddle.index;

import 'dart:math' as math;

import 'package:quiver/iterables.dart' show range, zip;

//import scala.{specialized => spec, Array}
//import 'index/index.dart';
import 'index/reindexer.dart';
import 'index/join_type.dart';
import 'index/slice.dart';
import 'index/splitter.dart';
import 'index/stacker.dart';
import 'scalar/scalar.dart';
import 'locator/locator.dart' show Locator;
//import 'util/concat.dart' show Promoter;
import 'vec.dart';
import 'vec/vec_impl.dart' show VecImpl;
//import java.io.OutputStream
//import org.joda.time.DateTime
//import org.saddle.time.RRule
import 'scalar/scalar_tag.dart';
import 'util/util.dart' as util;
import 'time/rrule.dart';

/**
 * Index provides a constant-time look-up of a value within array-backed storage,
 * as well as operations to support joining and slicing.
 */
abstract class Index<
    T> /*[@spec(Boolean, Int, Long, Double) T] extends Serializable*/ {
  Locator locator;
//  /*protected*/ Locator get locator {
//    if (_locator == null) {
//      _locator = new Locator(scalarTag);
//    }
//    return _locator;
//  }

  /**
   * Number of elements in the index
   */
  int length;

  /**
   * A [[org.saddle.scalar.ScalarTag]] representing the kind of Scalar
   * found in this index.
   */
  ScalarTag<T> scalarTag;

  /**
   * Convert Index to a [[org.saddle.Vec]]
   */
  Vec<T> toVec();

  /**
   * Access an element directly within the index, without wrapping in a Scalar
   * box.
   * @param loc Offset into the index
   */
  T raw(int loc);

  // at method, gets index key(s) by location

  /**
   * Retrieve an element of the index at a particular offset
   * @param loc Offset into index
   */
  Scalar<T> operator [](int loc) {
    /*implicit*/ var tag = scalarTag;
    return new Scalar(raw(loc), tag);
  }

  /**
   * Retrieve several elements from the index at provided offets
   * @param locs An array of integer offsets
   */
  Index<T> at(List<int> locs) => take(locs);

  /**
   * Retrieve several elements from the index at provided offsets
   * @param locs A sequence of integer offsets
   */
//  Index<T> at(int* locs) => take(locs.toArray)

  /**
   * Given a sequence of keys, return the sequence of locations in the index
   * at which those keys correspondingly occur, ignoring keys which do not
   * exist.
   * @param keys Sequence of keys to find
   */
  List<int> call(List<T> keys) {
    var szhint = keys.length;
    var result = []; //new List<int> /*Buffer*/ (szhint);
    var i = 0;
    while (i < szhint) {
      var elems = get(keys[i]);
      var k = 0;
      while (k < elems.length) {
        result.add(elems[k]);
        k += 1;
      }
      i += 1;
    }
    return result;
  }

  /**
   * Given an array of keys, return the sequence of locations in the index
   * at which those keys correspondingly occur, ignoring keys which do not
   * exist.
   * @param keys Sequence of keys to find
   */
//  List<int> apply(List<T> keys) => apply(keys);// : _*);

  /**
   * Take values of the index at certain locations, returning a new Index
   * consisting of those values.
   *
   * See also [[org.saddle.array.take]]
   *
   * @param locs Locations to take
   */
  Index<T> take(List<int> locs);

  /**
   * Complement of the take method; return a new Index whose values are those
   * which do not occur at the specified locations.
   *
   * @param locs Locations to omit
   */
  Index<T> without(List<int> locs);

  /**
   * Concatenate two Index objects together
   *
   * @param other Other index to concatenate
   * @param p Implicit evidence of a Promoter which can send both T and B to C
   * @param mc Implicit evidence of ST[C]
   * @param oc Implicit evidence of ORD[C]
   * @tparam B Type of other index
   * @tparam C Result of promoting types A, B
   */
  Index /*<C>*/ concat /*[B, C]*/ (Index /*<B>*/ other,
      [ScalarTag stc]) /*(implicit p: Promoter[T, B, C], mc: ST[C], oc: ORD[C])*/;

  /**
   * Find the first location whereby inserting a key would maintain a sorted index. Index
   * must already be sorted.
   * @param t Key that would be inserted
   */
  int lsearch(T t);

  /**
   * Find the last location whereby inserting a key would maintain a sorted index. Index
   * must already be sorted.
   * @param t Key that would be inserted
   */
  int rsearch(T t);

  /**
   * Returns a slice of an index between two keys; if inclusive is false, then exclude
   * the upper bound. Index must be sorted, as this method relies on lsearch and rsearch.
   * @param from Key lower bound
   * @param to Key upper bound
   * @param inclusive If true (default), include upper bound in slice
   */
  Index<T> sliceByRange(T from, T to, [bool inclusive = true]) {
    if (inclusive) {
      return slice(lsearch(from), rsearch(to));
    } else {
      return slice(lsearch(from), lsearch(to));
    }
  }

  /**
   * Returns a slice of Index between two keys, including both the lower and
   * upper keys.
   * @param rng An instance of
   */
  Index<T> sliceBy(Slice<T> rng) {
    List res = rng(this);
    return slice(res[0], res[1]);
  }

  /**
   * Returns a slice of Index between two integers, including the `from` bound,
   * and excluding the `until` bound.
   * @param from Int, lower bound
   * @param until Int, one past upper bound
   * @param stride Default is 1, the step with which to advance over bound
   */
  Index<T> slice(int from, int until, [int stride = 1]);

  /**
   * Returns true if there are no duplicate keys in the Index
   */
  bool get isUnique => (locator.size == length);

  /**
   * Returns an array of unique keys in the Index, in the order in which they
   * originally appeared in the backing Vec.
   * @param ord Implicit ORD for instances of type T
   * @param tag Implicit ST for instances of type T
   */
  Index<T> uniques(/*implicit ORD<T> ord, ST<T> tag*/) =>
      new Index(new Vec(locator.keys(), scalarTag).toArray(), scalarTag);

  /**
   * Returns an array whose entries represent the number of times the corresponding
   * entry in `uniques` occurs within the index.
   */
  List<int> get counts => locator.counts();

  /**
   * Return the number of times the key occurs in the index
   * @param key The key to query
   */
  int count(T key) => locator.count(key);

  /**
   * Get first integer offset of a key
   * @param key Key to find in index
   */
  int getFirst(T key) => locator.get(key);

  /**
   * Get last integer offset of a key
   * @param key Key to find in index
   */
  int getLast(T key) {
    var loc = getFirst(key);
    if (loc == -1) {
      return -1;
    } else if (isContiguous) {
      return loc + locator.count(key) - 1;
    } else {
      var i = loc + 1;
      var c = locator.count(key);
      while (c > 1 && i < length) {
        if (raw(i) == key) c -= 1;
        i += 1;
      }
      return i - 1;
    }
  }

  /**
   * Get location offsets within Index given a particular key
   * @param key Key with which to search
   */
  List<int> get(T key) {
    var firstLoc = locator.get(key);
    int count = locator.count(key);
    if (firstLoc == -1) {
      return new List<int>();
    } else if (isUnique || count == 1) {
      return [locator.get(key)];
    } else if (isContiguous) {
      return range(firstLoc, firstLoc + count)
          .map((num a) => a.toInt())
          .toList();
    } else {
      var result = new List<int>(count);
      var loc = firstLoc;
      var i = 0;
      while (loc < length && count != 0) {
        if (raw(loc) == key) {
          result[i] = loc;
          i += 1;
          count -= 1;
        }
        loc += 1;
      }
      return result;
    }
  }

  /**
   * Returns a slice comprised of at most the first n elements of the Index
   * @param n Number of elements to slice
   */
  Index<T> head(int n) => slice(0, math.min(n, length));

  /**
   * Returns a slice comprised of at most the last n elements of the Index
   * @param n Number of elements to slice
   */
  Index<T> tail(int n) => slice(math.max(length - n, 0), length);

  /**
   * Returns the first element of the Index, or NA if there is none
   */
  Scalar<T> get first => (length > 0) ? this[0] : NA;

  /**
   * Returns the last element of the Index, or NA if there is none
   */
  Scalar<T> get last => (length > 0) ? this[length - 1] : NA;

  /**
   * Returns the index in sorted (ascending) order
   */
  Index<T> get sorted => take(argSort());

  /**
   * Returns the index in reversed order
   */
  Index<T> get reversed;

  /**
   * Returns the int location of the first element of the index to satisfy the predicate function,
   * or -1 if no element satisfies the function.
   * @param pred Function from T => Boolean
   */
  int findOne(bool pred(T arg)) => VecImpl.findOne(toVec(), pred);

  /**
   * Returns true if there is an element which satisfies the predicate function,
   * @param pred Function from T => Boolean
   */
  bool exists(bool pred(T arg)) => findOne(pred) != -1;

  /**
   * For an index which contains Tuples, drop the right-most element of each tuple, resulting
   * in a new index.
   * @param ev Implicit evidence of a Splitter instance that takes T (of arity N) to U (of arity N-1)
   * @tparam U Type of elements of result index
   */
  Index /*<U>*/ dropLevel /*[U, _]*/ (/*implicit*/ Splitter /*[T, U, _]*/ ev) =>
      ev(this).left;

  /**
   * Given this index whose elements have arity N and another index of arity 1, form a result
   * index whose entries are tuples of arity N+1 reflecting the Cartesian product of the two,
   * in the provided order. See [[org.saddle.index.Stacker]] for more details.
   * @param other Another Index
   * @param ev Implicit evidence of a Stacker
   * @tparam U The input type, of arity 1
   * @tparam V The result type, of arity N+1
   */
  Index /*<V>*/ stack /*[U, V]*/ (Index /*<U>*/ other,
          Stacker /*[T, U, V]*/ ev) /*(implicit Stacker[T, U, V] ev)*/ =>
      ev(this, other);

  /**
   * Given this index contains tuples of arity N > 1, split will result in a pair of index
   * instances; the left will have elements of arity N-1, and the right arity 1.
   * @param ev Implicit evidence of an instance of Splitter
   * @tparam O1 Left index type (of arity N-1)
   * @tparam O2 Right index type (of arity 1)
   */
  /*(Index[O1], Index[O2])*/ split /*[O1, O2]*/ (
          /*implicit*/ Splitter /*[T, O1, O2]*/ ev) =>
      ev(this);

  /**
   * Generates offsets into current index given another index for the purposes of
   * re-indexing. For more on reindexing, see [[org.saddle.index.ReIndexer]]. If
   * the current and other indexes are equal, a value of None is returned.
   *
   * @param other The other index with which to generate offsets
   */
  /*Option<*/ List<int> getIndexer(Index<T> other) {
    var ixer = this.join(other, JoinType.RightJoin);
    if (ixer.index.length != other.length) {
      throw "Could not reindex unambiguously";
    }
    return ixer.lTake;
  }

  /**
   * Returns true if the index contains at least one entry equal to the provided key
   * @param key Key to query
   */
  bool contains(T key) => locator.contains(key);

  /**
   * Produces a [[org.saddle.index.ReIndexer]] corresponding to the intersection of
   * this Index with another. Both indexes must have set semantics - ie, have no
   * duplicates.
   *
   * @param other The other index
   */
  ReIndexer<T> intersect(Index<T> other);

  /**
   * Produces a [[org.saddle.index.ReIndexer]] corresponding to the union of
   * this Index with another. Both indexes must have set semantics - ie, have no
   * duplicates.
   *
   * @param other The other index
   */
  ReIndexer<T> union(Index<T> other);

  // default implementation, could be sped up in specialized instances
  /**
   * Returns true if the ordering of the elements of the Index is non-decreasing.
   */
  bool get isMonotonic;

  /**
   * Returns true if the index is either unique, or any two or more duplicate keys
   * occur in consecutive locations in the index.
   */
  bool get isContiguous;

  /**
   * Returns offsets into index that would result in sorted index
   */
  List<int> argSort();

  // sql-style joins

  /**
   * Allows for the following SQL-style joins between this index and another:
   *
   *   - [[org.saddle.index.LeftJoin]]
   *   - [[org.saddle.index.RightJoin]]
   *   - [[org.saddle.index.InnerJoin]]
   *   - [[org.saddle.index.OuterJoin]]
   *
   * @param other Another index
   * @param how join type, see [[org.saddle.index.JoinType]]
   */
  ReIndexer<T> join(Index<T> other, [JoinType how = JoinType.LeftJoin]);

  /**
   * Given a key, return the previous value in the Index (in the natural, ie supplied,
   * order). The Index must at least be contiguous, if not unique.
   *
   * @param current Key value to find
   */
  Scalar<T> prev(Scalar<T> current) {
    /*implicit*/ var tag = scalarTag;

    if (!isContiguous) {
      throw new IndexException(
          "Cannot traverse index that is not contiguous in its values");
    }

    var prevSpot = locator.get(current.get) - 1;
    if (prevSpot >= 0) {
      // TODO: check
      return new Scalar(raw(prevSpot), tag);
    } else {
      return current;
    }
//    switch (prevSpot) {
//      case x:
//        if (x >= 0) {
//          return raw(x);
//        }
//        break;
//      default:
//        return current;
//    }
  }

  /**
   * Given a key, return the next value in the Index (in the natural, ie supplied,
   * order). The Index must at least be contiguous, if not unique.
   *
   * @param current Key value to find
   */
  Scalar<T> next(Scalar<T> current) {
    /*implicit*/ var tag = scalarTag;

    if (!isContiguous) {
      throw new IndexException(
          "Cannot traverse index that is not contiguous in its values");
    }

    var nextSpot = locator.get(current.get) + locator.count(current.get);
    if (nextSpot < length) {
      // TODO: check
      return new Scalar<T>(raw(nextSpot), tag);
    } else {
      return current;
    }
//    nextSpot match {
//      case x if x < length => raw(x)
//      case _               => current
//    }
  }

  /**
   * Map over the elements in the Index, producing a new Index, similar to Map in the
   * Scala collections.
   *
   * @param f Function to map with
   * @tparam B Type of resulting elements
   */
  Index /*<B>*/ map /*[@spec(Boolean, Int, Long, Double) B: ST: ORD]*/ (
      dynamic f(T arg), ScalarTag scb);

  /**
   * Convert Index elements to an IndexedSeq.
   *
   */
  /*IndexedSeq*/ List<T> toSeq() => new List.from(toArray_()); //.toIndexedSeq;

  /*private[saddle]*/ List<T> toArray_();

  /** Default hashcode is simple rolling prime multiplication of sums of hashcodes for all values. */
  @override
  int get hashCode =>
      /*toArray().fold(
      1,
      (a, b) =>
          a * 31 + b.hashCode);*/
      toVec().foldLeft(1, (a, b) => a * 31 + b.hashCode);

  /** Default equality does an iterative, element-wise equality check of all values. */
  @override
  bool operator ==(o) {
    if (o is Index) {
      var rv = o as Index;
      if (identical(this, rv)) {
        return true;
      } else if (length != rv.length) {
        return false;
      } else {
        var i = 0;
        var eq = true;
        while (eq && i < this.length) {
          eq = eq && raw(i) == rv.raw(i);
          i += 1;
        }
        return eq;
      }
    } else {
      return false;
    }
  }

  /**
   * Creates a string representation of Index
   * @param len Max number of elements to include
   */
  String stringify([int len = 10]) {
    var half = len ~/ 2;

    var buf = new StringBuffer();

    List maxf(List<int> a, List<String> b) =>
        zip([a, b]).map((v) => v[0].max(v[1].length)).toList();

    var varr = toArray_();
    var sm = scalarTag;

    if (varr.length == 0) {
      buf.write("Empty Index");
    } else {
      List vlens = util
          .grab(varr, half)
          .map((a) => sm.strList(a))
          .toList()
          .fold(sm.strList(varr[0]).map((b) => b.length), maxf);

      buf.write("[Index $length x 1]\n");

      createRow(int r) {
        var lst = zip([vlens, sm.strList(raw(r))])
            .map((z) => "${z[1]}".padLeft(z[0]))
            .toList();
        return lst.join(" ") + "\n";
      }

      buf.write(util.buildStr(len, length, createRow, () => " ... \n"));
    }

    return buf.toString();
  }

  /**
   * Pretty-printer for Index, which simply outputs the result of stringify.
   * @param len Number of elements to display
   */
//  print([int len = 10, OutputStream stream /* = System.out*/]) {
//    stream.write(stringify(len).getBytes);
//  }

  @override
  toString() => stringify();
//}
//
//class Index {
  Index.internal();

  /**
   * Factory method to create an index from a Vec of elements
   * @param values Vec
   * @tparam C Type of elements in Vec
   */
//  Index/*<C> apply[C: ST: ORD]*/(Vec<C> values) => implicitly[ST[C]].makeIndex(values);
  factory Index.fromVec(Vec values, ScalarTag st) {
    return st.makeIndex(values);
  }

  /**
   * Factory method to create an index from an array of elements
   * @param arr Array
   * @tparam C Type of elements in array
   */
//  Index<C> apply/*[C: ST: ORD]*/(Array<C> arr) => apply(Vec(arr));
  factory Index(List arr, ScalarTag st) =>
      new Index.fromVec(new Vec(arr, st), st);

  /**
   * Factory method to create an index from a sequence of elements, eg
   *
   * {{{
   *   Index(1,2,3)
   *   Index(IndexedSeq(1,2,3) : _*)
   * }}}
   *
   * @param values Seq[C]
   * @tparam C Type of elements in Seq
   */
//  Index<C> apply/*[C: ST: ORD]*/(C* values) => apply(values.toArray);

  /**
   * Factory method to create an Index; the basic use case is to construct
   * a multi-level index (i.e., an Index of Tuples) via a Tuple of Vecs.
   *
   * For instance:
   *
   * {{{
   *   Index.make(vec.rand(10), vec.rand(10))
   * }}}
   *
   * @param values Values from which to construct the index
   * @param ev Implicit evidence of an IndexMaker that can utilize values
   * @tparam I The type of the values input
   * @tparam O The type of the elements of the result index
   */
//  Index<O> make/*[I, O]*/(I values)/*(implicit IndexMaker<I, O> ev)*/ => ev(values);

  /**
   * Factory method to create an Index from a recurrence rule between two
   * dates.
   *
   * For instance:
   *
   * {{{
   *   Index.make(RRules.bizEoms, datetime(2005,1,1), datetime(2005,12,31))
   * }}}
   *
   * @param rrule Recurrence rule to use
   * @param start The earliest datetime on or after which to being the recurrence
   * @param end   The latest datetime on or before which to end the recurrence
   */
  Index<DateTime> make(RRule rrule, DateTime start, DateTime end) {
//    import time._
//    Index((rrule.copy(count = None) withUntil end from start).toSeq : _*)
  }

  /**
   * Factor method to create an empty Index
   * @tparam C type of Index
   */
  factory Index.empty(ScalarTag<T> st) /*[C: ST: ORD]*/ => new Index([], st);

  // (safe) conversions

  /**
   * An array may be implicitly converted to an Index
   * @param arr Array
   * @tparam C Type of elements in array
   */
  /*implicit*/ arrayToIndex /*[C: ST: ORD]*/ (List /*<C>*/ arr, ScalarTag st) =>
      new Index(arr, st);

  /**
   * A Vec may be implicitly converted to an Index
   * @param s Vec
   * @tparam C Type of elements in Vec
   */
  /*implicit*/ vecToIndex /*[C: ST: ORD]*/ (Vec /*<C>*/ s) =>
      new Index(s.toArray(), s.scalarTag);
}

/**
 * Provides an index-specific exception
 * @param err Error message
 */
class IndexException implements Exception {
  final String err;
  IndexException(this.err); // : super(err);

  toString() => err;
}
