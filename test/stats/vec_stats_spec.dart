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

import 'dart:math' as math;

import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';

import 'package:dataframe/src/stats/vec_stats.dart' as stats;

const delta = 1e-9;

cbrt(x) {
  var y = math.pow(x.abs(), 1 / 3);
  return x < 0 ? -y : y;
}

/**
 * Hand-calculated tests
 */
//class VecStatsSpec extends Specification {
vecStatsTest() {
  var st = ScalarTag.stDouble;

  var v1 = new Vec<double>([1.0, 2, 20, 23, 76, 12, -5, -27, 76, 67], st);
  var v1pos = new Vec<double>([1.0, 2, 20, 23, 76, 12, 76, 67], st);
  var v2 = new Vec<double>([12.0, 4, 19, 23, 76, 7, 6, -29, 50, 17], st);
  var v3 = new Vec<double>([1.0, 2, 20, 15, 23, 56, 12], st);
  var v4 = new Vec<double>([1.0, 2, 20, 23, 56, 12], st);
  var v5 = new Vec<double>([2.0, 89, 23], st);

  test("compute mean of a vector", () {
    expect(v1.mean(), closeTo(24.5, delta));
  });

  test("compute the median of a vector", () {
    expect(v1.median(), closeTo(16, delta));
  });

  test("compute the geometric mean of a vector with positive elements", () {
    expect(v1pos.geomean(), closeTo(15.9895, 1e-4));
  });

  test("compute the sample variance of a vector", () {
    expect(v1.variance(), closeTo(1318.9444, 1e-4));
  });

  test("compute the sample standard deviation of a vector", () {
    expect(v1.stdev(), closeTo(36.3173, 1e-4));
  });

  test("compute the sample skewness of a vector (unbiased)", () {
    expect(v1.skew(), closeTo(0.4676, 1e-4));
  });

  test("compute the sample excess kurtosis of a vector (unbiased)", () {
    expect(v1.kurt(), closeTo(-1.1138, 1e-4));
  });

  test("find the maximum element of a vector", () {
    expect(v1.max() /*.get*/, closeTo(76.0, delta));
  });

  test("find the minimum element of a vector", () {
    expect(v1.min() /*.get*/, closeTo(-27.0, delta));
  });

  test("find the sum of all elements in a vector", () {
    expect(v1.sum(), closeTo(245.0, delta));
  });

  test("find the product of all elements in a vector", () {
    expect(v1.prod(), closeTo(5.7677e11, 1e-4));
  });

  test(
      "Vector.median on an even vector is equivalent to the mean of the two center elements",
      () {
    expect(v4.median(), closeTo((12 + 20) / 2.0, delta));
  });

  test(
      "Vector.geometricMean on a 3 element vector is equivalent to the cube root of the product of elements",
      () {
    expect(
        v5.geomean(), closeTo(cbrt(v5.foldLeft(1.0)((a, b) => a * b)), delta));
  });

  test("Vector skew corner case works", () {
    var vec = new Vec<double>([-1.0, 1000, -1000, 1], st);
    expect(vec.skew, closeTo(0.0, delta));
  });

  test("Rank works", () {
    var vec = new Vec<double>([1.0, 5.0, 4.0, 4.0, NA, 3.0], st);

    expect(vec.rank(stats.RankTie.Avg, true),
        equals(new Vec<double>([1.0, 5.0, 3.5, 3.5, NA, 2.0], st)));
    expect(vec.rank(stats.RankTie.Min, true),
        equals(new Vec<double>([1.0, 5.0, 3.0, 3.0, NA, 2.0], st)));
    expect(vec.rank(stats.RankTie.Max, true),
        equals(new Vec<double>([1.0, 5.0, 4.0, 4.0, NA, 2.0], st)));
    expect(vec.rank(stats.RankTie.Nat, true),
        equals(new Vec<double>([1.0, 5.0, 3.0, 4.0, NA, 2.0], st)));

    expect(vec.rank(stats.RankTie.Avg, false),
        equals(new Vec<double>([5.0, 1.0, 2.5, 2.5, NA, 4.0], st)));
    expect(vec.rank(stats.RankTie.Min, false),
        equals(new Vec<double>([5.0, 1.0, 2.0, 2.0, NA, 4.0], st)));
    expect(vec.rank(stats.RankTie.Max, false),
        equals(new Vec<double>([5.0, 1.0, 3.0, 3.0, NA, 4.0], st)));
    expect(vec.rank(stats.RankTie.Nat, false),
        equals(new Vec<double>([5.0, 1.0, 2.0, 3.0, NA, 4.0], st)));

    Vec vec2 = new Vec.empty<double>();
    expect(vec2.rank(), equals(vec2));

    Vec vec3 = new Vec([1.0], st);
    expect(vec3.rank(), equals(vec3));
  });

  test("Percentile works", () {
    var vec = new Vec<double>([15.0, 20, 35, 40, NA, 50], st);
    expect(vec.percentile(40.0), closeTo(26.0, delta));

    expect(vec.percentile(-1.0).isNaN, isTrue);
    expect(vec.percentile(101.0).isNaN, isTrue);

    expect(new Vec.empty<double>.percentile(0).isNaN, isTrue);

    expect(new Vec([1.0], st).percentile(0.0),
        equals(new Vec([1.0], st).percentile(100.0)));

    var tst = new Vec<double>([
      NA,
      -1000.0000,
      0.0000,
      -946.7879,
      -256.7953,
      1000.0000,
      -307.5079,
      -832.8867
    ], st);
    expect(tst.percentile(50.0), closeTo(-307.5079, 1e-4));

    var tst2 = new Vec<double>([1, 0], st);
    expect(tst2.percentile(50.0), closeTo(0.5, 1e-4));

    var tst3 =
        new Vec([0.785, 0.0296, 0.2408, 0.884, 0.5759, 0.8087, 0.4421], st);
    expect(tst3.percentile(0.0, stats.PctMethod.Excel), closeTo(0.0296, 1e-4));
    expect(tst3.percentile(35.0, stats.PctMethod.Excel), closeTo(0.4555, 1e-4));
    expect(
        tst3.percentile(100.0, stats.PctMethod.Excel), closeTo(0.8840, 1e-4));
  });
}
