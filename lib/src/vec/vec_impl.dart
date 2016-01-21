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

//import scala.{ specialized => spec }
//import org.saddle._

// Specialized method implementations for code reuse in implementations of Vec; NA-safe
/*private[saddle]*/ class VecImpl {
  Vec<A> mask /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec<A> v1, Vec<bool> v2, A value) {
    require(v1.length == v2.length, "Vectors must be the same length");
    val buf = Array.ofDim[A](v1.length);
    var i = 0;
    while (i < v1.length) {
      val a = v1(i);
      val b = v2(i);
      buf[i] = !b ? a : value;
      i += 1;
    }
    Vec(buf);
  }

  Vec<A> mask /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec<A> v1, bool f(A arg), A value) {
    val sa = implicitly[ST[A]];
    val buf = Array.ofDim[A](v1.length);
    var i = 0;
    while (i < v1.length) {
      val a = v1(i);
      buf[i] = (sa.isMissing(a) || !f(a)) ? a : value;
      i += 1;
    }
    Vec(buf);
  }

  B foldLeft /*[@spec(Boolean, Int, Long, Double) A: ST, @spec(Boolean, Int, Long, Double) B]*/ (
      Vec<A> vec) /*(B init)(B f(B arg1, A arg2))*/ {
    val sa = implicitly[ST[A]];
    var acc = init;
    var i = 0;
    while (i < vec.length) {
      val v = vec(i);
      if (sa.notMissing(v)) acc = f(acc, v);
      i += 1;
    }
    acc;
  }

  /**
   * Same as foldLeft, but with a condition that operates on the accumulator and element
   * that if false, breaks out of the fold
   */
  B foldLeftWhile /*[@spec(Boolean, Int, Long, Double) A: ST, @spec(Boolean, Int, Long, Double) B]*/ (
      Vec<A> vec) /*(B init)(B f(B arg1, A arg2))(bool cond(B arg1, A arg2))*/ {
    val sa = implicitly[ST[A]];
    var acc = init;
    var i = 0;
    while (i < vec.length) {
      val v = vec(i);
      if (sa.notMissing(v)) {
        if (cond(acc, v)) {
          acc = f(acc, v);
        } else {
          i = vec.length;
        }
      }
      i += 1;
    }
    acc;
  }

  Vec<B> map /*[@spec(Boolean, Int, Long, Double) A: ST, @spec(Boolean, Int, Long, Double) B: ST]*/ (
      Vec<A> vec) /*(f: A => B)*/ {
    val sca = implicitly[ST[A]];
    val scb = implicitly[ST[B]];
    val buf = Array.ofDim[B](vec.length);
    var i = 0;
    while (i < vec.length) {
      A v = vec(i);
      if (sca.isMissing(v)) {
        buf[i] = scb.missing;
      } else {
        buf[i] = f(v);
      }
      i += 1;
    }
    Vec(buf);
  }

  Vec<B> flatMap /*[@spec(Boolean, Int, Long, Double) A: ST,
              @spec(Boolean, Int, Long, Double) B: ST]*/
  (Vec<A> vec) /*(Vec<B> f(A arg))*/ {
    var i = 0;
    val b = implicitly[ST[B]].makeBuf(vec.length);
    while (i < vec.length) {
      A v = vec(i);
//      for { u <- f(v) } b.add(u);
      i += 1;
    }
    Vec(b.toArray);
  }

  /**
   * Same as foldLeft, but store and return intermediate accumulated results. Note this differs
   * from the Scala collections library by not including the initial value at the head of the
   * scan.
   */
  Vec<B> scanLeft /*[@spec(Boolean, Int, Long, Double) A: ST, @spec(Boolean, Int, Long, Double) B: ST]*/ (
      Vec<A> vec) /*(B init)(B f(B arg1, A arg2))*/ {
    val sca = implicitly[ST[A]];
    val scb = implicitly[ST[B]];
    val buf = Array.ofDim[B](vec.length);
    var acc = init;
    var i = 0;
    while (i < vec.length) {
      val v = vec(i);
      if (sca.notMissing(v)) {
        acc = f(acc, v);
        buf[i] = acc;
      } else {
        buf[i] = scb.missing;
      }
      i += 1;
    }
    Vec(buf);
  }

  Vec<C> zipMap /*[@spec(Int, Long, Double) A: ST, @spec(Int, Long, Double) B: ST, @spec(Boolean, Int, Long, Double) C: ST]*/ (
      Vec<A> v1, Vec<B> v2) /*(C f(A arg1, B arg2))*/ {
    require(v1.length == v2.length, "Vectors must be the same length");
    val sca = implicitly[ST[A]];
    val scb = implicitly[ST[B]];
    val scc = implicitly[ST[C]];
    val buf = Array.ofDim[C](v1.length);
    var i = 0;
    while (i < v1.length) {
      val a = v1(i);
      val b = v2(i);
      if (sca.isMissing(a) || scb.isMissing(b)) {
        buf[i] = scc.missing;
      } else {
        buf[i] = f(a, b);
      }
      i += 1;
    }
    Vec(buf);
  }

  B filterFoldLeft /*[@spec(Boolean, Int, Long, Double) A: ST, @spec(Boolean, Int, Long, Double) B]*/ (
      Vec<A> vec) /*(bool pred(A arg))(B init)(B f(B arg1, A arg2))*/ {
    val sa = implicitly[ST[A]];
    var acc = init;
    var i = 0;
    while (i < vec.length) {
      val vi = vec(i);
      if (sa.notMissing(vi) && pred(vi)) {
        acc = f(acc, vi);
      }
      i += 1;
    }
    acc;
  }

  Vec<B> filterScanLeft /*[@spec(Boolean, Int, Long, Double) A: ST, @spec(Boolean, Int, Long, Double) B: ST]*/ (
      Vec<A> vec) /*(bool pred(A arg))(B init)(B f(B arg1, A arg2))*/ {
    val sa = implicitly[ST[A]];
    val sb = implicitly[ST[B]];
    val buf = Array.ofDim[B](vec.length);
    var acc = init;
    var i = 0;
    while (i < vec.length) {
      val v = vec(i);
      if (sa.notMissing(v) && pred(v)) {
        acc = f(acc, v);
        buf[i] = acc;
      } else {
        buf[i] = sb.missing;
      }
      i += 1;
    }
    Vec(buf);
  }

  Vec<B> rolling /*[@spec(Boolean, Int, Long, Double) A, @spec(Boolean, Int, Long, Double) B: ST]*/ (
      Vec<A> vec) /*(
    int winSz, B f(Vec<A> arg1))*/
  {
    if (winSz <= 0) {
      Vec.empty[B];
    } else {
      val len = vec.length;
      val win = (winSz > len) ? len : winSz;
      if (len == 0) {
        Vec.empty;
      } else {
        val buf = new Array<B>(len - win + 1);
        var i = win;
        while (i <= vec.length) {
          buf[i - win] = f(vec.slice(i - win, i));
          i += 1;
        }
        Vec(buf);
      }
    }
  }

  void foreach /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec<A> vec) /*(Unit op(A arg))*/ {
    val sa = implicitly[ST[A]];
    var i = 0;
    while (i < vec.length) {
      A v = vec(i);
      if (sa.notMissing(v)) op(v);
      i += 1;
    }
  }

  void forall /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec<A> vec) /*(bool pred(A arg))(Unit op(A arg))*/ {
    val sa = implicitly[ST[A]];
    var i = 0;
    while (i < vec.length) {
      A v = vec(i);
      if (sa.notMissing(v) && pred(v)) op(v);
      i += 1;
    }
  }

  Vec<int> find /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec<A> vec) /*(bool pred(A arg))*/ {
    val sa = implicitly[ST[A]];
    var i = 0;
    val buf = Buffer[Int]();
    while (i < vec.length) {
      A v = vec(i);
      if (sa.notMissing(v) && pred(v)) buf.add(i);
      i += 1;
    }
    Vec(buf.toArray);
  }

  bool findOneNA /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (Vec<A> vec) {
    val sa = implicitly[ST[A]];
    var ex = false;
    var i = 0;
    while (!ex && i < vec.length) {
      A v = vec(i);
      ex = sa.isMissing(v);
      i += 1;
    }
    ex;
  }

  bool isAllNA /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (Vec<A> vec) {
    val sa = implicitly[ST[A]];
    var ex = true;
    var i = 0;
    while (ex && i < vec.length) {
      A v = vec(i);
      ex = ex && sa.isMissing(v);
      i += 1;
    }
    ex;
  }

  int findOne /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec<A> vec) /*(bool pred(A arg))*/ {
//    val sa = implicitly[ST<A>];
    var ex = false;
    var i = 0;
    while (!ex && i < vec.length) {
      A v = vec(i);
      ex = sa.notMissing(v) && pred(v);
      i += 1;
    }
    if (ex) i - 1;
    else -1;
  }

  Vec<A> filter /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec<A> vec) /*(bool pred(A arg))*/ {
//    val sa = implicitly[ST[A]];
    var i = 0;
    val buf = Buffer[A]();
    while (i < vec.length) {
      A v = vec(i);
      if (sa.notMissing(v) && pred(v)) buf.add(v);
      i += 1;
    }
    Vec(buf.toArray);
  }

  Vec<A> filterAt /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec<A> vec) /*(bool pred(int arg))*/ {
    var i = 0;
    val buf = Buffer[A]();
    while (i < vec.length) {
      A v = vec(i);
      if (pred(i)) buf.add(v);
      i += 1;
    }
    Vec(buf.toArray);
  }

  Vec<A> where /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec<A> vec) /*(Array<bool> pred)*/ {
    var i = 0;
    val buf = Buffer[A]();
    while (i < vec.length) {
      A v = vec(i);
      if (pred(i)) buf.add(v);
      i += 1;
    }
    Vec(buf.toArray);
  }

  Vec<A> pad /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (Vec<A> vec,
      [int atMost = 0]) {
    if (vec.length == 0 || vec.length == 1) {
      vec;
    } else {
      var lim = (atMost > 0) ? atMost : vec.length;
//      val sa = implicitly[ST[A]];
      val buf = array.empty[A](vec.length);
      buf[0] = vec(0);
      var i = 1;
      var c = lim;
      while (i < vec.length) {
        A v = vec(i);
        if (sa.notMissing(v)) {
          buf[i] = v;
          c = lim;
        } else {
          buf[i] = (c > 0) ? buf(i - 1) : v;
          c -= 1;
        }
        i += 1;
      }
      Vec(buf);
    }
  }

  Vec<A> vecfillNA /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec<A> vec) /*(A f(int arg))*/ {
    val buf = vec.contents;
    var i = 0;
    val l = vec.length;
    val s = implicitly[ST[A]];
    while (i < l) {
      if (s.isMissing(buf(i))) buf[i] = f(i);
      i += 1;
    }
    Vec(buf);
  }

  Vec<A> seriesfillNA /*[@spec(Int, Long, Double) X, @spec(Boolean, Int, Long, Double) A: ST]*/ (
      Vec<X> idx, Vec<A> vec) /*(A f(X arg))*/ {
    val buf = vec.contents;
    var i = 0;
    val l = vec.length;
    val s = implicitly[ST[A]];
    while (i < l) {
      if (s.isMissing(buf(i))) buf[i] = f(idx(i));
      i += 1;
    }
    Vec(buf);
  }
}
