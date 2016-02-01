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

library saddle.util;

//import org.specs2.mutable.Specification
//import org.specs2.ScalaCheck
//import org.scalacheck.Prop._
//import org.saddle.Vec

import 'dart:math';

import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';
import 'package:dataframe/src/util/concat.dart';

final Random r = new Random();

const int minl = 2;
const int maxl = 48;

final ScalarTag si = ScalarTag.stInt;
final ScalarTag sb = ScalarTag.stBool;
final ScalarTag sd = ScalarTag.stDouble;
//final ScalarTag st = ScalarTag.stTime;

List<bool> boolList() {
  var l = r.nextInt(maxl) + minl;
  return new List<bool>.generate(l, (_) => r.nextBool());
}

List<int> intList() {
  var l = r.nextInt(maxl) + minl;
  return new List<int>.generate(l, (_) {
    return r.nextInt(99) * (r.nextBool() ? -1 : 1);
  });
}

List<double> doubleList() {
  var l = r.nextInt(maxl) + minl;
  return new List<double>.generate(l, (_) {
    var j = r.nextInt(10);
    if (j == 4) {
      return double.NAN;
    } else if (j == 5) {
      return double.NEGATIVE_INFINITY;
    } else if (j == 6) {
      return double.INFINITY;
    } else {
      return r.nextDouble() * (r.nextBool() ? -1 : 1);
    }
  });
}

