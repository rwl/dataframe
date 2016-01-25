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

library saddle.stats;

//import scala.{specialized => spec}
//import org.saddle._
//import org.saddle.vec._
//import org.saddle.scalar._

import 'dart:math' as math;
import 'dart:typed_data';

import '../array/array.dart';
import '../vec.dart';
import '../vec/vec_double.dart';
import '../scalar/scalar_tag_double.dart';
import '../scalar/scalar_tag_int.dart';

/**
 * Trait which specifies how to break a rank tie
 */
//sealed trait RankTie

enum RankTie {
  /**
   * Take the average of the ranks for all ties
   *
   * {{{
   *   Vec(3,6,6,4).rank(tie = stats.RankTie.Avg) == Vec[Double](1,3.5,3.5,2)
   * }}}
   */
  Avg,

  /**
   * Take the minimum rank for all ties
   *
   * {{{
   *   Vec(3,6,6,4).rank(tie = stats.RankTie.Min) == Vec[Double](1,3,3,2)
   * }}}
   */
  Min,

  /**
   * Take the maximum rank for all ties
   *
   * {{{
   *   Vec(3,6,6,4).rank(tie = stats.RankTie.Max) == Vec[Double](1,4,4,2)
   * }}}
   */
  Max,

  /**
   * Take the rank according to natural (input) order
   *
   * {{{
   *   Vec(3,6,6,4).rank(tie = stats.RankTie.Nat) == Vec[Double](1,3,4,2)
   * }}}
   */
  Nat
}

/**
 * Trait which specifies what percentile method to use
 */
//sealed trait PctMethod

enum PctMethod {
  /**
   * Take percentile as MS Excel does
   */
  Excel,

  /**
   * Take percentile according to [[http://www.itl.nist.gov/div898/handbook/prc/section2/prc252.htm NIST]]
   */
  NIST
}

/**
 * Statistical methods made available on numeric Vec objects via enrichment.
 */
abstract class VecStats /*[@spec(Int, Long, Double) A]*/ <A> {
  Vec<A> get r;

  /**
   * Sum of the elements of the Vec, ignoring NA values
   */
  A sum();

  /**
   * Count of the non-NA elements of the Vec
   */
  int count();

  /**
   * Minimum element of the Vec, if one exists, or else None
   */
  A min();

  /**
   * Maximum element of the Vec, if one exists, or else None
   */
  A max();

  /**
   * Integer offset of the minimum element of the Vec, if one exists, or else -1
   */
  int argmin();

  /**
   * Integer offset of the minimum element of the Vec, if one exists, or else -1
   */
  int argmax();

  /**
   * Product of all the values in the Vec, ignoring NA values
   */
  A prod();

  /**
   * Counts the non-NA elements of the Vec subject to passing the
   * predicate function
   * @param test A function from A to Boolean
   */
  int countif(bool test(A arg));

  /**
   * Return the sum of the natural log of each element, ignoring NA values
   */
  double logsum();

  /**
   * Return the mean (average) of the values in the Vec, ignoring NA
   */
  double mean();

  /**
   * Return the median of the values in the Vec, ignoring NA
   */
  double median();

  /**
   * Return the geometric median of the values in the Vec, ignoring NA
   */
  double geomean();

  /**
   * Return the sample variance of the values in the Vec, ignoring NA
   */
  double variance();

  /**
   * Return the sample standard deviation of values in the Vec, ignoring NA
   */
  double stdev() => math.sqrt(variance());

  /**
   * Return the sample skewness of the values in the Vec, ignoring NA
   */
  double skew();

  /**
   * Return the sample kurtosis of the values in the Vec, ignoring NA
   */
  double kurt();

  /**
   * Return the percentile of the values at a particular threshold, ignoring NA
   * @param tile The percentile in [0, 100] at which to compute the threshold
   * @param method The percentile method; one of [[org.saddle.stats.PctMethod]]
   */
  double percentile(double tile, [PctMethod method = PctMethod.NIST]);

  /**
   * Return a copy of a numeric Vec with its values demeaned according to the
   * mean function
   */
  Vec<double> demeaned();

  /**
   * Return a Vec of ranks corresponding to a Vec of numeric values.
   * @param tie Method with which to break ties; a [[org.saddle.stats.RankTie]]
   * @param ascending Boolean, default true, whether to give lower values larger rank
   */
  Vec<double> rank([RankTie tie = RankTie.Avg, bool ascending = true]);

