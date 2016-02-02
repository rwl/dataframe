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

library saddle.index.bool;

//import scala.{specialized => spec}
//import org.saddle._
//import vec.{VecImpl, VecBool}
//import util.Concat.Promoter
//import index.IndexImpl.IndexProperties
//import locator.Locator
//import org.saddle.scalar._

import '../array/array.dart';
import '../index.dart';
import 'join_type.dart';
import '../vec.dart';
import '../scalar/scalar_tag.dart';
import '../scalar/scalar_tag_bool.dart';
import '../locator/locator.dart';
import '../index/reindexer.dart';
import '../index/joiner_impl.dart';
import '../vec/vec_impl.dart';
import '../vec/vec_bool.dart';
import '../util/concat.dart';

import 'index_impl.dart';

/**
 * Index with integer keys
 */
class IndexBool extends Index<bool> {
  Vec<bool> keys;
  IndexBool(this.keys) : super.internal();

  ScalarTag scalarTag = ScalarTagBool;

//  private lazy val (kmap, IndexProperties(contiguous, monotonic)) = IndexImpl.keys2map(this)Keys2Map<int> __keys2map = null;
  Keys2Map<bool> __keys2map = null;
  Keys2Map<bool> get _keys2map {
    if (__keys2map == null) {
      __keys2map = IndexImpl.keys2map(this, scalarTag);
    }
    return __keys2map;
  }

  /*protected*/ Locator<bool> get locator => _keys2map.locator;

  int get length => keys.length;

  Vec<bool> toVec() => keys;

  // get the key at the position specified
  bool raw(int idx) => keys[idx];

  Index<bool> take(List<int> locs) => new Index<bool>(
      array.take(keys.toArray(), locs, () => IndexImpl.sentinelErr), scalarTag);

  Index<bool> without(List<int> locs) =>
      new Index<bool>(array.remove(keys.toArray(), locs), scalarTag);

  Index /*[C]*/ concat /*[B, C]*/ (Index /*<B>*/ x,
      [ScalarTag stc]) /*(implicit wd: Promoter[Boolean, B, C], mc: ST[C], oc: ORD[C])*/ {
    if (stc == null) {
      stc = scalarTag;
    }
    return new Index(
        Concat.append /*[Boolean, B, C]*/ (
            toArray_(), x.toArray_(), scalarTag, x.scalarTag, stc),
        stc);
  }

  bool get isMonotonic => _keys2map.props.monotonic;

  bool get isContiguous => isUnique || _keys2map.props.contiguous;

  List<int> argSort() => VecBool.argSort(keys.toArray());

  Index<bool> get reversed => new IndexBool(toVec().reversed);

  ReIndexer<bool> join(Index<bool> other, [JoinType how = JoinType.LeftJoin]) =>
      JoinerImpl.join(this, other, how);

  // Intersects two indices if both have set semantics
  ReIndexer<bool> intersect(Index<bool> other) {
    if (!this.isUnique || !other.isUnique) {
      throw new IndexException("Cannot intersect non-unique indexes");
    }
    return JoinerImpl.join(this, other, JoinType.InnerJoin);
  }

  // Unions two indices if both have set semantics
  ReIndexer<bool> union(Index<bool> other) {
    if (!this.isUnique || !other.isUnique) {
      throw new IndexException("Cannot union non-unique indexes");
    }
    return JoinerImpl.join(this, other, JoinType.OuterJoin);
  }

  Index<bool> slice(int from, int until, [int stride = 0]) {
    return new IndexBool(keys.slice(from, until, stride));
  }

  // find the first location whereby an insertion would maintain a sorted index
  int lsearch(bool t) {
    if (!isMonotonic) {
      throw "Index must be sorted";
    }
    return locator.get(t);
  }

  // find the last location whereby an insertion would maintain a sorted index
  int rsearch(bool t) {
    if (!isMonotonic) {
      throw "Index must be sorted";
    }
    return locator.get(t) + locator.count(t);
  }

  Index /*<B>*/ map /*[@spec(Boolean, Int, Long, Double) B:ST: ORD]*/ (
          dynamic f(bool arg), ScalarTag scb) =>
      new Index(VecImpl.map(keys, f, scb).toArray(), scb);

  List<bool> toArray_() => keys.toArray();

  /**Default equality does an iterative, element-wise equality check of all values. */
  @override
  bool operator ==(o) {
    if (o is IndexBool) {
      var rv = o as IndexBool;
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
