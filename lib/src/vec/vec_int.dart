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

import '../vec.dart';
import '../scalar/scalar_tag.dart';
import '../scalar/scalar_tag_int.dart';

class VecInt extends Vec<int> {
  //self =>
  List<int> values;

  VecInt(this.values) : super.internal();

  int get length => values.length;

  ScalarTag scalarTag = ScalarTagInt;

  int apply(int i) => values[i];
  int raw(int i) => values[i];

  Vec<int> copy() => new Vec(new List.from(toArray()) /*.clone()*/, scalarTag);

  Vec<int> take(List<int> locs) => array.take(toArray, locs, scalarTag.missing);

  Vec<int> without(List<int> locs) => array.remove(toArray, locs);

  Vec<int> dropNA() => filter((_) => true);

  bool get hasNA => VecImpl.findOneNA(this);

  Vec<int> operator -() => map((x) => -x);

  Vec<C> concat /*[B, C]*/ (
          Vec<B> v) /*(implicit wd: Promoter[Int, B, C], mc: ST[C])*/ =>
      Vec(util.Concat.append /*[Int, B, C]*/ (toArray, v.toArray));

  B foldLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          B init) /*(B f(B, Int))*/ =>
      VecImpl.foldLeft(this)(init)(f);

  B foldLeftWhile /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          B init) /*(B f(B, Int))(bool cond(B, Int))*/ =>
      VecImpl.foldLeftWhile(this)(init)(f)(cond);

  B filterFoldLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          bool pred(Int)) /*(B init)(B f(B, Int))*/ =>
      VecImpl.filterFoldLeft(this)(pred)(init)(f);

  Vec<B> rolling /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          int winSz, B f(Vec<int> arg)) =>
      VecImpl.rolling(this)(winSz, f);

  Vec<B> map /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (B f(Int)) =>
      VecImpl.map(this)(f);

  Vec<B> flatMap /*[@spec(Boolean, Int, Long, Double) B : ST]*/ (
          Vec<B> f(Int arg)) =>
      VecImpl.flatMap(this)(f);

  Vec<B> scanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          B init) /*(B f(B, Int))*/ =>
      VecImpl.scanLeft(this)(init)(f);

  Vec<B> filterScanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          bool pred(Int)) /*(b init)(b f(B, Int))*/ =>
      VecImpl.filterScanLeft(this)(pred)(init)(f);

  Vec<C> zipMap /*[@spec(Int, Long, Double) B: ST, @spec(Boolean, Int, Long, Double) C: ST]*/ (
          Vec<B> other) /*(C f(Int, B))*/ =>
      VecImpl.zipMap(this, other)(f);

  slice(int from, int until, [int stride = 1]) {
    val b = math.max(from, 0);
    val e = math.min(until, self.length);

    if (e <= b) {
      Vec.empty;
    } else {
//      new VecInt(values) {
//      private val ub = math.min(self.length, e)
//
//      override def length = math.ceil((ub - b) / stride.toDouble).toInt
//
//      override def apply(i: Int): Int = {
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

//    new VecInt(values) {
//      override def length = self.length
//
//      override def apply(i: Int): Int = {
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

  /*private[saddle]*/ List<int> toArray() {
    // need to check if we're a view on an array
    if (!needsCopy) {
      return values;
    } else {
      var buf = new List<int>(length);
      var i = 0;
      while (i < length) {
        buf[i] = apply(i);
        i += 1;
      }
      return buf;
    }
  }

  /** Default equality does an iterative, element-wise equality check of all values. */
  @override
  bool equals(o) {
//    o match {
//    case rv: VecInt => (this eq rv) || (this.length == rv.length) && {
//      var i = 0
//      var eq = true
//      while(eq && i < this.length) {
//        eq &&= (apply(i) == rv(i) || this.scalarTag.isMissing(apply(i)) && rv.scalarTag.isMissing(rv(i)))
//        i += 1
//      }
//      eq
//    }
//    case _ => super.equals(o)
  }
}
