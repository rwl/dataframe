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

library saddle.stats.test;

//import org.specs2.mutable.Specification
//import org.saddle._
//import org.saddle.scalar.NA

import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';

/**
 * Hand-calculated tests
 */
//class VecStatsSpec extends Specification {
vecStatsTest() {
  val v1 = new Vec<double>(_1d, 2, 20, 23, 76, 12, -5, -27, 76, 67);
  val v1pos = new Vec<double>(_1d, 2, 20, 23, 76, 12, 76, 67);
  val v2 = new Vec<double>(_12d, 4, 19, 23, 76, 7, 6, -29, 50, 17);
  val v3 = new Vec<double>(_1d, 2, 20, 15, 23, 56, 12);
  val v4 = new Vec<double>(_1d, 2, 20, 23, 56, 12);
  val v5 = new Vec<double>(_2d, 89, 23);

  test("compute mean of a vector", () {
    areClose(v1.mean, 24.5);
  });

  test("compute the median of a vector", () {
    areClose(v1.median, 16);
  });

  test("compute the geometric mean of a vector with positive elements", () {
    areClose(v1pos.geomean, 15.9895, 1e-4);
  });

  test("compute the sample variance of a vector", () {
    areClose(v1.variance, 1318.9444, 1e-4);
  });

  test("compute the sample standard deviation of a vector", () {
    areClose(v1.stdev, 36.3173, 1e-4);
  });

  test("compute the sample skewness of a vector (unbiased)", () {
    areClose(v1.skew, 0.4676, 1e-4);
  });

  test("compute the sample excess kurtosis of a vector (unbiased)", () {
    areClose(v1.kurt, -1.1138, 1e-4);
  });

  test("find the maximum element of a vector", () {
    areClose(v1.max.get, 76.0);
  });

  test("find the minimum element of a vector", () {
    areClose(v1.min.get, -27.0);
  });

  test("find the sum of all elements in a vector", () {
    areClose(v1.sum, 245.0);
  });

  test("find the product of all elements in a vector", () {
    areClose(v1.prod, 5.7677e11, 1e-4);
  });

  test(
      "Vector.median on an even vector is equivalent to the mean of the two center elements",
      () {
    areClose(v4.median, (12 + 20) / 2.0);
  });

  test(
      "Vector.geometricMean on a 3 element vector is equivalent to the cube root of the product of elements",
      () {
    areClose(v5.geomean, math.cbrt(v5.foldLeft(1.0)(_ * _)));
  });

  test("Vector skew corner case works", () {
    val vec = new Vec<double>(-1.0, 1000, -1000, 1);
    areClose(vec.skew, 0.0);
  });

  test("Rank works", () {
    val vec = new Vec<double>(1.0, 5.0, 4.0, 4.0, NA, 3.0);

    expect(vec.rank(tie = stats.RankTie.Avg, ascending = true),
        equals(new Vec<double>(1.0, 5.0, 3.5, 3.5, NA, 2.0)));
    expect(vec.rank(tie = stats.RankTie.Min, ascending = true),
        equals(new Vec<double>(1.0, 5.0, 3.0, 3.0, NA, 2.0)));
    expect(vec.rank(tie = stats.RankTie.Max, ascending = true),
        equals(new Vec<double>(1.0, 5.0, 4.0, 4.0, NA, 2.0)));
    expect(vec.rank(tie = stats.RankTie.Nat, ascending = true),
        equals(new Vec<double>(1.0, 5.0, 3.0, 4.0, NA, 2.0)));

    expect(vec.rank(tie = stats.RankTie.Avg, ascending = false),
        equals(new Vec<double>(5.0, 1.0, 2.5, 2.5, NA, 4.0)));
    expect(vec.rank(tie = stats.RankTie.Min, ascending = false),
        equals(new Vec<double>(5.0, 1.0, 2.0, 2.0, NA, 4.0)));
    expect(vec.rank(tie = stats.RankTie.Max, ascending = false),
        equals(new Vec<double>(5.0, 1.0, 3.0, 3.0, NA, 4.0)));
    expect(vec.rank(tie = stats.RankTie.Nat, ascending = false),
        equals(new Vec<double>(5.0, 1.0, 2.0, 3.0, NA, 4.0)));

    val vec2 = new Vec.empty<double>();
    expect(vec2.rank(), euqals(vec2));

    val vec3 = new Vec(1.0);
    expect(vec3.rank(), equals(vec3));
  });

  test("Percentile works", () {
    val vec = new Vec<double>(15.0, 20, 35, 40, NA, 50);
    areClose(vec.percentile(40), 26.0);

    expect(vec.percentile(-1).isNaN, isTrue);
    expect(vec.percentile(101).isNaN, isTrue);

    expect(new Vec.empty<double>.percentile(0).isNaN, isTrue);

    expect(Vec(1.0).percentile(0), equals(new Vec(1.0).percentile(100)));

    val tst = new Vec<double>(NA, -1000.0000, 0.0000, -946.7879, -256.7953,
        1000.0000, -307.5079, -832.8867);
    areClose(tst.percentile(50), -307.5079, 1e-4);

    val tst2 = new Vec<double>(1, 0);
    areClose(tst2.percentile(50), 0.5, 1e-4);

    val tst3 = new Vec(0.785, 0.0296, 0.2408, 0.884, 0.5759, 0.8087, 0.4421);
    areClose(tst3.percentile(0, PctMethod.Excel), 0.0296, 1e-4);
    areClose(tst3.percentile(35, PctMethod.Excel), 0.4555, 1e-4);
    areClose(tst3.percentile(100, PctMethod.Excel), 0.8840, 1e-4);
  });
}
