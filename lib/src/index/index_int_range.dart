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

library saddle.index.int_range;

//import scala.{specialized => spec}
//import org.saddle._
//import org.saddle.scalar._
//import util.Concat.Promoter
//import vec.VecInt
//import locator.Locator

import 'dart:math' as math;

import '../index.dart';
import '../scalar/scalar_tag.dart';
import '../scalar/scalar_tag_int.dart';
import '../array/array.dart';
import '../vec.dart';
import '../vec/vec_int.dart';
import 'join_type.dart';

/**
 * An implementation of an Index<int> which implicitly represents a bound of integers,
 * which lazily generates its elements as an array when needed. This compact representation
 * is the default when creating a Saddle object such as [[org.saddle.Series]] which
 * requires and index and one is not supplied.
 */
class IndexIntRange extends Index<int> {
  int length, from;

  IndexIntRange(this.length, [this.from = 0]) : super.internal() {
    if (length < 0) {
      throw new ArgumentError("Length must be non-negative");
    }
  }

  /*@transient lazy*/ ScalarTag scalarTag = ScalarTagInt;

  /*@transient private lazy*/ get asArr => array.range(from, from + length);
  /*@transient private lazy*/ get genIdx => new Index(asArr, scalarTag);

  /**
   * Custom implementation of a Locator to serve as the backing map in a
   * more space-efficient manner than the full blown LocatorInt implementation.
   */
//  protected def locator = new Locator<int> {
//    def size = length
//
//    lazy val cts = {
//      val res = Array.ofDim<int>(length)
//      var i = 0
//      while (i < length) {
//        res(i) = 1
//        i += 1
//      }
//      res
//    }
//
//    def contains(key: Int) = key >= from && key < from + length
//    def get(key: Int) = if (contains(key)) key - from else -1
//    def count(key: Int) = if (contains(key)) 1 else 0
//
//    def put(key: Int, value: Int) { sys.error("Not supported") }
//    def inc(key: Int) = sys.error("Not supported")
//    def keys() = asArr
//    def counts() = cts
//  }

  /*private*/ int guardLoc(int loc) {
    if (loc < 0 || loc >= length) {
      throw new IndexError(loc, this, "Location $loc is out of bounds");
    } else {
      return loc;
    }
  }

  raw(int loc) => from + guardLoc(loc);

  Vec<int> toVec() => new Vec(asArr, scalarTag);

  // take values of index at certain locations
  take(List<int> locs) => new Index(
      new VecInt(locs)
          .map((i) => (i == -1) ? IndexImpl.sentinelErr : guardLoc(i) + from,
              scalarTag)
          .toArray(),
      scalarTag);

  Index<int> without(List<int> locs) =>
      new Index<int>(array.remove(asArr, locs), scalarTag);

  Index /*[C]*/ concat /*[B, C]*/ (Index /*[B]*/ x,
          ScalarTag scc) /*(implicit wd: Promoter[Int, B, C], mc: ST[C], oc: ORD[C])*/ =>
      new Index(util.Concat.append /*[Int, B, C]*/ (toArray, x.toArray), scc);

  // find the first location whereby an insertion would maintain a sorted index
  lsearch(int t) => math.min(math.max(0, from + t), from + length);

  // find the last location whereby an insertion would maintain a sorted index
  rsearch(int t) => math.min(math.max(0, from + t + 1), from + length);

  // slice at array locations, [from, until)
  slice(int from, int until, int stride) {
    if (stride == 1) {
      return new IndexIntRange(math.min(length, until - from),
          math.max(this.from + math.max(from, 0), 0));
    } else {
      return genIdx.slice(from, until, stride);
    }
  }

  getAll(List<int> keys) => new VecInt(keys)
      .filter((a) => locator.contains(a))
      .map((b) => b - from, scalarTag)
      .toArray();

  bool get isMonotonic => true;

  bool get isContiguous => true;

  argSort() => asArr();

  get reversed => new Index(asArr, scalarTag).reversed;

  intersect(Index<int> other) =>
      JoinerImpl.join(this, other, JoinType.InnerJoin);

  union(Index<int> other) => JoinerImpl.join(this, other, JoinType.OuterJoin);

  ReIndexer<int> join(Index<int> other, [JoinType how = JoinType.LeftJoin]) =>
      JoinerImpl.join(this, other, how);

  Index /*[B]*/ map /*[@spec(Boolean, Int, Long, Double) B: ST: ORD]*/ (
          dynamic f(int arg)) =>
      genIdx.map(f);

  /*private[saddle]*/ toArray_() => asArr;
}

//object IndexIntRange {
//  def apply(length: Int, from: Int = 0) = new IndexIntRange(length, from)
//}
