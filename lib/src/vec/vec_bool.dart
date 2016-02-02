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

library saddle.vec.bool;

//import scala.{specialized => spec}
//import org.saddle._
//import org.saddle.scalar._
//import util.Concat.Promoter

import 'dart:math' as math;

import '../vec.dart';
import 'vec_impl.dart';
import '../scalar/scalar_tag.dart';
import '../scalar/scalar_tag_bool.dart';
import '../array/array.dart';
import '../stats/vec_stats.dart';
import '../util/concat.dart';

class VecBool extends Vec<bool> {
  //self =>
  List<bool> values;

  VecBool(this.values) : super.internal();

  int get length => values.length;

  ScalarTag<bool> scalarTag = ScalarTagBool;

  bool apply_(int i) => values[i];

  Vec<bool> copy() => new Vec(new List<bool>.from(toArray()), scalarTag);

  Vec<bool> take(List<int> locs) =>
      new Vec<bool>(array.take(toArray(), locs, scalarTag.missing), scalarTag);

  Vec<bool> without(List<int> locs) =>
      new Vec<bool>(array.remove(toArray(), locs), scalarTag);

  Vec<bool> dropNA() => filter((b) => true);

  bool get hasNA => VecImpl.findOneNA(this);

  Vec<bool> operator -() => map((b) => !b);

  Vec concat(Vec v,
      [ScalarTag stc]) /*(implicit wd: Promoter[bool, B, C], mc: ST[C]): Vec[C]*/ {
    if (stc == null) {
      stc = scalarTag;
    }
    return new Vec(
        Concat.append(toArray(), v.toArray(), scalarTag, v.scalarTag, stc),
        stc);
  }

  dynamic foldLeft /*[@spec(bool, Int, Long, Double) B: ST]*/ (
          init, dynamic f(arg1, bool arg2)) =>
      VecImpl.foldLeft(this, init, f);

  dynamic foldLeftWhile /*[@spec(bool, Int, Long, Double) B: ST]*/ (
          init, dynamic f(arg1, bool arg2), bool cond(arg1, bool arg2)) =>
      VecImpl.foldLeftWhile(this, init, f, cond);

  dynamic filterFoldLeft /*[@spec(bool, Int, Long, Double) B: ST]*/ (
          bool pred(bool arg), init, dynamic f(arg1, bool arg2)) =>
      VecImpl.filterFoldLeft(this, pred, init, f);

  Vec filterScanLeft /*[@spec(bool, Int, Long, Double) B: ST]*/ (
          bool pred(bool), init, dynamic f(arg1, bool arg2), ScalarTag sb) =>
      VecImpl.filterScanLeft(this, pred, init, f, sb);

  Vec rolling /*[@spec(bool, Int, Long, Double) B: ST]*/ (
          int winSz, dynamic f(Vec<bool> arg), ScalarTag sb) =>
      VecImpl.rolling(this, winSz, f, sb);

  Vec map /*[@spec(bool, Int, Long, Double) B: ST]*/ (
          dynamic f(bool arg), ScalarTag sb) =>
      VecImpl.map(this, f, sb);

  Vec flatMap /*[@spec(bool, Int, Long, Double) B : ST]*/ (
          Vec f(bool arg), ScalarTag sb) =>
      VecImpl.flatMap(this, f, sb);

  Vec scanLeft /*[@spec(bool, Int, Long, Double) B: ST]*/ (
          init, dynamic f(arg1, bool arg2), ScalarTag sb) =>
      VecImpl.scanLeft(this, init, f, sb);

  Vec zipMap /*[@spec(Int, Long, Double) B: ST, @spec(bool, Int, Long, Double) C: ST]*/ (
          Vec other, dynamic f(bool arg1, arg2), ScalarTag sc) =>
      VecImpl.zipMap(this, other, f, sc);

  Vec<bool> slice(int from, int until, [int stride = 1]) {
    var b = math.max(from, 0);
    var e = math.min(until, super.length);

    if (e <= b) {
      return new Vec.empty(scalarTag);
    } else {
      return new SplitVecBool(b, e, stride, values);
    }
  }

  ///     shift(1)  : [1 2 3 4] => [NA 1 2 3]
  ///     shift(-1) : [1 2 3 4] => [2 3 4 NA]
  Vec<bool> shift(int n) {
    var m = math.min(n, this.length);
    var b = -m;
    var e = this.length - m;
    return new ShiftVecBool(m, b, e, values);
  }

  /*private[saddle]*/ List<bool> toArray() {
    // need to check if we're a view on an array
    if (!needsCopy) {
      return values;
    } else {
      var buf = new List<bool>(length);
      var i = 0;
      while (i < length) {
        buf[i] = apply_(i);
        i += 1;
      }
      return buf;
    }
  }

  /** Default equality does an iterative, element-wise equality check of all values. */
  @override
  bool operator ==(o) {
    if (o is VecBool) {
      VecBool rv = o;
      if (identical(this, rv)) {
        return true;
      } else if (this.length != rv.length) {
        return false;
      } else {
        var i = 0;
        bool eq = true;
        while (eq && i < this.length) {
          eq = eq && (apply_(i) == rv[i]);
          i += 1;
        }
        return eq;
      }
    } else {
      return super == o;
    }
  }
//}

//private[saddle] object VecBool {
  // indirect counting sort of boolean vector
  static List<int> argSort(List<bool> arr) {
    var newArr = array.range(0, arr.length);
    var c = 0;

    // first pass for false
    var i = 0;
    while (i < arr.length) {
      if (!arr[i]) {
        newArr[i] = c;
        c += 1;
      }
      i += 1;
    }

    // second pass for true
    i = 0;
    while (c < arr.length) {
      if (arr[i]) {
        newArr[i] = c;
        c += 1;
      }
      i += 1;
    }

    return newArr;
  }

  // direct sort of boolean vector
  List<bool> sort(List<bool> arr) {
    var newArr = array.empty(arr.length, scalarTag);
    var c = 0;
    var i = 0;

    // count # false
    while (i < arr.length) {
      if (!arr[i]) c += 1;
      i += 1;
    }

    // populate true
    while (c < arr.length) {
      newArr[c] = true;
      c += 1;
    }

    return newArr;
  }
}

class SplitVecBool extends VecBool {
  int ub;
  int b, e, stride;

  SplitVecBool(this.b, this.e, this.stride, values) : super(values) {
    ub = math.min(super.length, e);
  }

  @override
  int get length => ((ub - b) / stride).ceil();

  @override
  bool apply_(int i) {
    var loc = b + i * stride;
    if (loc >= ub) {
      throw new IndexError(
          loc, this, "Cannot access location $loc >= length $ub");
    }
    return super.apply_(loc);
  }

  @override
  bool get needsCopy => true;
}

class ShiftVecBool extends VecBool {
  int m, b, e;

  ShiftVecBool(this.m, this.b, this.e, values) : super(values);

  @override
  get length => super.length;

  @override
  bool apply_(int i) {
    var loc = b + i;
    if (loc >= e || loc < b) {
      throw new IndexError(
          loc, this, "Cannot access location $i (vec length ${super.length})");
    } else if (loc >= super.length || loc < 0) {
      return scalarTag.missing();
    } else {
      super.apply_(loc);
    }
  }

  @override
  bool get needsCopy => true;
}
