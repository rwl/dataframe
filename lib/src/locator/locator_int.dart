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

library saddle.locator;

//import it.unimi.dsi.fastutil.ints.{Int2IntLinkedOpenHashMap, Int2IntOpenHashMap}

import 'locator.dart';

/**
 * A integer-to-integer hash map, backed by fastutil implementation
 */
class LocatorInt extends Locator<int> {
  Map<int, int> map, cts;

  LocatorInt([int sz = Locator.INIT_CAPACITY]) : super.internal() {
    map = {};
    cts = {};
//    map.defaultReturnValue(-1);
//    cts.defaultReturnValue(0);
  }

//  var map = new Int2IntLinkedOpenHashMap(sz);
//  var cts = new Int2IntOpenHashMap(sz);

  int get(int key) => map[key] ?? -1;

  void put(int key, int value) {
    // prevents unboxing!
    var _ = map[key] = value;
  }

  bool contains(int key) => map.containsKey(key);

  int get size => map.length;

  List<int> keys() => map.keys.toList();

  int inc(int key) {
    int cur = cts[key] ?? 0;
    cts[key] = cur + 1;
    return cur;
  }

  int count(int key) => cts[key];

  List<int> counts() {
    var iter = map.keys;
    var res = new List<int>(size);
    var i = 0;
    for (var k in iter) {
      res[i] = cts[k];
      i += 1;
    }
    return res;
  }
}
