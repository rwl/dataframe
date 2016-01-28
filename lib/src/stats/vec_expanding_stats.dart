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

library saddle.stats.vec_expanding_stats;

//import org.saddle.Vec
//
//import scala.{specialized => spec}
//import org.saddle.scalar._

import '../vec.dart';
import '../scalar/scalar_tag_double.dart';
import '../scalar/scalar_tag_int.dart';

/**
 * Expanding statistical methods made available on numeric Vec objects via enrichment.
 * These methods scan over the Vec and compute cumulative values.
 */
abstract class VecExpandingStats<A> /*[@spec(Int, Long, Double) A]*/ {
  Vec<A> get r;

  /**
   * Cumulative sum; each successive element of the output is the cumulative
   * sum from the initial element, ignoring NAs.
   */
  Vec<A> cumSum();

  /**
   * Cumulative count; each successive element of the output is the cumulative
   * count from the initial element, ignoring NAs.
   */
  Vec<int> cumCount();

  /**
   * Cumulative min; each successive element of the output is the cumulative
   * min from the initial element, ignoring NAs.
   */
  Vec<A> cumMin();

  /**
   * Cumulative max; each successive element of the output is the cumulative
   * max from the initial element, ignoring NAs.
   */
  Vec<A> cumMax();

  /**
   * Cumulative product; each successive element of the output is the cumulative
   * product from the initial element, ignoring NAs.
   */
  Vec<A> cumProd();
}

abstract class DoubleExpandingStats implements VecExpandingStats<double> {
//  Vec<double> get r;
//  Vec<double> r;
//  DoubleExpandingStats(this.r);

  /*private*/ var sd = ScalarTagDouble;

  Vec<double> cumSum() => r.filterScanLeft(sd.notMissing, 0.0, (a, b) => a + b);
  Vec<int> cumCount() => r.filterScanLeft(sd.notMissing, 0, (a, b) => a + 1);
  Vec<double> cumMin() => r.filterScanLeft(
      sd.notMissing, sd.inf, (double x, double y) => x < y ? x : y);
  Vec<double> cumMax() => r.filterScanLeft(
      sd.notMissing, sd.negInf, (double x, double y) => x > y ? x : y);
  Vec<double> cumProd() =>
      r.filterScanLeft(sd.notMissing, 1.0, (a, b) => a * b);
}

abstract class IntExpandingStats implements VecExpandingStats<int> {
//  Vec<int> get r;
//  Vec<int> r;
//  IntExpandingStats(this.r);

  /*private*/ var sa = ScalarTagInt;

  Vec<int> cumSum() => r.filterScanLeft(sa.notMissing, 0, (a, b) => a + b);
  Vec<int> cumCount() => r.filterScanLeft(sa.notMissing, 0, (a, b) => a + 1);
  Vec<int> cumMin() =>
      r.filterScanLeft(sa.notMissing, sa.inf, (int x, int y) => x < y ? x : y);
  Vec<int> cumMax() => r.filterScanLeft(
      sa.notMissing, sa.negInf, (int x, int y) => x > y ? x : y);
  Vec<int> cumProd() => r.filterScanLeft(sa.notMissing, 1, (a, b) => a * b);
}
/*
class LongExpandingStats(r: Vec[Long]) extends VecExpandingStats[Long] {
  private val sl = ScalarTagLong

  def cumSum: Vec[Long] = r.filterScanLeft(sl.notMissing)(0L)(_ + _)
  def cumCount: Vec<int> = r.filterScanLeft(sl.notMissing)(0)((a, b) => a + 1)
  def cumMin: Vec[Long] = r.filterScanLeft(sl.notMissing)(sl.inf)((x: Long, y: Long) => if (x < y) x else y)
  def cumMax: Vec[Long] = r.filterScanLeft(sl.notMissing)(sl.negInf)((x: Long, y: Long) => if (x > y) x else y)
  def cumProd: Vec[Long] = r.filterScanLeft(sl.notMissing)(1L)(_ * _)
}
*/
