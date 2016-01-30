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
//import time._

import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';

seriesTest() {
  test("reindex works on dates", () {
    var s1 = new Series(
        new Vec([1.0, 2.0, 3.0], ScalarTag.stDouble),
        new Index([
          new DateTime(2005, 1, 1),
          new DateTime(2005, 1, 2),
          new DateTime(2005, 1, 3)
        ], ScalarTag.stTime));
    var s2 = new Series(
        new Vec([5.0, 7.0], ScalarTag.stDouble),
        new Index([new DateTime(2005, 1, 1), new DateTime(2005, 1, 3)],
            ScalarTag.stTime));

    expect(s2.reindex(s1.index).index, equals(s1.index));
  });

  test("non-spec primitive groupby must work", () {
    var s = new Series({'a': 1, 'b': 2, 'b': 3});
    expect(s.groupBy().combineIgnoreKey((Vec v) => v.first ?? 0),
        equals(new Series({'a': 1, 'b': 2})));
  });

  test("map works", () {
    var s = new Series({'a': 1, 'b': 2, 'b': 3});
    expect(s.map((k, v) => [k, v + 1]), equals(s + 1));
  });

  test("flatMap works", () {
    var s = new Series({'a': 1, 'b': 2, 'b': 3});
    expect(s.flatMap((k, v) => /*Some(*/ [k, v + 1]), equals(s + 1));
  });
}
