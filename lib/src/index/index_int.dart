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
//import java.util.Arrays._
//import org.saddle._
//import util.Concat.Promoter
//import index.IndexImpl.IndexProperties
//import vec.VecImpl
//import locator.Locator
//import org.saddle.scalar._

import '../array/array.dart';
import '../index.dart';
import 'join_type.dart';
import '../vec.dart';
import '../scalar/scalar_tag.dart';
import '../scalar/scalar_tag_int.dart';
import '../locator/locator.dart';
import '../index/reindexer.dart';
import '../index/joiner_impl.dart';

import 'index_impl.dart';

/**
 * Index with integer keys
 */
class IndexInt extends Index<int> {
  Vec<int> keys;

  IndexInt(this.keys) : super.internal();

  ScalarTag<int> scalarTag = ScalarTagInt;

//  private lazy val (lmap, IndexProperties(contiguous, monotonic)) = IndexImpl.keys2map(this)
  IndexProperties _properties;
  IndexProperties get properties {
    if (_properties == null) {
      _properties = new IndexProperties(this);
    }
    return _properties;
  }

  /*protected*/ Locator<int> get locator => properties.map;

  int get length => keys.length;

  Vec<int> toVec() => keys;

  // get the key at the position specified
  int raw(int idx) => keys[idx];

  Index<int> take(List<int> locs) =>
      new Index(array.take(keys, locs, IndexImpl.sentinelErr), scalarTag);

  Index<int> without(List<int> locs) => Index(array.remove(keys, locs));

  Index<C> concat /*[B, C]*/ (Index<
          B> x) /*(implicit wd: Promoter[Int, B, C], mc: ST[C], oc: ORD[C])*/ =>
      new Index(util.Concat.append /*[Int, B, C]*/ (toArray, x.toArray));

  bool get isMonotonic => properties.monotonic;

  bool get isContiguous => isUnique || properties.contiguous;

  List<int> argSort() => array.argsort(keys.toArray);

  Index<int> get reversed => new IndexInt(toVec().reversed);

  ReIndexer<int> join(Index<int> other, [JoinType how = JoinType.LeftJoin]) =>
      JoinerImpl.indexJoin(this, other, how);

  // Intersects two indices if both have set semantics
  ReIndexer<int> intersect(Index<int> other) {
    if (!this.isUnique || !other.isUnique) {
      throw Index.IndexException("Cannot intersect non-unique indexes");
    }
    JoinerImpl.join(this, other, JoinType.InnerJoin);
  }

  // Unions two indices if both have set semantics
  ReIndexer<int> union(Index<int> other) {
    if (!this.isUnique || !other.isUnique) {
      throw Index.IndexException("Cannot union non-unique indexes");
    }
    JoinerImpl.join(this, other, OuterJoin);
  }

  Index<int> slice(int from, int until, int stride) {
    new IndexInt(keys.slice(from, until, stride));
  }

  // find the first location whereby an insertion would maintain a sorted index
  int lsearch(int t) {
    require(isMonotonic, "Index must be sorted");

    val fnd = locator.count(t);

    if (fnd > 0) {
      locator.get(t);
    } else {
      -(binarySearch(keys, t) + 1);
    }
  }

  // find the last location whereby an insertion would maintain a sorted index
  int rsearch(int t) {
    require(isMonotonic, "Index must be sorted");

    val fnd = locator.count(t);

    if (fnd > 0) {
      fnd + locator.get(t);
    } else {
      -(binarySearch(keys, t) + 1);
    }
  }

  Index<B> map /*[@spec(Boolean, Int, Long, Double) B: ST: ORD]*/ (
          B f(int arg)) =>
      Index(VecImpl.map(keys)(f).toArray);

  List<int> toArray() => keys.toArray();

  /**Default equality does an iterative, element-wise equality check of all values. */
  @override
  bool equals(o) {
//    o match {
//      case rv: IndexInt => (this eq rv) || (this.length == rv.length) && {
//        var i = 0
//        var eq = true
//        while(eq && i < this.length) {
//          eq &&= raw(i) == rv.raw(i)
//          i += 1
//        }
//        eq
//      }
//      case _ => super.equals(o)
//    }
  }
}
