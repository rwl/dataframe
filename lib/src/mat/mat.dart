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

library saddle.mat.mat;

//import scala.{specialized => spec}

import 'package:quiver/iterables.dart' show range;

import '../mat.dart';
import '../vec.dart';
import '../scalar/scalar_tag.dart';
import '../array/array.dart';

/*
 * Some matrix utilities
 */

//package object mat {
/**
 * Generate a uniform random Mat[Double] of a certain size
 * @param rows Number of rows
 * @param cols Number of rows
 */
Mat<double> rand(int rows, int cols) =>
    new Mat(rows, cols, array.randDouble(rows * cols), ScalarTag.stDouble);

/**
 * Generate a uniform random positive Mat[Double] of a certain size
 * @param rows Number of rows
 * @param cols Number of rows
 */
Mat<double> randp(int rows, int cols) =>
    new Mat(rows, cols, array.randDoublePos(rows * cols), ScalarTag.stDouble);

/**
 * Generate a uniform random Mat[Long] of a certain size
 * @param rows Number of rows
 * @param cols Number of rows
 */
//def randl(rows: Int, cols: Int): Mat[Long] =
//  Mat(rows, cols, array.randLong(rows * cols))

/**
 * Generate a uniform random positive Mat[Long] of a certain size
 * @param rows Number of rows
 * @param cols Number of rows
 */
//def randpl(rows: Int, cols: Int): Mat[Long] =
//  Mat(rows, cols, array.randLongPos(rows * cols))

/**
 * Generate a uniform random Mat[Int] of a certain size
 * @param rows Number of rows
 * @param cols Number of rows
 */
Mat<int> randi(int rows, int cols) =>
    new Mat(rows, cols, array.randInt(rows * cols), ScalarTag.stInt);

/**
 * Generate a uniform random positive Mat[Int] of a certain size
 * @param rows Number of rows
 * @param cols Number of rows
 */
Mat<int> randpi(int rows, int cols) =>
    new Mat(rows, cols, array.randIntPos(rows * cols), ScalarTag.stInt);

/**
 * Generate a gaussian(0, 1) random Mat[Double] of a certain size
 * @param rows Number of rows
 * @param cols Number of rows
 */
Mat<double> randn(int rows, int cols) =>
    new Mat(rows, cols, array.randNormal(rows * cols), ScalarTag.stDouble);

/**
 * Generate a gaussian(mu, sigma) random Mat[Double] of a certain size
 * @param rows Number of rows
 * @param cols Number of rows
 * @param mu Mean of distribution
 * @param sigma Stdev of distribution
 */
Mat<double> randn2(int rows, int cols, double mu, double sigma) => new Mat(
    rows, cols, array.randNormal2(rows * cols, mu, sigma), ScalarTag.stDouble);

Mat<double> ones(int rows, int cols) {
  var tmp = new List<double>(rows * cols);
  array.fill(tmp, 1.0);
  return new Mat<double>(rows, cols, tmp, ScalarTag.stDouble);
}

Mat<double> zeros(int rows, int cols) => new Mat(rows, cols,
    array.empty(rows * cols, ScalarTag.stDouble), ScalarTag.stDouble);

/**
 * Create a square identity matrix of dimension n x n
 * @param n The number of rows/columns of the square matrix
 */
Mat<double> ident(int n) {
  if (n <= 0) {
    return new Mat<double>.empty(ScalarTag.stDouble);
  } else {
    var tmp = new List<double>(n * n);
    var i = 0;
    while (i < n) {
      tmp[n * i + i] = 1;
      i += 1;
    }
    return new Mat<double>(n, n, tmp, ScalarTag.stDouble);
  }
}

/**
 * Given a vector, create a matrix whose diagonal entries equal the vector, with zeros off-diagonal.
 * @param v The vector of source data
 */
Mat<double> diag(Vec<double> v) {
  var l = v.length;
  var d = array.empty(l * l, ScalarTag.stDouble);

  var i = 0;
  while (i < l) {
    d[i * l + i] = v.raw(i);
    i += 1;
  }

  return new Mat(l, l, d, ScalarTag.stDouble);
}

/**
 * Repeats an array in a particular direction to create a 2D matrix
 *
 * @param v array of values to repeat
 * @param n number of repetitions
 * @param asRows if true, returns row-tiling; default is column-tiling
 * @tparam T type of elements in array
 */
Mat repeat /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
    List v, int n, ScalarTag st,
    [bool asRows = false]) {
  if (asRows) {
    var tmp = array.flatten(range(1, n).map((i) => v)); // TODO: check
    return new Mat(n, v.length, tmp, st);
  } else {
    var tmp = array.range(0, n).map((i) => v);
    return new Mat.fromList(tmp, st);
  }
}
//}
