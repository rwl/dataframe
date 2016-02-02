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

library saddle.test.frame_check;

//import org.specs2.mutable.Specification
//import org.specs2.ScalaCheck
//import org.scalacheck.{ Gen, Arbitrary }
//import org.scalacheck.Prop._
//import Serde.serializedCopy

import 'dart:math' show Random;

import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';

final Random r = new Random();

/// Generates frame of size of up to 20x10
///  with 90% of entries between -1e3/+1e3 and 10% NA
Frame<int, int, double> frameDoubleWithNA() {
  int n = r.nextInt(20);
  int m = r.nextInt(10);
  var lst = new List<double>.generate(n, (_) {
    if (r.nextInt(10) == 5) {
      return double.NAN;
    } else {
      return (r.nextDouble() * 1e3) * (r.nextBool() ? 1 : -1);
    }
  });
  return new Frame(new Mat(n, m, lst));
}

//class FrameCheck extends Specification with ScalaCheck {
frameCheck() {
  group("Frame Tests", () {
//    /*implicit*/ val frame = Arbitrary(FrameArbitraries.frameDoubleWithNA);

    Frame<int, int, double> f;
    setUp(() {
      f = frameDoubleWithNA();
    });
    test("frame equality", () {
//      expect(f, equals(f.col(*)));
      expect(f, equals(f));
    });

    test("frame sortedRowsBy", () {
      if (f.numCols > 0) {
        var res = f.sortedRowsBy((x) => x.at(0));
        var ord = array.argsort(f.colAt(0).toVec);
        var exp = f.rowAt(ord);
        expect(res, equals(exp));
      } else {
        expect(f, equals(new Frame<int, int, double>.empty()));
      }
    });

    test("frame colSplitAt works", () {
      var i = r.nextInt(f.numCols - 1);
      var splt = f.colSplitAt(i);
      expect(splt.left.numCols, equals(i));
      expect(splt.right.numCols, equals(f.numCols - i));
      expect((splt.left.rconcat(splt.right)), equals(f));
    });

    test("frame rowSplitAt works", () {
      var i = r.nextInt(f.numRows - 1);
      var splt = f.rowSplitAt(i);
      expect(splt.left.numRows, equals(i));
      expect(splt.right.numRows, equals(f.numRows - i));
      expect((splt.left.concat(splt.right)), equals(f));
    });

    test("Stringify works for one col, zero rows", () {
      f = new Frame.fromVecs([new Vec.empty(ScalarTag.stDouble)]);
      expect(f.toString, isNot(throwsA(RuntimeException)));
    });

    test("Transpose must work for a string frame", () {
      var f = new Frame.fromVecs([
        new Vec(["a", "b", "c"]),
        new Vec(["d", "e", "f"])
      ]);
      expect(
          f.transpose(),
          equals(new Frame.fromVecs([
            new Vec(["a", "d"]),
            new Vec(["b", "e"]),
            new Vec(["c", "f"])
          ])));
    });

    test("serialization works", () {
      expect(f, equals(serializedCopy(f)));
    });
  });
}
