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

library org.saddle.vec;

//import scala.{specialized => spec}
//import org.saddle._
//import org.saddle.scalar._
//import org.saddle.util
//import org.saddle.util.Concat.Promoter

import 'dart:math' as math;

import '../vec.dart';
import 'vec_impl.dart';
import '../scalar/scalar_tag.dart';
import '../scalar/scalar_tag_int.dart';
import '../array/array.dart';
import '../stats/vec_stats.dart';

class VecInt extends Vec<int> with IntStats {
  Vec<int> get r => this;

  //self =>
  List<int> values;

  VecInt(this.values) : super.internal();

  int get length => values.length;

  ScalarTag scalarTag = ScalarTagInt;

  int apply_(int i) => values[i];
//  int raw(int i) => values[i];

  Vec<int> copy() => new Vec(new List.from(toArray()) /*.clone()*/, scalarTag);

  Vec<int> take(List<int> locs) =>
      scalarTag.makeVec(array.take(toArray(), locs, scalarTag.missing));

  Vec<int> without(List<int> locs) =>
      new Vec(array.remove(toArray(), locs), scalarTag);

  Vec<int> dropNA() => filter((_) => true);

  bool get hasNA => VecImpl.findOneNA(this);

  Vec<int> operator -() => map((x) => -x, scalarTag);

  Vec /*<C>*/ concat /*[B, C]*/ (
          Vec /*<B>*/ v) /*(implicit wd: Promoter[Int, B, C], mc: ST[C])*/ =>
      new Vec(util.Concat.append /*[Int, B, C]*/ (toArray(), v.toArray()));

  /*B*/ foldLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          init, dynamic f(arg1, int arg2)) /*(B f(B, Int))*/ =>
      VecImpl.foldLeft(this, init, f);

  /*B*/ foldLeftWhile /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          init,
          dynamic f(arg1, int arg2),
          bool cond(arg1, int arg2)) /*(B f(B, Int))(bool cond(B, Int))*/ =>
      VecImpl.foldLeftWhile(this, init, f, cond);

  /*B*/ filterFoldLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          bool pred(int arg),
          init,
          dynamic f(arg1, int arg2)) /*(B init)(B f(B, Int))*/ =>
      VecImpl.filterFoldLeft(this, pred, init, f);

  Vec /*<B>*/ rolling /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          int winSz, dynamic f(Vec<int> arg), ScalarTag sb) =>
      VecImpl.rolling(this, winSz, f, sb);

  Vec /*<B>*/ map /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          dynamic f(int arg), ScalarTag sb) =>
      VecImpl.map(this, f, sb);

  Vec /*<B>*/ flatMap /*[@spec(Boolean, Int, Long, Double) B : ST]*/ (
          Vec /*<B>*/ f(int arg), ScalarTag sb) =>
      VecImpl.flatMap(this, f, sb);

  Vec /*<B>*/ scanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          init, dynamic f(arg1, int arg2), ScalarTag sb) /*(B f(B, Int))*/ =>
      VecImpl.scanLeft(this, init, f, sb);

  Vec /*<B>*/ filterScanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          bool pred(Int),
          init,
          dynamic f(arg1, int arg2),
          ScalarTag sb) /*(b init)(b f(B, Int))*/ =>
      VecImpl.filterScanLeft(this, pred, init, f, sb);

  Vec /*<C>*/ zipMap /*[@spec(Int, Long, Double) B: ST, @spec(Boolean, Int, Long, Double) C: ST]*/ (
          Vec /*<B>*/ other,
          dynamic f(int arg1, arg2),
          ScalarTag sc) /*(C f(Int, B))*/ =>
      VecImpl.zipMap(this, other, f, sc);

  Vec<int> slice(int from, int until, [int stride = 1]) {
    var b = math.max(from, 0);
    var e = math.min(until, this.length);

    if (e <= b) {
      return new Vec.empty(scalarTag);
    } else {
      return new SplitVecInt(b, e, stride, values);
    }
  }

  ///     shift(1)  : [1 2 3 4] => [NA 1 2 3]
  ///     shift(-1) : [1 2 3 4] => [2 3 4 NA]
  shift(int n) {
    var m = math.min(n, this.length);
    var b = -m;
    var e = this.length - m;
    return new ShiftVecInt(m, b, e, values);
  }

  /*private[saddle]*/ List<int> toArray() {
    // need to check if we're a view on an array
    if (!needsCopy) {
      return values;
    } else {
      var buf = new List<int>(length);
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
    if (o is VecInt) {
      VecInt rv = o;
      if (identical(this, rv)) {
        return true;
      } else if (this.length != rv.length) {
        return false;
      } else {
        var i = 0;
        bool eq = true;
        while (eq && i < this.length) {
          eq = eq &&
              (apply_(i) == rv[i] ||
                  this.scalarTag.isMissing(this[i]) &&
                      rv.scalarTag.isMissing(rv[i]));
          i += 1;
        }
        return eq;
      }
    } else {
      return super == o;
    }
  }
}

class SplitVecInt extends VecInt {
  int ub;
  int b, e, stride;

  SplitVecInt(this.b, this.e, this.stride, values) : super(values) {
    ub = math.min(super.length, e);
  }

  @override
  int get length => ((ub - b) / stride).ceil();

  @override
  int apply_(int i) {
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

class ShiftVecInt extends VecInt {
  int m, b, e;

  ShiftVecInt(this.m, this.b, this.e, values) : super(values);

  @override
  get length => super.length;

  @override
  int apply_(int i) {
    var loc = b + i;
    if (loc >= e || loc < b) {
      throw new IndexError(
          loc, this, "Cannot access location $i (vec length ${super.length})");
    } else if (loc >= super.length || loc < 0) {
      return scalarTag.missing();
    } else {
      return this.apply_(loc);
    }
  }

  @override
  bool get needsCopy => true;
}
