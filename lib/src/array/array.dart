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

library saddle.array;

//import scala.{ specialized => spec }
//import util.Random
//import it.unimi.dsi.fastutil.ints.IntOpenHashSet

//import 'dart:math' show Random;

import '../scalar/scalar_tag.dart';

final _array array = new _array();

/**
 * This package contains utilities for working with arrays that
 * are specialized for numeric types.
 */
class _array {
  /**
   * Create a new array consisting of a range of numbers from a lower bound up to, but
   * not including, an upper bound, at a particular increment (default 1)
   */
  List<int> range(int from, int until, [int step = 1]) {
    var sz = ((until - from) / step.toDouble()).ceil();
    var i = from;
    var k = 0;
    var arr = new List<int>(sz);
    while (k < sz) {
      arr[k] = i;
      k += 1;
      i += step;
    }
    return arr;
  }

  /**
   * Create a new initialized empty array
   */
  List /*<T>*/ empty /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
          int len, ScalarTag st) =>
      new List.generate(len, (i) => st.zero());

  /**
   * Return a uniform random permutation of the array
   */
  List shuffle /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (List arr) {
    var i = 0;
    var sz = arr.length;
    var result = new List.from(arr);
    while (i < sz) {
      // maintains the invariant that at position i in result, all items to the left of i
      // have been randomly selected from the remaining sz - i locations
      var loc = i + ((sz - i) * random.nextNonNegDouble).floor();
      var tmp = result(i);
      result[i] = result(loc);
      result[loc] = tmp;
      i += 1;
    }
    return result;
  }

  /**
   * Repeat elements of the array some number of times
   */
  List tile /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (List arr, int n) {
    if (n < 0) {
      throw new ArgumentError("n must not be negative");
    }
    var sz = arr.length * n;
    var res = new List(sz);
    var i = 0;
    var j = 0;
    while (i < sz) {
      res[i] = arr[j];
      i += 1;
      j += 1;
      if (j >= n) {
        j = 0;
      }
    }
    return res;
  }

  // *** random number generators
  /*private*/ var random; // = new Random();

  /**
   * Generate an array of random integers excluding 0
   */
  List<int> randInt(int sz) {
    var arr = new List<int>(sz);
    var i = 0;
    while (i < sz) {
      arr[i] = random.nextInt();
      i += 1;
    }
    return arr;
  }

  /**
   * Generate an array of a random long integers excluding 0
   */
//  def randLong(sz: Int): Array[Long] = {
//    val arr = Array.ofDim[Long](sz)
//    var i = 0
//    while(i < sz) {
//      arr(i) = random.nextLong
//      i += 1
//    }
//    arr
//  }

  /**
   * Generate an array of random doubles on [-1, 1] excluding 0
   */
  List<double> randDouble(int sz) {
    var arr = new List<double>(sz);
    var i = 0;
    while (i < sz) {
      arr[i] = random.nextDouble();
      i += 1;
    }
    return arr;
  }

  /**
   * Generate an array of random positive integers excluding 0
   */
  List<int> randIntPos(int sz) {
    var arr = new List<int>(sz);
    var i = 0;
    while (i < sz) {
      arr[i] = random.nextNonNegInt();
      i += 1;
    }
    return arr;
  }

  /**
   * Generate an array of random long positive integers excluding 0
   */
