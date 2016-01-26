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
//import scala.Predef._
//import org.saddle._
//import org.saddle.scalar._
//import util.Concat.Promoter

import '../vec.dart';

/**
 * Vec of Any
 */
class VecAny<T> /*[T: ST]*/ extends Vec<T> {
  //self =>
  VecAny(List<T> values) : super.internal();

  int get length => values.length;

  get scalarTag => implicitly[ST /*<T>*/];

  T apply(int i) => values(i);

  Vec<T> copy() => Vec(toArray.clone());

  Vec<T> take(List<int> locs) => array.take(toArray, locs, scalarTag.missing);

  Vec<T> without(List<int> locs) => array.remove(toArray, locs);

  Vec<T> dropNA() => filter((_) => true);

  bool get hasNA => VecImpl.findOneNA(this);

  Vec<T> operator -() => sys.error("Cannot negate AnyVec");

  Vec<C> concat /*[B, C]*/ (
          Vec<B> v) /*(implicit wd: Promoter[T, B, C], mc: ST[C])*/ =>
      new Vec(util.Concat.append /*[T, B, C]*/ (toArray, v.toArray));

  B foldLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          B init) /*(B f(B, T))*/ =>
      VecImpl.foldLeft(this)(init)(f);

  B foldLeftWhile /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          B init) /*(B f(B, T))(bool cond(B, T))*/ =>
      VecImpl.foldLeftWhile(this)(init)(f)(cond);

  B filterFoldLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          bool pred(T arg)) /*(B init)(B f(B, T))*/ =>
      VecImpl.filterFoldLeft(this)(pred)(init)(f);

  Vec<B> filterScanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          bool pred(T arg)) /*(B init)(B f(B, T))*/ =>
      VecImpl.filterScanLeft(this)(pred)(init)(f);

  Vec<B> rolling /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          int winSz, B f(Vec<T> arg)) =>
      VecImpl.rolling(this)(winSz, f);

  Vec<B> map /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (B f(T arg)) =>
      VecImpl.map(this)(f);

  Vec<B> flatMap /*[@spec(Boolean, Int, Long, Double) B : ST]*/ (
          Vec<B> f(T arg)) =>
      VecImpl.flatMap(this)(f);

  Vec<B> scanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          B init) /*(B f(B, T))*/ =>
      VecImpl.scanLeft(this)(init)(f);

  Vec<C> zipMap /*[@spec(Int, Long, Double) B: ST, @spec(Boolean, Int, Long, Double) C: ST]*/ (
          Vec<B> other) /*(C f(T, B))*/ =>
      VecImpl.zipMap(this, other)(f);

  slice(int from, int until, [int stride = 1]) {
    var b = math.max(from, 0);
    var e = math.min(until, self.length);

    if (e <= b) {
      Vec.empty;
    } else {
//      new VecAny(values) {
//        private val ub = math.min(self.length, e)
//
//        override def length = math.ceil((ub - b) / stride.toDouble).toInt
//
//        override def apply(i: Int): T = {
//          val loc = b + i * stride
//          if (loc >= ub)
//            throw new ArrayIndexOutOfBoundsException("Cannot access location %d >= length %d".format(loc, ub))
//          self.apply(loc)
//        }
//
//        override def needsCopy = true
//      }
    }
  }

  // ex. shift(1)  : [1 2 3 4] => [NA 1 2 3]
  //     shift(-1) : [1 2 3 4] => [2 3 4 NA]
  shift(int n) {
    val m = math.min(n, self.length);
    val b = -m;
    val e = self.length - m;

//    new VecAny(values) {
//      override def length = self.length
//
//      override def apply(i: Int): T = {
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

  /*private[saddle]*/ List<T> toArray() {
    // need to check if we're a view on an array
    if (!needsCopy) {
      values;
    } else {
      val buf = new Array<T>(length);
      var i = 0;
      while (i < length) {
        buf[i] = apply(i);
        i += 1;
      }
      buf;
    }
  }

  /** Default equality does an iterative, element-wise equality check of all values. */
  @override
  bool equals(o) {
//    o match {
//    case rv: VecAny[_] => (this eq rv) || (this.length == rv.length) && {
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
