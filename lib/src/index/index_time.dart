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

library saddle.index.time;

//import scala.{ specialized => spec }
//
//import org.saddle._
//import org.saddle.scalar._
//import org.saddle.locator._
//
//import org.joda.time._
//
//import org.saddle.vec.VecTime
//import org.saddle.time._
//import org.saddle.util.Concat.Promoter

import '../array/array.dart';
import '../index.dart';
import '../vec.dart';
import '../scalar/scalar_tag.dart';
import '../scalar/scalar_tag_int.dart';
import '../scalar/scalar_tag_time.dart';
import '../locator/locator.dart';
import '../vec/vec_impl.dart';
import '../vec/vec_time.dart';
import '../util/concat.dart';

import 'reindexer.dart';
import 'joiner_impl.dart';
import 'join_type.dart';
import 'index_impl.dart';

/**
 * A compact native int representation of posix times at millisecond resolution which
 * conforms to and extends the interface of Index<DateTime>
 *
 * @param times An Index[Long], where each element is a millisecond timestamp
 * @param tzone Optional time zone containing localization info
 */
class IndexTime extends Index<DateTime> {
  final Index<int> times;
//  DateTimeZone tzone = ISO_CHRONO.getZone;

  IndexTime(this.times /*, [this.tzone = ISO_CHRONO.getZone]*/)
      : super.internal();

  /*@transient lazy*/ ScalarTag scalarTag = ScalarTagTime;

//  @transient lazy val chrono = ISO_CHRONO.withZone(tzone)

  /*@transient lazy*/ ScalarTag lmf = ScalarTagInt;

  /*private*/ l2t(int l) => lmf.isMissing(l)
      ? scalarTag.missing()
      : new DateTime.fromMillisecondsSinceEpoch(l /*, chrono*/);
  /*private def*/ t2l(DateTime t) =>
      scalarTag.isMissing(t) ? lmf.missing : t.millisecondsSinceEpoch;
  /*private def*/ IndexTime il2it(Index<int> l) => new IndexTime(l /*, tzone*/);

  _Locator _locator;
//  @transient lazy private val _locator = new Locator<DateTime> {
//    lazy val _keys = times.uniques.map(l2t)
//
//    def contains(key: DateTime) = times.contains(t2l(key))
//    def get(key: DateTime) = times.getFirst(t2l(key))
//
//    def count(key: DateTime) = times.count(t2l(key))
//
//    def keys() = _keys.toArray
//    def counts() = times.counts
//
//    def size = _keys.length
//
//    // these should not be accessible
//    def put(key: DateTime, value: Int) { throw new IllegalAccessError() }
//    def inc(key: DateTime) = throw new IllegalAccessError()
//  }

  /*protected*/ Locator get locator {
    if (_locator == null) {
      _locator = new _Locator(times, l2t, t2l);
    }
    return _locator;
  }

  /**
   * Localize TimeIndex using particular time zone. Note, this does not
   * change the values of the times; merely how they are interpreted.
   *
   * @param tzone The time zone
   */
//  withZone(DateTimeZone tzone) => new IndexTime(times, tzone);

  int get length => times.length;

  toVec() => new VecTime(times.toVec() /*, tzone*/);

  raw(int loc) => l2t(times.raw(loc));

  take(List<int> locs) => il2it(times.take(locs));

  without(List<int> locs) => il2it(times.without(locs));

  // specialized concatenation
  IndexTime concat(IndexTime x, [ScalarTag<DateTime> stc]) {
    return il2it(new Index(
        Concat.append(times.toArray_(), x.times.toArray_(), times.scalarTag,
            x.times.scalarTag, ScalarTag.stInt),
        ScalarTag.stInt));
  }

  // general concatenation
//  def concat[B, C](x: Index[B])(implicit wd: Promoter[DateTime, B, C], mc: ST[C], oc: ORD[C]) =
//    Index(util.Concat.append[DateTime, B, C](toArray, x.toArray))

  // find the first location whereby an insertion would maintain a sorted index
  lsearch(DateTime t) => times.lsearch(t2l(t));

