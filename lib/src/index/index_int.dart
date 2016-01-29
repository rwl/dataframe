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

library saddle.index.int;

//import scala.{specialized => spec}
//import java.util.Arrays._
//import org.saddle._
//import util.Concat.Promoter
//import index.IndexImpl.IndexProperties
//import vec.VecImpl
//import locator.Locator
//import org.saddle.scalar._

import 'package:collection/algorithms.dart' show binarySearch;

import '../array/array.dart';
import '../index.dart';
import 'join_type.dart';
import '../vec.dart';
import '../scalar/scalar_tag.dart';
import '../scalar/scalar_tag_int.dart';
import '../locator/locator.dart';
import '../index/reindexer.dart';
import '../index/joiner_impl.dart';
import '../vec/vec_impl.dart';

import 'index_impl.dart';

/**
 * Index with integer keys
 */
class IndexInt extends Index<int> {
  Vec<int> keys;

  IndexInt(this.keys) : super.internal();

  ScalarTag<int> scalarTag = ScalarTagInt;

//  private lazy val (lmap, IndexProperties(contiguous, monotonic)) = IndexImpl.keys2map(this)
  Keys2Map<int> __keys2map = null;
  Keys2Map<int> get _keys2map {
    if (__keys2map == null) {
      __keys2map = IndexImpl.keys2map(this, scalarTag);
    }
    return __keys2map;
  }

  /*protected*/ Locator<int> get locator => _keys2map.locator;

  int get length => keys.length;

  Vec<int> toVec() => keys;

  // get the key at the position specified
  int raw(int idx) => keys[idx];

  Index<int> take(List<int> locs) => new Index(
      array.take(keys.toArray(), locs, IndexImpl.sentinelErr), scalarTag);

  Index<int> without(List<int> locs) =>
      new Index(array.remove(keys.toArray(), locs), scalarTag);

  Index /*<C>*/ concat /*[B, C]*/ (
          Index /*<B>*/ x) /*(implicit wd: Promoter[Int, B, C], mc: ST[C], oc: ORD[C])*/ =>
      new Index(util.Concat.append /*[Int, B, C]*/ (toArray, x.toArray));

  bool get isMonotonic => _keys2map.props.monotonic;

  bool get isContiguous => isUnique || _keys2map.props.contiguous;

  List<int> argSort() => array.argsort(keys.toArray(), scalarTag);

  Index<int> get reversed => new IndexInt(toVec().reversed);

  ReIndexer<int> join(Index<int> other, [JoinType how = JoinType.LeftJoin]) =>
      JoinerImpl.join(this, other, how);

  // Intersects two indices if both have set semantics
  ReIndexer<int> intersect(Index<int> other) {
    if (!this.isUnique || !other.isUnique) {
      throw new IndexException("Cannot intersect non-unique indexes");
    }
    return JoinerImpl.join(this, other, JoinType.InnerJoin);
  }

  // Unions two indices if both have set semantics
  ReIndexer<int> union(Index<int> other) {
    if (!this.isUnique || !other.isUnique) {
      throw new IndexException("Cannot union non-unique indexes");
    }
    return JoinerImpl.join(this, other, JoinType.OuterJoin);
  }

  Index<int> slice(int from, int until, [int stride = 1]) {
    return new IndexInt(keys.slice(from, until, stride));
  }

  // find the first location whereby an insertion would maintain a sorted index
  int lsearch(int t) {
    if (!isMonotonic) {
      throw "Index must be sorted";
    }

    var fnd = locator.count(t);

    if (fnd > 0) {
      return locator.get(t);
    } else {
      return -(binarySearch(keys, t) + 1);
    }
  }

  // find the last location whereby an insertion would maintain a sorted index
  int rsearch(int t) {
    if (!isMonotonic) {
      throw "Index must be sorted";
    }

    var fnd = locator.count(t);

    if (fnd > 0) {
      return fnd + locator.get(t);
    } else {
      return -(binarySearch(keys, t) + 1);
    }
  }

  Index /*<B>*/ map /*[@spec(Boolean, Int, Long, Double) B: ST: ORD]*/ (
          dynamic f(int arg), ScalarTag sb) =>
      new Index(VecImpl.map(keys, f, sb).toArray(), sb);

  List<int> toArray_() => keys.toArray();

  /**Default equality does an iterative, element-wise equality check of all values. */
  @override
  bool operator ==(o) {
    if (o is IndexInt) {
      var rv = o as IndexInt;
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
