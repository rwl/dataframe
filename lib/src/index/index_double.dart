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

library saddle.index.double;

//import scala.{specialized => spec}
//import java.util.Arrays._
//import org.saddle._
//import util.Concat.Promoter
//import index.IndexImpl.IndexProperties
//import vec.VecImpl
//import locator.Locator
//import org.saddle.scalar.ScalarTagDouble

import 'package:collection/algorithms.dart' show binarySearch;

import '../array/array.dart';
import '../index.dart';
import 'join_type.dart';
import '../vec.dart';
import '../scalar/scalar_tag.dart';
import '../scalar/scalar_tag_double.dart';
import '../locator/locator.dart';
import '../index/reindexer.dart';
import '../index/joiner_impl.dart';
import '../vec/vec_impl.dart';

import 'index_impl.dart';

/**
 * Index with double keys
 */
class IndexDouble extends Index<double> {
  final Vec<double> keys;

  IndexDouble(this.keys) : super.internal();

  ScalarTag scalarTag = ScalarTagDouble;

//  private lazy val (kmap, IndexProperties(contiguous, monotonic)) = IndexImpl.keys2map(this)
  Keys2Map<double> __keys2map = null;
  Keys2Map<double> get _keys2map {
    if (__keys2map == null) {
      __keys2map = IndexImpl.keys2map(this, scalarTag);
    }
    return __keys2map;
  }

  /*protected*/ Locator<double> get locator => _keys2map.locator;

  int get length => keys.length;

  Vec<double> toVec() => keys;

  // get the key at the position specified
  double raw(int idx) => keys[idx];

  Index<double> take(List<int> locs) => new Index(
      array.take(keys.toArray(), locs, IndexImpl.sentinelErr), scalarTag);

  Index<double> without(List<int> locs) =>
      new Index(array.remove(keys.toArray(), locs), scalarTag);

  Index /*<C>*/ concat /*[B, C]*/ (Index<
          B> x) /*(implicit wd: Promoter[Double, B, C], mc: ST[C], oc: ORD[C])*/ =>
      Index(util.Concat.append /*[Double, B, C]*/ (toArray(), x.toArray()));

  bool get isMonotonic => _keys2map.props.monotonic;

  bool get isContiguous => isUnique || _keys2map.props.contiguous;

  List<int> argSort() => array.argsort(keys.toArray(), scalarTag);

  Index<double> get reversed => new IndexDouble(toVec().reversed);

  ReIndexer<double> join(Index<double> other,
          [JoinType how = JoinType.LeftJoin]) =>
      JoinerImpl.join(this, other, how);

  // Intersects two indices if both have set semantics
  ReIndexer<double> intersect(Index<double> other) {
    if (!this.isUnique || !other.isUnique) {
      throw new IndexException("Cannot intersect non-unique indexes");
    }
    return JoinerImpl.join(this, other, JoinType.InnerJoin);
  }

  // Unions two indices if both have set semantics
  ReIndexer<double> union(Index<double> other) {
    if (!this.isUnique || !other.isUnique) {
      throw new IndexException("Cannot union non-unique indexes");
    }
    return JoinerImpl.join(this, other, JoinType.OuterJoin);
  }

  Index<double> slice(int from, int until, [int stride = 1]) {
    return new IndexDouble(keys.slice(from, until, stride));
  }

  // find the first location whereby an insertion would maintain a sorted index
  int lsearch(double t) {
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
  int rsearch(double t) {
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

  Index /*B>*/ map /*[@spec(Boolean, Int, Long, Double) B: ST: ORD]*/ (
          dynamic f(double arg), ScalarTag sb) =>
      new Index(VecImpl.map(keys, f, sb).toArray(), sb);

  List<double> toArray_() => keys.toArray();

  /** Default equality does an iterative, element-wise equality check of all values. */
  @override
  bool operator ==(o) {
    if (o is IndexDouble) {
      var rv = o as IndexDouble;
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
