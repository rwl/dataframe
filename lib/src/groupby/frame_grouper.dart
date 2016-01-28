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

library saddle.groupby;

//import org.saddle._

/**
 * Helper class to do combine or transform after a groupBy
 */
class FrameGrouper<Z, X, Y, T> /*[Z: ST: ORD, X: ST: ORD, Y: ST: ORD, T: ST]*/ {
  FrameGrouper(Index<Z> ix, Frame<X, Y, T> frame, [bool sorted = true]);

  /*private lazy val uniq: Array<Z> = {
    val arr = ix.uniques.toArray
    if (sorted && !ix.isMonotonic)
      array.take(arr, array.argsort(arr), sys.error("Logic error in sorting group index"))
    else
      arr
  }*/

  Array<Z> get keys => uniq;

//  Array/*<(Z, Array<int>)>*/ groups() => for (k <- keys) yield (k, ix.get(k))

  Frame<Z, Y, U> combine /*[U: ST]*/ (U fn(Z arg1, Vec<T> arg2)) => new Frame(
          frame.values.map(SeriesGrouper.combine(ix, keys, _, fn))) // : _*)
      .setRowIndex(keys)
      .setColIndex(frame.colIx);

  // less powerful combine, ignores group key
  Frame<Z, Y, U> combineIgnoreKey /*[U: ST: ORD]*/ (U fn(Vec<T> arg)) =>
      combine((k, v) => fn(v));

  Frame<X, Y, U> transform /*[U: ST]*/ (Vec<U> fn(Z arg1, Vec<T> arg2)) =>
      Frame(frame.values.map(SeriesGrouper.transform(_, groups, fn)),
          frame.rowIx, frame.colIx);

  // less powerful transform, ignores group key
  Frame<X, Y, U> transformIgnoreKey /*[U: ST]*/ (Vec<U> fn(Vec<T> arg)) =>
      transform((k, v) => fn(v));
}

//object FrameGrouper {
//  def apply[Z: ST: ORD, Y: ST: ORD, T: ST](frame: Frame[Z, Y, T]) =
//    new FrameGrouper(frame.rowIx, frame)
//
//  def apply[Z: ST: ORD, X: ST: ORD, Y: ST: ORD, T: ST](
//    ix: Index<Z>, frame: Frame[X, Y, T]) = new FrameGrouper(ix, frame)
//}
//
