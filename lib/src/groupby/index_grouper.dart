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

library saddle.groupby.index_grouper;

//import org.saddle._

import '../index.dart';
import '../array/array.dart';
import 'groupby.dart';

/**
 * Creates groups for each unique key in an index
 */
class IndexGrouper<Y> /*[Y: ST: ORD]*/ {
  Index<Y> ix;
  bool sorted;

  IndexGrouper(this.ix, [this.sorted = true]);

  List<Y> _uniq = null;
  /*private lazy*/ List<Y> get uniq {
    if (_uniq == null) {
      var arr = ix.uniques().toArray_();
      if (sorted && !ix.isMonotonic) {
        _uniq = array.take(arr, array.argsort(arr, ix.scalarTag),
            () => throw "Logic error in sorting group index");
      } else {
        _uniq = arr;
      }
    }
    return _uniq;
  }

  List<Y> get keys => uniq;

  List<Group<Y>> /*[(Y, Array[Int])]*/ get groups =>
      keys.map((k) => new Group<Y>(k, ix.get(k))).toList();
//}

//object IndexGrouper {
  factory IndexGrouper.fromIndex /*[Y: ST: ORD]*/ (Index<Y> ix) =>
      new IndexGrouper(ix);
  factory IndexGrouper.make /*[Y: ST: ORD]*/ (Index<Y> ix,
          [bool sorted = true]) =>
      new IndexGrouper(ix, sorted);
}
