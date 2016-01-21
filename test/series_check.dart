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

//import org.saddle.Serde._
//import org.specs2.mutable.Specification
//import org.specs2.ScalaCheck
//import org.scalacheck.{Gen, Arbitrary}
//import org.scalacheck.Prop._
//
//import org.joda.time._
//import org.saddle.time._

import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';

//class SeriesCheck extends Specification with ScalaCheck {
seriesCheck() {
  group("Series<int, double> Tests", () {
    /*implicit*/ var ser = Arbitrary(SeriesArbitraries.seriesDoubleWithNA);

    test("series equality", () {
      forAll((Series<int, double> s) {
        expect(s, equals(Series(s.toVec)));
        expect(s, equals(s));
      });
    });

    test("take works", () {
      forAll((Series<int, double> s) {
        val idx = Gen.listOfN(3, Gen.choose(0, s.length - 1));
        forAll(idx, (i) {
          val res = s.take(i.toArray);
//          val exp = s(i(0)) concat s(i(1)) concat s(i(2));
          expect(res, equals(exp));
        });
      });
    });

    test("head works", () {
      forAll((Series<int, double> s) {
        expect(s.head(0), equals(new Series.empty<int, double>()));
        if (s.length == 1) {
          expect(s.head(1), equals(s(0)));
        } else {
//          val exp = s(0) concat s(1)
          expect(s.head(2), equals(exp));
        }
      });
    });

    test("tail works", () {
      forAll((Series<int, double> s) {
        expect(s.tail(0), equals(new Series.empty<int, double>()));
        if (s.length == 1) {
          expect(s.tail(1), equals(s(0)));
        } else {
//          val exp = s(s.length - 2) concat s(s.length - 1);
          expect(s.tail(2), equals(exp));
        }
      });
    });

    test("shift works", () {
      forAll((Series<int, double> s) {
        expect(s.shift(1).index, equals(s.index));

        if (!s.isEmpty) {
//          val exp = Vec(na.to[Double]) concat s.values.slice(0, s.length - 1)
          expect(s.shift(1).values, equals(exp));
        } else {
          expect(s.shift(1).isEmpty, isTrue);
        }

        expect(s.shift(-1).index, equals(s.index));

        if (!s.isEmpty) {
//          val exp = s.values.slice(1, s.length) concat Vec(na.to[Double])
          expect(s.shift(-1).values, equals(exp));
        } else {
          expect(s.shift(1).isEmpty, isTrue);
        }
      });
    });

    test("first works", () {
      forAll((Series<int, double> s) {
        if (s.isEmpty) {
          expect(s.first, equals(scalar.NA));
        } else {
          expect(s.first, equals(s.values.at(0)));
        }
      });
    });

    test("last works", () {
      forAll((Series<int, double> s) {
        if (s.isEmpty) {
          expect(s.last, equals(scalar.NA));
        } else {
          expect(s.last, equals(s.values.at(s.length - 1)));
        }
      });
    });

    test("first (key) works", () {
      /*implicit*/ val ser = Arbitrary(SeriesArbitraries.dupSeriesDoubleWithNA);

      forAll((Series<int, double> s) {
        val loc = Gen.choose(0, s.length - 1);
        forAll(loc, (i) {
          val idx = s.index.raw(i);
          expect(s.first(idx), equals(s.values.at(s.index.findOne(_ == idx))));
        });
      });
    });

    test("last (key) works", () {
      /*implicit*/ val ser = Arbitrary(SeriesArbitraries.dupSeriesDoubleWithNA);

      forAll((Series<int, double> s) {
        val loc = Gen.choose(0, s.length - 1);
        forAll(loc, (i) {
          val idx = s.index.raw(i);
          expect(s.last(idx), equals(s(idx).tail(1).at(0)));
        });
      });
    });

    test("apply/slice (no index dups) works", () {
      forAll((Series<int, double> s) {
        val idx = Gen.listOfN(3, Gen.choose(0, s.length - 1));

        forAll(idx, (i) {
          expect(s(i.toArray), equals(s.take(i.toArray)));
//          s(i : _*), equals(s.take(i.toArray);
        });

//        val locs = for {
//          i <- Gen.choose(0, s.length - 1)
//          j <- Gen.choose(i, s.length - 1)
//        } yield (i, j)

//        forAll(locs) { case (i, j) =>
//          val exp = s.take(Range(i, j+1).toArray);
//          expect(s(i -> j), equals(exp));
//          expect(s.sliceBy(i, j), equals(exp));
//          expect(s.sliceBy(i, j, inclusive = false), equals(s.take(Range(i, j).toArray)));
//        }
      });
    });

    test("apply/slice (with index dups) works", () {
      /*implicit*/ val ser = Arbitrary(SeriesArbitraries.dupSeriesDoubleWithNA);

      forAll((Series<int, double> s) {
        val idx = Gen.listOfN(3, Gen.choose(0, s.length - 1));

        forAll(idx, (i) {
//          expect(i.length, lessThanOrEqualTo(2)) or {
//            val locs = i.toArray;
//            val keys = s.index.take(locs).toArray;
//            val exp = s(keys(0)) concat s(keys(1)) concat s(keys(2));
//
//            expect(s(keys), equals(exp));
//            expect(s(keys : _*), equals(exp));
//
//            val srt = s.sortedIx;
//
//            val exp2 = srt.slice(srt.index.getFirst(keys(0)),
//                                   srt.index.getLast(keys(1)) + 1);
//            expect(srt(keys(0) -> keys(1)), equals(exp2));
//            expect(srt.sliceBy(keys(0), keys(1)), equals(exp2));
//
//            val exp3 = srt.slice(srt.index.getFirst(keys(0)),
//                                   srt.index.getLast(keys(1)) - srt.index.count(keys(1)) + 1);
//            expect(srt.sliceBy(keys(0), keys(1), inclusive = false), equals(exp3));
//          }
        });
      });
    });

    test("splitAt works", () {
      forAll((Series<int, double> s) {
        val idx = Gen.choose(0, s.length - 1);
        forAll(idx, (i) {
          val res1, res2 = s.splitAt(i);
          expect(res1.length, equals(i));
          expect(res2.length, equals((s.length - i)));
//          expect((res1 concat res2), equals(s));
        });
      });
    });

    test("proxyWith", () {
      forAll((Series<int, double> s1, Series<int, double> s2) {
        val proxied = s1.proxyWith(s2);
//        val all = for (i <- 0 until proxied.length if s1.at(i).isNA && i < s2.length) yield {
//          proxied.at(i), equals(s2.at(i)
//        }
        all.foldLeft(true)((acc, v) => acc && v.isSuccess);
      });
    });

    test("filter works", () {
      forAll((Series<int, double> s1) {
        expect(s1.filter(_ > 0).sum >= 0, isTrue);
        expect(s1.filter(_ < 0).sum <= 0, isTrue);
      });
    });

    test("filterAt works", () {
      forAll((Series<int, double> s) {
        val idx = Gen.choose(0, s.length - 1);
        forAll(idx, (i) {
          expect(
              (s.filterAt(_ != i).length == 0 ||
                  s.filterAt(_ != i).length == s.length - 1),
              isTrue);
        });
      });
    });

    test("reindex works", () {
      forAll((Series<int, double> s1, Series<int, double> s2) {
        expect(s1.reindex(s2.index).index, equals(s2.index));
      });
    });

    test("pivot works", () {
      val v1 = vec.rand(8);
      val v3 = vec.rand(7);
//      val x1 = Index(("a", "1m"), ("a", "3m"), ("a", "6m"),  ("a", "1y"),  ("a", "2y"), ("a", "3y"),
//                     ("a", "10y"), ("a", "20y"))
//      val x2 = Index(("b", "1m"), ("b", "3m"), ("b", "6m"),  ("b", "1y"),  ("b", "2y"), ("b", "3y"),
//                     ("b", "20y"))

      val a = Series(v1, x1);
      val b = Series(v3, x2);

//      val c = a concat b

      val dat1 = v1.toDoubleArray;
//      val dat2 = v3.sliceBy(0, 5).toDoubleArray ++ Array(na.to[Double]) ++ v3.sliceBy(6,7).toDoubleArray;
//      val exp   = Frame(Mat(2, 8, dat1 ++ dat2), Index("a", "b"), x1.map(_._2));

      expect(c.pivot, equals(exp));
    });

    test("pivot/melt are opposites", () {
      /*implicit*/ val frame = Arbitrary(FrameArbitraries.frameDoubleWithNA);
      forAll((Frame<int, int, double> f) {
        expect(f.melt.pivot, equals(f));
      });
    });

    test("serialization works", () {
      forAll((Series<int, double> s1) {
        expect(s1, equals(serializedCopy(s1)));
      });
    });
  });

  group("Series<DateTime, double> Tests", () {
    /*implicit*/ val ser =
        Arbitrary(SeriesArbitraries.seriesDateTimeDoubleWithNA);

    test("series equality", () {
      forAll((Series<DateTime, double> s) {
        expect(s, equals(Series(s.toVec, s.index)));
        expect(s, equals(s));
      });
    });

    test("take works", () {
      forAll((Series<DateTime, double> s) {
        val idx = Gen.listOfN(3, Gen.choose(0, s.length - 1));
        forAll(idx, (i) {
          val res = s.take(i.toArray);
//          val exp = s.slice(i(0), i(0)+1) concat s.slice(i(1), i(1)+1) concat s.slice(i(2), i(2)+1);
          expect(res, equals(exp));
        });
      });
    });

    test("first (key) works", () {
      forAll((Series<DateTime, double> s) {
        val loc = Gen.choose(0, s.length - 1);
        forAll(loc, (i) {
          val idx = s.index.raw(i);
          expect(s.first(idx), equals(s.values.at(s.index.findOne(_ == idx))));
        });
      });
    });

    test("last (key) works", () {
      forAll((Series<DateTime, double> s) {
        val loc = Gen.choose(0, s.length - 1);
        forAll(loc, (i) {
          val idx = s.index.raw(i);
          expect(s.last(idx), equals(s(idx).tail(1).at(0)));
        });
      });
    });

    test("apply/slice (with index dups) works", () {
      forAll((Series<DateTime, double> s) {
        val idx = Gen.listOfN(3, Gen.choose(0, s.length - 1));

        forAll(idx, (i) {
//          expect(i.length, lessThanOrEqualTo(2)) or {
//            val locs = i.toArray;
//            val keys = s.index.take(locs).toArray;
//            val exp = s(keys(0)) concat s(keys(1)) concat s(keys(2));
//
//            expect(s(keys), equals(exp));
//            expect(s(keys : _*), equals(exp));
//
//            val srt = s.sortedIx;
//
//            val exp2 = srt.slice(srt.index.getFirst(keys(0)),
//                                 srt.index.getLast(keys(1)) + 1);
//            expect(srt(keys(0) -> keys(1)), equals(exp2));
//            expect(srt.sliceBy(keys(0), keys(1)), equals(exp2));
//
//            val exp3 = srt.slice(srt.index.getFirst(keys(0)),
//                                 srt.index.getLast(keys(1)) - srt.index.count(keys(1)) + 1);
//            expect(srt.sliceBy(keys(0), keys(1), inclusive = false), equals(exp3));
//          }
        });
      });
    });

    test("proxyWith", () {
      /*implicit*/ val ser =
          Arbitrary(SeriesArbitraries.seriesDateTimeDoubleNoDup);

      forAll((Series<DateTime, double> s1, Series<DateTime, double> s2) {
        val proxied = s1.proxyWith(s2);
//        val all = for (i <- 0 until proxied.length if s1.at(i).isNA && i < s2.length) yield {
//          proxied.at(i), equals(s2.at(i)
//        }
        all.foldLeft(true)((acc, v) => acc && v.isSuccess);
      });
    });

    test("reindex works", () {
      /*implicit*/ val ser =
          Arbitrary(SeriesArbitraries.seriesDateTimeDoubleNoDup);

      forAll((Series<DateTime, double> s1, Series<DateTime, double> s2) {
        expect(s1.reindex(s2.index).index, equals(s2.index));
      });
    });

    test("serialization works", () {
      /*implicit*/ val ser =
          Arbitrary(SeriesArbitraries.seriesDateTimeDoubleNoDup);

      forAll((Series<DateTime, double> s) {
        expect(s, equals(serializedCopy(s)));
      });
    });
  });
}
