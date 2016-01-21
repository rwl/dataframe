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

library saddle.index;

//import scala.{ specialized => spec }
//import org.saddle._
//import locator.Locator

import '../index.dart';
import '../locator/locator.dart';

/**
 * Helper class for Index instances
 */
/*private[saddle]*/ class IndexImpl {
//  case class IndexProperties(contiguous: Boolean,  // if there are duplicates, are they all in the same place?
//                             monotonic: Boolean)   // are the elements ordered (ascending)?

  static sentinelErr() => throw new ArrayIndexOutOfBoundsException(
      "Cannot access index position -1");

  /*(Locator[T], IndexProperties)*/ keys2map /*[@spec(Boolean, Int, Long, Double) T: ST: ORD]*/ (
      Index<T> keys) {
    var map = Locator[T](keys.length);
    var sc = keys.scalarTag;
    var i = 0;
    var contiguous = true;
    var monotonic = true;
    while (i < keys.length) {
      val k = keys.raw(i);
      if (map.inc(k) == 0) {
        map.put(k, i);
      } else {
        if (k != keys.raw(i - 1)) contiguous = false;
      }
      if (i > 0) {
//        monotonic &&= !sc.gt(keys.raw(i-1), keys.raw(i));
      }
      i += 1;
    }
//    (map, IndexProperties(contiguous, monotonic))
  }

  static bool contiguous(Index keys) {
    var sc = keys.scalarTag;
    var i = 0;
    var contiguous = true;
    while (i < keys.length) {
      var k = keys.raw(i);
      if (map.inc(k) == 0) {
        map.put(k, i);
      } else {
        if (k != keys.raw(i - 1)) contiguous = false;
      }
      if (i > 0) {
//        monotonic &&= !sc.gt(keys.raw(i-1), keys.raw(i));
      }
      i += 1;
    }
  }
}

class IndexProperties<T> {
  bool contiguous;
  bool monotonic;
  Locator map;

  IndexProperties(Index keys) {
    var sc = keys.scalarTag;
    map = new Locator<T>(sc, keys.length);
    var i = 0;
    contiguous = true;
    monotonic = true;
    while (i < keys.length) {
      var k = keys.raw(i);
      if (map.inc(k) == 0) {
        map.put(k, i);
      } else {
        if (k != keys.raw(i - 1)) contiguous = false;
      }
      if (i > 0) {
        monotonic = monotonic && !sc.gt(keys.raw(i - 1), keys.raw(i));
      }
      i += 1;
    }
  }
}
