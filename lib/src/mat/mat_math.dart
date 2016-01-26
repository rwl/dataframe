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

library saddle.mat.math;

//import scala.{specialized => spec}
//import org.saddle._

import 'dart:math' as math;
import '../mat.dart';
import '../scalar/scalar_tag.dart';

/**
 * Matrix mathematical helper routines.
 */
abstract class MatMath {
  /**
   * Performs matrix multiplication via EJML
   *
   * @param m1 Left hand matrix operand
   * @param m2 Right hand matrix operand
   */
  static Mat<double> mult /*[A, B]*/ (
      Mat /*<A>*/ m1, Mat /*<B>*/ m2) /*(implicit evA: NUM<A>, evB: NUM<B>)*/ {
//    import org.ejml.data.DenseMatrix64F
//    import org.ejml.ops.CommonOps

    // allocate result
    var tmp = new DenseMatrix64F(m1.numRows, m2.numCols);

    var d1 =
        new DenseMatrix64F.wrap(m1.numRows, m1.numCols, m1.toDoubleArray_());
    var d2 =
        new DenseMatrix64F.wrap(m2.numRows, m2.numCols, m2.toDoubleArray_());

    CommonOps.mult(d1, d2, tmp);

    // return result
    return new Mat(
        tmp.getNumRows, tmp.getNumCols, tmp.getData, ScalarTag.stDouble);
  }

  /**
   * Yields covariance matrix from input matrix whose columns are variable observations
   *
   * @param mat Input matrix of observations, with a variable per column
   * @param corr If true, return correlation rather than covariance
   */
  static Mat<double> cov(Mat<double> mat, [bool corr = false]) {
    // we do cov calc on columns; but as rows for efficiency
    var numCols = mat.numCols;
    var numRows = mat.numRows;

    if (numRows < 2 || numCols < 2) {
      throw new ArgumentError("Matrix dimension must be at least [2 x 2]");
    }

    var input = new List.from(mat.transpose().toArray_());
    var output = new List<double>(numCols * numCols);

    // demean columns (in-place)
    demean(input, numCols, numRows);

    // compute pairwise moments
    var i = 0;
    while (i < numCols) {
      var ri0 = i * numRows;

      var j = 0;
      while (j <= i) {
        var rj0 = j * numRows;

        var tmp =
            (corr && i == j) ? 1.0 : covariance(input, ri0, rj0, numRows, corr);

        output[j * numCols + i] = tmp;
        output[i * numCols + j] = tmp;

        j += 1;
      }
      i += 1;
    }

    return new Mat<double>(numCols, numCols, output, ScalarTag.stDouble);
  }

  /**
   * Return a matrix whose rows are demeaned
   * @param mat The matrix to demean
   */
  static Mat<double> demeaned(Mat<double> mat) {
    List<double> data = mat.contents;
    demean(data, mat.numRows, mat.numCols);
    return new Mat(mat.numRows, mat.numCols, data, ScalarTag.stDouble);
  }

  // demeans matrix columns, helper function to cov()
  static /*private*/ void demean(List<double> m, int rows, int cols) {
    // for each row
    var i = 0;
    while (i < rows) {
      var j = 0;
      // calculate the (na-friendly) mean
      var mean = 0.0;
      var count = 0;
      while (j < cols) {
        var idx = i * cols + j;
        var mval = m[idx];
        if (!mval.isNaN) {
          mean += mval;
          count += 1;
        }
        j += 1;
      }
      mean /= count;
      // subtract mean from row
      j = 0;
      while (j < cols) {
        var idx = i * cols + j;
        m[idx] -= mean;
        j += 1;
      }
      i += 1;
    }
  }

  // parameters:
  // values : one-d array of matrix values
  // ixA    : starting index of vector a,
  // ixB    : starting index of vector b
  // n      : length of vector
  // corr   : do correlation computation
  static /*private*/ double covariance(
      List<double> values, int ixA, int ixB, int n,
      [bool corr = false]) {
    var va = 0.0;
    var vb = 0.0;

    var aa = 0.0; // sum of squares
    var bb = 0.0;
    var ab = 0.0; // sum of products
    var i = 0;

    var count = n;
    while (i < n) {
      va = values[ixA + i];
      vb = values[ixB + i];
      if (va != va || vb != vb) {
        count -= 1;
      } else {
        if (corr) {
          aa += va * va;
          bb += vb * vb;
        }
        ab += va * vb;
      }
      i += 1;
    }
    if (corr) {
      // corr or cov?
      return ab / math.sqrt(aa * bb);
    } else {
      return ab / (count - 1);
    }
  }

  /** Efficient block-based non-square matrix transpose that is sensitive to cache line
    * effects (destructive to out matrix)
    */
  static /*private[saddle]*/ void blockTranspose /*[@spec(Int, Long, Double) S]*/ (
      int inR, int inC, List in_, List out) {
    var XOVER = 60;

    var r = 0;
    var rsz = inR;
    var csz = inC;
    while (r < rsz) {
      var blockHeight = (XOVER < rsz - r) ? XOVER : rsz - r;
      var inRow = r * csz; // first element of current row
      var outCol = r; // first element of current col
      var c = 0;
      while (c < csz) {
        var blockWidth = (XOVER < csz - c) ? XOVER : csz - c;
        var rowEnd = inRow + blockWidth;
        while (inRow < rowEnd) {
          var rowSrc = inRow;
          var colDst = outCol;
          var colEnd = colDst + blockHeight;
          while (colDst < colEnd) {
            out[colDst] = in_[rowSrc];
            colDst += 1;
            rowSrc += csz;
          }
          outCol += rsz;
          inRow += 1;
        }
        c += XOVER;
      }
      r += XOVER;
    }
  }

  /** Efficient square matrix transpose (destructive)
    */
  static /*private[saddle]*/ void squareTranspose /*[@spec(Int, Long, Double) S: ST]*/ (
      int sz, List out) {
    var csz = sz;
    var rsz = sz;

    var i = 0;
    var idx1 = 1;
    var cols = csz;
    while (i < rsz) {
      var idx2 = (i + 1) * csz + i;
      while (idx1 < cols) {
        var v = out[idx1];
        out[idx1] = out[idx2];
        out[idx2] = v;
        idx1 += 1;
        idx2 += csz;
      }
      i += 1;
      idx1 += (i + 1);
      cols += csz;
    }
  }
}
