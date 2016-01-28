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

library saddle.stats.vec_rolling_stats;

//import scala.{specialized => spec}
//import org.saddle._
//import ops._
//import Vec.Vec2Stats
//import org.saddle.scalar._

import '../vec.dart';

/**
 * Rolling statistical methods made available on numeric Vec objects via enrichment.
 * These methods scan over the Vec and compute values over a specified historical
 * window.
 */
abstract class VecRollingStats<
    A> /*[@spec(Int, Long, Double) A: ST: Vec2Stats: AddOp: SubOp: NUM]*/ {
  Vec<A> get v;
//  Vec<A> v;
//  VecRollingStats(this.v);

  /**
   * Rolling count; compute count of number of elements in Vec over a sliding window, ignoring
   * any NA values.
   * @param winSz Size of the sliding window
   */
  Vec<int> rollingCount(int winSz) => v.rolling(winSz, new RollingCount<A>());

  /**
   * Rolling sum; compute sum of elements in Vec over a sliding window, ignoring any NA
   * values.
   * @param winSz Size of the sliding window
   */
  Vec<A> rollingSum(int winSz) => v.rolling(winSz, new RollingSum<A>());

  /**
   * Rolling mean; compute mean of elements in Vec over a sliding window, ignoring any NA
   * values.
   * @param winSz Size of the sliding window
   */
  Vec<double> rollingMean(int winSz) => v.rolling(winSz, new RollingMean<A>());

  /**
   * Rolling median; compute median of elements in Vec over a sliding window, ignoring any NA
   * values.
   * @param winSz Size of the sliding window
   */
  Vec<double> rollingMedian(int winSz) =>
      new RollingMedian<A>(winSz, v).evaluate();
}

class RollingCount /*[@spec(Int, Long, Double) A: ST: Vec2Stats: NUM] extends Function1[Vec<A>, Int]*/ {
  var i = 0;
  var s = 0;
  var sa = implicitly[ST /*<A>*/];
  var p; // = Scalar(sa.zero);

  int apply(Vec<A> v) {
    if (i == 0) {
      s = v.count();
      i += 1;
      if (v.length > 0) p = v.first;
    } else {
      if (!p.isNA) s -= 1;
      if (!v.last.isNA) s += 1;
      p = v.first;
    }
    return s;
  }
}

class RollingSum /*[@spec(Int, Long, Double) A: ST: AddOp: SubOp: Vec2Stats: NUM] extends Function1[Vec<A>, A]*/ {
  var i = 0;
  var sa = implicitly[ST /*<A>*/];
  var add = implicitly[AddOp /*<A>*/];
  var sub = implicitly[SubOp /*<A>*/];
//  var s = sa.zero;
//  var p = Scalar(sa.zero);

  A apply(Vec<A> v) {
    if (i == 0) {
      s = v.sum;
      i += 1;
      if (v.length > 0) p = v.first;
    } else {
      if (!p.isNA) s = sub(s, p.get);
      if (!v.last.isNA) s = add(s, v.last.get);
      p = v.first;
    }
    return s;
  }
}

class RollingMean /*[@spec(Int, Long, Double) A: ST: Vec2Stats: NUM] extends Function1[Vec<A>, Double]*/ {
  var i = 0;
  var s = 0.0;
  var c = 0;
//  var sa = implicitly[ST<A>];
//  var p = Scalar(sa.zero);

  double apply(Vec<A> v) {
    if (i == 0) {
      s = sa.toDouble(v.sum);
      c = v.count;
      i += 1;
      if (v.length > 0) p = v.first;
    } else {
      if (!p.isNA) {
        s -= sa.toDouble(p.get);
        c -= 1;
      }
      if (!v.last.isNA) {
        s += sa.toDouble(v.last.get);
        c += 1;
      }
      p = v.first;
    }
    return s / c;
  }
}

class RollingMedian /*[@spec(Int, Long, Double) A: ST: Vec2Stats: NUM]*/ {
  RollingMean(int winSz, Vec<A> origv);

//  var sa = implicitly[ST<A>];

  var len = origv.length;
//  var win = winSz > len ? len : winSz;

  Vec<double> evaluate() {
    if (len == 0 || winSz <= 0) {
      return new Vec.empty();
    } else {
      var m = new Mediator(win);
      var r = Float64List(len - win + 1);

      var i = 0;
      while (i < win) {
        var v = sa.toDouble(origv.raw(i));
        m.push(v);
        i += 1;
      }

      r[0] = m.median;

      var j = 1;
      while (i < len) {
        var v = sa.toDouble(origv.raw(i));
        m.push(v);
        i += 1;
        r[j] = m.median;
        j += 1;
      }

      return new Vec(r);
    }
  }
}
