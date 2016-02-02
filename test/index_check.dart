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

library saddle.test.index_check;

//import org.saddle.Serde._
//import org.specs2.mutable.Specification
//import org.specs2.ScalaCheck
//import org.scalacheck.{Gen, Arbitrary}
//import org.scalacheck.Prop._
//import scalar.Scalar
//import org.joda.time._

import 'dart:math' show Random;
import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';
import 'package:quiver/iterables.dart' show range;

final Random r = new Random();

Index<int> indexIntWithDups() {
  var l = r.nextInt(20) + 2;
  var lst = new List.generate(l, (_) => r.nextInt(l));
  return new Index(lst, ScalarTag.stInt);
}

Index<int> indexIntNoDups() {
  var l = 20; //r.nextInt(20);
  var lst = new List.generate(l, (_) => r.nextInt(l));
  return new Index(lst.toSet().toList(), ScalarTag.stInt);
}

DateTime getDate() {
  var m = r.nextInt(11) + 1;
  var d = r.nextInt(27) + 1;
  var y = r.nextBool() ? 2012 : 2013;
  return new DateTime.utc(y, m, d);
}

Index<DateTime> indexTimeWithDups() {
  var l = r.nextInt(100);
  var lst = new List.generate(l, (_) => getDate());
  return new Index(lst, ScalarTag.stTime);
}

Index<DateTime> indexTimeNoDups() {
  var l = r.nextInt(100);
  var lst = new List.generate(l, (_) => getDate());
  return new Index(lst.toSet().toList(), ScalarTag.stTime);
}

