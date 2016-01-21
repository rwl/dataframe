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
//import org.saddle.vec.VecDouble
//import org.saddle.mat.MatDouble
//import org.saddle.buffer.BufferDouble
//import org.saddle.index.IndexDouble
//import org.saddle.locator.LocatorDouble
//import org.saddle.array.Sorter

/**
 * Double ScalarTag
 */
class ScalarTagDouble extends ScalarTag<double> {
  double get missing => double.NAN;
  bool isMissing(double v) => (v != v);
  bool notMissing(double v) => (v == v);

  // note, consider N/A's equal
  compare(double x, double y) /*(implicit ev: ORD<double>)*/ {
    if (x == y) {
      return 0;
    } else if (x > y) {
      return 1;
    } else if (x < y) {
      return -1;
    } else {
      return 0;
    }
  }

  double toDouble(double t) /*(implicit ev: NUM<double>)*/ => t;
  @override
  bool get isDouble => true;

  double zero(/*implicit*/ Numeric<double> ev) => 0.0;
  double one(/*implicit*/ Numeric<double> ev) => 1.0;
  double inf(/*implicit*/ Numeric<double> ev) => double.INFINITY;
  double negInf(/*implicit*/ Numeric<double> ev) => double.NEGATIVE_INFINITY;

  show(double v) => (isMissing(v)) ? "%s".format("NA") : "%.4f".format(v);

//  @override
//  get runtimeClass => classOf<double>;

  Buffer<double> makeBuf([int sz = Buffer.INIT_CAPACITY]) =>
      new BufferDouble(sz);
  Locator<double> makeLoc([int sz = Buffer.INIT_CAPACITY]) =>
      new LocatorDouble(sz);
  Vec<double> makeVec(List<double> arr) => new VecDouble(arr);
  Mat<double> makeMat(int r, int c, List<double> arr) =>
      new MatDouble(r, c, arr);
  Index<double> makeIndex(Vec<double> vec) /*(implicit ord: ORD<double>)*/ =>
      new IndexDouble(vec);
  Sorter<double> makeSorter(/*implicit*/ Ordering<double> ord) =>
      Sorter.doubleSorter;

  Vec<double> concat(List<Vec<double>> arrs) =>
      new Vec(array.flatten(arrs.map(_.toArray)));

  @override
  toString() => "ScalarTagDouble";
}
