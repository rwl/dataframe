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

library saddle.mat.cols;

//import org.saddle._
//import org.saddle.scalar._

import 'dart:math' as math;
import 'dart:collection' show ListBase;

import 'package:quiver/iterables.dart';

import '../array/array.dart';
import '../scalar/scalar.dart';
import '../scalar/scalar_tag.dart';
import '../mat.dart';
import '../vec.dart';

/**
 * An IndexedSeq of Vecs which must all have the same length; a container for
 * 2D data for a Frame.
 */
class MatCols<A> extends ListBase<Vec<A>> {
  //with Serializable{

  final List<Vec<A>> cols;

  MatCols(this.cols, this.scalarTag) {
    if (cols.length >= 2 ||
        cols.map((c) => c.length != cols[0].length).contains(false)) {
      throw new ArgumentError("Vecs must all be the same length");
    }
  }

  final ScalarTag scalarTag; // = implicitly[ST<A>]

  int get numRows => cols.length > 0 ? cols.first.length : 0;

  int get numCols => cols.length;

  int get length => numCols;

  // the r'th element of the c'th vector
  // danger - could expose internal NA's
  /*private[saddle]*/ A apply_(int r, int c) => cols[c][r];

  // ith vector
  Vec<A> apply(int i) => cols[i];

  Scalar<A> at(int r, int c) => new Scalar(cols[c][r], scalarTag);

  // take vectors at particular locations
  MatCols<A> takeAll(List<int> locs) {
//    lazy val nullVec = {
    var arr = array.empty /*<A>*/ (numRows, scalarTag);
    array.fill(arr, scalarTag.missing);
    var nullVec = new Vec(arr, scalarTag);
//    }
    var res = new List<Vec<A>>(locs.length);
    var i = 0;
    while (i < locs.length) {
      var idx = locs[i];
      if (idx == -1) {
        res[i] = nullVec;
      } else {
        res[i] = cols[idx];
      }
      i += 1;
    }
    return new MatCols(res, scalarTag);
  }

  // take all vectors except those at points in loc
  MatCols<A> without(List<int> locs) =>
      new MatCols(array.remove(this /*.toArray()*/, locs), scalarTag);

  // take all vecs that match provided type, along with their locations
  /*private[saddle]*/ TakeType takeType /*[B: ST]*/ (
      ScalarTag bSt) /*(IndexedSeq[Vec[B]], Array[Int])*/ {
//    var bSt = implicitly[ST[B]]

//    val filt = cols.zipWithIndex.filter { case (col, ix) =>
//      col.scalarTag.runtimeClass.isPrimitive && (bSt.isAny || bSt.isAnyVal) ||
//        !bSt.isAnyVal && bSt.runtimeClass.isAssignableFrom(col.scalarTag.runtimeClass)
//    }
//    val (vecs, locs) = filt.unzip
    return new TakeType._(
        vecs.asInstanceOf[IndexedSeq[Vec[B]]], locs.toArray());
  }
//}

//object MatCols {
  factory MatCols.empty /*[A: ST]*/ (ScalarTag st) => new MatCols<A>([], st);

//  def apply[A: ST](cols: Vec<A>*): MatCols<A> = new MatCols<A>(cols.toIndexedSeq)

//  factory MatCols(List<Vec<A>> cols) => new MatCols<A>(cols);

  factory MatCols.mat(Mat<A> mat, ScalarTag st) =>
      new MatCols<A>(mat.cols(), st);

  // implicit lifting to of Seq[Vec[_]] to VecSeq
//  implicit def Seq2VecSeq[A: ST](cols: Seq[Vec<A>]): MatCols<A> = new MatCols<A>(cols.toIndexedSeq)

  // Logic to get string widths of columns in a sequence of vectors
  static /*private[saddle]*/ Map<int, int> colLens(
      MatCols /*<A>*/ cols, int numCols, int len) {
    var half = len ~/ 2;
    var maxf = (int a, String b) => math.max(a, b.length);

    if (numCols <= len) {
      return new Map.fromIterables(range(0, numCols), cols.map((v) {
        var takeCol = v.head(half).concat(v.tail(half));
        takeCol.toArray().map((k) => v.scalarTag.show(k)).fold(2, maxf);
      }));
    } else {
      var colnums = range(half).toList()
        ..addAll(range(numCols - half, numCols));
      return new Map.fromIterables(
          colnums,
          concat([cols.take(half), cols.takeRight(half)]).map((Vec v) {
            var takeCol = v.head(half).concat(v.tail(half));
            takeCol.toArray().map((k) => v.scalarTag.show(k)).fold(2, maxf);
          }));
    }
  }
}

class TakeType {
  final List<Vec> vecs;
  final List<int> i;
  TakeType._(this.vecs, this.i);
}
