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

//import org.specs2.mutable.Specification
//import org.specs2.ScalaCheck
//import org.scalacheck.{ Gen, Arbitrary }
//import org.scalacheck.Prop._
//import Serde.serializedCopy

import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';

//class FrameCheck extends Specification with ScalaCheck {
frameCheck() {
  group("Frame Tests", () {
    /*implicit*/ val frame = Arbitrary(FrameArbitraries.frameDoubleWithNA);

    test("frame equality", () {
      forAll((Frame<int, int, double> f) {
//          expect(f, equals(f.col(*)));
        expect(f, equals(f));
      });
    });

    test("frame sortedRowsBy", () {
      forAll((Frame<int, int, double> f) {
        if (f.numCols > 0) {
//          val res = f.sortedRowsBy { x => x.at(0) }
          val ord = array.argsort(f.colAt(0).toVec);
          val exp = f.rowAt(ord);
          expect(res, equals(exp));
        } else {
          expect(f, equals(new Frame.empty<int, int, double>()));
        }
      });
    });

    test("frame colSplitAt works", () {
      forAll((Frame<int, int, double> f) {
        val idx = Gen.choose(0, f.numCols - 1);
        forAll(idx, (i) {
          var l, r = f.colSplitAt(i);
          expect(l.numCols, equals(i));
          expect(r.numCols, equals(f.numCols - i));
//          expect((l rconcat r), equals(f));
        });
      });
    });

    test("frame rowSplitAt works", () {
      forAll((Frame<int, int, double> f) {
        val idx = Gen.choose(0, f.numRows - 1);
        forAll(idx, (i) {
          var l, r = f.rowSplitAt(i);
          expect(l.numRows, equals(i));
          expect(r.numRows, equals(f.numRows - i));
//          expect((l concat r), equals(f));
        });
      });
    });

    test("Stringify works for one col, zero rows", () {
//      val f = Frame(Array(Vec.empty[Double]) : _*)
      expect(f.toString, isNot(throwsA(RuntimeException)));
    });

    test("Transpose must work for a string frame", () {
      val f = Frame(Vec("a", "b", "c"), Vec("d", "e", "f"));
      expect(f.T, equals(Frame(Vec("a", "d"), Vec("b", "e"), Vec("c", "f"))));
    });

    test("serialization works", () {
      forAll((Frame<int, int, double> f) {
        expect(f, equals(serializedCopy(f)));
      });
    });
  });
}
