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

library saddle.scalar;

//import org.joda.time._
//
//import org.saddle._
//import org.saddle.array.Sorter
//import org.joda.time.format.DateTimeFormat
//import org.saddle.vec.VecTime
//import org.saddle.index.IndexTime

import 'scalar_tag_any.dart';
import 'scalar_tag_int.dart';
import '../vec.dart';
//import '../vec/vec_time.dart';
//import '../index/index_time.dart';
import '../index.dart';
import '../locator/locator.dart';
//import '../locator/locator_time.dart';
import '../buffer.dart';
import '../util/util.dart';

/**
 * DateTime ScalarTag
 */
class ScalarTagTime extends ScalarTagAny<DateTime> {
  List<int> time2LongArray(List<DateTime> arr) {
    var sz = arr.length;
    var larr = new List<int>(sz);
    var i = 0;
    while (i < sz) {
      if (arr[i] == null) {
        larr[i] = ScalarTagInt.missing();
      } else {
        larr[i] = arr[i].millisecondsSinceEpoch;
      }
//      larr(i) = Option(arr(i)) match {
//        case Some(x) => x.getMillis
//        case None    => ScalarTagLong.missing
//      }
      i += 1;
    }
    return larr;
  }

  @override
  Vec<DateTime> makeVec(List<DateTime> arr) =>
      new VecTime(new Vec(time2LongArray(arr)));

  @override
  Index<DateTime> makeIndex(
          Vec<DateTime> vec) /*(implicit ord: ORD[DateTime])*/ =>
      new IndexTime(new Index(time2LongArray(vec.toArray)));

  @override
  Sorter<DateTime> makeSorter(/*implicit Ordering<DateTime> ord*/) =>
      Sorter.timeSorter;

//  @transient lazy private val fmtZ = DateTimeFormat.forPattern("YYYY-MM-dd HH:mm:ss.SSSZZ")

  @override
  show(DateTime v) => v != null ? v.map((a) => fmtZ.print(a)) : "NA";

  // forward 2.10 compatibility
//  @override def runtimeClass = classOf[DateTime]

  @override
  toString() => "ScalarTagTime";

  @override
  VecTime concat(List<Vec<DateTime>> vecs) => VecTime.concat(vecs);
}
