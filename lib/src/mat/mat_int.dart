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

library saddle.mat.int;

//import scala.{specialized => spec}
//import org.saddle._
//import org.saddle.scalar._

import '../mat.dart';
import '../vec.dart';
import '../scalar/scalar_tag.dart';
import '../scalar/scalar_tag_int.dart';
import 'mat_impl.dart';
import 'mat_math.dart';

/**
 * A Mat instance containing elements of type Int
 */
class MatInt extends Mat<int> {
  final int r, c;
  final List<int> values;

  MatInt(this.r, this.c, this.values) : super.internal();

  get repr => this;

  int get numRows => r;

  int get numCols => c;

  ScalarTag scalarTag = ScalarTagInt;

  Vec<int> toVec() => scalarTag.makeVec(toArray_());

  Mat map /*[@spec(Boolean, Int, Long, Double) B: ST]*/ (
          dynamic f(int arg), ScalarTag scb) =>
      MatImpl.map(this, f, scb);

  // Cache the transpose: it's much faster to transpose and slice a continuous
  // bound than to take large strides, especially on large matrices where it
  // seems to eject cache lines on each stride (something like 10x slowdown)
  MatInt _cachedT;
  MatInt get cachedT {
    if (_cachedT == null) {
      var arrT = new List.from(values);

      if (this.isSquare) {
        MatMath.squareTranspose(numCols, arrT);
      } else {
        MatMath.blockTranspose(numRows, numCols, this.toArray_(), arrT);
      }

      _cachedT = new MatInt(numCols, numRows, arrT);
    }
    return _cachedT;
  }

  transpose() => cachedT;

  Mat<int> takeRows(List<int> locs) => MatImpl.takeRows(this, locs, scalarTag);

  Mat<int> withoutRows(List<int> locs) =>
      MatImpl.withoutRows(this, locs, scalarTag);

  Mat<int> reshape(int r, int c) => new MatInt(r, c, values);

  // access like vector in row-major order
  /*private[saddle]*/ applyFlat_(int i) => values[i];

  // implement access like matrix(i, j)
  /*private[saddle]*/ apply_(int r, int c) => applyFlat_(r * numCols + c);

  // use with caution, may not return copy
  /*private[saddle]*/ toArray_() => values;

  /*private[saddle]*/ List<double> toDoubleArray_(/*implicit ev: NUM<int>*/) =>
      arrCopyToDblArr(values);

  /*private[saddle]*/ List<double> arrCopyToDblArr(List<int> r) {
    var sa = ScalarTagInt;
    var arr = new List<double>(r.length);
    var i = 0;
    while (i < r.length) {
      arr[i] = sa.toDouble(r[i]);
      i += 1;
    }
    return arr;
  }

  /** Row-by-row equality check of all values. */
  bool operator ==(o) {
    if (o is Mat) {
      var rv = o as Mat;
      if (identical(this, rv)) {
        return true;
      } else if (numRows != rv.numRows || numCols != rv.numCols) {
        return false;
      } else {
        var i = 0;
        bool eq = true;
        while (eq && i < length) {
          eq = eq &&
              (applyFlat_(i) == rv.applyFlat_(i) ||
                  this.scalarTag.isMissing(applyFlat_(i)) &&
                      rv.scalarTag.isMissing(rv.applyFlat_(i)));
          i += 1;
        }
        return eq;
      }
    } else {
      return super == o;
    }
  }
}
