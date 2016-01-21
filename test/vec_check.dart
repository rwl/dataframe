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

import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';

/**
 * Test on properties of Vec
 */
//class VecCheck extends Specification with ScalaCheck {
vecCheck() {
  group("Double Vec Tests", () {
    /*implicit*/ val vec = Arbitrary(VecArbitraries.vecDoubleWithNA);

    test("vectors equality", () {
      forAll((Vec<double> v) {
        expect(v, equals(Vec(v.contents)));
        expect(v, equals(v));
      });
    });

    test("single element access of vector", () {
      forAll((Vec<double> v) {
        val idx = Gen.choose(0, v.length - 1);
        val data = v.contents;
        forAll(idx, (i) {
//          expect((v.at(i).isNA, isTrue) or expect(v.at(i), equals(Value(data(i)));
//          expect((v.raw(i).isNaN, isTrue) or expect(v.raw(i), equals(data(i));
        });
      });
    });

    test("multiple element access / slicing of vector", () {
      forAll((Vec<double> v) {
        val idx = Gen.choose(0, v.length - 2);
        val data = v.contents;
        forAll(idx, (i) {
//          expect(v(i, i+1), equals(Vec(data(i), data(i + 1));
//          expect(v(i -> (i+1)), equals(Vec(data(i), data(i + 1));
//          expect(v((i+1) -> i), equals(Vec.empty[Double];
//          expect(v(i -> *), equals(Vec(Range(i, v.length).map(data(_)) : _*);
//          expect(v(* -> i), equals(Vec(Range(0, i+1).map(data(_)) : _*);
//          expect(v(*), equals(v
        });
      });
    });

    test("first works", () {
      forAll((Vec<double> v) {
        if (v.isEmpty) {
          expect(v.first, equals(scalar.NA));
        } else {
          expect(v.first, equals(v.at(0)));
        }
      });
    });

    test("last works", () {
      forAll((Vec<double> v) {
        if (v.isEmpty) {
          expect(v.last, equals(scalar.NA));
        } else {
          expect(v.last, equals(v.at(v.length - 1)));
        }
      });
    });

    test("concat works", () {
      forAll((Vec<double> v) {
        val data = v.contents;
//        expect(v.concat(v), equals(Vec(data ++ data);
      });
    });

    test("map works", () {
      forAll((Vec<double> v) {
        val data = v.contents;
        expect(v.map(_ + 1.0), equals(Vec(data.map(_ + 1.0))));
//        expect(v.map(d => 5.0), equals(Vec(data.map(d => if (d.isNaN) na.to[Double] else 5.0));
//        expect(v.map(d => 5), equals(Vec[Int](data.map(d => if (d.isNaN) na.to[Int] else 5));
      });
    });

    test("zipmap works", () {
      forAll((Vec<double> v) {
        expect(v.zipMap(v)(_ + _), equals(v * 2.0));
      });
    });

    test("dropNA works", () {
      forAll((Vec<double> v) {
        val data = v.contents;
        expect(v.dropNA, equals(Vec(data.filter(!_.isNaN))));
      });
    });

    test("hasNA works", () {
      forAll((Vec<double> v) {
        val data = v.contents;
        expect(v.hasNA, equals((data.indexWhere(_.isNaN) >= 0)));
      });
    });

    test("findOne works", () {
      val v = Vec(_1d, 2, 3, na.to(Double), 5);
      expect(v.findOne(_ == _3d), equals(2));
      expect(v.findOne(_ == _5d), equals(4));
      expect(v.findOne(_ == _7d), equals(-1));
    });

    test("find works", () {
      val v = Vec(_1d, 2, 3, na.to[Double], 3, 4);
      expect(v.find(_ == _3d), equals(Vec(2, 4)));
      expect(v.find(_ == _4d), equals(Vec(5)));
      expect(v.find(_ == _7d), equals(Vec.empty[Int]));
    });

    test("exists works", () {
      val v = Vec(_1d, 2, 3, na.to[Double], 3, 4);
      expect(v.exists(_ == _3d), isTrue);
      expect(v.exists(_ == _2d), isTrue);
      expect(v.exists(_ == _9d), isFalse);
    });

    test("filter works", () {
      forAll((Vec<double> v) {
        val res = v.filter(_ < 0);
        expect(res.contents.indexWhere(_ >= 0), equals(-1));
      });
    });

    test("filterAt works", () {
      forAll((Vec<double> v) {
        val idx = Gen.choose(0, v.length);
        forAll(idx, (i) {
          val res = v.filterAt(_ != i);
//          expect((res.length <= i) || (res.length, equals(v.length - 1));
        });
      });
    });

    test("where works", () {
      forAll((Vec<double> v) {
        val whereVec = (v < 0);
        expect(v.where(whereVec), equals(v.filter(_ < 0)));
      });
    });

    test("sorted works", () {
      forAll((Vec<double> v) {
        val res = v.sorted;
        val exp = Vec(v.contents.sorted);
        val nas = v.length - v.count;

        expect(
            res.slice(nas, res.length), equals(exp.slice(0, res.length - nas)));
      });
    });

    test("forall works", () {
      forAll((Vec<double> v) {
        var c = 0;
//        v.forall(_ > 0.5) { i => if (!i.isNaN) c += 1 };
        val exp = v.filter(_ > 0.5).count;
        expect(c, equals(exp));
      });
    });

    test("foreach works", () {
      forAll((Vec<double> v) {
        var c = 0;
//        v.foreach { i => if (!i.isNaN) c += 1 };
        val exp = v.count;
        expect(c, equals(exp));
      });
    });

    test("reversed works", () {
      forAll((Vec<double> v) {
        val res = v.reversed;
        val exp = Vec(v.contents.reverse);
        expect(res, equals(exp));
      });
    });

    test("fillNA works", () {
      forAll((Vec<double> v) {
        val res = v.fillNA((_) => 5.0);
        val exp = Vec(v.contents.map((x) => (x.isNaN) ? 5.0 : x));
        expect(res.hasNA, isFalse);
        expect(res, equals(exp));
      });
    });

    test("sliceAt works", () {
      forAll((Vec<double> v) {
        val idx = Gen.choose(0, v.length);
        forAll(idx, (i) {
          val slc = v.slice(1, i);
          val exp = v.contents.slice(1, i);
          expect(slc, equals(Vec(exp)));
        });
      });
    });

    test("foldLeft works", () {
      forAll((Vec<double> v) {
//        val res = v.foldLeft(0)((int c, double x) => c + { (x.isNaN) ? 0 : 1 } )
        val exp = v.count;
        expect(res, equals(exp));
      });
    });

    test("filterFoldLeft works", () {
      forAll((Vec<double> v) {
        val res = v.filterFoldLeft(_ < 0)(0)((int c, double x) => c + 1);
        val exp = v.filter(_ < 0).count;
        expect(res, equals(exp));
      });
    });

    test("foldLeftWhile works", () {
      forAll((Vec<double> v) {
        val res = v.foldLeftWhile(0)((int c, double x) => c + 1)(
            (int c, double x) => c < 3);
        var c = 0;
//        val exp = v.contents.takeWhile { (double v) => v.isNaN || { c += 1; c <= 3 } }
        expect(res, equals(Vec(exp).count));
      });
    });

    test("scanLeft works", () {
      forAll((Vec<double> v) {
        val res = v.scanLeft(0)((int c, double x) => c + 1);
        expect(res.length, equals(v.length));
//        expect(res.last.isNA, isTrue) or expect((res.last, equals(Value(v.count));
      });
    });

    test("filterScanLeft works", () {
      forAll((Vec<double> v) {
        val res = v.filterScanLeft(_ > 0.5)(0)((int c, double x) => c + 1);
        expect(res.length, equals(v.length));
//        expect(res.last.isNA, isTrue) or expect(res.last, equals(Value(v.filter(_ > 0.5).count));
      });
    });

    test("concat works", () {
      forAll((Vec<double> v1, Vec<double> v2) {
//        val res = v1 concat v2;
//        val exp = Vec(v1.toArray ++ v2.toArray);
        expect(res, equals(exp));
      });
    });

    test("negation works", () {
      forAll((Vec<double> v) {
        val res = -v;
        val exp = Vec(v.toArray.map(_ * -1));
        expect(res, equals(exp));
      });
    });

    test("take works", () {
      forAll((Vec<double> v) {
        val idx = Gen.listOfN(3, Gen.choose(0, v.length - 1));
        forAll(idx, (i) {
          val res = v.take(i.toArray);
          val exp = Vec(i.toArray.map(v.raw(_)));
          expect(res, equals(exp));
          expect(res, equals(v(i))); // : _*)
        });
      });
    });

    test("mask works", () {
      forAll((Vec<double> v) {
        val res = v.mask(_ > 0.5).count;
        val exp = v.countif(_ <= 0.5);
        expect(res, equals(exp));

        val res2 = v.mask(v.map((_) > 0.5)).count;
        expect(res2, equals(exp));
      });
    });

    test("splitAt works", () {
      forAll((Vec<double> v) {
        val idx = Gen.choose(0, v.length - 1);
        forAll(idx, (i) {
          var res1, res2 = v.splitAt(i);
          expect(res1.length, equals(i));
          expect(res2.length, equals((v.length - i)));
//          expect((res1 concat res2), equals(v));
        });
      });
    });

    test("shift works", () {
      forAll((Vec<double> v) {
        expect(v.shift(0), equals(v));

        val idx = Gen.choose(0, v.length - 1);
        forAll(idx, (i) {
          val res = v.shift(i);
          expect(res.length, equals(v.length));
          expect(res.slice(i, res.length), equals(v.slice(0, v.length - i)));
        });
      });
    });

    test("without works", () {
      forAll((Vec<double> v) {
        val idx = Gen.listOfN(3, Gen.choose(0, v.length - 1));
        forAll(idx, (i) {
          val res = v.without(i.toArray);
          val tmp = Buffer[Double]();
//          for (k <- 0 until v.length if !i.toSet.contains(k) ) tmp.add(v.raw(k));
          expect(res, equals(Vec(tmp.toArray)));
        });
      });
    });

    test("rolling works", () {
      forAll((Vec<double> v) {
        val res = v.rolling(2, _.sum);

        if (v.length == 0) {
          expect(res, equals(Vec.empty[Double]));
        } else if (v.length == 1) {
          expect(res.raw(0), equals(v.sum));
        } else {
          val dat = v.contents;
//          val exp = for {
//            i <- 0 until v.length - 1
//            a = dat(i)
//            b = dat(i + 1)
//          }); yield (if (a.isNaN) 0 else a) + (if (b.isNaN) 0 else b)

          expect(res, equals(Vec(exp))); // : _*)
        }
      });
    });

    test("pad works", () {
      expect(new Vec<double>(_1d, na, na, _2d).pad,
          equals(new Vec<double>(_1d, _1d, _1d, _2d)));
      expect(new Vec<double>(_1d, na, na, _2d).padAtMost(1),
          equals(new Vec<double>(_1d, _1d, na, _2d)));

      forAll((Vec<double> v) {
//        expect((v.length > 0 && v.at(0).isNA) || (v.pad.hasNA, isFalse));
      });
    });

    test("serialization works", () {
      forAll((Vec<double> v) {
        expect(v, equals(serializedCopy(v)));
      });
    });
  });
}
