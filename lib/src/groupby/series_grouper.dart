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

library saddle.groupby.series_grouaper;

//import org.saddle._

import '../series.dart';
import '../index.dart';
import '../vec.dart';

import 'index_grouper.dart';

/**
 * Helper class to do combine or transform after a groupBy
 */
class SeriesGrouper<Y, X,
    T> /*[Y: ST: ORD, X: ST: ORD, T: ST]*/ extends IndexGrouper<Y> {
  SeriesGrouper(Index<Y> ix, Series<X, T> series, [bool sorted = true])
      : super(ix, sorted);

  Series<Y, U> combine /*[U: ST: ORD]*/ (U fn(Y arg1, Vec<T> arg2)) =>
      new Series(new SeriesGrouper.combine(ix, keys, series.values, fn),
          new Index(keys));

  // less powerful combine, ignores group key
  Series<Y, U> combineIgnoreKey /*[U: ST: ORD]*/ (U fn(Vec<T> arg)) =>
      combine((k, v) => fn(v));

  Series<X, U> transform /*[U: ST]*/ (Vec<U> fn(Y arg1, Vec<T> arg2)) =>
      new Series(
          new SeriesGrouper.transform(series.values, groups, fn), series.index);

  // less powerful transform, ignores group key
  Series<X, U> transformIgnoreKey /*[U: ST]*/ (Vec<U> fn(Vec<T> arg)) =>
      transform((k, v) => fn(v));
//}
//
//object SeriesGrouper {
  // Collapses each group vector to a single value
  static /*private[saddle]*/ Vec<U> combine_ /*[Y: ST: ORD, T: ST, U: ST]*/ (
      Index<Y> ix, List<Y> uniq, Vec<T> vec, U fn(Y arg1, Vec<T> arg2)) {
    var sz = uniq.length;

    var res = new List<U>(sz);
    var i = 0;
    while (i < sz) {
      var v = uniq[i];
      res[i] = fn(v, vec.take(ix(v)));
      i += 1;
    }

    return new Vec(res);
  }

  // Transforms each group vector into a new vector
  static /*private[saddle]*/ Vec<U> transform_ /*[Y: ST: ORD, T: ST, U: ST]*/ (
      Vec<T> vec,
      List /*[(Y, Array[Int])]*/ groups,
      Vec<U> fn(Y arg1, Vec<T> arg2)) {
//    var iter = for ( (k, i) <- groups) yield (fn(k, vec(i)), i)
//    var res = Array.ofDim[U](vec.length)
//    for ((v, i) <- iter) {
//      val sz = v.length
//      var k = 0
//      while (k < sz) {
//        // put each value back into original location
//        res(i(k)) = v(k)
//        k += 1
//      }
//    }
    return new Vec(res);
  }

  factory SeriesGrouper.make /*[Y: ST: ORD, X: ST: ORD, T: ST]*/ (
          Index<Y> ix, Series<X, T> ser) =>
      new SeriesGrouper(ix, ser);

  factory SeriesGrouper.fromSeries /*[Y: ST: ORD, T: ST]*/ (
          Series<Y, T> series) =>
      new SeriesGrouper(series.index, series);
}
