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

library saddle.mat.impl;

//import scala.Int
//import scala.{specialized => spec}
//import org.saddle._

import '../mat.dart';
import '../scalar/scalar_tag.dart';

/**
 * Houses specialized method implementations for code reuse in Mat subclasses
 */
/*private[saddle]*/ abstract class MatImpl {
  MatImpl._();

  static Mat /*<B>*/ map /*[@spec(Boolean, Int, Long, Double) A: ST,
          @spec(Boolean, Int, Long, Double) B: ST]*/
  (Mat /*<A>*/ mat, dynamic f(arg), ScalarTag scb) {
    var sca = mat.scalarTag;
//    var scb = implicitly[ST<B>]
    var buf = new List /*<B>*/ (mat.length);
    var i = 0;
    while (i < mat.length) {
      var v = mat[i];
      if (sca.isMissing(v)) {
        buf[i] = scb.missing;
      } else {
        buf[i] = f(v);
      }
      i += 1;
    }
    return new Mat /*<B>*/ (mat.numRows, mat.numCols, buf, scb);
  }

  static Mat /*<A>*/ withoutRows /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Mat /*<A>*/ m, List<int> locs, ScalarTag sca) {
    if (m.length == 0) {
      return new Mat.empty(sca);
    } else {
      var locset = locs.toSet();
      var buf = []; //Buffer<A>(m.length)
      var r = 0;
      var nRows = 0;
      while (r < m.numRows) {
        if (!locset.contains(r)) {
          nRows += 1;
          var c = 0;
          while (c < m.numCols) {
            buf.add(m.raw(r, c));
            c += 1;
          }
        }
        r += 1;
      }
      if (nRows == 0) {
        return new Mat.empty(sca);
      } else {
        return new Mat(nRows, m.numCols, buf, sca);
      }
    }
  }

  static Mat /*<A>*/ takeRows /*[@spec(Boolean, Int, Long, Double) A: ST]*/ (
      Mat /*<A>*/ m, List<int> locs, ScalarTag sca) {
    if (m.length == 0) {
      return new Mat.empty(sca);
    } else {
      var buf = []; //Buffer<A>(m.length)
      var r = 0;
      while (r < locs.length) {
        var currRow = locs[r];
        var c = 0;
        while (c < m.numCols) {
          buf.add(m.raw(currRow, c));
          c += 1;
        }
        r += 1;
      }
      return new Mat(r, m.numCols, buf, sca);
    }
  }
}
