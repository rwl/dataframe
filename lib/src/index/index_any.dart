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

//import scala.{specialized => spec}
//import annotation.tailrec
//import org.saddle._
//import util.Concat.Promoter
//import index.IndexImpl.IndexProperties
//import vec.VecImpl
//import locator.Locator

import '../index.dart';
import 'join_type.dart';

/**
 * An implementation of [[org.saddle.Index]] generic in type T for which there is an Ordering<T>
 * and a ST<T> available in the implicit context.
 */
class IndexAny<T> /*[T: ST: ORD]*/ extends Index<T> {
  IndexAny(Vec<T> keys) : super.internal();

  val scalarTag = keys.scalarTag;

//  /*private lazy*/ val (lmap, IndexProperties(contiguous, monotonic)) = IndexImpl.keys2map(this)

  /*protected*/ Locator<T> locator = lmap;

  int length = keys.length;

  Vec<T> toVec() => keys;

  // get the key at the position specified
  T raw(int idx) => keys(idx);

  Index<T> take(Array<int> locs) =>
      Index(array.take(keys, locs, IndexImpl.sentinelErr));

  Index<T> without(Array<int> locs) => Index(array.remove(keys, locs));

  Index<C> concat /*[B, C]*/ (Index<
          B> x) /*(implicit wd: Promoter[T, B, C], mc: ST[C], oc: ORD[C])*/ =>
      Index(util.Concat.append /*[T, B, C]*/ (toArray, x.toArray));

  bool get isMonotonic => monotonic;

  bool get isContiguous => isUnique || contiguous;

  /** Returns offsets into index that would result in sorted index */
  Array<int> argSort() => array.argsort(keys.toArray);

  Index<T> get reversed => new IndexAny<T>(toVec.reversed);

  ReIndexer<T> join(Index<T> other, [JoinType how = JoinType.LeftJoin]) =>
      JoinerImpl.join(this, other, how);

  // Intersects two indices if both have set semantics
  ReIndexer<T> intersect(Index<T> other) {
    if (!this.isUnique || !other.isUnique) {
      throw Index.IndexException("Cannot intersect non-unique indexes");
    }
    JoinerImpl.join(this, other, InnerJoin);
  }

  // Unions two indices if both have set semantics
  ReIndexer<T> union(Index<T> other) {
    if (!this.isUnique || !other.isUnique) {
      throw Index.IndexException("Cannot union non-unique indexes");
    }
    JoinerImpl.join(this, other, OuterJoin);
  }

  Index<T> slice(int from, int until, int stride) {
    new Index<T>(keys.slice(from, until, stride));
  }

  // find the first location whereby an insertion would maintain a sorted index
  int lsearch(T t) {
    require(isMonotonic, "Index must be sorted");

    val fnd = locator.count(t);

    if (fnd > 0) {
      locator.get(t);
    } else {
      -(binarySearch(keys, t) + 1);
    }
  }

  // find the last location whereby an insertion would maintain a sorted index
  int rsearch(T t) {
    require(isMonotonic, "Index must be sorted");

    val fnd = locator.count(t);

    if (fnd > 0) {
      fnd + locator.get(t);
    } else {
      -(binarySearch(keys, t) + 1);
    }
  }

  // adapted from java source
  /*private*/ int binarySearch(Array<T> a, T key) {
    /*@tailrec*/ int bSearch([int lo = 0, int hi]) {
      if (hi == null) {
        hi = a.length - 1;
      }
      if (lo > hi) {
        -(lo + 1);
      } else {
//        int mid = (lo + hi) >>> 1
        T midVal = a(mid);
        if (scalarTag.lt(midVal, key)) {
          bSearch(mid + 1, hi);
        } else if (scalarTag.gt(midVal, key)) {
          bSearch(lo, mid - 1);
        } else {
          mid;
        }
      }
    }
    bSearch(0, a.length - 1);
  }

  Index<B> map /*[@spec(Boolean, Int, Long, Double) B: ST: ORD]*/ (
          b f(T arg)) =>
      Index(VecImpl.map(keys)(f).toArray);

  Array<T> toArray() => keys.toArray;

  /**Default equality does an iterative, element-wise equality check of all values. */
  @override
  bool equals(o) {
    /*o match {
      case rv: IndexInt => (this eq rv) || (this.length == rv.length) && {
        var i = 0
        var eq = true
        while(eq && i < this.length) {
          eq &&= raw(i) == rv.raw(i)
          i += 1
        }
        eq
      }
      case _ => super.equals(o)
    }*/
  }
}
