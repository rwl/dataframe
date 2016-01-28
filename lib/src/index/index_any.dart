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
import '../vec.dart';
import '../array/array.dart';
import '../scalar/scalar_tag.dart';
import '../locator/locator.dart';
import '../vec/vec_impl.dart';
import 'join_type.dart';
import 'index_impl.dart';
import 'reindexer.dart';
import 'joiner_impl.dart';

/**
 * An implementation of [[org.saddle.Index]] generic in type T for which there is an Ordering<T>
 * and a ST<T> available in the implicit context.
 */
class IndexAny<T> /*[T: ST: ORD]*/ extends Index<T> {
  final Vec<T> keys;
  IndexAny(this.keys) : super.internal() {
    scalarTag = keys.scalarTag;
  }

  ScalarTag<T> scalarTag;

//  /*private lazy*/ val (lmap, IndexProperties(contiguous, monotonic)) = IndexImpl.keys2map(this)
  Keys2Map<T> __keys2map = null;
  Keys2Map<T> get _keys2map {
    if (__keys2map == null) {
      __keys2map = IndexImpl.keys2map(this, scalarTag);
    }
    return __keys2map;
  }

  /*protected*/ Locator<T> get locator => _keys2map.locator;

  int get length => keys.length;

  Vec<T> toVec() => keys;

  // get the key at the position specified
  T raw(int idx) => keys[idx];

  Index<T> take(List<int> locs) => new Index(
      array.take(keys.toArray(), locs, IndexImpl.sentinelErr), scalarTag);

  Index<T> without(List<int> locs) =>
      new Index(array.remove(keys.toArray(), locs), scalarTag);

  Index /*<C>*/ concat /*[B, C]*/ (Index /*<B>*/ x,
          ScalarTag scc) /*(implicit wd: Promoter[T, B, C], mc: ST[C], oc: ORD[C])*/ =>
      new Index(
          util.Concat.append /*[T, B, C]*/ (toArray_(), x.toArray_()), scc);

  bool get isMonotonic => _keys2map.props.monotonic;

  bool get isContiguous => isUnique || _keys2map.props.contiguous;

  /** Returns offsets into index that would result in sorted index */
  List<int> argSort() => array.argsort(keys.toArray(), scalarTag);

  Index<T> get reversed => new IndexAny<T>(toVec().reversed);

  ReIndexer<T> join(Index<T> other, [JoinType how = JoinType.LeftJoin]) =>
      JoinerImpl.join(this, other, how);

  // Intersects two indices if both have set semantics
  ReIndexer<T> intersect(Index<T> other) {
    if (!this.isUnique || !other.isUnique) {
      throw new IndexException("Cannot intersect non-unique indexes");
    }
    return JoinerImpl.join(this, other, JoinType.InnerJoin);
  }

  // Unions two indices if both have set semantics
  ReIndexer<T> union(Index<T> other) {
    if (!this.isUnique || !other.isUnique) {
      throw new IndexException("Cannot union non-unique indexes");
    }
    return JoinerImpl.join(this, other, JoinType.OuterJoin);
  }

  Index<T> slice(int from, int until, [int stride = 1]) {
    return new Index<T>(keys.slice(from, until, stride).toArray(), scalarTag);
  }

  // find the first location whereby an insertion would maintain a sorted index
  int lsearch(T t) {
    if (!isMonotonic) {
      throw "Index must be sorted";
    }

    var fnd = locator.count(t);

    if (fnd > 0) {
      return locator.get(t);
    } else {
      return -(binarySearch(keys.toArray(), t) + 1);
    }
  }

  // find the last location whereby an insertion would maintain a sorted index
  int rsearch(T t) {
    if (!isMonotonic) {
      throw "Index must be sorted";
    }

    var fnd = locator.count(t);

    if (fnd > 0) {
      return fnd + locator.get(t);
    } else {
      return -(binarySearch(keys.toArray(), t) + 1);
    }
  }

  // adapted from java source
  /*private*/ int binarySearch(List<T> a, T key) {
    /*@tailrec*/ int bSearch([int lo = 0, int hi]) {
      if (hi == null) {
        hi = a.length - 1;
      }
      if (lo > hi) {
        return -(lo + 1);
      } else {
        int mid = ((lo + hi) & 0xFFFFFFFF) >> 1; // TODO: check 32-bit shift
        T midVal = a[mid];
        if (scalarTag.lt(midVal, key)) {
          return bSearch(mid + 1, hi);
        } else if (scalarTag.gt(midVal, key)) {
          return bSearch(lo, mid - 1);
        } else {
          return mid;
        }
      }
    }
    return bSearch(0, a.length - 1);
  }

  Index /*<B>*/ map /*[@spec(Boolean, Int, Long, Double) B: ST: ORD]*/ (
          dynamic f(T arg), ScalarTag scb) =>
      new Index(VecImpl.map(keys, f, scb).toArray(), scb);

  List<T> toArray_() => keys.toArray();

  /**Default equality does an iterative, element-wise equality check of all values. */
  @override
  bool operator ==(o) {
    if (o is IndexAny) {
      var rv = o as IndexAny;
      if (identical(this, rv)) {
        return true;
      } else if (length != rv.length) {
        return false;
      } else {
        var i = 0;
        bool eq = true;
        while (eq && i < this.length) {
          eq = eq && raw(i) == rv.raw(i);
          i += 1;
        }
        return eq;
      }
    } else {
      return super == o;
    }
  }
}
