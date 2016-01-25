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

library saddle.vec.double;

//import scala.{specialized => spec}
//import org.saddle._
//import org.saddle.util
//import org.saddle.util.Concat.Promoter
//import org.saddle.scalar._

import 'dart:math' as math;
import 'dart:typed_data';

import '../vec.dart';
import '../scalar/scalar_tag.dart';
import '../scalar/scalar_tag_double.dart';
import '../array/array.dart';
import '../stats/vec_stats.dart';
import 'vec_impl.dart';

class VecDouble extends Vec<double> with DoubleStats {
  Vec<double> get r => this;

  //self =>
  Float64List values;

  VecDouble(List<double> values_)
      : values = new Float64List.fromList(values_),
        super.internal();

  int get length => values.length;

  get scalarTag => ScalarTagDouble;

  double apply_(int i) => values[i];

  Vec<double> copy() => new Vec(new List.from(toArray()), scalarTag);

  Vec<double> take(List<int> locs) =>
      new Vec(array.take(toArray(), locs, scalarTag.missing), scalarTag);

  Vec<double> without(List<int> locs) =>
      new Vec(array.remove(toArray(), locs), scalarTag);

  Vec<double> dropNA() => filter((_) => true);

  bool get hasNA => VecImpl.findOneNA(this);

  Vec<double> operator -() => map((x) => -x, scalarTag);

  Vec /*<C>*/ concat /*[B, C]*/ (
          Vec /*<B>*/ v) /*(implicit wd: Promoter[Double, B, C], mc: ST[C])*/ =>
      new Vec(util.Concat.append /*[Double, B, C]*/ (toArray(), v.toArray()));

  /*B*/ dynamic foldLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          init, dynamic f(arg1, double arg2)) /*(B f(B, Double))*/ =>
      VecImpl.foldLeft(this, init, f);

  /*B*/ dynamic foldLeftWhile /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          init,
          dynamic f(arg1, double arg2),
          bool cond(
              arg1, double arg2)) /*(b f(B, double))(bool cond(B, Double))*/ =>
      VecImpl.foldLeftWhile(this, init, f, cond);

  /*B*/ dynamic filterFoldLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          bool pred(double arg),
          init,
          dynamic f(arg1, double arg2)) /*(B init)(B f(B arg, double arg))*/ =>
      VecImpl.filterFoldLeft(this, pred, init, f);

  Vec /*<B>*/ rolling /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          int winSz, dynamic f(Vec<double> arg), ScalarTag scb) =>
      VecImpl.rolling(this, winSz, f, scb);

  Vec /*<B>*/ map /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          dynamic f(double arg), ScalarTag scb) =>
      VecImpl.map /*[Double, B]*/ (this, f, scb);

  Vec /*<B>*/ flatMap /*[@spec(Boolean, Int, Long, Double) B : ST]*/ (
          Vec /*<B>*/ f(double arg), ScalarTag scb) =>
      VecImpl.flatMap(this, f, scb);

  Vec /*<B>*/ scanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          init,
          dynamic f(arg, double arg2),
          ScalarTag scb) /*(b f(B arg, double arg2))*/ =>
      VecImpl.scanLeft(this, init, f, scb);

  Vec /*<B>*/ filterScanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          bool pred(double arg),
          init,
          dynamic f(arg, double arg2),
          ScalarTag scb) /*(B init)(B f(B arg, double arg2))*/ =>
      VecImpl.filterScanLeft(this, pred, init, f, scb);

  Vec /*<C>*/ zipMap /*[@spec(Int, Long, Double) B: ST, @spec(Boolean, Int, Long, Double) C: ST]*/ (
          Vec /*<B>*/ other,
          dynamic f(double arg, arg2),
          ScalarTag scc) /*(C f(double arg, B arg2))*/ =>
      VecImpl.zipMap(this, other, f, scc);

  Vec /*<T>*/ slice(int from, int until, [int stride = 1]) {
    var b = math.max(from, 0);
    var e = math.min(until, this.length);

    if (e <= b) {
      return new Vec.empty(scalarTag);
    } else {
      return new SplitVecDouble(b, e, stride, values);
//      new VecDouble(values) {
//      private val ub = math.min(self.length, e)
//
//      override def length = math.ceil((ub - b) / stride.toDouble).toInt
//
//      override def apply(i: Int): Double = {
//        val loc = b + i * stride
//        if (loc >= ub)
//          throw new ArrayIndexOutOfBoundsException("Cannot access location %d >= length %d".format(loc, ub))
//        self.apply(loc)
//      }
//
//      override def needsCopy = true
    }
  }

  ///     shift(1)  : [1 2 3 4] => [NA 1 2 3]
  ///     shift(-1) : [1 2 3 4] => [2 3 4 NA]
  Vec<double> shift(int n) {
    var m = math.min(n, this.length);
    var b = -m;
    var e = this.length - m;

    return new ShiftVecDouble(m, b, e, values);
//    new VecDouble(values) {
//      override def length = self.length
//
//      override def apply(i: Int): Double = {
//        val loc = b + i
//        if (loc >= e || loc < b)
//          throw new ArrayIndexOutOfBoundsException("Cannot access location %d (vec length %d)".format(i, self.length))
//        else if (loc >= self.length || loc < 0)
//          scalarTag.missing
//        else
//          self.apply(loc)
//      }
//
//      override def needsCopy = true
//    }
  }

  /*private[saddle]*/
  @override
  List<double> toDoubleArray(/*implicit Numeric<double> na*/) => toArray();

  /*private[saddle]*/
  @override
  List<double> toArray() {
    // need to check if we're a view on an array
    if (!needsCopy) {
      return values;
    } else {
      var buf = new List<double>(length);
      var i = 0;
      while (i < length) {
        buf[i] = this[i];
        i += 1;
      }
      return buf;
    }
  }

  /** Default equality does an iterative, element-wise equality check of all values. */
//  @override
  bool operator ==(o) {
    if (o is VecDouble) {
      VecDouble rv = o;
      if (identical(this, rv)) {
        return true;
      } else if (this.length != rv.length) {
        return false;
      } else {
        var i = 0;
        var eq = true;
        while (eq && i < this.length) {
          eq = eq &&
              (this[i] == rv[i] ||
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

class SplitVecDouble extends VecDouble {
  int ub;
  int b, e, stride;

  SplitVecDouble(this.b, this.e, this.stride, values) : super(values) {
    ub = math.min(super.length, e);
  }

  @override
  int get length => ((ub - b) / stride).ceil();

  @override
  double operator [](int i) {
    var loc = b + i * stride;
    if (loc >= ub) {
      throw new IndexError(
          loc, this, "Cannot access location $loc >= length $ub");
    }
    return super[loc];
  }

  @override
  bool get needsCopy => true;
}

class ShiftVecDouble extends VecDouble {
  int m, b, e;

  ShiftVecDouble(this.m, this.b, this.e, values) : super(values);
  @override
  get length => super.length;

  @override
  double operator [](int i) {
    var loc = b + i;
    if (loc >= e || loc < b) {
      throw new IndexError(
          loc, this, "Cannot access location $i (vec length ${super.length})");
    } else if (loc >= super.length || loc < 0) {
      return scalarTag.missing();
    } else {
      return super[loc];
    }
  }

  @override
  bool get needsCopy => true;
}