  /*protected*/ double _variance(Vec<A> r, double subOp(A arg1, double arg2)) {
    var sa = r.scalarTag;
    var sd = ScalarTagDouble;
    var c = count();

    if (c < 1) {
      return sd.missing();
    } else if (c == 1) {
      return 0.0;
    } else {
      double m = mean();
      return r.filterFoldLeft(sa.notMissing, 0.0, (x, y) {
        var tmp = subOp(y, m);
        x + tmp * tmp / (c - 1.0);
      });
    }
  }

  /*protected*/ double _skew(Vec<A> r, double subOp(A arg1, double arg2)) {
    var sa = r.scalarTag;
    var sd = ScalarTagDouble;
    var c = count();

    if (c > 2) {
      double v = variance();
      double m = mean();
      var coef = c / ((c - 1) * (c - 2) * v * math.sqrt(v));
      return r.filterFoldLeft(sa.notMissing, 0.0, (x, y) {
        var tmp = subOp(y, m);
        x + coef * tmp * tmp * tmp;
      });
    } else {
      return sd.missing();
    }
  }

  /*protected*/ double _kurt(Vec<A> r, double subOp(A arg1, double arg2)) {
    var sa = r.scalarTag;
    var sd = ScalarTagDouble;
    var c = count();

    if (c > 3) {
      var vari = variance();
      double m = mean();
      var acacc = r.filterFoldLeft(sa.notMissing, 0.0, (x, y) {
        var tmp = subOp(y, m);
        x + (tmp * tmp * tmp * tmp) / (vari * vari);
      });
      var coef1 = (c * (c + 1)) / ((c - 1) * (c - 2) * (c - 3));
      var coef2 = (c - 1) * (c - 1) / ((c - 2) * (c - 3));
      return (coef1 * acacc - 3.0 * coef2);
    } else {
      return sd.missing();
    }
  }

  /*protected*/ Vec<double> _demeaned(
      Vec<A> r, double subOp(A arg1, double arg2)) {
    var sa = r.scalarTag;
    var sd = ScalarTagDouble;

    var mn = mean();
    var ar = new Float64List(r.length);
    var i = 0;
    while (i < r.length) {
      var v = r[i];
      if (sa.notMissing(v)) {
        ar[i] = subOp(r[i], mn);
      } else {
        ar[i] = sd.missing();
      }
      i += 1;
    }
    return new VecDouble(ar);
  }

  // Fast median function that is N/A friendly; destructive to array
  /*protected*/ double _median(Vec<A> r) /*(implicit n: NUM<A>)*/ {
    var sd = ScalarTagDouble;

    /*(int, )*/ int _arrCopyToDblArr(
        Vec<A> r, List<double> arr) /*(implicit n: NUM<A>)*/ {
      var sa = r.scalarTag;
      var i = 0;
      var j = 0;
      while (i < r.length) {
        var v = sa.toDouble(r[i]);
        if (v == v) {
          arr[j] = v;
          j += 1;
        }
        i += 1;
      }
//      return (j, arr);
      return j;
    }

    var arr = new Float64List(r.length);
    var len = _arrCopyToDblArr(r, arr);

    if (len == 0) {
      return sd.missing();
    } else if (len % 2 != 0) {
      return _kSmallest(arr, len, len ~/ 2);
    } else {
      return (_kSmallest(arr, len, len ~/ 2) +
              _kSmallest(arr, len, len ~/ 2 - 1)) /
          2.0;
    }
  }

  // Find k_th smallest element,taken from N.Worth via pandas python library
  // (moments.pyx). Destructive to array input and not N/A friendly
  /*private*/ double _kSmallest(List<double> a, int n, int k) {
    var l = 0;
    var m = n - 1;

    while (l < m) {
      var x = a[k];
      var i = l;
      var j = m;
      while (i <= j) {
        while (a[i] < x) i += 1;
        while (a[j] > x) j -= 1;
        if (i <= j) {
          var t = a[i];
          a[i] = a[j];
          a[j] = t;
          i += 1;
          j -= 1;
        }
      }
      if (j < k) l = i;
      if (k < i) m = j;
    }
    return a[k];
  }

