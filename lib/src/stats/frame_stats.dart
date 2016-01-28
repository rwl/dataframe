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

import '../frame.dart';
import '../series.dart';

/**
 * Statistical methods made available to operate on columns of a Frame via enrichment.
 *
 * @param frame The frame to enrich
 * @tparam RX Type of the row index elements
 * @tparam CX Type of the column index elements
 * @tparam T Type of the elements of the frame
 */
class FrameStats<RX, CX, T> /*[RX, CX, T: ST]*/ {
  Frame<RX, CX, T> frame;
  FrameStats(this.frame);
  // --------------------------------------
  // helpful math ops

//  type S2Stats = Series.Series2Stats[T]

  /**
   * Sum of the elements of each column, ignoring NA values
   */
  Series<CX, T> sum(/*implicit*/ S2Stats ev) => frame.reduce(_.sum);

  /**
   * Count of the elements of each column, ignoring NA values
   */
  Series<CX, int> count(/*implicit*/ S2Stats ev) => frame.reduce(_.count);

  /**
   * Min of the elements of each column, ignoring NA values
   */
  Series<CX, T> min(/*implicit*/ S2Stats ev) =>
      frame.reduce(_.min.getOrElse(implicitly[ST[T]].missing));

  /**
   * Max of the elements of each column, ignoring NA values
   */
  Series<CX, T> max(/*implicit*/ S2Stats ev) =>
      frame.reduce(_.max.getOrElse(implicitly[ST[T]].missing));

  /**
   * Product of the elements of each column, ignoring NA values
   */
  Series<CX, T> prod(/*implicit*/ S2Stats ev) => frame.reduce(_.prod);

  /**
   * Conditional count of the elements of each column, ignoring NA values
   * @param test Function predicate to utilize in count, T => Boolean
   */
  Series<CX, int> countif(bool test(T arg)) /*(implicit S2Stats ev)*/ =>
      frame.reduce(_.countif(test));

  /**
   * Sum of the natural logs of the elements of each column, ignoring NA values.
   */
  Series<CX, double> logsum(/*implicit*/ S2Stats ev) => frame.reduce(_.logsum);

  /**
   * Sample mean of each column
   */
  Series<CX, double> mean(/*implicit*/ S2Stats ev) => frame.reduce(_.mean);

  /**
   * Median of each column
   */
  Series<CX, double> median(/*implicit*/ S2Stats ev) => frame.reduce(_.median);

  /**
   * Geometric mean of each column
   */
  Series<CX, double> geomean(/*implicit*/ S2Stats ev) =>
      frame.reduce(_.geomean);

  /**
   * Sample variance of each column
   */
  Series<CX, double> variance(/*implicit*/ S2Stats ev) =>
      frame.reduce(_.variance);

  /**
   * Sample standard deviation of each column
   */
  Series<CX, double> stdev(/*implicit*/ S2Stats ev) =>
      variance.mapValues(math.sqrt);

  /**
   * Sample skewness of each column
   */
  Series<CX, double> skew(/*implicit*/ S2Stats ev) => frame.reduce(_.skew);

  /**
   * Sample kurtosis of each column
   */
  Series<CX, double> kurt(/*implicit*/ S2Stats ev) => frame.reduce(_.kurt);

//  private type V2Stats = Vec[T] => VecStats[T]

  /**
   * Demean each column in the frame
   */
  Frame<RX, CX, double> demeaned(/*implicit*/ V2Stats ev) =>
      frame.mapVec(_.demeaned);

//  private type V2RollingStats = Vec[T] => VecRollingStats[T]

  /**
   * Rolling count; compute count of number of elements in columns of Frame over a sliding window, ignoring
   * any NA values.
   * @param winSz Size of the rolling window
   */
  Frame<RX, CX, int> rollingCount(
          int winSz) /*(implicit ev: V2RollingStats)*/ =>
      frame.mapVec(_.rollingCount(winSz));

  /**
   * Rolling sum; compute sum of elements in columns of Frame over a sliding window, ignoring any NA
   * values.
   * @param winSz Size of the sliding window
   */
  Frame<RX, CX, T> rollingSum(int winSz) /*(implicit ev: V2RollingStats)*/ =>
      frame.mapVec(_.rollingSum(winSz));

  /**
   * Rolling mean; compute mean of elements in columns of Frame over a sliding window, ignoring any NA
   * values.
   * @param winSz Size of the sliding window
   */
  Frame<RX, CX, double> rollingMean(
          int winSz) /*(implicit ev: V2RollingStats)*/ =>
      frame.mapVec(_.rollingMean(winSz));

  /**
   * Rolling median; compute median of elements in columns of Frame over a sliding window, ignoring any NA
   * values.
   * @param winSz Size of the sliding window
   */
  Frame<RX, CX, double> rollingMedian(
          int winSz) /*(implicit ev: V2RollingStats)*/ =>
      frame.mapVec(_.rollingMedian(winSz));

//  private type V2ExpandingStats = Vec[T] => VecExpandingStats[T]

  /**
   * Cumulative count for each column; each successive element of the output is the cumulative
   * count from the initial element, ignoring NAs.
   */
  Frame<RX, CX, int> cumCount(/*implicit*/ V2ExpandingStats ev) =>
      frame.mapVec(_.cumCount);

  /**
   * Cumulative sum for each column; each successive element of the output is the cumulative
   * sum from the initial element, ignoring NAs.
   */
  Frame<RX, CX, T> cumSum(/*implicit*/ V2ExpandingStats ev) =>
      frame.mapVec(_.cumSum);

  /**
   * Cumulative product for each column; each successive element of the output is the cumulative
   * product from the initial element, ignoring NAs.
   */
  Frame<RX, CX, T> cumProd(/*implicit*/ V2ExpandingStats ev) =>
      frame.mapVec(_.cumProd);

  /**
   * Cumulative min for each column; each successive element of the output is the cumulative
   * min from the initial element, ignoring NAs.
   */
  Frame<RX, CX, T> cumMin(/*implicit*/ V2ExpandingStats ev) =>
      frame.mapVec(_.cumMin);

  /**
   * Cumulative max for each column; each successive element of the output is the cumulative
   * max from the initial element, ignoring NAs.
   */
  Frame<RX, CX, T> cumMax(/*implicit*/ V2ExpandingStats ev) =>
      frame.mapVec(_.cumMax);
}
