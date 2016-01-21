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

import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';

/**
 * Test Mat
 */
//class MatCheck extends Specification with ScalaCheck {
matCheck() {
  group("Double Mat Tests", () {
    /*implicit*/ val arbMat = Arbitrary(MatArbitraries.matDouble);

    test("equality works", () {
      forAll((Mat<double> m) {
        expect(m, equals(Mat(m.numRows, m.numCols, m.toArray)));
        expect(m, equals(m));
      });
    });

    test("map works", () {
      forAll((Mat<double> m) {
        val res = m.map(_ + 1);
        val exp = m.contents.map(_ + 1);
        expect(res.contents, equals(exp));
      });
    });

    test("reshape works", () {
      forAll((Mat<double> m) {
        val res = m.reshape(m.numCols, m.numRows);
        expect(res.contents, equals(m.contents));
        expect(res.numCols, equals(m.numRows));
        expect(res.numRows, equals(m.numCols));
      });
    });

    test("isSquare works", () {
      forAll((Mat<double> m) {
        expect(m.isSquare, equals((m.numRows == m.numCols)));
      });
    });

    test("map works", () {
      forAll((Mat<double> m) {
        val data = m.contents;
        expect(m.map(_ + 1.0),
            equals(Mat(m.numRows, m.numCols, data.map(_ + 1.0))));
        expect(
            m.map((d) => 5.0),
            equals(Mat(m.numRows, m.numCols,
                (data.map((d) => (d.isNaN) ? na.to[Double] : 5.0)))));
        expect(
            m.map((d) => 5),
            equals(Mat[Int](m.numRows, m.numCols,
                data.map((d) => (d.isNaN) ? na.to[Int] : 5))));
      });
    });

    test("transpose works", () {
      /*implicit*/ val arbMat = Arbitrary(MatArbitraries.matDoubleWithNA);

      forAll((Mat<double> m) {
        val res = m.T;
        expect(res.numCols, equals(m.numRows));
        expect(res.numRows, equals(m.numCols));
//         for(i <- Range(0, m.numRows); j <- Range(0, m.numCols)) m.at(i, j), equals(res.at(j, i)
        expect(res.T, equals(m));
      });
    });

    test("takeRows works", () {
      forAll((Mat<double> m) {
        val idx = Gen.listOfN(3, Gen.choose[Int](0, m.numRows - 1));
        forAll(idx, (i) {
//           val res = m.takeRows(i : _*);
          expect(res.numRows, equals(i.size));
//           val exp = for (j <- i) yield m.row(j)
//           expect(res, equals(Mat(exp : _*).T));
        });
      });
    });

    test("takeCols works", () {
      forAll((Mat<double> m) {
        val idx = Gen.listOfN(3, Gen.choose[Int](0, m.numCols - 1));
        forAll(idx, (i) {
//           val res = m.takeCols(i : _*);
          expect(res.numCols, equals(i.size));
//           val exp = for (j <- i) yield m.col(j)
//           expect(res, equals(Mat(exp : _*)));
        });
      });
    });

    test("withoutRows works", () {
      forAll((Mat<double> m) {
        val idx = Gen.listOfN(3, Gen.choose[Int](0, m.numRows - 1));
        forAll(idx, (i) {
//           val loc = Set(i : _*);
//           val res = m.withoutRows(i : _*);
          expect(res.numRows, equals((m.numRows - loc.size)));
//           val exp = for (j <- 0 until m.numRows if !loc.contains(j)) yield m.row(j)
//           expect(res, equals(Mat(exp : _*).T;
        });
      });
    });

    test("withoutCols works", () {
      forAll((Mat<double> m) {
        val idx = Gen.listOfN(3, Gen.choose[Int](0, m.numCols - 1));
        forAll(idx, (i) {
//           val loc = Set(i : _*);
//           val res = m.withoutCols(i : _*);
          expect(res.numCols, equals((m.numCols - loc.size)));
//           val exp = for (j <- 0 until m.numCols if !loc.contains(j)) yield m.col(j)
//           expect(res, equals(Mat(exp : _*));
        });
      });
    });

    test("rowsWithNA works (no NA)", () {
      forAll((Mat<double> m) {
        expect(m.rowsWithNA, equals(Set.empty[Double]));
      });
    });

    test("rowsWithNA works (with NA)", () {
      /*implicit*/ val arbMat = Arbitrary(MatArbitraries.matDoubleWithNA);

      forAll((Mat<double> m) {
//         val exp = (m.rows() zip Range(0, m.numRows)).flatMap {
//           case (a: Vec[_], b: Int) => if (a.hasNA) Some(b) else None
//         }
        expect(m.rowsWithNA, equals(exp.toSet));
      });
    });

    test("dropRowsWithNA works", () {
      /*implicit*/ val arbMat = Arbitrary(MatArbitraries.matDoubleWithNA);
      forAll((Mat<double> m) {
        expect(m.dropRowsWithNA, equals(m.rdropNA.toMat));
      });
    });

    test("dropColsWithNA works", () {
      /*implicit*/ val arbMat = Arbitrary(MatArbitraries.matDoubleWithNA);
      forAll((Mat<double> m) {
        expect(m.dropColsWithNA, equals(m.dropNA.toMat));
      });
    });

    test("cols works", () {
      forAll((Mat<double> m) {
        val data = m.T.contents;
//         val exp = for (i <- IndexedSeq(Range(0, m.numCols) : _*))
//                   yield Vec(data).slice(i * m.numRows, (i + 1) * m.numRows)
        expect(m.cols(), equals(exp));
      });
    });

    test("rows works", () {
      forAll((Mat<double> m) {
        val data = m.contents;
//         val exp = for (i <- IndexedSeq(Range(0, m.numRows) : _*));
//         yield Vec(data).slice(i * m.numCols, (i + 1) * m.numCols);
        expect(m.rows(), equals(exp));
      });
    });

    test("col works", () {
      forAll((Mat<double> m) {
        val idx = Gen.choose(0, m.numCols - 1);
        val data = m.T.contents;
        forAll(idx, (i) {
          expect(m.col(i),
              equals(Vec(data).slice(i * m.numRows, (i + 1) * m.numRows)));
        });
      });
    });

    test("row works", () {
      forAll((Mat<double> m) {
        val idx = Gen.choose(0, m.numRows - 1);
        val data = m.contents;
        forAll(idx, (i) {
          expect(m.row(i),
              equals(Vec(data).slice(i * m.numCols, (i + 1) * m.numCols)));
        });
      });
    });

    test("mult works", () {
//       import org.apache.commons.math.linear.Array2DRowRealMatrix

      forAll((Mat<double> ma, Mat<double> mb) {
        if (ma.numCols != mb.numRows) {
          expect(ma.mult(mb), throwsA(IllegalArgumentException));
        } else {
          val res = ma.mult(mb);

          expect(res.numRows, equals(ma.numRows));
          expect(res.numCols, equals(mb.numCols));

          if (ma.numRows > 0 && mb.numRows > 0) {
            val matA =
                new Array2DRowRealMatrix(ma.rows().map(_.toArray).toArray);
            val matB =
                new Array2DRowRealMatrix(mb.rows().map(_.toArray).toArray);

            val matC = matA.multiply(matB);

            expect(res.contents, equals(flatten(matC.getData)));
          } else {
            expect(res.numRows, equals(0));
          }
        }
      });
    });

    test("roundTo works", () {
      forAll((Mat<double> ma) {
        expect(ma.contents.map((double v) => math.round(v * 100) / 100 /*d*/),
            equals(ma.roundTo(2).contents));
      });
    });

    test("cov works", () {
      forAll((Mat<double> ma) {
//         import org.apache.commons.math.stat.correlation.Covariance

        if (ma.numRows < 2 || ma.numCols < 2) {
          expect(MatMath.cov(ma), throwsA(IllegalArgumentException));
        } else {
          val aCov = new Covariance(ma.rows().map(_.toArray).toArray);
          val exp = aCov.getCovarianceMatrix;
          val res = MatMath.cov(ma).contents;

          expect(Vec(res), beCloseToVec(Vec(flatten(exp.getData)), 1e-9));
        }
      });
    });
  });

  test("serialization works", () {
    forAll((Mat<double> ma) {
      expect(ma, equals(serializedCopy(ma)));
    });
  });
}
