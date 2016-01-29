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

library saddle.test;

//import mat.MatMath
//import org.saddle.Serde._
//import org.specs2.mutable.Specification
//import org.specs2.ScalaCheck
//import org.scalacheck.{Gen, Arbitrary}
//import org.scalacheck.Prop._
//import org.saddle._
//import org.saddle.array._
//import org.saddle.framework._

import 'dart:math' as math;

import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';
import 'package:quiver/iterables.dart';

final math.Random rand = new math.Random();

const minl = 2;
const maxl = 20;

// Generates Mat instance up to 10x10 with entries between -1e3/+1e3 and no NAs
Mat<double> matDouble() {
  var r = rand.nextInt(maxl) + minl;
  var c = rand.nextInt(maxl) + minl;
  var lst = new List<double>.generate(
      r * c, (i) => (rand.nextDouble() * 1e3) * (rand.nextBool() ? 1 : -1));
  return new Mat<double>(r, c, lst, ScalarTag.stDouble);
}

// Same, but with 10% NAs
Mat<double> matDoubleWithNA() {
  var r = rand.nextInt(maxl) + minl;
  var c = rand.nextInt(maxl) + minl;
  var lst = new List<double>.generate(r * c, (i) {
    if (i % 10 == 0) {
      return double.NAN;
    } else {
      return (rand.nextDouble() * 1e3) * (rand.nextBool() ? 1 : -1);
    }
  });
  return new Mat<double>(r, c, lst, ScalarTag.stDouble);
}

/**
 * Test Mat
 */
