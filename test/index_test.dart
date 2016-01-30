library saddle.test;

//import org.specs2.mutable.Specification

import 'package:test/test.dart';
import 'package:dataframe/dataframe.dart';

/**
 * User: Adam Klein
 * Date: 2/19/13
 * Time: 7:17 PM
 */
indexTest() {
  group("Index Joins", () {
    ScalarTag st = ScalarTag.stInt;
    test("Unique sorted left join", () {
      var ix1 = new Index([0, 1, 2], st);
      var ix2 = new Index([1, 2, 3], st);

      var res = ix1.join(ix2, JoinType.LeftJoin);

      expect(res.index, equals(new Index([0, 1, 2], st)));
      expect(res.lTake, isNull);
      expect(res.rTake /*.get*/, equals([-1, 0, 1]));
    });

    test("Unique sorted right join", () {
      var ix1 = new Index([0, 1, 2], st);
      var ix2 = new Index([1, 2, 3], st);

      var res = ix1.join(ix2, JoinType.RightJoin);

      expect(res.index, equals(new Index([1, 2, 3], st)));
      expect(res.lTake /*.get*/, equals([1, 2, -1]));
      expect(res.rTake, isNull);
    });

    test("Unique sorted inner join", () {
      var ix1 = new Index([0, 1, 2], st);
      var ix2 = new Index([1, 2, 3], st);

      var res = ix1.join(ix2, JoinType.InnerJoin);

      expect(res.index, equals(new Index([1, 2], st)));
      expect(res.lTake /*.get*/, equals([1, 2]));
      expect(res.rTake /*.get*/, equals([0, 1]));
    });

    test("Unique sorted outer join", () {
      var ix1 = new Index([0, 1, 2], st);
      var ix2 = new Index([1, 2, 3], st);

      var res = ix1.join(ix2, JoinType.OuterJoin);

      expect(res.index, equals(new Index([0, 1, 2, 3], st)));
      expect(res.lTake /*.get*/, equals([0, 1, 2, -1]));
      expect(res.rTake /*.get*/, equals([-1, 0, 1, 2]));
    });

    test("Unique unsorted left join", () {
      var ix1 = new Index([1, 0, 2], st);
      var ix2 = new Index([2, 3, 1], st);

      var res = ix1.join(ix2, JoinType.LeftJoin);

      expect(res.index, equals(new Index([1, 0, 2], st)));
      expect(res.lTake, isNull);
      expect(res.rTake /*.get*/, equals([2, -1, 0]));
    });

    test("Unique unsorted right join", () {
      var ix1 = new Index([1, 0, 2], st);
      var ix2 = new Index([2, 1, 3], st);

      var res = ix1.join(ix2, JoinType.RightJoin);

      expect(res.index, equals(new Index([2, 1, 3], st)));
      expect(res.lTake /*.get*/, equals([2, 0, -1]));
      expect(res.rTake, isNull);
    });

    test("Unique unsorted inner join", () {
      var ix1 = new Index([1, 0, 2], st);
      var ix2 = new Index([2, 1, 3], st);

      var res = ix1.join(ix2, JoinType.InnerJoin);

      expect(res.index, equals(new Index([1, 2], st)));
      expect(res.lTake /*.get*/, equals([0, 2]));
      expect(res.rTake /*.get*/, equals([1, 0]));
    });

    test("Unique unsorted outer join", () {
      var ix1 = new Index([1, 0, 2], st);
      var ix2 = new Index([2, 1, 3], st);

      var res = ix1.join(ix2, JoinType.OuterJoin);

      expect(res.index, equals(new Index([1, 0, 2, 3], st)));
      expect(res.lTake /*get*/, equals([0, 1, 2, -1]));
      expect(res.rTake /*get*/, equals([1, -1, 0, 2]));
    });

    test("Non-unique sorted left join", () {
      var ix1 = new Index([0, 1, 1, 2], st);
      var ix2 = new Index([1, 2, 2, 3], st);

      var res = ix1.join(ix2, JoinType.LeftJoin);

      expect(res.index, equals(new Index([0, 1, 1, 2, 2], st)));
      expect(res.lTake /*get*/, equals([0, 1, 2, 3, 3]));
      expect(res.rTake /*get*/, equals([-1, 0, 0, 1, 2]));
    });

    test("Non-unique sorted left join [case 2]", () {
      var ix1 = new Index([0, 1, 1, 2], st);
      var ix2 = new Index([1], st);

      var res1 = ix1.join(ix2, JoinType.LeftJoin);

      expect(res1.index, equals(new Index([0, 1, 1, 2], st)));
      expect(res1.lTake, isNull);
      expect(res1.rTake /*get*/, equals([-1, 0, 0, -1]));

      var res2 = ix2.join(ix1, JoinType.LeftJoin);

      expect(res2.index, equals(new Index([1, 1], st)));
      expect(res2.lTake /*get*/, equals([0, 0]));
      expect(res2.rTake /*get*/, equals([1, 2]));
    });

    test("Non-unique sorted left join [case 3]", () {
      var ix1 = new Index([0, 1, 1, 2, 2], st);
      var ix2 = new Index([1, 2, 2, 3], st);

      var res = ix1.join(ix2, JoinType.LeftJoin);

      expect(res.index, equals(new Index([0, 1, 1, 2, 2, 2, 2], st)));
      expect(res.lTake /*get*/, equals([0, 1, 2, 3, 3, 4, 4]));
      expect(res.rTake /*get*/, equals([-1, 0, 0, 1, 2, 1, 2]));
    });

    test("Non-unique sorted right join", () {
      var ix1 = new Index([0, 1, 1, 2], st);
      var ix2 = new Index([1, 2, 2, 3], st);

      var res = ix1.join(ix2, JoinType.RightJoin);

      expect(res.index, equals(new Index([1, 1, 2, 2, 3], st)));
      expect(res.lTake /*get*/, equals([1, 2, 3, 3, -1]));
      expect(res.rTake /*get*/, equals([0, 0, 1, 2, 3]));
    });

    test("Non-unique sorted inner join", () {
      var ix1 = new Index([0, 1, 1, 2], st);
      var ix2 = new Index([1, 2, 2, 3], st);

      var res = ix1.join(ix2, JoinType.InnerJoin);

      expect(res.index, equals(new Index([1, 1, 2, 2], st)));
      expect(res.lTake /*get*/, equals([1, 2, 3, 3]));
      expect(res.rTake /*get*/, equals([0, 0, 1, 2]));
    });

    test("Non-unique sorted inner join [case 2]", () {
      var ix1 = new Index([1, 1, 3, 4], st);
      var ix2 = new Index([1], st);

      var res1 = ix1.join(ix2, JoinType.InnerJoin);

      expect(res1.index, equals(new Index([1, 1], st)));
      expect(res1.lTake /*get*/, equals([0, 1]));
      expect(res1.rTake /*get*/, equals([0, 0]));

      var res2 = ix2.join(ix1, JoinType.InnerJoin);

      expect(res2.index, equals(new Index([1, 1], st)));
      expect(res2.lTake /*get*/, equals([0, 0]));
      expect(res2.rTake /*get*/, equals([0, 1]));
    });

    test("Non-unique sorted inner join [case 3]", () {
      var ix1 = new Index([0, 1, 1, 2, 2], st);
      var ix2 = new Index([1, 2, 2, 3], st);

      var res = ix1.join(ix2, JoinType.InnerJoin);

      expect(res.index, equals(new Index([1, 1, 2, 2, 2, 2], st)));
      expect(res.lTake /*get*/, equals([1, 2, 3, 3, 4, 4]));
      expect(res.rTake /*get*/, equals([0, 0, 1, 2, 1, 2]));
    });

    test("Non-unique sorted outer join", () {
      var ix1 = new Index([0, 1, 1, 2], st);
      var ix2 = new Index([1, 2, 2, 3], st);

      var res = ix1.join(ix2, JoinType.OuterJoin);

      expect(res.index, equals(new Index([0, 1, 1, 2, 2, 3], st)));
      expect(res.lTake /*get*/, equals([0, 1, 2, 3, 3, -1]));
      expect(res.rTake /*get*/, equals([-1, 0, 0, 1, 2, 3]));
    });

    test("Non-unique sorted outer join [case 2]", () {
      var ix1 = new Index([0, 1, 1, 2], st);
      var ix2 = new Index([1], st);

      var res1 = ix1.join(ix2, JoinType.OuterJoin);

      expect(res1.index, equals(new Index([0, 1, 1, 2], st)));
      expect(res1.lTake /*get*/, equals([0, 1, 2, 3]));
      expect(res1.rTake /*get*/, equals([-1, 0, 0, -1]));

      var res2 = ix2.join(ix1, JoinType.OuterJoin);

      expect(res2.index, equals(new Index([0, 1, 1, 2], st)));
      expect(res2.lTake /*get*/, equals([-1, 0, 0, -1]));
      expect(res2.rTake /*get*/, equals([0, 1, 2, 3]));
    });

    test("Non-unique unsorted left join", () {
      var ix1 = new Index([1, 1, 2, 0], st);
      var ix2 = new Index([1, 3, 2, 2], st);

      var res = ix1.join(ix2, JoinType.LeftJoin);

      expect(res.index, equals(new Index([1, 1, 2, 2, 0], st)));
      expect(res.lTake /*get*/, equals([0, 1, 2, 2, 3]));
      expect(res.rTake /*get*/, equals([0, 0, 2, 3, -1]));
    });

    test("Non-unique unsorted left join [case 2]", () {
      var ix1 = new Index([1, 1, 2, 2, 0], st);
      var ix2 = new Index([1, 3, 2, 2], st);

      var res = ix1.join(ix2, JoinType.LeftJoin);

      expect(res.index, equals(new Index([1, 1, 2, 2, 2, 2, 0], st)));
      expect(res.lTake /*get*/, equals([0, 1, 2, 2, 3, 3, 4]));
      expect(res.rTake /*get*/, equals([0, 0, 2, 3, 2, 3, -1]));
    });

    test("Non-unique unsorted right join", () {
      var ix1 = new Index([1, 1, 2, 0], st);
      var ix2 = new Index([1, 3, 2, 2], st);

      var res = ix1.join(ix2, JoinType.RightJoin);

      expect(res.index, equals(new Index([1, 1, 3, 2, 2], st)));
      expect(res.lTake /*get*/, equals([0, 1, -1, 2, 2]));
      expect(res.rTake /*get*/, equals([0, 0, 1, 2, 3]));
    });

    test("Non-unique unsorted inner join", () {
      var ix1 = new Index([1, 1, 2, 0], st);
      var ix2 = new Index([1, 3, 2, 2], st);

      var res = ix1.join(ix2, JoinType.InnerJoin);

      expect(res.index, equals(new Index([1, 1, 2, 2], st)));
      expect(res.lTake /*get*/, equals([0, 1, 2, 2]));
      expect(res.rTake /*get*/, equals([0, 0, 2, 3]));
    });

    test("Non-unique unsorted outer join", () {
      var ix1 = new Index([1, 1, 2, 0], st);
      var ix2 = new Index([1, 3, 2, 2], st);

      var res = ix1.join(ix2, JoinType.OuterJoin);

      expect(res.index, equals(new Index([1, 1, 2, 2, 0, 3], st)));
      expect(res.lTake /*get*/, equals([0, 1, 2, 2, 3, -1]));
      expect(res.rTake /*get*/, equals([0, 0, 2, 3, -1, 1]));
    });
  });
}

main() {
  indexTest();
}
