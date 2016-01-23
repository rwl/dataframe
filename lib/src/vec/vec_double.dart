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

library saddle.vec;

//import scala.{specialized => spec}
//import org.saddle._
//import org.saddle.util
//import org.saddle.util.Concat.Promoter
//import org.saddle.scalar._

import 'dart:typed_data';

import '../vec.dart';
import '../scalar/scalar_tag.dart';
import '../scalar/scalar_tag_double.dart';
import '../array/array.dart';
import 'vec_impl.dart';

class VecDouble extends Vec<double> {
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

  Vec<double> without(List<int> locs) => array.remove(toArray(), locs);

  Vec<double> dropNA() => filter((_) => true);

  bool get hasNA => VecImpl.findOneNA(this);

  Vec<double> operator -() => map((x) => -x);

  Vec<C> concat /*[B, C]*/ (
          Vec<B> v) /*(implicit wd: Promoter[Double, B, C], mc: ST[C])*/ =>
      Vec(util.Concat.append /*[Double, B, C]*/ (toArray(), v.toArray()));

  B foldLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          B init) /*(B f(B, Double))*/ =>
      VecImpl.foldLeft(this)(init)(f);

  B foldLeftWhile /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          B init) /*(b f(B, double))(bool cond(B, Double))*/ =>
      VecImpl.foldLeftWhile(this)(init)(f)(cond);

  B filterFoldLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          bool pred(double arg)) /*(B init)(B f(B arg, double arg))*/ =>
      VecImpl.filterFoldLeft(this)(pred)(init)(f);

  Vec<B> rolling /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          int winSz, B f(Vec<double> arg)) =>
      VecImpl.rolling(this)(winSz, f);

  Vec /*<B>*/ map /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          dynamic f(double arg), ScalarTag scb) =>
      VecImpl.map /*[Double, B]*/ (this, f, scb);

  Vec<B> flatMap /*[@spec(Boolean, Int, Long, Double) B : ST]*/ (
          Vec<B> f(double arg)) =>
      VecImpl.flatMap(this)(f);

  Vec<B> scanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          B init) /*(b f(B arg, double arg2))*/ =>
      VecImpl.scanLeft(this)(init)(f);

  Vec<B> filterScanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          bool pred(double arg)) /*(B init)(B f(B arg, double arg2))*/ =>
      VecImpl.filterScanLeft(this)(pred)(init)(f);

  Vec<C> zipMap /*[@spec(Int, Long, Double) B: ST, @spec(Boolean, Int, Long, Double) C: ST]*/ (
          Vec<B> other) /*(C f(double arg, B arg2))*/ =>
      VecImpl.zipMap(this, other)(f);

  slice(int from, int until, [int stride = 1]) {
    val b = math.max(from, 0);
    val e = math.min(until, self.length);

    if (e <= b) {
      Vec.empty;
    } else {
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

  // ex. shift(1)  : [1 2 3 4] => [NA 1 2 3]
  //     shift(-1) : [1 2 3 4] => [2 3 4 NA]
  shift(int n) {
    val m = math.min(n, self.length);
    val b = -m;
    val e = self.length - m;

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
  List<double> toDoubleArray(/*implicit*/ Numeric<double> na) => toArray();

  /*private[saddle]*/
  @override
  List<double> toArray() {
    // need to check if we're a view on an array
    if (!needsCopy) {
      return values;
    } else {
      val buf = new Array<double>(length);
      var i = 0;
      while (i < length) {
        buf[i] = apply(i);
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