//class MatCheck extends Specification with ScalaCheck {
matCheck() {
  group("Mat double", () {
//    /*implicit*/ val arbMat = Arbitrary(MatArbitraries.matDouble);
    ScalarTag st = ScalarTag.stDouble;
    Mat<double> m;
    setUp(() {
      m = matDouble();
//      print(m.toString());
    });

    test("equality works", () {
      expect(m, equals(new Mat(m.numRows, m.numCols, m.toArray_(), st)));
      expect(m, equals(m));
    });

    test("map works", () {
      var res = m.map((a) => a + 1, st);
      var exp = m.contents.map((a) => a + 1);
      expect(res.contents, equals(exp));
    });

    test("reshape works", () {
      var res = m.reshape(m.numCols, m.numRows);
      expect(res.contents, equals(m.contents));
      expect(res.numCols, equals(m.numRows));
      expect(res.numRows, equals(m.numCols));
    });

    test("isSquare works", () {
      expect(m.isSquare, equals((m.numRows == m.numCols)));
    });

    test("map works", () {
      var data = m.contents;
      expect(
          m.map((a) => a + 1.0, st),
          equals(new Mat(
              m.numRows, m.numCols, data.map((a) => a + 1.0).toList(), st)));
      expect(
          m.map((d) => 5.0, st),
          equals(new Mat(m.numRows, m.numCols,
              data.map((d) => d.isNaN ? double.NAN : 5.0).toList(), st)));
      expect(
          m.map((d) => 5, st),
          equals(new Mat<int>(
              m.numRows,
              m.numCols,
              data.map((d) => d.isNaN ? ScalarTag.stInt.missing() : 5).toList(),
              ScalarTag.stInt)));
    });

    test("transpose works", () {
//      implicit val arbMat = Arbitrary(MatArbitraries.matDoubleWithNA);

      m = matDoubleWithNA();
      var res = m.T;
      expect(res.numCols, equals(m.numRows));
      expect(res.numRows, equals(m.numCols));
      range(m.numRows).forEach((i) {
        range(m.numCols).forEach((j) {
          expect(m.at(i, j), equals(res.at(j, i)));
        });
      });
      expect(res.T, equals(m));
    });

    test("takeRows works", () {
      var i = new List<int>.generate(3, (i) => rand.nextInt(m.numRows - 1));
      var res = m.takeRows(i /* : _**/);
      expect(res.numRows, equals(i.length));
      var exp = i.map((j) => m.row(j)).toList();
      expect(res, equals(new Mat.fromVecs(exp /*: _**/, st).T));
    });

    test("takeCols works", () {
      var i = new List<int>.generate(3, (i) => rand.nextInt(m.numCols - 1));
      var res = m.takeCols(i /* : _**/);
      expect(res.numCols, equals(i.length));
      var exp = i.map((j) => m.col(j)).toList();
      expect(res, equals(new Mat.fromVecs(exp /*: _**/, st)));
    });

    test("withoutRows works", () {
      var i = new List<int>.generate(3, (i) => rand.nextInt(m.numRows - 1));
      var loc = new Set.from(i /*: _**/);
      var res = m.withoutRows(i /*: _**/);
      expect(res.numRows, equals((m.numRows - loc.length)));
      var exp = range(m.numRows)
          .where((j) => !loc.contains(j))
          .map((j) => m.row(j))
          .toList();
      expect(res, equals(new Mat.fromVecs(exp /*: _**/, st).T));
    });

    test("withoutCols works", () {
      var i = new List<int>.generate(3, (i) => rand.nextInt(m.numCols - 1));
      var loc = new Set.from(i /*: _**/);
      var res = m.withoutCols(i /*: _**/);
      expect(res.numCols, equals((m.numCols - loc.length)));
      var exp = range(m.numCols)
          .where((j) => !loc.contains(j))
          .map((j) => m.col(j))
          .toList();
      expect(res, equals(new Mat.fromVecs(exp /*: _**/, st)));
    });

    test("rowsWithNA works (no NA)", () {
      expect(m.rowsWithNA(), equals(new Set<double>()));
    });

    test("rowsWithNA works (with NA)", () {
//      /*implicit*/ val arbMat = Arbitrary(MatArbitraries.matDoubleWithNA);

      m = matDoubleWithNA();
      var exp = enumerate(m.rows())
          .where((iv) => iv.value.hasNA)
          .map((iv) => iv.index);
      expect(m.rowsWithNA(), equals(exp.toSet()));
    });

//    test("dropRowsWithNA works", () {
////      /*implicit*/ val arbMat = Arbitrary(MatArbitraries.matDoubleWithNA);
//      m = matDoubleWithNA();
//      expect(m.dropRowsWithNA(), equals(m.rdropNA().toMat()));
//    });
//
//    test("dropColsWithNA works", () {
////      /*implicit*/ val arbMat = Arbitrary(MatArbitraries.matDoubleWithNA);
//      m = matDoubleWithNA();
//      expect(m.dropColsWithNA(), equals(m.dropNA().toMat()));
//    });

    test("cols works", () {
      var data = m.T.contents;
      var exp = range(m.numCols).map((i) {
        return new Vec(data, st).slice(i * m.numRows, (i + 1) * m.numRows);
      });
      expect(m.cols(), equals(exp));
    });

    test("rows works", () {
      var data = m.contents;
      var exp = range(m.numRows).map((i) {
        return new Vec(data, st).slice(i * m.numCols, (i + 1) * m.numCols);
      });
      expect(m.rows(), equals(exp));
    });

    test("col works", () {
      var i = rand.nextInt(m.numCols - 1);
      var data = m.T.contents;
      expect(m.col(i),
          equals(new Vec(data, st).slice(i * m.numRows, (i + 1) * m.numRows)));
    });

    test("row works", () {
      var i = rand.nextInt(m.numRows - 1);
      var data = m.contents;
      expect(m.row(i),
          equals(new Vec(data, st).slice(i * m.numCols, (i + 1) * m.numCols)));
    });

//    test("mult works", () {
//       import org.apache.commons.math.linear.Array2DRowRealMatrix
//
//      forAll((Mat<double> ma, Mat<double> mb) {
//        if (ma.numCols != mb.numRows) {
//          expect(ma.mult(mb), throwsA(IllegalArgumentException));
//        } else {
//          val res = ma.mult(mb);
//
//          expect(res.numRows, equals(ma.numRows));
//          expect(res.numCols, equals(mb.numCols));
//
//          if (ma.numRows > 0 && mb.numRows > 0) {
//            val matA =
//                new Array2DRowRealMatrix(ma.rows().map(_.toArray).toArray);
//            val matB =
//                new Array2DRowRealMatrix(mb.rows().map(_.toArray).toArray);
//
//            val matC = matA.multiply(matB);
//
//            expect(res.contents, equals(flatten(matC.getData)));
//          } else {
//            expect(res.numRows, equals(0));
//          }
//        }
//      });
//    });

    test("roundTo works", () {
      expect(m.contents.map((double v) => (v * 100).round() / 100.0 /*d*/),
          equals(m.roundTo(2).contents));
    });

//    test("cov works", () {
//      forAll((Mat<double> ma) {
////         import org.apache.commons.math.stat.correlation.Covariance
//
//        if (ma.numRows < 2 || ma.numCols < 2) {
//          expect(MatMath.cov(ma), throwsA(IllegalArgumentException));
//        } else {
//          val aCov = new Covariance(ma.rows().map(_.toArray).toArray);
//          val exp = aCov.getCovarianceMatrix;
//          val res = MatMath.cov(ma).contents;
//
//          expect(Vec(res), beCloseToVec(Vec(flatten(exp.getData)), 1e-9));
//        }
//      });
//    });
  });

//  test("serialization works", () {
//    expect(m, equals(serializedCopy(m)));
//  });
}

main() {
  range(1).forEach((_) {
    matCheck();
  });
}
