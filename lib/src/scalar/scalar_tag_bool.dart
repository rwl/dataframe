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

library saddle.scalar.bool;

//import org.saddle._
//import org.saddle.vec.VecBool
//import org.saddle.mat.MatBool
//import org.saddle.buffer.BufferAny
//import org.saddle.index.IndexAny
//import org.saddle.locator.LocatorBool
//import org.saddle.array.Sorter

import 'scalar_tag.dart';
import '../vec.dart';
import '../vec/vec_bool.dart';
import '../index/index_bool.dart';
import '../index.dart';
import '../locator/locator.dart';
//import '../locator/locator_bool.dart';
import '../buffer.dart';
import '../util/util.dart';

final _ScalarTagBool ScalarTagBool = new ScalarTagBool();

/**
 * bool ScalarTag
 */
class _ScalarTagBool extends ScalarTag<bool> {
  bool missing() => false;
  bool isMissing(bool v) => false;
  bool notMissing(bool v) => true;

  int compare(bool x, bool y) /*(implicit ev: ORD<bool>)*/ => x > y ? 1 : 0;

  double toDouble(bool t) /*(implicit ev: NUM<bool>)*/ => t ? 1.0 : 0.0;

  bool zero(/*implicit ev: NUM<bool>*/) => false;
  bool one(/*implicit ev: NUM<bool>*/) => true;
  bool inf(/*implicit ev: NUM<bool>*/) => true;
  bool negInf(/*implicit ev: NUM<bool>*/) => false;

  String show(bool v) => "$v";

//  override def runtimeClass = classOf<bool>

//  def makeBuf(sz: Int = Buffer.INIT_CAPACITY) = new BufferAny<bool>(sz)
  Locator makeLoc([int sz = Buffer.INIT_CAPACITY]) => new LocatorBool();
  Vec<bool> makeVec(List<bool> arr) => new VecBool(arr, this);
  Mat<bool> makeMat(int r, int c, List<bool> arr) => new MatBool(r, c, arr);
  Index<bool> makeIndex(Vec<bool> vec) /*(implicit ord: ORD<bool>)*/ =>
      new IndexAny<bool>(vec);
  Sorter<bool> makeSorter(/*implicit ord: ORD<bool>*/) => Sorter.boolSorter;

//  def concat(arrs: IndexedSeq[Vec<bool>]): Vec<bool> = Vec(array.flatten(arrs.map(_.toArray)))

  @override
  toString() => "ScalarTagBool";
}
