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

library saddle.index.impl;

//import scala.{ specialized => spec }
//import org.saddle._
//import locator.Locator

import '../index.dart';
import '../locator/locator.dart';
import '../scalar/scalar_tag.dart';

/**
 * Helper class for Index instances
 */
/*private[saddle]*/ class IndexImpl {
  static sentinelErr() =>
      throw new IndexError(-1, null, "Cannot access index position -1");

  static Keys2Map /*(Locator[T], IndexProperties)*/ keys2map /*[@spec(Boolean, Int, Long, Double) T: ST: ORD]*/ (
      Index /*<T>*/ keys, ScalarTag st) {
    var map = new Locator /*[T]*/ (st, keys.length);
    var sc = keys.scalarTag;
    var i = 0;
    var contiguous = true;
    var monotonic = true;
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
    return new Keys2Map(map, new IndexProperties(contiguous, monotonic));
  }
}

class IndexProperties<T> {
  // if there are duplicates, are they all in the same place?
  final bool contiguous;
  // are the elements ordered (ascending)?
  final bool monotonic;

  IndexProperties(this.contiguous, this.monotonic);
}

class Keys2Map<T> {
  final Locator<T> locator;
  final IndexProperties props;
  Keys2Map(this.locator, this.props);
}