//class IndexCheck extends Specification with ScalaCheck {
indexCheck() {
  group("int", () {
//    /*implicit*/ var arbIndex = Arbitrary(IndexArbitraries.indexIntWithDups);

    Index<int> ix;
    ScalarTag st = ScalarTag.stInt;
    setUp(() {
      ix = indexIntWithDups();
    });

    test("access works", () {
      var i = r.nextInt(ix.length - 1);
      expect(ix[i], equals(new Scalar(ix.toVec().contents[i], st)));
      expect(ix.raw(i), equals(ix.toVec().contents[i]));
    });

    test("key lookup works", () {
      var i = r.nextInt(ix.length - 1);
      var v = ix.raw(i);
      var expected = range(ix.length).where((x) => ix.raw(x) == v);
      expect(ix([v]), equals(expected));
    });

    test("key counts work", () {
      var i = r.nextInt(ix.length - 1);
      var v = ix.raw(i);
      int expected = range(ix.length)
          .map((l) => ix.raw(l) == v ? 1 : 0)
          .reduce((a, b) => a + b);
      expect(ix.count(v), equals(expected));
    });

//    test("index joins work", () {
//      Index<int> ix1 = indexIntWithDups();
//      Index<int> ix2 = indexIntWithDups();
//      JoinType.values.forEach((jointype) {
//        print(jointype);
//        var res = ix1.join(ix2, jointype);
//
//        var exp = res.index.toVec();
//        var lix = ix1.toVec();
//        var rix = ix2.toVec();
//        var lft = res.lTake != null
//            ? lix.take(res.lTake)
//            : lix.fillNA((i) => exp.raw(i));
//        var rgt = res.rTake != null
//            ? rix.take(res.rTake)
//            : rix.fillNA((i) => exp.raw(i));
//
//        expect(lft, equals(exp));
//        expect(rgt, equals(exp));
//      });
////      all.foldLeft(true)((acc, v) => acc && v.isSuccess);
//    });

    test("index union works", () {
      Index<int> ix1 = indexIntNoDups();
      Index<int> ix2 = indexIntNoDups();
      var expected = (ix1.toSeq()..addAll(ix2.toSeq())).toSet();
      expect(ix1.union(ix2).index.toSeq().toSet(), equals(expected));
    });

    test("without dups, index union is outer join", () {
      Index<int> ix1 = indexIntNoDups();
      Index<int> ix2 = indexIntNoDups();
      var expected = (ix1.toSeq()..addAll(ix2.toSeq())).toSet();

      expect(ix1.join(ix2, JoinType.OuterJoin).index.toSeq().toSet(),
          equals(expected));
    });

    test("index intersect works", () {
      Index<int> ix1 = indexIntNoDups();
      Index<int> ix2 = indexIntNoDups();
      var expected = ix1.toSeq().toSet().intersection(ix2.toSeq().toSet());

      expect(ix1.intersect(ix2).index.toSeq().toSet(), equals(expected));
    });

    test("joins preserves index order with dups", () {
      Index<int> ix1 = indexIntWithDups();
      Index<int> ix2 = indexIntWithDups();

      var ixs1 = ix1.sorted;
      var ixs2 = ix2.sorted;

      expect(ixs1.join(ixs2, JoinType.RightJoin).index.isMonotonic, isTrue);
      expect(ixs1.join(ixs2, JoinType.LeftJoin).index.isMonotonic, isTrue);
      expect(ixs1.join(ixs2, JoinType.InnerJoin).index.isMonotonic, isTrue);
      expect(ixs1.join(ixs2, JoinType.OuterJoin).index.isMonotonic, isTrue);
    });

    test("joins preserves index order no dups", () {
      Index<int> ix1 = indexIntNoDups();
      Index<int> ix2 = indexIntNoDups();

      var ixs1 = ix1.sorted;
      var ixs2 = ix2.sorted;

      expect(ixs1.join(ixs2, JoinType.RightJoin).index.isMonotonic, isTrue);
      expect(ixs1.join(ixs2, JoinType.LeftJoin).index.isMonotonic, isTrue);
//      expect(ixs1.join(ixs2, JoinType.InnerJoin).index.isMonotonic, isTrue);
      expect(ixs1.join(ixs2, JoinType.OuterJoin).index.isMonotonic, isTrue);
    });

    /*test("serialization works", () {
      Index<int> ix1 = indexIntNoDups();
      Index<int> ix2 = indexIntNoDups();

      expect(ix1, equals(serializedCopy(ix1)));
      expect(ix2, equals(serializedCopy(ix2)));
    });*/
  });

  group("DateTime", () {
    Index<DateTime> ix;
    ScalarTag st = ScalarTag.stTime;
    setUp(() {
      ix = indexTimeWithDups();
    });

    test("access works", () {
      var i = r.nextInt(ix.length - 1);
      expect(ix[i], equals(new Scalar(ix.toVec().contents[i], st)));
      expect(ix.raw(i), equals(ix.toVec().contents[i]));
    });

    test("key lookup works", () {
      var i = r.nextInt(ix.length - 1);
      var v = ix.raw(i);
      var expected = range(ix.length).where((j) => ix.raw(j) == v);
      expect(ix([v]), equals(expected));
    });

    test("key counts work", () {
      var i = r.nextInt(ix.length - 1);
      var v = ix.raw(i);
      int expected = range(ix.length)
          .map((l) => (ix.raw(l) == v) ? 1 : 0)
          .reduce((a, b) => a + b);
      expect(ix.count(v), equals(expected));
    });

    test("index joins work", () {
      var ix1 = indexTimeWithDups();
      var ix2 = indexTimeWithDups();

      JoinType.values.map((jointype) {
        var res = ix1.join(ix2, jointype);

        var exp = res.index.toVec();
        var lix = ix1.toVec();
        var rix = ix2.toVec();
        var lft = res.lTake != null
            ? res.lTake.map((x) => lix.take([x]))
            : lix.fillNA((i) => exp.raw(i));
        var rgt = res.rTake != null
            ? res.rTake.map((x) => rix.take([x]))
            : rix.fillNA((i) => exp.raw(i));

        expect(lft, equals(exp));
        expect(rgt, equals(exp));
      });
//      all.foldLeft(true)((acc, v) => acc && v.isSuccess);
    });

    test("index union works", () {
      var ix1 = indexTimeNoDups();
      var ix2 = indexTimeNoDups();

      var expected = (ix1.toSeq()..addAll(ix2.toSeq())).toSet();
      expect(ix1.union(ix2).index.toSeq().toSet(), equals(expected));
    });

    test("without dups, index union is outer join", () {
      var ix1 = indexTimeNoDups();
      var ix2 = indexTimeNoDups();

      var expected = (ix1.toSeq()..addAll(ix2.toSeq())).toSet();
      expect(ix1.join(ix2, JoinType.OuterJoin).index.toSeq().toSet(),
          equals(expected));
    });

    test("index intersect works", () {
      var ix1 = indexTimeNoDups();
      var ix2 = indexTimeNoDups();

      var expected = ix1.toSeq().toSet().intersection(ix2.toSeq().toSet());
      expect(ix1.intersect(ix2).index.toSeq().toSet(), equals(expected));
    });

    test("joins preserves index order with dups", () {
      var ix1 = indexTimeWithDups();
      var ix2 = indexTimeWithDups();

      var ixs1 = ix1.sorted;
      var ixs2 = ix2.sorted;

      expect(ixs1.join(ixs2, JoinType.RightJoin).index.isMonotonic, isTrue);
      expect(ixs1.join(ixs2, JoinType.LeftJoin).index.isMonotonic, isTrue);
      expect(ixs1.join(ixs2, JoinType.InnerJoin).index.isMonotonic, isTrue);
      expect(ixs1.join(ixs2, JoinType.OuterJoin).index.isMonotonic, isTrue);
    });

    test("joins preserves index order no dups", () {
      var ix1 = indexTimeNoDups();
      var ix2 = indexTimeNoDups();

      var ixs1 = ix1.sorted;
      var ixs2 = ix2.sorted;

      expect(ixs1.join(ixs2, JoinType.RightJoin).index.isMonotonic, isTrue);
      expect(ixs1.join(ixs2, JoinType.LeftJoin).index.isMonotonic, isTrue);
//      expect(ixs1.join(ixs2, JoinType.InnerJoin).index.isMonotonic, isTrue);
      expect(ixs1.join(ixs2, JoinType.OuterJoin).index.isMonotonic, isTrue);
    });

    /*test("serialization works", () {
      var ix1 = indexTimeWithDups();
      var ix2 = indexTimeWithDups();

      expect(ix1, equals(serializedCopy(ix1)));
      expect(ix2, equals(serializedCopy(ix2)));
    });*/
  });
}

main() {
  group('Index', indexCheck);
}