//  def randLongPos(sz: Int): Array[Long] = {
//    val arr = Array.ofDim[Long](sz)
//    var i = 0
//    while(i < sz) {
//      arr(i) = random.nextNonNegLong
//      i += 1
//    }
//    arr
//  }

  /**
   * Generate an array of random positive doubles on (0, 1]
   */
  List<double> randDoublePos(int sz) {
    var arr = new List<double>(sz);
    var i = 0;
    while (i < sz) {
      arr[i] = random.nextNonNegDouble();
      i += 1;
    }
    return arr;
  }

  /**
   * Generate an array of random doubles which is normally distributed
   * with a mean of zero and stdev of one.
   */
  List<double> randNormal(int sz) {
    var arr = new List<double>(sz);
    var i = 0;
    while (i < sz) {
      arr[i] = random.nextGaussian();
      i += 1;
    }
    return arr;
  }

  /**
   * Generate an array of random doubles which is normally distributed
   * with a mean of mu and stdev of sigma.
   */
  List<double> randNormal2(int sz, double mu, double sigma) {
    var arr = new List<double>(sz);
    var i = 0;
    while (i < sz) {
      arr[i] = mu + sigma * random.nextGaussian();
      i += 1;
    }
    return arr;
  }

  /**
   * Takes values from array arr at particular offsets so as to produce a new array.
   * Offset -1 is mapped to by-name parameter `missing`.
   *
   * Note that each integer I at offset O in `offsets` works to "take" input[I] to
   * output[O]. Eg, Array(2,0,1) permutes locations as follows:
   *
   *  - 2 to 0
   *  - 0 to 1
   *  - 1 to 2
   *
   * For example,
   *
   * {{{
   *   take(Array(5,6,7), Array(2,0,1), -1) == Array(7,5,6)
   * }}}
   */
  List take /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
      List arr, List<int> offsets, /*T*/ missing()) {
    var res = new List /*<T>*/ (offsets.length);
    var i = 0;
    while (i < offsets.length) {
      var idx = offsets[i];
      if (idx == -1) {
        res[i] = missing();
      } else {
        res[i] = arr[idx];
      }
      i += 1;
    }
    return res;
  }

  /**
   * Compute the sum of the array at particular offets. If any of the offets is -1,
   * the pass-by-name value 'missing' is used instead.
   *
   * For example,
   *
   * {{{
   *   sum(Array(1,2,3,4), Array(0,2,), 0)
   * }}}
   */
  dynamic sum /*[@spec(Boolean, Int, Long, Double) T: ST: NUM: ops.AddOp]*/ (
      List arr, List<int> offsets, ScalarTag st) {
//    val st = implicitly[ST /*<T>*/];
//    val nm = implicitly[NUM /*<T>*/];
//    val op = implicitly[ops.AddOp /*<T>*/];
    var res = st.zero(/*nm*/);
    var i = 0;
    while (i < offsets.length) {
      var idx = offsets[i];
      res = (idx == -1) ? res + st.missing() : res + arr[idx];
      i += 1;
    }
    return res;
  }

  /**
   * Sends values from an array to particular offsets so as to produce a new array.
   * This does the inverse of 'take'; ie, each integer I at offset O in `offsets`
   * works to "send" input[O] to output[I]. Eg, Array(2,0,1) permutes locations as
   * follows:
   *
   *   - 0 to 2
   *   - 1 to 0
   *   - 2 to 1
   *
   * For example,
   *
   * {{{
   *   send(Array(5,6,7), Array(2,0,1)) == Array(6,7,5)
   * }}}
   */
  List send /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
      List arr, List<int> offsets) {
    var res = new List /*<T>*/ (offsets.length);
    var i = 0;
    while (i < offsets.length) {
      res[offsets[i]] = arr[i];
      i += 1;
    }
    return res;
  }

  /**
   * Remove values from array arr at particular offsets so as to
   * produce a new array.
   */
  List remove /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
      List arr, List<int> locs) {
    var set = new /*IntOpenHash*/ Set(); //locs.length);

    var i = 0;
    while (i < locs.length) {
      var loc = locs[i];
      if (loc >= 0 && loc < arr.length) {
        set.add(loc);
      }
      i += 1;
    }

    var len = arr.length - set.length;
    var res = new List(len); //empty /*<T>*/ (len);

    i = 0;
    var k = 0;
    while (i < arr.length) {
      if (!set.contains(i)) {
        res[k] = arr[i];
        k += 1;
      }
      i += 1;
    }

    return res;
  }

  /**
   * Put a single value into array arr at particular offsets, so as to produce a new array.
   */
  List put /*[@spec(Boolean, Int, Long, Double) T]*/ (
      List arr, List<int> offsets, value) {
    var res = new List.from(arr);
    var i = 0;
    while (i < offsets.length) {
      var idx = offsets[i];
      res[idx] = value;
      i += 1;
    }
    return res;
  }

  /**
   * Put a value into array arr at particular offsets provided by a boolean array where its locations
   * are true, so as to produce a new array.
   */
  List put2 /*[@spec(Boolean, Int, Long, Double) T]*/ (
      List arr, List<bool> offsets, value) {
    var res = new List.from(arr);
    var i = 0;
    while (i < offsets.length) {
      if (offsets[i]) {
        res[i] = value;
      }
      i += 1;
    }
    return res;
  }

  /**
   * Put n values into array arr at particular offsets, where the values come from another array,
   * so as to produce a new array.
   */
  List putn /*[@spec(Boolean, Int, Long, Double) T]*/ (
      List arr, List<int> offsets, List values) {
    var res = new List.from(arr);
    var i = 0;
    while (i < offsets.length) {
      var idx = offsets[i];
      res[idx] = values[i];
      i += 1;
    }
    return res;
  }

  /**
   * Fill array with value
   */
  void fill /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (List arr, v) {
    var i = 0;
    while (i < arr.length) {
      arr[i] = v;
      i += 1;
    }
  }

  /**
   * Derived from numpy 1.7
   *
   * Return evenly spaced numbers over a specified interval.
   *
   * Returns num evenly spaced samples, calculated over the
   * interval [start, stop].
   *
   * The endpoint of the interval can optionally be excluded.
   */
  List<double> linspace(double start, double stop,
      [int _num = 50, bool endpoint = true]) {
    if (_num <= 0) {
      return [];
    } else if (_num == 1) {
      return [start];
    } else {
      var result = new List<double>(_num);
      var step = (stop - start) / (_num - (endpoint ? 1 : 0));

      var i = 1;
      var n = _num - 1;
      result[0] = start;
      while (i < n) {
        result[i] = result(i - 1) + step;
        i += 1;
      }
      result[n] = stop;
      return result;
    }
  }

  /**
   * Stable indirect sort resulting in permutation of numbers [0, n), whose application
   * on an array results in a sorted array.
   *
   * @param arr Array to sort
   */
  List<int> argsort /*[T: ST: ORD]*/ (List arr, ScalarTag st) =>
      st.makeSorter().argSorted(arr);

  /**
   * Stable sort of array argument (not destructive), using radix sort
   * implementation wherever possible.
   *
   * @param arr Array to sort
   */
  List sort /*[T: ST: ORD]*/ (List arr, ScalarTag st) =>
      st.makeSorter().sorted(arr);

  /**
   * Reverse an array
   */
  List reverse /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (List arr) {
    var end = arr.length - 1;
    var newArr = new List(end + 1);

    var i = 0;
    while (i <= end) {
      newArr[i] = arr[end - i];
      i += 1;
    }
    return newArr;
  }

  /**
   * Filter an array based on a predicate function, wherever that predicate is true
   */
  List filter /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
      bool f(arg), List arr) /*(Array<T> arr)*/ {
    var i = 0;
    var count = 0;
    while (i < arr.length) {
      var v = arr[i];
      if (f(v)) count += 1;
      i += 1;
    }
    if (count == arr.length) {
      return arr;
    } else {
      var res = /*empty <T>*/ new List(count);
      i = 0;
      count = 0;
      while (i < arr.length) {
        var v = arr[i];
        if (f(v)) {
          res[count] = v;
          count += 1;
        }
        i += 1;
      }
      return res;
    }
  }

  /**
   * Flatten a sequence of arrays into a single array
   */
  List flatten /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
      Iterable<List> arrs) {
    var size = arrs.map((a) => a.length).reduce((a, b) => a + b);
    var newArr = new List(size);
    var i = 0;

    arrs.forEach((List a) {
      var l = a.length;
      var j = 0;
      while (j < l) {
        newArr[i + j] = a[j];
        j += 1;
      }
      i += l;
    });

    return newArr;
  }

  /**
   * Return the integer offset of the minimum element, or -1 for an empty array
   */
  int argmin /*[@spec(Int, Long, Double) T: ST: ORD: NUM]*/ (
      List arr, ScalarTag sca) {
//    var sca = implicitly[ST /*<T>*/];
    var sz = arr.length;
    if (sz == 0) {
      return -1;
    } else {
      var min = sca.isMissing(arr[0]) ? sca.inf() : arr[0];
      var arg = sca.isMissing(arr[0]) ? -1 : 0;
      var i = 1;
      while (i < sz) {
        var v = arr[i];
        if (sca.notMissing(v) && sca.compare(min, v) == 1) {
          min = arr[i];
          arg = i;
        }
        i += 1;
      }
      return arg;
    }
  }

  /**
   * Return the integer offset of the maximum element, or -1 for an empty array
   */
  int argmax /*[@spec(Int, Long, Double) T: ST: ORD: NUM]*/ (
      List arr, ScalarTag sca) {
//    val sca = implicitly[ST /*<T>*/];
    var sz = arr.length;
    if (sz == 0) {
      return -1;
    } else {
      var max = sca.isMissing(arr[0]) ? sca.negInf() : arr[0];
      var arg = sca.isMissing(arr[0]) ? -1 : 0;
      var i = 1;
      while (i < sz) {
        var v = arr[i];
        if (sca.notMissing(v) && sca.compare(v, max) == 1) {
          max = arr[i];
          arg = i;
        }
        i += 1;
      }
      return arg;
    }
  }
}
