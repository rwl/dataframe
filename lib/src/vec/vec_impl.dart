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

library saddle.vec.impl;

//import scala.{ specialized => spec }
//import org.saddle._

import '../vec.dart';
import '../scalar/scalar_tag.dart';

// Specialized method implementations for code reuse in implementations of Vec; NA-safe
/*private[saddle]*/ class VecImpl {
  static Vec /*<A>*/ mask /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec /*<A>*/ v1, Vec<bool> v2, value) {
    if (v1.length != v2.length) {
      throw new ArgumentError("Vectors must be the same length");
    }
    var buf = new List(v1.length);
    var i = 0;
    while (i < v1.length) {
      var a = v1[i];
      var b = v2[i];
      buf[i] = !b ? a : value;
      i += 1;
    }
    return new Vec(buf, v1.scalarTag);
  }

  static Vec /*<A>*/ maskFn /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec /*<A>*/ v1, bool f(arg), value) {
    var sa = v1.scalarTag; //implicitly[ST[A]];
    var buf = new List(v1.length);
    var i = 0;
    while (i < v1.length) {
      var a = v1[i];
      buf[i] = (sa.isMissing(a) || !f(a)) ? a : value;
      i += 1;
    }
    return new Vec(buf, sa);
  }

  static dynamic foldLeft /*[@spec(Boolean, Int, Long, Double) A: ST, @spec(Boolean, Int, Long, Double) B]*/ (
      Vec vec, init, dynamic f(arg1, arg2)) /*(B init)()*/ {
    var sa = vec.scalarTag; //implicitly[ST[A]];
    var acc = init;
    var i = 0;
    while (i < vec.length) {
      var v = vec[i];
      if (sa.notMissing(v)) {
        acc = f(acc, v);
      }
      i += 1;
    }
    return acc;
  }

  /**
   * Same as foldLeft, but with a condition that operates on the accumulator and element
   * that if false, breaks out of the fold
   */
  static dynamic foldLeftWhile /*[@spec(Boolean, Int, Long, Double) A: ST, @spec(Boolean, Int, Long, Double) B]*/ (
      Vec /*<A>*/ vec,
      init,
      dynamic f(arg1, arg2),
      bool cond(arg1, arg2)) /*(B init)()()*/ {
    var sa = vec.scalarTag; //implicitly[ST[A]];
    var acc = init;
    var i = 0;
    while (i < vec.length) {
      var v = vec[i];
      if (sa.notMissing(v)) {
        if (cond(acc, v)) {
          acc = f(acc, v);
        } else {
          i = vec.length;
        }
      }
      i += 1;
    }
    return acc;
  }

  static Vec /*<B>*/ map /*[@spec(Boolean, Int, Long, Double) A: ST, @spec(Boolean, Int, Long, Double) B: ST]*/ (
      Vec /*<A>*/ vec, dynamic f(dynamic a), ScalarTag scb) /*(f: A => B)*/ {
    var sca = vec.scalarTag; //implicitly[ST[A]];
//    var scb = implicitly[ST[B]];
    var buf = new List(vec.length);
    var i = 0;
    while (i < vec.length) {
      var v = vec[i];
      if (sca.isMissing(v)) {
        buf[i] = scb.missing();
      } else {
        buf[i] = f(v);
      }
      i += 1;
    }
    return new Vec(buf, scb);
  }

  static Vec /*<B>*/ flatMap /*[@spec(Boolean, Int, Long, Double) A: ST,
              @spec(Boolean, Int, Long, Double) B: ST]*/
  (Vec /*<A>*/ vec, Vec /*<B>*/ f(arg), ScalarTag sb) /*(Vec<B> f(A arg))*/ {
    var i = 0;
    var b = sb.makeBuf(vec.length);
    while (i < vec.length) {
      var v = vec[i];
      for (var u in f(v)) b.add(u);
      i += 1;
    }
    return new Vec(b.toArray(), sb);
  }

  /**
   * Same as foldLeft, but store and return intermediate accumulated results. Note this differs
   * from the Scala collections library by not including the initial value at the head of the
   * scan.
   */
  static Vec /*<B>*/ scanLeft /*[@spec(Boolean, Int, Long, Double) A: ST, @spec(Boolean, Int, Long, Double) B: ST]*/ (
      Vec /*<A>*/ vec,
      init,
      dynamic f(arg1, arg2),
      ScalarTag scb) /*(B init)()*/ {
    var sca = vec.scalarTag; //implicitly[ST[A]];
//    var scb = implicitly[ST[B]];
    var buf = new List(vec.length);
    var acc = init;
    var i = 0;
    while (i < vec.length) {
      var v = vec[i];
      if (sca.notMissing(v)) {
        acc = f(acc, v);
        buf[i] = acc;
      } else {
        buf[i] = scb.missing();
      }
      i += 1;
    }
    return new Vec(buf, scb);
  }

  static Vec /*<C>*/ zipMap /*[@spec(Int, Long, Double) A: ST, @spec(Int, Long, Double) B: ST, @spec(Boolean, Int, Long, Double) C: ST]*/ (
      Vec /*<A>*/ v1,
      Vec /*<B>*/ v2,
      dynamic f(arg1, arg2),
      ScalarTag scc) /*()*/ {
    if (v1.length != v2.length) {
      throw new ArgumentError("Vectors must be the same length");
    }
    var sca = v1.scalarTag; //implicitly[ST[A]];
    var scb = v2.scalarTag; //implicitly[ST[B]];
//    var scc = implicitly[ST[C]];
    var buf = new List /*[C]*/ (v1.length);
    var i = 0;
    while (i < v1.length) {
      var a = v1[i];
      var b = v2[i];
      if (sca.isMissing(a) || scb.isMissing(b)) {
        buf[i] = scc.missing();
      } else {
        buf[i] = f(a, b);
      }
      i += 1;
    }
    return new Vec(buf, scc);
  }

  static dynamic /*B*/ filterFoldLeft /*[@spec(Boolean, Int, Long, Double) A: ST, @spec(Boolean, Int, Long, Double) B]*/ (
      Vec /*<A>*/ vec,
      bool pred(arg),
      init,
      dynamic f(arg1, arg2)) /*()(B init)()*/ {
    var sa = vec.scalarTag; //implicitly[ST[A]];
    var acc = init;
    var i = 0;
    while (i < vec.length) {
      var vi = vec[i];
      if (sa.notMissing(vi) && pred(vi)) {
        acc = f(acc, vi);
      }
      i += 1;
    }
    return acc;
  }

  static Vec /*<B>*/ filterScanLeft /*[@spec(Boolean, Int, Long, Double) A: ST, @spec(Boolean, Int, Long, Double) B: ST]*/ (
      Vec /*<A>*/ vec,
      bool pred(arg),
      init,
      dynamic f(arg1, arg2),
      ScalarTag sb) /*()(B init)(B f(B arg1, A arg2))*/ {
    var sa = vec.scalarTag; //implicitly[ST[A]];
//    val sb = implicitly[ST[B]];
    var buf = new List /*[B]*/ (vec.length);
    var acc = init;
    var i = 0;
    while (i < vec.length) {
      var v = vec[i];
      if (sa.notMissing(v) && pred(v)) {
        acc = f(acc, v);
        buf[i] = acc;
      } else {
        buf[i] = sb.missing();
      }
      i += 1;
    }
    return new Vec(buf, sb);
  }

  static Vec /*<B>*/ rolling /*[@spec(Boolean, Int, Long, Double) A, @spec(Boolean, Int, Long, Double) B: ST]*/ (
      Vec /*<A>*/ vec,
      int winSz,
      dynamic f(Vec /*<A>*/ arg1),
      ScalarTag sb) /*()*/
  {
    if (winSz <= 0) {
      return new Vec /*<B>*/ .empty(sb);
    } else {
      var len = vec.length;
      var win = (winSz > len) ? len : winSz;
      if (len == 0) {
        return new Vec.empty(sb);
      } else {
        var buf = new List /*<B>*/ (len - win + 1);
        var i = win;
        while (i <= vec.length) {
          buf[i - win] = f(vec.slice(i - win, i));
          i += 1;
        }
        return new Vec(buf, sb);
      }
    }
  }

  static void foreach /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec vec, op(arg)) /*(Unit )*/ {
    var sa = vec.scalarTag; //implicitly[ST[A]];
    var i = 0;
    while (i < vec.length) {
      var v = vec[i];
      if (sa.notMissing(v)) op(v);
      i += 1;
    }
  }

  static void forall /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec vec, bool pred(arg), op(arg)) /*())(Unit ))*/ {
    var sa = vec.scalarTag; //implicitly[ST[A]];
    var i = 0;
    while (i < vec.length) {
      var v = vec[i];
      if (sa.notMissing(v) && pred(v)) op(v);
      i += 1;
    }
  }

  static Vec<int> find /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec /*<A>*/ vec, bool pred(arg)) {
    var sa = vec.scalarTag; //implicitly[ST[A]];
    var i = 0;
    var buf = []; //Buffer[Int]();
    while (i < vec.length) {
      var v = vec[i];
      if (sa.notMissing(v) && pred(v)) {
        buf.add(i);
      }
      i += 1;
    }
    return new Vec(buf, ScalarTag.stInt);
  }

  static bool findOneNA /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec /*<A>*/ vec) {
    var sa = vec.scalarTag; //implicitly[ST[A]];
    var ex = false;
    var i = 0;
    while (!ex && i < vec.length) {
      var v = vec[i];
      ex = sa.isMissing(v);
      i += 1;
    }
    return ex;
  }

  static bool isAllNA /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (Vec vec) {
    var sa = vec.scalarTag; //implicitly[ST[A]];
    var ex = true;
    var i = 0;
    while (ex && i < vec.length) {
      var v = vec[i];
      ex = ex && sa.isMissing(v);
      i += 1;
    }
    return ex;
  }

  static int findOne /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec /*<A>*/ vec, bool pred(arg)) {
    var sa = vec.scalarTag; //implicitly[ST<A>];
    bool ex = false;
    var i = 0;
    while (!ex && i < vec.length) {
      var v = vec[i];
      ex = sa.notMissing(v) && pred(v);
      i += 1;
    }
    return ex ? i - 1 : -1;
  }

  static Vec /*<A>*/ filter /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec /*<A>*/ vec, bool pred(/*<A>*/ arg)) /*(bool pred(A arg))*/ {
    var sa = vec.scalarTag; //implicitly[ST[A]];
    var i = 0;
    var buf = []; //Buffer[A]();
    while (i < vec.length) {
      var v = vec[i];
      if (sa.notMissing(v) && pred(v)) {
        buf.add(v);
      }
      i += 1;
    }
    return new Vec(buf, sa);
  }

  static Vec filterAt /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec vec, bool pred(int arg)) /*()*/ {
    var i = 0;
    var buf = []; //Buffer[A]();
    while (i < vec.length) {
      dynamic v = vec[i];
      if (pred(i)) {
        buf.add(v);
      }
      i += 1;
    }
    return new Vec(buf, vec.scalarTag);
  }

  static Vec where /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec vec, List<bool> pred) /*()*/ {
    var i = 0;
    var buf = []; //Buffer[A]();
    while (i < vec.length) {
      var v = vec[i];
      if (pred[i]) {
        buf.add(v);
      }
      i += 1;
    }
    return new Vec(buf, vec.scalarTag);
  }

  static Vec pad /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (Vec vec,
      [int atMost = 0]) {
    if (vec.length == 0 || vec.length == 1) {
      return vec;
    } else {
      var lim = (atMost > 0) ? atMost : vec.length;
      var sa = vec.scalarTag; //implicitly[ST[A]];
      var buf = new List(vec.length); //array.empty /*[A]*/ (vec.length, sa);
      buf[0] = vec[0];
      var i = 1;
      var c = lim;
      while (i < vec.length) {
        var v = vec[i];
        if (sa.notMissing(v)) {
          buf[i] = v;
          c = lim;
        } else {
          buf[i] = (c > 0) ? buf[i - 1] : v;
          c -= 1;
        }
        i += 1;
      }
      return new Vec(buf, sa);
    }
  }

  static Vec /*<A>*/ vecfillNA /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec /*<A>*/ vec, dynamic f(int arg)) /*()*/ {
    var buf = vec.contents;
    var i = 0;
    var l = vec.length;
    var s = vec.scalarTag; //implicitly[ST[A]];
    while (i < l) {
      if (s.isMissing(buf[i])) {
        buf[i] = f(i);
      }
      i += 1;
    }
    return new Vec(buf, vec.scalarTag);
  }

  static Vec /*<A>*/ seriesfillNA /*[@spec(Int, Long, Double) X, @spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec /*<X>*/ idx, Vec /*<A>*/ vec, /*A*/ f(/*X*/ arg)) /*()*/ {
    var buf = vec.contents;
    var i = 0;
    var l = vec.length;
    var s = vec.scalarTag; //implicitly[ST[A]];
    while (i < l) {
      if (s.isMissing(buf(i))) {
        buf[i] = f(idx[i]);
      }
      i += 1;
    }
    return new Vec(buf, vec.scalarTag);
  }
}
