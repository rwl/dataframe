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

library saddle.stats;

//import org.saddle._
//import Series.Vec2RollingStats

import '../series.dart';

/**
 * Rolling statistical methods made available on numeric Series objects via enrichment.
 * These methods scan over the Series and compute cumulative values.
 */
class SeriesRollingStats<T> /*[X: ST: ORD, T: Vec2RollingStats: ST]*/ {
  Series<X, T> s;
  SeriesRollingStats(this.s);

  /*protected*/ var ev = implicitly[Vec2RollingStats[T]];

  /**
   * Rolling count; compute count of number of elements in Series over a sliding window, ignoring
   * any NA values.
   * @param winSz Size of the sliding window
   */
  Series<X, int> rollingCount(int winSz) => Series(
      ev(s.values).rollingCount(winSz),
      s.index.slice(winSz - 1, s.values.length));

  /**
   * Rolling sum; compute sum of elements in Series over a sliding window, ignoring any NA
   * values.
   * @param winSz Size of the sliding window
   */
  Series<X, T> rollingSum(int winSz) => Series(ev(s.values).rollingSum(winSz),
      s.index.slice(winSz - 1, s.values.length));

  /**
   * Rolling mean; compute mean of elements in Series over a sliding window, ignoring any NA
   * values.
   * @param winSz Size of the sliding window
   */
  Series<X, double> rollingMean(int winSz) => Series(
      ev(s.values).rollingMean(winSz),
      s.index.slice(winSz - 1, s.values.length));

  /**
   * Rolling median; compute mean of elements in Series over a sliding window, ignoring any NA
   * values.
   * @param winSz Size of the sliding window
   */
  Series<X, double> rollingMedian(int winSz) => Series(
      ev(s.values).rollingMedian(winSz),
      s.index.slice(winSz - 1, s.values.length));
//}
//
//object SeriesRollingStats {
  /**
   * Factory method for creating an enriched Series object containing statistical functions;
   * usually created implicitly.
   *
   * @param s Series to wrap
   * @tparam X Type of index
   * @tparam T Type of elements
   */
//  SeriesRollingStats/*[X: ST: ORD, T: Vec2RollingStats: ST]*/(s: Series<X, T>) = new SeriesRollingStats(s)
}
