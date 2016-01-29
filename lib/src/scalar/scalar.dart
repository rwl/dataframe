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

//import org.saddle._
//import java.util.NoSuchElementException

import 'scalar_tag.dart';

/**
 * Scalar wrapper for a single element of a vector-like container.
 *
 * @tparam T The type of element wrapped
 */
/*sealed*/ abstract class Scalar<T> {
  final ScalarTag st;
  bool get isNA;
  T get get;

  /*@inline final*/ Scalar<B> map /*[B: ST]*/ (B f(T arg)) =>
      isNA ? NA : new Value(f(this.get), st);

  /*@inline final*/ Scalar<B> flatMap /*[B]*/ (Scalar<B> f(T arg)) =>
      isNA ? NA : f(this.get);

  /*@inline final*/ void foreach /*[U]*/ (U f(T arg)) {
    if (!isNA) f(this.get);
  }
//}

//class Scalar {
  Scalar.internal(this.st);

  /** An Scalar factory which creates Value(x) when the argument is neither null nor an NA primitive;
    * otherwise produces NA.
    *
    *  @param  x the value
    *  @return Value(value) if value not null or NA primitive; otherwise NA
    *  */
  factory Scalar /*<T> apply*/ /*[T: ST]*/ (T x, ScalarTag st) {
    return (x == null || /*implicitly[ST<T>]*/ st.isMissing(x))
        ? NA
        : new Value(x, st);
  }

  /**
   * Provides comparisons of Scalars, where NA always evaluates as less than non-NA
   */
//  /*implicit*/ Ordering<Scalar<T>> ord/*[T : ORD]*/() {
////    return new ORD[Scalar<T>] {
//    int compare(Scalar<T> x, Scalar<T> y) {
//      (x, y) match {
//      case (NA, NA) =>  0
//      case (NA,  _) => -1
//      case (_,  NA) =>  1
//      case (_,   _) => implicitly[ORD<T>].compare(x.get, y.get)
//    }
//  }

  bool operator ==(o) {
    if (identical(this, NA) && identical(o, NA)) {
      return true;
    } else if (identical(this, NA) || identical(o, NA)) {
      return false;
    } else if (o is Scalar) {
      return this.get == o.get;
    } else {
      return false;
    }
  }

  int get hashCode => this.get.hashCode;

  /**
   * Provides implicit boxing of primitive to scalar
   */
  /*implicit*/ Scalar<T> scalarBox /*[T : ST]*/ (T el) => new Scalar(el, st);

  /**
   * Provides implicit unboxing from double scalar to primitive
   */
  /*implicit*/ double scalarUnboxD(Scalar<double> ds) =>
      ds.isNA ? double.NAN : ds.get;

  /**
   * Provides implicit unboxing from float scalar to primitive
   */
//  implicit def scalarUnboxF(ds: Scalar[Float]): Float = {
//    if (ds.isNA) Float.NaN else ds.get
//  }

  /**
   * Scalar is isomorphic to Option
   */
  /*implicit*/ Option<T> scalarToOption /*<T>*/ (Scalar<T> sc) =>
      sc.isNA ? null : Some(sc.get);
  /*implicit*/ Scalar<T> optionToScalar /*[T: ST]*/ (Option<T> op) =>
      op.map((a) => new Scalar(a)) ?? NA;
}

/*case*/ class Value /*[+T : ST]*/ <T> extends Scalar<T> {
  ScalarTag st;
  T el;
  Value(this.el, ScalarTag st_)
      : st = st_,
        super.internal(st_);
  bool get isNA => /*implicitly [ST<T>]*/ st.isMissing(el);
  T get get => el;

  @override
  toString() => el.toString();
}

final _NA NA = new _NA();

/*case object*/ class _NA extends Scalar {
  _NA() : super.internal(null);

  bool get isNA => true;
  dynamic get get => throw new NoSuchElementException("NA.get");

  @override
  String toString() => "NA";
}
