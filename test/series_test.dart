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

//class SeriesSpec extends Specification {
seriesTest() {
  test("reindex works on dates", () {
    val s1 = Series(
        Vec(_1d, 2, 3),
        Index(
            datetime(2005, 1, 1), datetime(2005, 1, 2), datetime(2005, 1, 3)));
    val s2 =
        Series(Vec(_5d, 7), Index(datetime(2005, 1, 1), datetime(2005, 1, 3)));

    expect(s2.reindex(s1.index).index, equals(_ == s1.index));
  });

  test("non-spec primitive groupby must work", () {
    val s = Series({'a': 1, 'b': 2, 'b': 3});
    expect(s.groupBy.combine(_.first.getOrElse(0)),
        equals(_ == Series({'a': 1, 'b': 2})));
  });

  test("map works", () {
    val s = Series({'a': 1, 'b': 2, 'b': 3});
//    s.map { case (k, v) => (k, v+1) } must_== s + 1
  });

  test("flatMap works", () {
    val s = Series({'a': 1, 'b': 2, 'b': 3});
//    s.flatMap { case (k, v) => Some((k, v+1)) } must_== s + 1
  });
}
