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

library saddle.scalar;

//import scala.{ specialized => spec }
//import org.saddle._
//import org.saddle.locator.Locator
//import org.saddle.array.Sorter

import '../buffer.dart';
import '../locator/locator.dart';
import '../index.dart';
import '../vec.dart';
import '../mat.dart';

import 'scalar_tag_int.dart' as st_int;

/**
 * Typeclass definition for scalar tags. A ScalarTag contains important meta-data regarding
 * a scalar type, including how to instantiate a Buffer/Vec/Mat/Index of that type, as well
 * as an array. Often implicitly required when dealing with objects in Saddle
 */
abstract class ScalarTag<T> /*[@spec(Boolean, Int, Long, Float, Double) T]*/
    extends /*ClassManifest<T>*/ Object
    with
        SpecializedFactory<T>,
        CouldBeOrdered<T>,
        CouldBeNumber<T>,
        ScalarHelperOps<T> /*with Serializable*/ {
  // representation of missing data
  T missing();
  bool isMissing(T t);
  bool notMissing(T t);

  bool isTuple = false;
  bool isDouble = false;

//  def strList = (v: T) => List(show(v))

  String show(T v);

  // Workaround: Scala types Any, AnyRef, AnyVal all have runtimeClass java.lang.Object; workaround continues
  // via ScalarTag implicit resolution hierarchy below.
  var isAny = false;
  var isAnyVal = false;

  @override
  int get hashCode {
    isAny.hashCode() +
        isAnyVal.hashCode() * 31 +
        runtimeClass.hashCode() * 31 * 31;
  }

  @override
  bool equals(o) {
//    o match {
//    case s: ScalarTag[_] => (this eq s) || runtimeClass == s.runtimeClass && isAny == s.isAny && isAnyVal == s.isAnyVal
//    case _               => false
//    }
  }

  @override
  toString() => "ScalarTag[%s]".format(runtimeClass);

  @override
  erasure() => runtimeClass;

  // forward 2.10 compatibility
//  def runtimeClass: Class[_]
//}

//object ScalarTag extends ScalarTagImplicits {
//  /*implicit*/ static final ScalarTag stChar = ScalarTagChar;
//  /*implicit*/ static final ScalarTag stByte = ScalarTagByte;
  /*implicit*/ static final ScalarTag stBool = ScalarTagBool;
//  /*implicit*/ static final ScalarTag stShort = ScalarTagShort;
  /*implicit*/ static final ScalarTag stInt = st_int.ScalarTagInt;
//  /*implicit*/ static final ScalarTag stFloat = ScalarTagFloat;
//  /*implicit*/ static final ScalarTag stLong = ScalarTagLong;
  /*implicit*/ static final ScalarTag stDouble = ScalarTagDouble;
  /*implicit*/ static final ScalarTag stTime = ScalarTagTime;
}

/*abstract class ScalarTagImplicits extends ScalarTagImplicitsL1 {
  implicit def stPrd[T <: Product : CLM] = new ScalarTagProduct<T>
}

abstract class ScalarTagImplicitsL1 extends ScalarTagImplicitsL2 {
  implicit def stAnyVal[T <: AnyVal : CLM] = new ScalarTagAny<T> { override def isAnyVal = true }
}

abstract class ScalarTagImplicitsL2 extends ScalarTagImplicitsL3 {
  implicit def stAnyRef[T <: AnyRef : CLM] = new ScalarTagAny<T>
}

abstract class ScalarTagImplicitsL3 {
  implicit def stAny[T : CLM] = new ScalarTagAny<T> { override def isAny = true }
}*/

abstract class CouldBeOrdered<
    T> /*[@spec(Boolean, Int, Long, Float, Double) T]*/ {
  // for comparable scalars
  int compare(T a, T b) /*(implicit ev: ORD<T>)*/;
  bool lt(T a, T b) /*(implicit ev: ORD<T>)*/ => compare(a, b) < 0;
  bool gt(T a, T b) /*(implicit ev: ORD<T>)*/ => compare(a, b) > 0;
  bool iseq(T a, T b) /*(implicit ev: ORD<T>)*/ => compare(a, b) == 0;
}

abstract class ScalarHelperOps<
    T> /*[@spec(Boolean, Int, Long, Float, Double) T]*/ {
  /**
   * Offer a type-specific way to concat vecs
   */
  Vec<T> concat(List<Vec<T>> vecs);
}

abstract class CouldBeNumber<
    T> /*[@spec(Boolean, Int, Long, Float, Double) T]*/ {
  // for numeric scalars
  double toDouble(T t) /*(implicit ev: NUM<T>)*/;
  bool get isDouble;

  T zero(/*implicit*/ Numeric<T> ev);
  T one(/*implicit*/ Numeric<T> ev);
  T inf(/*implicit*/ Numeric<T> ev);
  T negInf(/*implicit*/ Numeric<T> ev);
}

abstract class SpecializedFactory<
    T> /*[@spec(Boolean, Int, Long, Float, Double) T]*/ {
  Buffer<T> makeBuf([int sz = Buffer.INIT_CAPACITY]);
  Locator<T> makeLoc([int sz = Buffer.INIT_CAPACITY]);
  Vec<T> makeVec(List<T> arr);
  Mat<T> makeMat(int r, int c, List<T> arr);
  Index<T> makeIndex(Vec<T> vec) /*(implicit ord: ORD<T>)*/;
  Sorter<T> makeSorter(/*implicit*/ Ordering<T> ord);

  /**
   * An alternative Mat factory method using array of Vecs
   */
//  /*final*/ Mat<T> makeMat(List<Vec<T>> arr) /*(implicit st: ST<T>)*/ {
//    val c = arr.length;
//    if (c == 0) {
//      st.makeMat(0, 0, st.newArray(0));
//    } else {
//      val r = arr(0).length;
//      if (r == 0) {
//        st.makeMat(0, 0, st.newArray(0));
//      } else {
//        require(arr.foldLeft(true)(_ && _.length == r),
//            "All vec inputs must have the same length");
//        altMatConstructor(r, c, arr);
//      }
//    }
//  }

  /**
   * Can override this default construction methodology to avoid the toArray call if you
   * don't want to extract elements that way.
   */
  /*protected*/ Mat<T> altMatConstructor(
          int r, int c, List<Vec<T>> arr) /*(implicit st: ST<T>)*/ =>
      makeMat(c, r, st.concat(arr).toArray).T;
}
