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

library saddle.groupby.frame_grouper;

//import org.saddle._

import '../index.dart';
import '../frame.dart';
import '../vec.dart';
import '../array/array.dart';

import 'series_grouper.dart';
import 'groupby.dart';

/**
 * Helper class to do combine or transform after a groupBy
 */
class FrameGrouper<Z, X, Y, T> /*[Z: ST: ORD, X: ST: ORD, Y: ST: ORD, T: ST]*/ {
  final Index<Z> ix;
  final Frame<X, Y, T> frame;
  final bool sorted;

  FrameGrouper(this.ix, this.frame, [this.sorted = true]);

  List _uniq = null;
  List get uniq {
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
  /*private lazy val uniq: Array<Z> = {
    val arr = ix.uniques.toArray
    if (sorted && !ix.isMonotonic)
      array.take(arr, array.argsort(arr), sys.error("Logic error in sorting group index"))
    else
      arr
  }*/

  List<Z> get keys => uniq;

  List<Group<Z>> /*<(Z, Array<int>)>*/ groups() =>
      keys.map((k) => new Group(k, ix.get(k))).toList();

  Frame<Z, Y, U> combine /*[U: ST]*/ (U fn(Z arg1, Vec<T> arg2)) {
    return new Frame(frame.values
            .map(new SeriesGrouper.combine(ix, keys, _, fn))) // : _*)
        .setRowIndex(keys)
        .setColIndex(frame.colIx);
  }

  // less powerful combine, ignores group key
  Frame<Z, Y, U> combineIgnoreKey /*[U: ST: ORD]*/ (U fn(Vec<T> arg)) =>
      combine((k, v) => fn(v));

  Frame<X, Y, U> transform /*[U: ST]*/ (Vec<U> fn(Z arg1, Vec<T> arg2)) =>
      new Frame(frame.values.map(new SeriesGrouper.transform(_, groups, fn)),
          frame.rowIx, frame.colIx);

  // less powerful transform, ignores group key
  Frame<X, Y, U> transformIgnoreKey /*[U: ST]*/ (Vec<U> fn(Vec<T> arg)) =>
      transform((k, v) => fn(v));
//}

//object FrameGrouper {
  factory FrameGrouper.fromFrame /*[Z: ST: ORD, Y: ST: ORD, T: ST]*/ (
          Frame<Z, Y, T> frame) =>
      new FrameGrouper(frame.rowIx, frame);

//  factory FrameGrouper.from /*[Z: ST: ORD, X: ST: ORD, Y: ST: ORD, T: ST]*/ (
//          Index<Z> ix, Frame<X, Y, T> frame) =>
//      new FrameGrouper(ix, frame);
}
