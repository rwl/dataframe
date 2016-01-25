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

library saddle.scalar_tag_int;

//import org.saddle._
//import org.saddle.vec.VecInt
//import org.saddle.mat.MatInt
//import org.saddle.buffer.BufferInt
//import org.saddle.index.IndexInt
//import org.saddle.locator.LocatorInt
//import org.saddle.array.Sorter

import 'scalar_tag.dart';
import '../vec.dart';
import '../vec/vec_int.dart';
import '../index/index_int.dart';
import '../index.dart';
import '../locator/locator.dart';
import '../locator/locator_int.dart';
import '../buffer.dart';
import '../util/util.dart';

_ScalarTagInt ScalarTagInt = new _ScalarTagInt();

/**
 * Int ScalarTag
 */
class _ScalarTagInt extends ScalarTag<int> {
  int missing() => MIN_INT;
  bool isMissing(int v) => v == MIN_INT;
  bool notMissing(int v) => v != MIN_INT;

  int compare(int x, int y) /*(implicit ev: ORD[Int])*/ {
    if (x == y) {
      return 0;
    } else if (x > y) {
      return 1;
    } else {
      return -1;
    }
  }

  double toDouble(int t) /*(implicit ev: NUM[Int])*/ {
    if (isMissing(t)) {
      ScalarTagDouble.missing;
    } else {
      return t.toDouble();
    }
  }

  int zero(/*implicit*/ Numeric<int> ev) => 0;
  int one(/*implicit*/ Numeric<int> ev) => 1;
  int inf(/*implicit*/ Numeric<int> ev) => MAX_INT;
  int negInf(/*implicit*/ Numeric<int> ev) => MIN_INT;

  show(int v) => isMissing(v) ? "%s".format("NA") : "%d".format(v);

//  @override
//  def runtimeClass = classOf[Int]

  Buffer<int> makeBuf([int sz = Buffer.INIT_CAPACITY]) => new BufferInt(sz);
  Locator<int> makeLoc([int sz = Buffer.INIT_CAPACITY]) => new LocatorInt(sz);
  Vec<int> makeVec(List<int> arr) => new VecInt(arr);
  Mat<int> makeMat(int r, int c, List<int> arr) => new MatInt(r, c, arr);
  Index<int> makeIndex(Vec<int> vec) /*(implicit ord: ORD[Int])*/ =>
      new IndexInt(vec);
  Sorter<int> makeSorter(/*implicit*/ Ordering<int> ord) => Sorter.intSorter;

  Vec<int> concat(List<Vec<int>> arrs) =>
      new Vec(array.flatten(arrs.map(_.toArray)));

  @override
  toString() => "ScalarTagInt";
}
