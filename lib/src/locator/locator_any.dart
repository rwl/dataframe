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

library saddle.locator.any;

//import org.saddle.ST
//import it.unimi.dsi.fastutil.objects.{Object2IntLinkedOpenHashMap, Object2IntOpenHashMap}

import 'locator.dart';

/**
 * An object-to-integer hash map, backed by fastutil implementation
 */
class LocatorAny<T> /*[T: ST]*/ extends Locator<T> {
  LocatorAny([int sz = Locator.INIT_CAPACITY]) : super.internal();

  Map map = {}; //new Object2IntLinkedOpenHashMap<T>(sz);
  Map cts = {}; //new Object2IntOpenHashMap<T>(sz);

//  map.defaultReturnValue(-1)
//  cts.defaultReturnValue(0)

  int get(T key) => map.getInt(key);

  put(T key, int value) {
    // prevents unboxing!
    int _ = map[key] = value;
  }

  bool contains(T key) => map.containsKey(key);

  int get size => map.size();

  inc(T key) => cts.addTo(key, 1);

  int count(T key) => cts.getInt(key);

  int counts() {
    var iter = map.keySet().iterator();
    var res = new List<int>(size);
    var i = 0;
    while (iter.hasNext) {
      res[i] = cts.getInt(iter.next());
      i += 1;
    }
    return res;
  }

  keys() {
    var ks = map.keySet();
    var it = ks.iterator();
    var sz = ks.size();
    var newArr = /*implicitly[ST<T>]*/ scalarTag.newArray(sz);
    var i = 0;
    while (i < sz) {
      newArr[i] = it.next();
      i += 1;
    }
    return newArr;
  }
}