  // NB: destructive to argument v
  /*protected*/ Vec<double> _rank(List<double> v, RankTie tie, bool ascending) {
    var sd = ScalarTagDouble;

    var nan = ascending ? double.INFINITY : double.NEGATIVE_INFINITY;
    var len = v.length;

    var k = 0;
    while (k < len) {
      if (sd.isMissing(v[k])) v[k] = nan;
      k += 1;
    }

    List srt =
        ascending ? array.argsort(v, sd) : array.reverse(array.argsort(v, sd));

    List dat = array.take(v, srt, () => 0.0);

    var i = 0;
    var s = 0.0; // summation
    var d = 0; // duplicate counter
    var res = array.empty /*[Double]*/ (len, sd);
    while (i < len) {
      var v = dat[i];

      s += (i + 1.0);
      d += 1;
      if (v == nan) {
        res[srt[i]] = sd.missing();
      } else if (i == len - 1 || (dat[i + 1] - v).abs() > 1e-13) {
        if (tie == RankTie.Avg) {
          var j = i - d + 1;
          while (j < i + 1) {
            res[srt[j]] = s / d;
            j += 1;
          }
        } else if (tie == RankTie.Min) {
          var j = i - d + 1;
          while (j < i + 1) {
            res[srt[j]] = i - d + 2;
            j += 1;
          }
        } else if (tie == RankTie.Max) {
          var j = i - d + 1;
          while (j < i + 1) {
            res[srt[j]] = i + 1;
            j += 1;
          }
        } else if (tie == RankTie.Nat && ascending) {
          var j = i - d + 1;
          while (j < i + 1) {
            res[srt[j]] = j + 1;
            j += 1;
          }
        } else {
          var j = i - d + 1;
          while (j < i + 1) {
            res[srt[j]] = 2 * i - j - d + 2;
            j += 1;
          }
        }
        s = 0.0;
        d = 0;
      }
      i += 1;
    }

    return new Vec(res, sd);
  }

  // percentile function: see: http://en.wikipedia.org/wiki/Percentile
  /*protected*/ double _percentile(
      Vec<double> v, double tile, PctMethod method) /*(implicit n: NUM<A>)*/ {
    var sd = ScalarTagDouble;
    var vf = v.dropNA();
    if (vf.length == 0 || tile < 0 || tile > 100) {
      return sd.missing();
    } else {
      var c = vf.length;
      if (c == 1) {
        return vf(0);
      } else {
        double n;
        switch (method) {
          case PctMethod.Excel:
            n = (tile / 100.0) * (c - 1.0) + 1.0;
            break;
          case PctMethod.NIST:
            n = (tile / 100.0) * (c + 1.0);
            break;
        }
        var s = vf.sorted();
        var k = n.floor();
        var d = n - k;
        if (k <= 0) {
          return s(0);
        } else if (k >= c) {
          return s.last;
        } else {
          return s(k - 1) + d * (s(k) - s(k - 1));
        }
      }
    }
  }
}

abstract class DoubleStats extends Object with VecStats<double> {
//  Vec<double> get r;
//  DoubleStats(this.r);

  var sd = ScalarTagDouble;

  double sum() => r.filterFoldLeft(sd.notMissing, 0.0, (a, b) => a + b);

  int count() => r.filterFoldLeft(sd.notMissing, 0, (a, b) => a + 1);

  double min() {
    if (count() == 0) {
      return null; //None
    } else {
      var res = r.filterFoldLeft(
          sd.notMissing, sd.inf, (double x, double y) => x < y ? x : y);
      return res; //Some(res);
    }
  }

  double max() {
    if (count() == 0) {
      return null; //None
    } else {
      double res = r.filterFoldLeft(
          sd.notMissing, sd.negInf, (double x, double y) => x > y ? x : y);
      return res; //Some(res)
    }
  }

  double prod() => r.filterFoldLeft(sd.notMissing, 1.0, (a, b) => a * b);

  int countif(bool test(double arg)) =>
      r.filterFoldLeft((t) => sd.notMissing(t) && test(t), 0, (a, b) => a + 1);

  double logsum() =>
      r.filterFoldLeft(sd.notMissing, 0.0, (x, y) => x + math.log(y));

  double mean() => sum() / count();

  double median() => _median(r);

  double geomean() => math.exp(logsum() / count());

  double variance() => _variance(r, (a, b) => a - b);

  double skew() => _skew(r, (a, b) => a - b);

  double kurt() => _kurt(r, (a, b) => a - b);

  double percentile(double tile, [PctMethod method = PctMethod.NIST]) =>
      _percentile(r, tile, method);

