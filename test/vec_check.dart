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
//import org.scalacheck.{Gen, Arbitrary}
//import org.scalacheck.Prop._
//import org.saddle.scalar.Value
//import Serde.serializedCopy

import 'dart:math' show Random;

import 'package:test/test.dart';
import 'package:quiver/iterables.dart' show concat, range;
import 'package:dataframe/dataframe.dart';

final Random r = new Random();

/// Generates vec of length of up to 20 entries
/// with 90% of entries between -1e3/+1e3 and 10% NA
Vec<double> vecDoubleWithNA() {
  var n = r.nextInt(17) + 3;
  var lst = new List<double>.generate(n, (_) {
    if (r.nextInt(10) == 5) {
      return double.NAN;
    } else {
      return (r.nextDouble() * 1e3) * (r.nextBool() ? 1 : -1);
    }
  });
  return new Vec(lst, ScalarTag.stDouble);
}

// Generates vec of length of up to 20 entries w/o NA's
Vec<double> vecDoubleWithoutNA() {
  var n = r.nextInt(17) + 3;
  var lst = new List<double>.generate(n, (_) {
    return (r.nextDouble() * 1e3) * (r.nextBool() ? 1 : -1);
  });
  return new Vec(lst, ScalarTag.stDouble);
}

Vec<double> vecDoublePWithNA() {
  var n = r.nextInt(17) + 3;
  var lst = new List<double>.generate(n, (_) {
    if (r.nextInt(10) == 0) {
      return NA;
    } else {
      return (r.nextDouble() * 1e3) * (r.nextBool() ? 1 : -1);
    }
  });
  return new Vec(lst.where((d) => d > 0).toList(), ScalarTag.stDouble);
}

Vec<double> vecDoublePWithoutNA() {
  var n = r.nextInt(17) + 3;
  var lst = new List<double>.generate(n, (_) {
    return (r.nextDouble() * 1e3) * (r.nextBool() ? 1 : -1);
  });
  return new Vec(lst.where((d) => d > 0).toList(), ScalarTag.stDouble);
}

/**
 * Test on properties of Vec
 */
