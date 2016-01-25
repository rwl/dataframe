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

//import annotation.tailrec
//import java.io.InputStream
//import org.saddle.vec

import 'dart:math' as math;
import 'util.dart';

/**
 * The Random class provides methods to generate pseudo-random numbers via a plug-in
 * PRNG, which is simply any function that generates a Long primitive.
 */
class Random {
  Function rng64;
  Random.rng(int rng()) : rng64 = rng;
  /**
   * Generate a new integer (taking the 32 low order bits of the
   * 64 bit state)
   */
  int nextInt() => rng64();

  /**
   * Generate a new long
   */
//  def nextLong: Long = rng64()

  /**
   * Generate a new float
   */
//  def nextFloat: Float = nextInt.asInstanceOf[Float] / Int.MaxValue

  /**
   * Generate a new double
   */
  double nextDouble() => nextInt().toDouble() / MAX_INT;

  /**
   * Generate a new non-negative integer
   */
  /*@tailrec final def*/
  int nextNonNegInt() {
    var tmp = nextInt();
    return tmp >= 0 ? tmp : nextNonNegInt();
  }

  /**
   * Generate a new non-negative long
   */
//  @tailrec final def nextNonNegLong: Long = {
//    val tmp = nextLong
//    if (tmp >= 0) tmp else nextNonNegLong
//  }

  /**
   * Generate a new non-negative float
   */
//  @tailrec final def nextNonNegFloat: Float = {
//    val tmp = nextFloat
//    if (tmp >= 0) tmp else nextNonNegFloat
//  }

  /**
   * Generate a new non-negative double
   */
  /*@tailrec final def*/
  double nextNonNegDouble() {
    var tmp = nextDouble();
    return tmp >= 0 ? tmp : nextNonNegDouble();
  }

  /*private*/ var next = double.NAN;

  /**
   * Generate a new Gaussian (normally distributed) number
   *
   * This is based on Apache Commons Math's nextGaussian, which in turn is based
   * on the Polar Method of Box, Muller, & Marsiglia as described in Knuth 3.4.1C
   */
  /*@tailrec final def*/
  double nextGaussian() {
    if (next == next) {
      var tmp = next;
      next = double.NAN;
      return tmp;
    } else {
      var u1 = 2.0 * nextDouble() - 1.0;
      var u2 = 2.0 * nextDouble() - 1.0;
      var s = u1 * u1 + u2 * u2;

      if (s >= 1) {
        return nextGaussian();
      } else {
        var bm = (s != 0) ? (math.sqrt(-2.0 * math.log(s) / s)) : s;
        next = u1 * bm;
        return u2 * bm;
      }
    }
  }
//}
//
//object Random {
  /**
   * Create Random instance
   */
//  Random() = new Random(XorShift(new java.util.Random().nextLong))

  /**
   * Create Random instance from provided seed
   */
  factory Random([int seed]) {
    if (seed != null) {
      return new Random.rng(
          new XorShift(new math.Random(seed).nextInt(MAX_INT)));
    } else {
      return new Random.rng(new XorShift(new math.Random().nextInt(MAX_INT)));
    }
  }

  /**
   * Create Random instance from custom RNG function
   */
//  Random.rng(rng: () => Long) = new Random(rng)
}

abstract class Rng {
  Function _rng;

  int call() => _rng();

  Rng([int seed]) {
    if (seed != null) {
      _rng = _makeRNG(seed);
    } else {
      _rng = new Random().nextInt;
    }
  }

  Function _makeRNG(int seed);
}

/**
 * Marsaglia XorShift PRNG
 *
 * See [[http://www.jstatsoft.org/v08/i14/ Marsaglia]]
 */
class XorShift extends Rng {
  XorShift([int seed]) : super(seed);

  Function _makeRNG(int seed) {
    return () {
      seed ^= (seed << 13);
      seed ^= (seed >> 7);
      seed ^= (seed << 17);
      return seed;
    };
  }
}

/**
 * Marsaglia Lagged Fibonacci PRNG
 *
 * See [[https://groups.google.com/forum/?fromgroups=#!msg/sci.crypt/yoaCpGWKEk0/UXCxgufdTesJ]]
 */
class LFib4 extends Rng {
  LFib4([int seed]) : super(seed);

  Function _makeRNG([int seed]) {
    var jrand = new math.Random(seed);
    // 2K of memory
    List state = new List<int>.generate(256, (_) => jrand.nextInt(MAX_INT));
    var c = 0;

    return () {
      c += 1;
      c &= 0xFF;
      state[c] = state[c] +
          state[(c + 58) & 0xFF] +
          state[(c + 119) & 0xFF] +
          state[(c + 178) & 0xFF];
      return state[c];
    };
  }
}

/**
 * Ziff 4-tap shift-register-sequence
 *
 * http://arxiv.org/pdf/cond-mat/9710104v1.pdf
 * http://www.aip.org/cip/pdf/vol_12/iss_4/385_1.pdf
 */
class Ziff98 extends Rng {
  Ziff98([int seed]) : super(seed);

  Function _makeRNG(int seed) {
    const int a = 471, b = 1586, c = 6988, d = 9689, m = 16383;

    var jrand = new math.Random(seed);
    // 128K of memory
    var state = new List<int>.generate(m + 1, (_) => jrand.nextInt(MAX_INT));

    var nd = 0;
    return () {
      nd += 1;
      var a1 = nd & m;
      var b1 = (nd - a) & m;
      var c1 = (nd - b) & m;
      var d1 = (nd - c) & m;
      var e1 = (nd - d) & m;
      state[a1] = state[b1] ^ state[c1] ^ state[d1] ^ state[e1];
      return state(a1);
    };
  }
}

/**
 * Create a random InputStream of bytes from a PRNG. Useful for testing, e.g.,
 * for feeding into dieharder battery of tests via stdin.
 */
//case class RandomStream(rng: () => Long) extends InputStream {
//  var c = 0
//  var r = rng()
//
//  def read(): Int = {
//    c += 1
//    val byte = c match {
//      case 1 => r
//      case 2 => r >>> 8
//      case 3 => r >>> 16
//      case 4 => r >>> 24
//      case 5 => r >>> 32
//      case 6 => r >>> 40
//      case 7 => r >>> 48
//      case 8 => c = 0; val tmp = (r >>> 56); r = rng(); tmp
//    }
//    (byte & 0xFF).asInstanceOf[Int]
//  }
//}
