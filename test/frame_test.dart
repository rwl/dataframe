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

import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';

/**
 * Specs for a Frame
 */
//class FrameSpec extends Specification {
frameTest() {
  test("Frame.empty behaves as expected", () {
    expect(
        new Frame({
          "a": new Vec<int>.empty(ScalarTag.stInt),
          "b": new Vec<int>.empty(ScalarTag.stInt)
        }).isEmpty,
        isTrue);
  });

  test("shift-merge must work", () {
    var s1 = new Series(
        new Vec([1, 2, 3], ScalarTag.stInt), new Index(["a", "b", "c"]));
    var mergeShift = s1.join(s1.shift(1));
    expect(
        mergeShift.row("b"),
        equals(new Frame({
          0: new Series({"b": 2}),
          1: new Series({"b": 1})
        })));
  });

  test("map works", () {
    var f = new Frame({
      "a": new Series({"x": 1, "y": 2, "z": 3}),
      "b": new Series({"x": 4, "y": 5, "z": 6})
    });
//    f.map { case (r, c, v) => (r, c, v + 1) } must_== f + 1
  });

  test("flatMap works", () {
    var f = new Frame({
      "a": new Series({"x": 1, "y": 2, "z": 3}),
      "b": new Series({"x": 4, "y": 5, "z": 6})
    });
//    f.flatMap { case (r, c, v) => Some((r, c, v + 1)) } must_== f + 1
  });

  test("colType works within rfilter", () {
    var strVec = new Vec(["string", "another string", "unrelated"]);
    var intVec = vec.randi(3);
    var df = new Panel(strVec, intVec);
    var df2 = df.rfilter((x) =>
        x.get(0).map((y) => y.toString()).getOrElse("").contains("string"));
    expect(df2.colType(ScalarTag.stInt),
        isNot(equals(new Frame<int, int, int>.empty())));
    expect(df2.colType[String],
        isNot(equals(new Frame<int, int, String>.empty())));
  });
}
