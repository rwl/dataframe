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

//import org.saddle._
//import org.saddle.vec.VecAny
//import org.saddle.mat.MatAny
//import org.saddle.buffer.BufferAny
//import org.saddle.index.IndexAny
//import org.saddle.locator.{Locator, LocatorAny}
//import org.saddle.array.Sorter

import 'scalar_tag.dart';
import '../vec.dart';
import '../vec/vec_bool.dart';
import '../index/index_any.dart';
import '../index.dart';
import '../locator/locator.dart';
import '../locator/locator_any.dart';
import '../buffer.dart';
import '../util/util.dart';

class ScalarTagAny<T> /*[T: CLM]*/ extends ScalarTag<T> {
  T missing() => null; //.asInstanceOf /*<T>*/ ();
  bool isMissing(T v) => v == null;
  bool notMissing(T v) => v != null;

  int compare(T x, T y) /*(implicit ev: ORD<T>)*/ {
    if (x == null && y == null) {
      return 0;
    } else if (x == null) {
      return -1;
    } else if (y == null) {
      return 1;
    } else {
      return identical(x, y) ? 1 : 0; //ev.compare(x, y);
    }
  }

  double toDouble(T t) /*(implicit ev: NUM<T>)*/ =>
      (t as dynamic).toDouble(); //ev.toDouble(t);

  T zero(/*implicit Numeric<T> ev*/) => ev.zero;
  T one(/*implicit Numeric<T> ev*/) => ev.one;
  T inf(/*implicit Numeric<T> ev*/) => throw "Infinities not supported";
  T negInf(/*implicit Numeric<T> ev*/) => throw "Infinities not supported";

  show(T v) => "%s".format(v == null ? "NA" : v.toString());

//  @override def runtimeClass = implicitly[CLM<T>].erasure

  Buffer<T> makeBuf([int sz = Buffer.INIT_CAPACITY]) =>
      new BufferAny<T>(sz)(this);
  Locator<T> makeLoc([int sz = Buffer.INIT_CAPACITY]) =>
      new LocatorAny<T>(sz)(this);
  Vec<T> makeVec(List<T> arr) => new VecAny<T>(arr)(this);
  Mat<T> makeMat(int r, int c, List<T> arr) => new MatAny<T>(r, c, arr)(this);
  Index<T> makeIndex(Vec<T> vec) /*(implicit ord: ORD<T>)*/ =>
      new IndexAny<T>(vec)(this, ord);
  Sorter makeSorter(/*implicit*/ Ordering<T> ord) =>
      Sorter.anySorter /*<T>*/ ();

  Vec<T> concat(List<Vec<T>> arrs) =>
      new Vec(array.flatten(arrs.map(_.toArray)));
}
