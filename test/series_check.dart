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

library saddle.test.series_check;

//import org.saddle.Serde._
//import org.specs2.mutable.Specification
//import org.specs2.ScalaCheck
//import org.scalacheck.{Gen, Arbitrary}
//import org.scalacheck.Prop._
//
//import org.joda.time._
//import org.saddle.time._

import 'dart:math' show Random;
import 'package:quiver/iterables.dart' show range;

import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';
import 'index_check.dart' show getDate;
import 'frame_check.dart' show frameDoubleWithNA;

final Random r = new Random();

const minl = 3;
const maxl = 20;

/// Generates series of length of up to [maxl] entries
///  with 90% of entries between -1e3/+1e3 and 10% NA
Series<int, double> seriesIntDoubleWithNA() {
  var n = r.nextInt(maxl) + minl;
  var lst = new List<double>.generate(n, (_) {
    if (r.nextInt(10) == 5) {
      return double.NAN;
    } else {
      return r.nextDouble() * 1e3 * (r.nextBool() ? 1 : -1);
    }
  });
  var values = new Vec(lst, ScalarTag.stDouble);
  return Series.fromVec(values);
}

/// As above, but with arbitrary duplicates in (unsorted) index
Series<int, double> dupSeriesIntDoubleWithNA() {
  var n = r.nextInt(maxl) + minl;
  var lst = new List<double>.generate(n, (_) {
    if (r.nextInt(10) == 5) {
      return double.NAN;
    } else {
      return r.nextDouble() * 1e3 * (r.nextBool() ? 1 : -1);
    }
  });
  var idx = new List<int>.generate(n, (_) => r.nextInt(5));
  var values = new Vec(lst, ScalarTag.stDouble);
  var index = new Index(idx, ScalarTag.stInt);
  return new Series(values, index);
}

Series<DateTime, double> seriesDateTimeDoubleNoDup() {
  var n = r.nextInt(maxl) + minl;
  var ix = new List<DateTime>.generate(n, (_) => getDate());
  var uq = new Index<DateTime>(ix.toSet().toList(), ScalarTag.stTime);
  var lst = new List<double>.generate(uq.length, (_) {
    return r.nextDouble() * 1e3 * (r.nextBool() ? 1 : -1);
  });
  var values = new Vec(lst, ScalarTag.stDouble);
  return new Series(values, uq);
}

Series<DateTime, double> dupSeriesDateTimeDoubleWithNA() {
  var n = r.nextInt(maxl) + minl;
  var lst = new List<double>.generate(n, (_) {
    if (r.nextInt(10) == 5) {
      return double.NAN;
    } else {
      return r.nextDouble() * 1e3 * (r.nextBool() ? 1 : -1);
    }
  });
  var values = new Vec(lst, ScalarTag.stDouble);
  var ix = new List<DateTime>.generate(n, (_) => getDate());
  var index = new Index<DateTime>(ix, ScalarTag.stTime);
  return new Series(values, index);
}

