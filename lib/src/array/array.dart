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

import 'dart:math' show Random;

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
  Array<int> range(int from, int until, [int step = 1]) {
    val sz = math.ceil((until - from) / step.toDouble).toInt;
    var i = from;
    var k = 0;
    val arr = new Array.ofDim<int>(sz);
    while (k < sz) {
      arr[k] = i;
      k += 1;
      i += step;
    }
    arr;
  }

  /**
   * Create a new initialized empty array
   */
  List<T> empty /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (int len) =>
      new List<T>(len);

  /**
   * Return a uniform random permutation of the array
   */
  Array<T> shuffle /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
      Array<T> arr) {
    var i = 0;
    val sz = arr.length;
    val result = arr.clone();
    while (i < sz) {
      // maintains the invariant that at position i in result, all items to the left of i
      // have been randomly selected from the remaining sz - i locations
      val loc = i + math.floor((sz - i) * random.nextNonNegDouble).toInt;
      val tmp = result(i);
      result[i] = result(loc);
      result[loc] = tmp;
      i += 1;
    }
    result;
  }

  /**
   * Repeat elements of the array some number of times
   */
  Array<T> tile /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
      Array<T> arr, int n) {
    require(n >= 0, "n must not be negative");
    val sz = arr.length * n;
    val res = empty /*<T>*/ (sz);
    var i = 0;
    var j = 0;
    while (i < sz) {
      res[i] = arr(j);
      i += 1;
      j += 1;
      if (j >= n) j = 0;
    }
    res;
  }

  // *** random number generators
  /*private*/ var random = new Random();

  /**
   * Generate an array of random integers excluding 0
   */
  Array<int> randInt(int sz) {
    val arr = new Array.ofDim<int>(sz);
    var i = 0;
    while (i < sz) {
      arr[i] = random.nextInt;
      i += 1;
    }
    arr;
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
  Array<double> randDouble(int sz) {
    val arr = new Array.ofDim<double>(sz);
    var i = 0;
    while (i < sz) {
      arr[i] = random.nextDouble;
      i += 1;
    }
    arr;
  }

  /**
   * Generate an array of random positive integers excluding 0
   */
  Array<int> randIntPos(int sz) {
    val arr = new Array.ofDim<int>(sz);
    var i = 0;
    while (i < sz) {
      arr[i] = random.nextNonNegInt;
      i += 1;
    }
    arr;
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
  Array<double> randDoublePos(int sz) {
    val arr = new Array.ofDim<double>(sz);
    var i = 0;
    while (i < sz) {
      arr[i] = random.nextNonNegDouble;
      i += 1;
    }
    arr;
  }

  /**
   * Generate an array of random doubles which is normally distributed
   * with a mean of zero and stdev of one.
   */
  Array<double> randNormal(int sz) {
    val arr = new Array.ofDim<double>(sz);
    var i = 0;
    while (i < sz) {
      arr[i] = random.nextGaussian;
      i += 1;
    }
    arr;
  }

  /**
   * Generate an array of random doubles which is normally distributed
   * with a mean of mu and stdev of sigma.
   */
  Array<double> randNormal2(int sz, double mu, double sigma) {
    val arr = new Array.ofDim<double>(sz);
    var i = 0;
    while (i < sz) {
      arr[i] = mu + sigma * random.nextGaussian;
      i += 1;
    }
    arr;
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
    var res = empty /*<T>*/ (offsets.length);
    var i = 0;
    while (i < offsets.length) {
      var idx = offsets[i];
      if (idx == -1) {
        res[i] = missing;
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
  T sum /*[@spec(Boolean, Int, Long, Double) T: ST: NUM: ops.AddOp]*/ (
      Array<T> arr, Array<int> offsets, T missing()) {
    val st = implicitly[ST /*<T>*/];
    val nm = implicitly[NUM /*<T>*/];
    val op = implicitly[ops.AddOp /*<T>*/];
    var res = st.zero(nm);
    var i = 0;
    while (i < offsets.length) {
      val idx = offsets(i);
      res = (idx == -1) ? op(res, missing) : op(res, arr(idx));
      i += 1;
    }
    res;
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
  Array<T> send /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
      Array<T> arr, Array<int> offsets) {
    var res = empty /*<T>*/ (offsets.length);
    var i = 0;
    while (i < offsets.length) {
      res[offsets(i)] = arr(i);
      i += 1;
    }
    res;
  }

  /**
   * Remove values from array arr at particular offsets so as to
   * produce a new array.
   */
  Array<T> remove /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
      Array<T> arr, Array<int> locs) {
    val set = new IntOpenHashSet(locs.length);

    var i = 0;
    while (i < locs.length) {
      val loc = locs(i);
      if (loc >= 0 && loc < arr.length) set.add(loc);
      i += 1;
    }

    val len = arr.length - set.size();
    val res = empty /*<T>*/ (len);

    i = 0;
    var k = 0;
    while (i < arr.length) {
      if (!set.contains(i)) {
        res[k] = arr(i);
        k += 1;
      }
      i += 1;
    }

    res;
  }

  /**
   * Put a single value into array arr at particular offsets, so as to produce a new array.
   */
  Array<T> put /*[@spec(Boolean, Int, Long, Double) T]*/ (
      Array<T> arr, Array<int> offsets, T value) {
    val res = arr.clone();
    var i = 0;
    while (i < offsets.length) {
      val idx = offsets(i);
      res[idx] = value;
      i += 1;
    }
    res;
  }

  /**
   * Put a value into array arr at particular offsets provided by a boolean array where its locations
   * are true, so as to produce a new array.
   */
  Array<T> put2 /*[@spec(Boolean, Int, Long, Double) T]*/ (
      Array<T> arr, Array<bool> offsets, T value) {
    val res = arr.clone();
    var i = 0;
    while (i < offsets.length) {
      if (offsets(i)) res[i] = value;
      i += 1;
    }
    res;
  }

  /**
   * Put n values into array arr at particular offsets, where the values come from another array,
   * so as to produce a new array.
   */
  Array<T> putn /*[@spec(Boolean, Int, Long, Double) T]*/ (
      Array<T> arr, Array<int> offsets, Array<T> values) {
    val res = arr.clone();
    var i = 0;
    while (i < offsets.length) {
      val idx = offsets(i);
      res[idx] = values(i);
      i += 1;
    }
    res;
  }

  /**
   * Fill array with value
   */
  fill /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (Array<T> arr, T v) {
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
  Array<double> linspace(double start, double stop,
      [int _num = 50, bool endpoint = true]) {
    if (num <= 0) {
      new Array.empty<double>();
    } else if (num == 1) {
      Array(start);
    } else {
      val result = new Array.ofDim<double>(num);
      val step = (stop - start) / (num - (endpoint ? 1 : 0));

      var i = 1;
      val n = num - 1;
      result[0] = start;
      while (i < n) {
        result[i] = result(i - 1) + step;
        i += 1;
      }
      result[n] = stop;
      result;
    }
  }

  /**
   * Stable indirect sort resulting in permutation of numbers [0, n), whose application
   * on an array results in a sorted array.
   *
   * @param arr Array to sort
   */
  Array<int> argsort /*[T: ST: ORD]*/ (Array<T> arr) =>
      implicitly[ST /*<T>*/].makeSorter.argSorted(arr);

  /**
   * Stable sort of array argument (not destructive), using radix sort
   * implementation wherever possible.
   *
   * @param arr Array to sort
   */
  Array<T> sort /*[T: ST: ORD]*/ (Array<T> arr) =>
      implicitly[ST /*<T>*/].makeSorter.sorted(arr);

  /**
   * Reverse an array
   */
  Array<T> reverse /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
      Array<T> arr) {
    val end = arr.length - 1;
    val newArr = new Array<T>(end + 1);

    var i = 0;
    while (i <= end) {
      newArr[i] = arr(end - i);
      i += 1;
    }
    newArr;
  }

  /**
   * Filter an array based on a predicate function, wherever that predicate is true
   */
  Array<T> filter /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
      bool f(T arg)) /*(Array<T> arr)*/ {
    var i = 0;
    var count = 0;
    while (i < arr.length) {
      val v = arr(i);
      if (f(v)) count += 1;
      i += 1;
    }
    if (count == arr.length) {
      arr;
    } else {
      val res = empty /*<T>*/ (count);
      i = 0;
      count = 0;
      while (i < arr.length) {
        val v = arr(i);
        if (f(v)) {
          res[count] = v;
          count += 1;
        }
        i += 1;
      }
      res;
    }
  }

  /**
   * Flatten a sequence of arrays into a single array
   */
  Array<T> flatten /*[@spec(Boolean, Int, Long, Double) T: ST]*/ (
      Seq<Array<T>> arrs) {
    val size = arrs.map(_.length).sum;
    val newArr = new Array<T>(size);
    var i = 0;

    arrs.foreach((a) {
      var l = a.length;
      var j = 0;
      while (j < l) {
        newArr[i + j] = a(j);
        j += 1;
      }
      i += l;
    });

    newArr;
  }

  /**
   * Return the integer offset of the minimum element, or -1 for an empty array
   */
  int argmin /*[@spec(Int, Long, Double) T: ST: ORD: NUM]*/ (Array<T> arr) {
    val sca = implicitly[ST /*<T>*/];
    val sz = arr.length;
    if (sz == 0) {
      -1;
    } else {
//      var min, arg = (sca.isMissing(arr(0))) ? (sca.inf, -1) : (arr(0), 0);
      var i = 1;
      while (i < sz) {
        val v = arr(i);
        if (sca.notMissing(v) && sca.compare(min, v) == 1) {
          min = arr(i);
          arg = i;
        }
        i += 1;
      }
      arg;
    }
  }

  /**
   * Return the integer offset of the maximum element, or -1 for an empty array
   */
  int argmax /*[@spec(Int, Long, Double) T: ST: ORD: NUM]*/ (Array<T> arr) {
    val sca = implicitly[ST /*<T>*/];
    val sz = arr.length;
    if (sz == 0) {
      -1;
    } else {
//      var max, arg = (sca.isMissing(arr(0))) ? (sca.negInf, -1) : (arr(0), 0);
      var i = 1;
      while (i < sz) {
        val v = arr(i);
        if (sca.notMissing(v) && sca.compare(v, max) == 1) {
          max = arr(i);
          arg = i;
        }
        i += 1;
      }
      arg;
    }
  }
}