concatTest() {
  test("concat bool, bool", () {
    var a1 = boolList();
    var a2 = boolList();

    var res = Concat.append(a1, a2, sb, sb);
    var exp = a1..addAll(a2);
    expect(res, equals(exp));
  });

//  test("concat Byte, Boolean", () {
//    forAll { (a1: Array[Byte], a2: Array[Boolean]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(if(_) 1.toByte else 0.toByte).contents
//      res must_== exp
//    }
//  });
//
//  test("concat Char, Boolean", () {
//    forAll { (a1: Array[Char], a2: Array[Boolean]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(if(_) 1.toChar else 0.toChar).contents
//      res must_== exp
//    }
//  });
//
//  test("concat Short, Boolean", () {
//    forAll { (a1: Array[Short], a2: Array[Boolean]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(if(_) 1.toShort else 0.toShort).contents
//      res must_== exp
//    }
//  });

  test("concat int, bool", () {
    var a1 = intList();
    var a2 = boolList();
    var res = Concat.append(a1, a2, si, sb);
    var v2 = new Vec<bool>(a2, sb).map((b) => b ? 1 : 0, si);
    var exp = a1..addAll(v2.toArray());
    expect(res, equals(exp));
  });

//  test("concat Float, Boolean", () {
//    forAll { (a1: Array[Float], a2: Array[Boolean]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(if(_) 1.toFloat else 0.toFloat).contents
//      res must_== exp
//    }
//  });
//
//  test("concat Long, Boolean", () {
//    forAll { (a1: Array[Long], a2: Array[Boolean]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(if(_) 1.toLong else 0.toLong).contents
//      res must_== exp
//    }
//  });

  test("concat double, bool", () {
    var a1 = doubleList();
    var a2 = boolList();
    var res = Concat.append(a1, a2, sd, sb);
    var exp = a1..addAll(a2.map((b) => b ? 1.0 : 0.0));
    expect(new Vec(res, sd), equals(new Vec(exp, sd)));
  });

  // -----
  // Byte

//  test("concat Byte, Byte", () {
//    forAll { (a1: Array[Byte], a2: Array[Byte]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ a2
//      res must_== exp
//    }
//  });
//
//  test("concat Char, Byte", () {
//    forAll { (a1: Array[Char], a2: Array[Byte]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toChar).contents
//      res must_== exp
//    }
//  });
//
//  test("concat Short, Byte", () {
//    forAll { (a1: Array[Short], a2: Array[Byte]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toShort).contents
//      res must_== exp
//    }
//  });
//
//  test("concat Int, Byte", () {
//    forAll { (a1: Array[Int], a2: Array[Byte]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toInt).contents
//      res must_== exp
//    }
//  });
//
//  test("concat Float, Byte", () {
//    forAll { (a1: Array[Float], a2: Array[Byte]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toFloat).contents
//      Vec(res) must_== Vec(exp)
//    }
//  });
//
//  test("concat Long, Byte", () {
//    forAll { (a1: Array[Long], a2: Array[Byte]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toLong).contents
//      res must_== exp
//    }
//  });
//
//  test("concat Double, Byte", () {
//    forAll { (a1: Array[Double], a2: Array[Byte]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toDouble).contents
//      Vec(res) must_== Vec(exp)
//    }
//  });

  // -----
  // Char

//  test("concat Char, Char", () {
//    forAll { (a1: Array[Char], a2: Array[Char]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ a2
//      res must_== exp
//    }
//  });
//
//  test("concat Short, Char", () {
//    forAll { (a1: Array[Short], a2: Array[Char]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toShort).contents
//      res must_== exp
//    }
//  });
//
//  test("concat Int, Char", () {
//    forAll { (a1: Array[Int], a2: Array[Char]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toInt).contents
//      res must_== exp
//    }
//  });
//
//  test("concat Float, Char", () {
//    forAll { (a1: Array[Float], a2: Array[Char]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toFloat).contents
//      Vec(res) must_== Vec(exp)
//    }
//  });
//
//  test("concat Long, Char", () {
//    forAll { (a1: Array[Long], a2: Array[Char]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toLong).contents
//      res must_== exp
//    }
//  });
//
//  test("concat Double, Char", () {
//    forAll { (a1: Array[Double], a2: Array[Char]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toDouble).contents
//      Vec(res) must_== Vec(exp)
//    }
//  });

  // ------
  // Short

//  test("concat Short, Short", () {
//    forAll { (a1: Array[Short], a2: Array[Short]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ a2
//      res must_== exp
//    }
//  });
//
//  test("concat Int, Short", () {
//    forAll { (a1: Array[Int], a2: Array[Short]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toInt).contents
//      res must_== exp
//    }
//  });
//
//  test("concat Float, Short", () {
//    forAll { (a1: Array[Float], a2: Array[Short]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toFloat).contents
//      Vec(res) must_== Vec(exp)
//    }
//  });
//
//  test("concat Long, Short", () {
//    forAll { (a1: Array[Long], a2: Array[Short]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toLong).contents
//      res must_== exp
//    }
//  });
//
//  test("concat Double, Short", () {
//    forAll { (a1: Array[Double], a2: Array[Short]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toDouble).contents
//      Vec(res) must_== Vec(exp)
//    }
//  });

  // ------
  // Int

  test("concat int, int", () {
    var a1 = intList();
    var a2 = intList();
    var res = Concat.append(a1, a2, si, si);
    var exp = new Vec(a1, si).map((i) => i.toInt(), si).contents..addAll(a2);
    expect(res, equals(exp));
  });

//  test("concat Float, Int", () {
//    forAll { (a1: Array[Float], a2: Array[Int]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toFloat).contents
//      Vec(res) must_== Vec(exp)   // must handle equality on NaN's properly
//    }
//  });
//
//  test("concat Long, Int", () {
//    forAll { (a1: Array[Long], a2: Array[Int]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toLong).contents
//      res must_== exp
//    }
//  });

  test("concat double, int", () {
    var a1 = doubleList();
    var a2 = intList();
    var res = Concat.append(a1, a2, sd, si);
    var v2 = new Vec(a2, si).map((i) => i.toDouble(), sd);
    var exp = a1..addAll(v2.contents);
    expect(new Vec(res, sd),
        new Vec(exp, sd)); // must handle equality on NaN's properly
  });

  // ------
  // Float

//  test("concat Float, Float", () {
//    forAll { (a1: Array[Float], a2: Array[Float]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ a2
//      Vec(res) must_== Vec(exp)   // must handle equality on NaN's properly
//    }
//  });
//
//  test("concat Double, Float", () {
//    forAll { (a1: Array[Double], a2: Array[Float]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toDouble).contents
//      Vec(res) must_== Vec(exp)   // must handle equality on NaN's properly
//    }
//  });

  // -----
  // Long

//  test("concat Long, Long", () {
//    forAll { (a1: Array[Long], a2: Array[Long]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ a2
//      res must_== exp
//    }
//  });
//
//  test("concat Double, Long", () {
//    forAll { (a1: Array[Double], a2: Array[Long]) =>
//      val res = Concat.append(a1, a2)
//      val exp = a1 ++ Vec(a2).map(_.toDouble).contents
//      Vec(res) must_== Vec(exp)   // must handle equality on NaN's properly
//    }
//  });

  // -----
  // Double

  test("concat double, double", () {
    var a1 = doubleList();
    var a2 = doubleList();
    var res = Concat.append(a1, a2, sd, sd);
    var exp = a1..addAll(a2);
    // must handle equality on NaN's properly
    expect(new Vec(res, sd), equals(new Vec(exp, sd)));
  });
}

main() {
  for (var i = 0; i < 1; i++) {
    concatTest();
  }
}
