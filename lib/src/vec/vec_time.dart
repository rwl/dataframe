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

library saddle.vec.time;

//import org.saddle._
//import org.saddle.scalar._
//
//import org.joda.time._
//import scala.{specialized => spec}
//import util.Concat.Promoter
//import org.saddle.time._
//import org.saddle.util.Concat.Promoter
//import org.saddle.buffer.BufferInt

import '../vec.dart';
import 'vec_impl.dart';
import '../scalar/scalar_tag.dart';
import '../scalar/scalar_tag_int.dart';
import '../array/array.dart';
import '../stats/vec_stats.dart';

/**
 * A compact native int representation of posix times at millisecond resolution which
 * conforms to and extends the interface of Vec<DateTime>
 *
 * @param times A Vec[Long], where each element is a millisecond timestamp
 * @param tzone Optional time zone containing localization info
 */
class VecTime extends Vec<DateTime> {
  Vec<int> times;
  DateTimeZone tzone;
  VecTime(this.times, [this.tzone = ISO_CHRONO.getZone]);

  /*@transient lazy*/
  ScalarTag scalarTag = ScalarTagTime;

  /*@transient lazy*/
  var chrono = ISO_CHRONO.withZone(tzone);

  /*@transient lazy private*/
  var lmf = scalar.ScalarTagInt;

  /*private def*/
  l2t(int l) {
    if (lmf.isMissing(l)) {
      return scalarTag.missing();
    } else {
      return new DateTime(l, chrono);
    }
  }

  /*private*/
  t2l(DateTime t) {
    if (scalarTag.isMissing(t)) {
      return lmf.missing();
    } else {
      return t.millisecondsSinceEpoch;
    }
  }

  /*private*/ VecTime vl2vt(Vec<int> l) => new VecTime(l, tzone);

  int get length => times.length;

  /*private[saddle]*/
  DateTime apply_(int loc) => l2t(times(loc));

  Vec<DateTime> take(List<int> locs) => vl2vt(times.take(locs));

  Vec<DateTime> without(List<int> locs) => vl2vt(times.without(locs));

  // specialized concatenation
  Vec<DateTime> concat(VecTime x) =>
      vl2vt(new Vec(util.Concat.append(times.toArray(), x.times.toArray())));

  // general concatenation
//  def concat[B, C](v: Vec[B])(implicit wd: Promoter[DateTime, B, C], mc: ST[C]) =
//    Vec(util.Concat.append[DateTime, B, C](toArray, v.toArray))

  Vec<DateTime> operator -() =>
      throw new UnsupportedError("Cannot negate VecTime");

  Vec<DateTime> map /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          dyanmic f(DateTime arg)) =>
      times.map((v) => f(l2t(v)));

  Vec flatMap /*[@spec(Boolean, Int, Long, Double) B : ST]*/ (
          Vec f(DateTime arg)) =>
      VecImpl.flatMap(this, f);

  dynamic foldLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          init, dynamic f(arg1, DateTime arg2)) =>
      times.foldLeft(init, (a, b) => f(a, l2t(b)));

  Vec scanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          init, dyanmic f(arg1, DateTime arg2)) =>
      times.scanLeft(init, (a, b) => f(a, l2t(b)));

  dynamic filterFoldLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          bool pred(DateTime arg), init, dynamic f(arg1, DateTime arg2)) =>
      times.filterFoldLeft((a) => pred(l2t(a)), init, (a, b) => f(a, l2t(b)));

  Vec filterScanLeft /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          bool pred(DateTime arg), init, dynamic f(arg1, DateTime arg2)) =>
      times.filterScanLeft((a) => pred(l2t(a)), init, (a, b) => f(a, l2t(b)));

  dynamic foldLeftWhile /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (init,
          dynamic f(arg1, DateTime arg2), bool cond(arg1, DateTime arg2)) =>
      times.foldLeftWhile(
          init, (a, b) => f(a, l2t(b)))((a, b) => cond(a, l2t(b)));

  Vec zipMap /*[@spec(Boolean, Int, Long, Double) B: ST, @spec(Boolean, Int, Long, Double) C: ST]*/ (
          Vec other, dynamci f(DateTime arg1, arg2)) =>
      times.zipMap(other, (a, b) => f(l2t(a), b));

  void dropNA() => vl2vt(times.dropNA());

  bool get hasNA => times.hasNA;

  Vec rolling /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          int winSz, dynamic f(Vec<DateTime> arg)) =>
      times.rolling(winSz, (a) => f(vl2vt(a)));

  Vec<DateTime> slice(int from, int until, int stride) =>
      vl2vt(times.slice(from, until, stride));

  Vec<DateTime> shift(int n) => vl2vt(times.shift(n));

  @override
  Vec<DateTime> sorted(/*implicit ev: ORD<DateTime>, st: ST<DateTime>*/) =>
      take(array.argsort(times.toArray));

  @override
  Vec<DateTime> pad() => vl2vt(times.pad);

  @override
  Vec<DateTime> fillNA(DateTime f(int arg)) =>
      vl2vt(times.fillNA((a) => t2l(f(a))));

  @override
  Vec<DateTime> reversed() => vl2vt(times.reversed);

  /*protected*/
  Vec<DateTime> copy() => vl2vt(new Vec(times.contents));

  /*private[saddle]*/
  toArray() => times.toArray().map(l2t);
//}
//
//object VecTime {
  static /*@transient lazy private*/ ScalarTag sm = ScalarTagTime;
  static /*@transient lazy private*/ ScalarTag sl = ScalarTagInt;

  /**
   * Create a new VecTime from an array of times
   */
  factory VecTime.fromList(List<DateTime> times) {
    var millis = array.empty(times.length);
    var i = 0;
    while (i < millis.length) {
      val t = times(i);
      millis[i] = sm.isMissing(t) ? sl.missing : t.getMillis;
      i += 1;
    }
    return new VecTime(Vec(millis));
  }

  /**
   * Create a new VecTime from a sequence of times
   */
//  def apply(timeSeq : DateTime*): VecTime = {
//    val times = timeSeq.toArray
//    val millis = array.empty[Long](times.length)
//    var i = 0
//    while (i < millis.length) {
//      val t = times(i)
//      millis(i) = if(sm.isMissing(t)) sl.missing else t.getMillis
//      i += 1
//    }
//    new VecTime(Vec(millis))
//  }

  /**
   * Concatenate several Vec<DateTime> instances into one
   */
  factory VecTime.concat(Iterable<Vec<DateTime>> arr) {
    List<VecTime> vecs = arr.map((v) {
      if (v is VecTime) {
        return v;
      } else {
        return new VecTime(v.toArray);
      }
    }).toList();

    // calculate offset for each subsequent vec of bytes
    var sz = vecs.fold(0, (o, v) => o + v.length);

    var databuf = new List<int>(sz);

    var c = 0; // byte counter
    enumerate(vecs).forEach((iv) {
      var v = iv.value;
      var vidx = iv.index;
      var vlen = v.length;
      var i = 0;
      while (i < vlen) {
        databuf[c] = v.times(i);
        i += 1;
        c += 1;
      }
    });

    return new VecTime(new Vec(databuf));
  }
}