  Vec<double> demeaned() => _demeaned(r, (a, b) => a - b);

  Vec<double> rank([RankTie tie = RankTie.Avg, bool ascending = true]) =>
      _rank(r.contents, tie, ascending);

  int argmin() => array.argmin(r.toArray(), r.scalarTag);

  int argmax() => array.argmax(r.toArray(), r.scalarTag);
}

abstract class IntStats extends Object with VecStats<int> {
//  Vec<int> get r;
//  IntStats(this.r);

  var si = ScalarTagInt;

  int min() {
    if (count() == 0) {
      return null; //None
    } else {
      int res = r.filterFoldLeft(
          si.notMissing, si.inf, (int x, int y) => x < y ? x : y);
      return res; //Some(res)
    }
  }

  int max() {
    if (count() == 0) {
      return null; //None
    } else {
      int res = r.filterFoldLeft(
          si.notMissing, si.negInf, (int x, int y) => x > y ? x : y);
      return res; //Some(res)
    }
  }

  int sum() => r.filterFoldLeft(si.notMissing, 0, (a, b) => a + b);

  int count() => r.filterFoldLeft(si.notMissing, 0, (a, b) => a + 1);

  int prod() => r.filterFoldLeft(si.notMissing, 1, (a, b) => a * b);

  int countif(bool test(int arg)) =>
      r.filterFoldLeft((t) => si.notMissing(t) && test(t), 0, (a, b) => a + 1);

  double logsum() => r.filterFoldLeft(
      si.notMissing, 0.0, (x, y) => x + math.log(y.toDouble()));

  double mean() => sum().toDouble() / count();

  double median() => _median(r);

  double geomean() => math.exp(logsum() / count());

  double variance() => _variance(r, (a, b) => a - b);

  double skew() => _skew(r, (a, b) => a - b);

  double kurt() => _kurt(r, (a, b) => a - b);

  double percentile(double tile, [PctMethod method = PctMethod.NIST]) =>
      _percentile(new Vec(r.toDoubleArray(), ScalarTagDouble), tile, method);

  Vec<double> demeaned() => _demeaned(r, (a, b) => a - b);

  Vec<double> rank([RankTie tie = RankTie.Avg, bool ascending = true]) =>
      _rank(r.toDoubleArray(), tie, ascending);

  int argmin() => array.argmin(r.toArray(), si);

  int argmax() => array.argmax(r.toArray(), si);
}
/*
class LongStats(r: Vec[Long]) extends VecStats[Long] {
  var sl = ScalarTagLong

  def min: Option[Long] =
    if (r.count == 0) None
    else {
      var res: Long = r.filterFoldLeft(sl.notMissing)(sl.inf)((x: Long, y: Long) => if (x < y) x else y)
      Some(res)
    }

  def max: Option[Long] =
    if (r.count == 0) None
    else {
      var res: Long = r.filterFoldLeft(sl.notMissing)(sl.negInf)((x: Long, y: Long) => if (x > y) x else y)
      Some(res)
    }

  def sum: Long = r.filterFoldLeft(sl.notMissing)(0L)(_ + _)
  def count: Int = r.filterFoldLeft(sl.notMissing)(0)((a, b) => a + 1)
  def prod: Long = r.filterFoldLeft(sl.notMissing)(1L)(_ * _)
  def countif(test: Long => Boolean): Int = r.filterFoldLeft(t => sl.notMissing(t) && test(t))(0)((a,b) => a + 1)
  def logsum: Double = r.filterFoldLeft(sl.notMissing)(0d)((x, y) => x + math.log(y))
  def mean: Double = sum.asInstanceOf[Double] / count
  def median: Double = _median(r)
  def geomean: Double = math.exp(logsum / count)
  def variance: Double = _variance(r, _ - _)
  def skew: Double = _skew(r, _ - _)
  def kurt: Double = _kurt(r, _ - _)
  def percentile(tile: Double, method: PctMethod = PctMethod.NIST): Double = _percentile(r.toDoubleArray, tile, method)

  def demeaned: Vec[Double] = _demeaned(r, _ - _)
  def rank(tie: RankTie = RankTie.Avg, ascending: Boolean = true): Vec[Double] = _rank(r.toDoubleArray, tie, ascending)

  def argmin: Int = array.argmin(r.toArray)
  def argmax: Int = array.argmax(r.toArray)
}
*/