//class SeriesCheck extends Specification with ScalaCheck {
seriesCheck() {
  group("Series<int, double>", () {
//    /*implicit*/ var ser = Arbitrary(SeriesArbitraries.seriesDoubleWithNA);
    Series<int, double> s;
    setUp(() {
      s = seriesIntDoubleWithNA();
    });

    test("series equality", () {
      expect(s, equals(Series.fromVec(s.toVec())));
      expect(s, equals(s));
    });

    test("take works", () {
      var i = new List<int>.generate(3, (_) => r.nextInt(s.length - 1));
      var res = s.take(i);
      var exp = s.extract(i[0]).concat(s.extract(i[1])).concat(s.extract(i[2]));
      expect(res, equals(exp));
    });
    /*
    test("head works", () {
      expect(
          s.head(0), equals(new Series<int, double>.empty(ScalarTag.stDouble)));
      if (s.length == 1) {
        expect(s.head(1), equals(s.extract(0)));
      } else {
        var exp = s.extract(0).concat(s.extract(1));
        expect(s.head(2), equals(exp));
      }
    });

    test("tail works", () {
      expect(
          s.tail(0), equals(new Series<int, double>.empty(ScalarTag.stDouble)));
      if (s.length == 1) {
        expect(s.tail(1), equals(s.extract(0)));
      } else {
        var exp = s.extract(s.length - 2).concat(s.extract(s.length - 1));
        expect(s.tail(2), equals(exp));
      }
    });

    test("shift works", () {
      expect(s.shift(1).index, equals(s.index));

      if (!s.isEmpty) {
        var exp = new Vec([double.NAN], ScalarTag.stDouble)
            .concat(s.values.slice(0, s.length - 1));
        expect(s.shift(1).values, equals(exp));
      } else {
        expect(s.shift(1).isEmpty, isTrue);
      }

      expect(s.shift(-1).index, equals(s.index));

      if (!s.isEmpty) {
        var exp = s.values
            .slice(1, s.length)
            .concat(new Vec([double.NAN], ScalarTag.stDouble));
        expect(s.shift(-1).values, equals(exp));
      } else {
        expect(s.shift(1).isEmpty, isTrue);
      }
    });

    test("first works", () {
      if (s.isEmpty) {
        expect(s.first, equals(NA));
      } else {
        expect(s.first, equals(s.values.at(0)));
      }
    });

    test("last works", () {
      if (s.isEmpty) {
        expect(s.last, equals(NA));
      } else {
        expect(s.last, equals(s.values.at(s.length - 1)));
      }
    });

    test("firstValue works", () {
//      /*implicit*/ val ser = Arbitrary(SeriesArbitraries.dupSeriesDoubleWithNA);

      s = dupSeriesIntDoubleWithNA();
      var i = r.nextInt(s.length - 1);
      var idx = s.index.raw(i);
      expect(s.firstValue(idx),
          equals(s.values.at(s.index.findOne((j) => j == idx))));
    });

    test("lastValue works", () {
//      /*implicit*/ val ser = Arbitrary(SeriesArbitraries.dupSeriesDoubleWithNA);

      s = dupSeriesIntDoubleWithNA();
      var i = r.nextInt(s.length - 1);
      var idx = s.index.raw(i);
      expect(s.lastValue(idx), equals(s.extract(idx).tail(1).at(0)));
    });

    test("apply/slice (no index dups) works", () {
      var i = r.nextInt(s.length - 1);

      expect(s.extract(i), equals(s.take([i])));
//          s(i : _*), equals(s.take(i);

//        val locs = for {
//          i <- Gen.choose(0, s.length - 1)
//          j <- Gen.choose(i, s.length - 1)
//        } yield (i, j)

      i = r.nextInt(s.length - 1);
      var j = r.nextInt(s.length - 1 - i) + i;

//        forAll(locs) { case (i, j) =>
      var exp = s.take(range(i, j + 1).toList());
      expect(s.extractAll(range(i, j).toList()), equals(exp));
      expect(s.sliceByRange(i, j), equals(exp));
      expect(s.sliceByRange(i, j, false), equals(s.take(range(i, j).toList())));
//        }
//      });
    });

    test("apply/slice (with index dups) works", () {
//      /*implicit*/ val ser = Arbitrary(SeriesArbitraries.dupSeriesDoubleWithNA);

      s = dupSeriesIntDoubleWithNA();
      var i = new List<int>.generate(3, (_) => r.nextInt(s.length - 1));

      if (i.length > 2) {
        var locs = i; //.toArray;
        var keys = s.index.take(locs).toArray_();
        var exp = s
            .extract(keys[0])
            .concat(s.extract(keys[1]))
            .concat(s.extract(keys[2]));

        expect(s.extractAll(keys), equals(exp));
//        expect(s(keys : _*), equals(exp));

        var srt = s.sortedIx();

        var exp2 = srt.slice(
            srt.index.getFirst(keys[0]), srt.index.getLast(keys[1]) + 1);
        expect(srt(range(keys[0], keys[1])), equals(exp2));
        expect(srt.sliceByRange(keys[0], keys[1]), equals(exp2));

        var exp3 = srt.slice(srt.index.getFirst(keys(0)),
            srt.index.getLast(keys(1)) - srt.index.count(keys(1)) + 1);
        expect(srt.sliceByRange(keys[0], keys[1], false), equals(exp3));
      }
    });

    test("splitAt works", () {
      var i = r.nextInt(s.length - 1);
      var res = s.splitAt(i);
      expect(res.left.length, equals(i));
      expect(res.right.length, equals((s.length - i)));
      expect((res.left.concat(res.right)), equals(s));
    });

    test("proxyWith", () {
      var s1 = seriesIntDoubleWithNA();
      var s2 = seriesIntDoubleWithNA();
      var proxied = s1.proxyWith(s2);
      range(proxied.length)
          .where((i) => s1.at(i).isNA && i < s2.length)
          .forEach((i) {
        expect(proxied.at(i), equals(s2.at(i)));
      });
    });

    test("filter works", () {
      expect(s.filter((i) => i > 0).sum() >= 0, isTrue);
      expect(s.filter((i) => i < 0).sum() <= 0, isTrue);
    });

    test("filterAt works", () {
      var i = r.nextInt(s.length - 1);
      expect(
          s.filterAt((j) => j != i).length == 0 ||
              s.filterAt((j) => j != i).length == s.length - 1,
          isTrue);
    });

    test("reindex works", () {
      var s1 = seriesIntDoubleWithNA();
      var s2 = seriesIntDoubleWithNA();
      expect(s1.reindex(s2.index).index, equals(s2.index));
    });

    test("pivot works", () {
      var v1 = rand(8);
      var v3 = rand(7);
      var x1 = new Index.fromTuples([
        new Tuple2("a", "1m"),
        new Tuple2("a", "3m"),
        new Tuple2("a", "6m"),
        new Tuple2("a", "1y"),
        new Tuple2("a", "2y"),
        new Tuple2("a", "3y"),
        new Tuple2("a", "10y"),
        new Tuple2("a", "20y")
      ]);
      var x2 = new Index([
        new Tuple2("b", "1m"),
        new Tuple2("b", "3m"),
        new Tuple2("b", "6m"),
        new Tuple2("b", "1y"),
        new Tuple2("b", "2y"),
        new Tuple2("b", "3y"),
        new Tuple2("b", "20y")
      ]);

      var a = new Series(v1, x1);
      var b = new Series(v3, x2);

      var c = a.concat(b);

      var dat1 = v1.toDoubleArray();
      var dat2 = v3.sliceBy(0, 5).toDoubleArray()
        ..add(double.NAN)
        ..addAll(v3.sliceBy(6, 7).toDoubleArray());
      var exp = Frame.fromMat(new Mat(2, 8, dat1..addAll(dat2)),
          new Index("a", "b"), x1.map((tup) => tup.value2));

      expect(c.pivot, equals(exp));
    });

    test("pivot/melt are opposites", () {
//      /*implicit*/ val frame = Arbitrary(FrameArbitraries.frameDoubleWithNA);
      Frame<int, int, double> f = frameDoubleWithNA();
      expect(f.melt().pivot(), equals(f));
    });

    test("serialization works", () {
      expect(s, equals(serializedCopy(s)));
    });
  });

  group("Series<DateTime, double> Tests", () {
//    /*implicit*/ val ser = Arbitrary(SeriesArbitraries.seriesDateTimeDoubleWithNA);

    Series<DateTime, double> s;
    setUp(() {
      s = dupSeriesDateTimeDoubleWithNA();
    });
    test("series equality", () {
      expect(s, equals(new Series(s.toVec(), s.index)));
      expect(s, equals(s));
    });

    test("take works", () {
      var i = new List<int>.generate(3, (_) => r.nextInt(s.length - 1));
      var res = s.take(i);
      var exp = s
          .slice(i[0], i[0] + 1)
          .concat(s.slice(i[1], i[1] + 1))
          .concat(s.slice(i[2], i[2] + 1));
      expect(res, equals(exp));
    });

    test("first (key) works", () {
      var i = r.nextInt(s.length - 1);
      var idx = s.index.raw(i);
      expect(s.firstValue(idx),
          equals(s.values.at(s.index.findOne((j) => j == idx))));
    });

    test("last (key) works", () {
      var i = r.nextInt(s.length - 1);
      var idx = s.index.raw(i);
      expect(s.lastValue(idx), equals(s.extract(idx).tail(1).at(0)));
    });

    test("apply/slice (with index dups) works", () {
      var i = new List<int>.generate(3, (_) => r.nextInt(s.length - 1));

      var locs = i;
      var keys = s.index.take(locs).toArray_();
      var exp = s
          .extract(keys[0])
          .concat(s.extract(keys[1]))
          .concat(s.extract(keys[2]));

      expect(s.extractAll(keys), equals(exp));
//        expect(s(keys : _*), equals(exp));

      var srt = s.sortedIx();

      var exp2 = srt.slice(
          srt.index.getFirst(keys[0]), srt.index.getLast(keys[1]) + 1);
//      expect(srt(range(keys[0], keys[1]).toList()), equals(exp2));
      expect(srt.sliceByRange(keys[0], keys[1]), equals(exp2));

      var exp3 = srt.slice(srt.index.getFirst(keys(0)),
          srt.index.getLast(keys(1)) - srt.index.count(keys(1)) + 1);
      expect(srt.sliceByRange(keys[0], keys[1], false), equals(exp3));
    });

    test("proxyWith", () {
//      /*implicit*/ val ser = Arbitrary(SeriesArbitraries.seriesDateTimeDoubleNoDup);

      var s1 = seriesDateTimeDoubleNoDup();
      var s2 = seriesDateTimeDoubleNoDup();
      var proxied = s1.proxyWith(s2);
      range(proxied.length)
          .where((i) => s1.at(i).isNA && i < s2.length)
          .forEach((i) {
        expect(proxied.at(i), equals(s2.at(i)));
      });
    });

    test("reindex works", () {
//      /*implicit*/ var ser = Arbitrary(SeriesArbitraries.seriesDateTimeDoubleNoDup);

      var s1 = seriesDateTimeDoubleNoDup();
      var s2 = seriesDateTimeDoubleNoDup();

      expect(s1.reindex(s2.index).index, equals(s2.index));
    });

    test("serialization works", () {
//      /*implicit*/ val ser = Arbitrary(SeriesArbitraries.seriesDateTimeDoubleNoDup);

      var s = seriesDateTimeDoubleNoDup();
      expect(s, equals(serializedCopy(s)));
    });
    *
     */
  });
}

main() {
  for (var i = 0; i < 1; i++) {
    seriesCheck();
  }
}