  // find the last location whereby an insertion would maintain a sorted index
  rsearch(DateTime t) => times.rsearch(t2l(t));

  // slice at array locations, [from, until)
  slice(int from, int until, [int stride = 1]) =>
      il2it(times.slice(from, until, stride));

  intersect(Index<DateTime> other) {
    var tmp = times.intersect(getTimes_(other));
    return new ReIndexer(tmp.lTake, tmp.rTake, il2it(tmp.index));
  }

  union(Index<DateTime> other) {
    var tmp = times.union(getTimes_(other));
    return new ReIndexer(tmp.lTake, tmp.rTake, il2it(tmp.index));
  }

  // default implementation, could be sped up in specialized instances
  bool get isMonotonic => times.isMonotonic;

  // check whether, if not unique, the index values are at least grouped together
  bool get isContiguous => times.isContiguous;

  /** Returns offsets into index that would result in sorted index */
  argSort() => times.argSort();

  IndexTime get reversed => il2it(times.reversed);

  // sql-style joins
  join(Index<DateTime> other, [JoinType how]) {
    var tmp = times.join(getTimes_(other), how);
    return new ReIndexer(tmp.lTake, tmp.rTake, il2it(tmp.index));
  }

  Index<int> getTimes_(Index<DateTime> other) {
    if (other is IndexTime) {
      return other.times;
    } else {
      return other.map(t2l, lmf);
    }
  }

  @override
  /*Option[*/ List<int> getIndexer(Index<DateTime> other) {
    var otherTs = getTimes_(other);
    var ixer = times.join(otherTs, JoinType.RightJoin);
    if (ixer.index.length != other.length) {
      throw "Could not reindex uniquely";
    }
    return ixer.lTake;
  }

  // maps

  map /*[@spec(Boolean, Int, Long, Double) B: ST: ORD]*/ (
          dynamic f(DateTime arg), ScalarTag scb) =>
      times.map(
          (v) => f(new DateTime.fromMillisecondsSinceEpoch(v /*, chrono*/)),
          scb);

  /*private[saddle]*/ toArray_() {
    var arr = array.empty(length, scalarTag);
    var i = 0;
    while (i < length) {
      arr[i] = l2t(times.raw(i));
      i += 1;
    }
    return arr;
  }
//}

//object IndexTime {
//  @transient lazy private val st = ScalarTagTime
//  @transient lazy private val sl = ScalarTagLong

  /**
   * Create a new IndexTime from a sequence of times
   */
//  def apply(times : DateTime*): IndexTime = apply(Vec(times : _*))
  factory IndexTime.fromList(List<DateTime> times) =>
      new IndexTime.fromVec(new Vec(times, ScalarTagTime));

  /**
   * Create a new IndexTime from a Vec of times, with an attached timezone
   */
  factory IndexTime.fromVec(
      Vec<DateTime> times /*, [DateTimeZone tzone = ISO_CHRONO.getZone]*/) {
    var millis = array.empty /*[Long]*/ (times.length, ScalarTagInt);
    var i = 0;
    while (i < millis.length) {
      var t = times[i];
      millis[i] = ScalarTagTime.isMissing(t)
          ? ScalarTagInt.missing()
          : t.millisecondsSinceEpoch;
      i += 1;
    }
    return new IndexTime(new Index(millis, ScalarTagInt) /*, tzone*/);
  }
}

class _Locator extends Locator<DateTime> {
  Index<int> _times;
  var _keys;
  Function _l2t, _t2l;

  _Locator(this._times, this._l2t, this._t2l) : super.internal() {
    _keys = _times.uniques().map(_l2t, ScalarTagTime);
  }

  bool contains(DateTime key) => _times.contains(_t2l(key));
  get(DateTime key) => _times.getFirst(_t2l(key));

  count(DateTime key) => _times.count(_t2l(key));

  keys() => _keys.toArray();
  counts() => _times.counts;

  int get size => _keys.length;

  // these should not be accessible
  put(DateTime key, int value) {
    throw new UnimplementedError();
  }

  inc(DateTime key) => throw new UnimplementedError();
}