//class VecCheck extends Specification with ScalaCheck {
vecCheck() {
  var gen = vecDoubleWithNA;
  group("double", () {
//    /*implicit*/ val vec = Arbitrary(VecArbitraries.vecDoubleWithNA);

    VecDouble v;
    ScalarTag st;
    setUp(() {
      v = gen();
      st = ScalarTag.stDouble;
    });

    test("vectors equality", () {
      expect(v, equals(new Vec(v.contents, st)));
      expect(v, equals(v));
    });

    test("single element access of vector", () {
      var i = r.nextInt(v.length - 1);
      List data = v.contents;
      expect(v.at(i).isNA || v.at(i) == new Value(data[i], st), isTrue);
      expect(v.raw(i).isNaN || v.raw(i) == data[i], isTrue);
    });

    test("multiple element access / slicing of vector", () {
      var i = r.nextInt(v.length - 2);
      List data = v.contents;
      expect(v.take([i, i + 1]), equals(new Vec([data[i], data[i + 1]], st)));
//      expect(v(i -> (i+1)), equals(Vec(data(i), data(i + 1));
//      expect(v((i+1) -> i), equals(Vec.empty[Double];
//      expect(v(i -> *), equals(Vec(Range(i, v.length).map(data(_)) : _*);
//      expect(v(* -> i), equals(Vec(Range(0, i+1).map(data(_)) : _*);
//      expect(v(*), equals(v
    });

    test("first works", () {
      if (v.isEmpty) {
        expect(v.first, equals(NA));
      } else {
        expect(v.first, equals(v.at(0)));
      }
    });

    test("last works", () {
      if (v.isEmpty) {
        expect(v.last, equals(NA));
      } else {
        expect(v.last, equals(v.at(v.length - 1)));
      }
    });

    test("concat works", () {
      var data = v.contents;
      expect(v.concat(v), equals(new Vec(concat([data, data]).toList(), st)));
    });

    test("map works", () {
      var si = ScalarTag.stInt;
      var data = v.contents;
      expect(v.map((b) => b + 1.0, st),
          equals(new Vec(data.map((b) => b + 1.0).toList(), st)));
      expect(
          v.map((d) => 5.0, st),
          equals(new Vec(
              data.map((d) => d.isNaN ? double.NAN : 5.0).toList(), st)));
      expect(
          v.map((d) => 5, si),
          equals(new Vec<int>(
              data.map((d) => d.isNaN ? si.missing() : 5).toList(), si)));
    });

//    test("zipmap works", () {
//      expect(v.zipMap(v, (a, b) => a + b, st), equals(v * 2.0));
//    });

    test("dropNA works", () {
      var data = v.contents;
      expect(v.dropNA(),
          equals(new Vec(data.where((d) => !d.isNaN).toList(), st)));
    });

    test("hasNA works", () {
      var data = v.contents;
      expect(v.hasNA, equals((data.where((d) => d.isNaN).isNotEmpty)));
    });

    test("findOne works", () {
      var v = new Vec<double>([1.0, 2.0, 3.0, st.missing(), 5.0], st);
      expect(v.findOne((d) => d == 3.0), equals(2));
      expect(v.findOne((d) => d == 5.0), equals(4));
      expect(v.findOne((d) => d == 7.0), equals(-1));
    });

    test("find works", () {
      var v = new Vec<double>([1.0, 2.0, 3.0, st.missing(), 3.0, 4.0], st);
      expect(v.find((d) => d == 3.0),
          equals(new Vec<int>([2, 4], ScalarTag.stInt)));
      expect(
          v.find((d) => d == 4.0), equals(new Vec<int>([5], ScalarTag.stInt)));
      expect(
          v.find((d) => d == 7.0), equals(new Vec<int>.empty(ScalarTag.stInt)));
    });

    test("exists works", () {
      var v = new Vec<double>([1.0, 2.0, 3.0, st.missing(), 3.0, 4.0], st);
      expect(v.exists((d) => d == 3.0), isTrue);
      expect(v.exists((d) => d == 2.0), isTrue);
      expect(v.exists((d) => d == 9.0), isFalse);
    });

    test("filter works", () {
      var res = v.filter((d) => d < 0);
      expect(res.contents.where((d) => d >= 0), isEmpty);
    });

    test("filterAt works", () {
      var i = r.nextInt(v.length);
      var res = v.filterAt((j) => j != i);
      expect(res.length <= i || res.length == v.length - 1, isTrue);
    });

//    test("where works", () {
//      var whereVec = v < 0;
//      expect(v.where(whereVec), equals(v.filter((d) => d < 0)));
//    });

    test("sorted works", () {
      var res = v.sorted();
      var exp = new Vec(v.contents..sort(), st);
      var nas = v.length - v.count();

      expect(
          res.slice(nas, res.length), equals(exp.slice(0, res.length - nas)));
    });

    test("forall works", () {
      var c = 0;
      v.forall((d) => d > 0.5, (i) {
        if (!i.isNaN) c += 1;
      });
      var exp = (v.filter((d) => d > 0.5) as VecDouble).count();
      expect(c, equals(exp));
    });

    test("foreach works", () {
      var c = 0;
      v.foreach((i) {
        if (!i.isNaN) c += 1;
      });
      var exp = v.count();
      expect(c, equals(exp));
    });

    test("reversed works", () {
      var res = v.reversed;
      var exp = new Vec(v.contents.reversed.toList(), st);
      expect(res, equals(exp));
    });

    test("fillNA works", () {
      var res = v.fillNA((_) => 5.0);
      var exp = new Vec(v.contents.map((x) => x.isNaN ? 5.0 : x).toList(), st);
      expect(res.hasNA, isFalse);
      expect(res, equals(exp));
    });

    test("sliceAt works", () {
      var i = r.nextInt(v.length - 1) + 1;
      var slc = v.slice(1, i);
      var exp = v.contents.sublist(1, i);
      expect(slc, equals(new Vec(exp, st)));
    });

    test("foldLeft works", () {
      var res = v.foldLeft(0, (int c, double x) => c + (x.isNaN ? 0 : 1));
      var exp = v.count();
      expect(res, equals(exp));
    });

    test("filterFoldLeft works", () {
      var res = v.filterFoldLeft((a) => a < 0, 0, (int c, double x) => c + 1);
      var exp = (v.filter((d) => d < 0) as VecDouble).count();
      expect(res, equals(exp));
    });

    test("foldLeftWhile works", () {
      var res = v.foldLeftWhile(
          0, (int c, double x) => c + 1, (int c, double x) => c < 3);
      var c = 0;
      var exp = v.contents.takeWhile((v) => v.isNaN || (++c <= 3));
      expect(res, equals(new VecDouble(exp.toList()).count()));
    });

    test("scanLeft works", () {
      var res = v.scanLeft(0, (int c, double x) => c + 1, ScalarTag.stInt);
      expect(res.length, equals(v.length));
      expect(res.last.isNA || res.last == new Value(v.count(), ScalarTag.stInt),
          isTrue);
    });

    test("filterScanLeft works", () {
      var res = v.filterScanLeft((double d) => d > 0.5, 0,
          (int c, double x) => c + 1, ScalarTag.stInt);
      expect(res.length, equals(v.length));
      expect(
          res.last.isNA ||
              res.last ==
                  new Value((v.filter((d) => d > 0.5) as VecDouble).count(),
                      ScalarTag.stInt),
          isTrue);
    });
    /*
    test("concat works", () {
      Vec<double> v1 = gen();
      Vec<double> v2 = gen();
      var res = v1.concat(v2);
      var exp = new Vec(concat([v1.toArray(), v2.toArray()]), st);
      expect(res, equals(exp));
    });

    test("negation works", () {
      var res = -v;
      var exp = new Vec(v.toArray().map((d) => d * -1), st);
      expect(res, equals(exp));
    });
*/
    test("take works", () {
      var i = new List.generate(3, (j) => r.nextInt(v.length - 1));
      var res = v.take(i);
      var exp = new Vec(i.map((j) => v.raw(j)).toList(), st);
      expect(res, equals(exp));
      expect(res, equals(new Vec(i.map((j) => v[j]).toList(), st)));
    });

    test("mask works", () {
      var res = (v.maskFn((d) => d > 0.5) as VecDouble).count();
      var exp = v.countif((double d) => d <= 0.5);
      expect(res, equals(exp));

//      var res2 = (v.mask(v.map((d) => d > 0.5, ScalarTag.stBool)) as VecDouble)
//          .count();
//      expect(res2, equals(exp));
    });

    test("splitAt works", () {
      var i = r.nextInt(v.length - 1);
      var res = v.splitAt(i);
      expect(res.v1.length, equals(i));
      expect(res.v2.length, equals((v.length - i)));
//      expect((res.v1.concat(res.v2)), equals(v));
    });

    test("shift works", () {
      expect(v.shift(0), equals(v));

      var i = r.nextInt(v.length - 1);
      var res = v.shift(i);
      expect(res.length, equals(v.length));
//      expect(res.slice(i, res.length), equals(v.slice(0, v.length - i)));
    });

    test("without works", () {
      var i = new List<int>.generate(3, (_) => r.nextInt(v.length - 1));
      var res = v.without(i);
      var tmp = []; //Buffer[Double]();
      i = i.toSet();
      for (var k in range(0, v.length)) {
        if (!i.contains(k)) {
          tmp.add(v.raw(k));
        }
      }
      expect(res, equals(new Vec(tmp, st)));
    });

    test("rolling works", () {
      var res = v.rolling(2, (d) => (d as VecDouble).sum(), st);

      if (v.length == 0) {
        expect(res, equals(new Vec.empty(st)));
      } else if (v.length == 1) {
        expect(res.raw(0), equals(v.sum()));
      } else {
        var dat = v.contents;
        var exp = range(v.length - 1).map((i) {
          var a = dat[i];
          var b = dat[i + 1];
          return (a.isNaN ? 0.0 : a) + (b.isNaN ? 0.0 : b);
        }).toList();

        expect(res, equals(new Vec(exp, st))); // : _*)
      }
    });

    test("pad works", () {
      expect(new Vec<double>([1.0, double.NAN, double.NAN, 2.0], st).pad(),
          equals(new Vec<double>([1.0, 1.0, 1.0, 2.0], st)));
      expect(
          new Vec<double>([1.0, double.NAN, double.NAN, 2.0], st).padAtMost(1),
          equals(new Vec<double>([1.0, 1.0, double.NAN, 2.0], st)));

      expect((v.length > 0 && v.at(0).isNA) || !v.pad().hasNA, isTrue);
    });

//    test("serialization works", () {
//      expect(v, equals(serializedCopy(v)));
//    });
  });
}

main() {
  group('Vec', vecCheck);
}
