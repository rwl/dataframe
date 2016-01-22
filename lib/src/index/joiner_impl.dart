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

library saddle.index;

//import scala.{ specialized => spec }
//import org.saddle._
//import locator.Locator

import 'dart:math' as math;
import 'dart:typed_data';

import '../array/array.dart';
import '../index.dart';
import '../index/join_type.dart';
import '../index/reindexer.dart';
import '../vec.dart';

import 'joiner.dart';
import 'join_helper.dart';

/**
 * Concrete implementation of Joiner instance which is specialized on basic
 * types.
 */
class JoinerImpl<
    T> /*[@spec(Boolean, Int, Long, Double) T: ST: ORD]*/ extends Joiner<T> {
//  /*private implicit*/ Option<Array<int>> wrapArray(Array<int> arr) => Some(arr);

  ReIndexer<T> join(Index<T> left, Index<T> right, JoinType how) {
    if (left == right) {
      return new ReIndexer(null, null, right);
    } else if (left.isUnique && right.isUnique) {
      switch (how) {
        case JoinType.InnerJoin:
          return intersect(left, right);
        case JoinType.OuterJoin:
          return union(left, right);
        case JoinType.LeftJoin:
          return leftJoinUnique(left, right);
        case JoinType.RightJoin:
          return leftJoinUnique(right, left).swap();
      }
    } else if (right.isUnique && how == JoinType.LeftJoin) {
      return leftJoinUnique(left, right);
    } else if (left.isUnique && how == JoinType.RightJoin) {
      return leftJoinUnique(right, left).swap;
    } else if (left.isMonotonic && right.isMonotonic) {
      switch (how) {
        case JoinType.InnerJoin:
          return innerJoinMonotonic(left, right);
        case JoinType.OuterJoin:
          return outerJoinMonotonic(left, right);
        case JoinType.LeftJoin:
          return leftJoinMonotonic(left, right);
        case JoinType.RightJoin:
          return leftJoinMonotonic(right, left).swap();
      }
    } else {
      switch (how) {
        case JoinType.RightJoin:
          return factorizedJoin(right, left, JoinType.LeftJoin).swap();
        default:
          return factorizedJoin(left, right, how);
      }
    }
  }

  // unions two indices with set semantics
  /*private*/ ReIndexer<T> union(Index<T> left, Index<T> right) {
    if (!left.isUnique || !right.isUnique) {
      throw new IndexException("Cannot union non-unique indexes");
    }

    if (left.isMonotonic && right.isMonotonic) {
      return outerJoinMonotonicUnique(left, right);
    } else {
      return outerJoinUnique(left, right);
    }
  }

  // Intersects two indices if both have set semantics
  /*private*/ ReIndexer<T> intersect(Index<T> left, Index<T> right) {
    if (!left.isUnique || !right.isUnique) {
      throw new IndexException("Cannot intersect non-unique indexes");
    }

    var ll = left.length;
    var rl = right.length;
    var min = math.min(ll, rl);
    var max = math.max(ll, rl);

    if (left.isMonotonic && right.isMonotonic && !(max > 5 * min)) {
      return innerJoinMonotonicUnique(left, right);
    } else {
      return innerJoinUnique(left, right);
    }
  }

  /*private*/ ReIndexer<T> leftJoinUnique(Index<T> left, Index<T> right) {
    var ll = left.length;
    var rl = right.length;

    if (left.isMonotonic && right.isMonotonic && !(ll > 5 * rl)) {
      return leftJoinMonotonicUnique(left, right);
    } else {
      var indexer = new Int32List(ll);
      var i = 0;
      while (i < ll) {
        var otherVal = left.raw(i);
        indexer[i] = right.getFirst(otherVal);
        i += 1;
      }
      return new ReIndexer(null, /*Some(*/ indexer, left);
    }
  }

  // driver function

  /*private*/ ReIndexer<T> factorizedJoin(
      Index<T> left, Index<T> right, JoinType how) {
    // factorize left and right inputs
    var rizer = new Factorizer(left.length + right.length);
    var leftLabels = rizer.factorize(left);
    var rightLabels = rizer.factorize(right);

    var max_groups = rizer.numUniq;

    var result = JoinHelper.apply(leftLabels, rightLabels, max_groups, how);
    List lTake = result.lIdx;
    List rTake = result.rIdx;

    // construct new joint index
    var newIdx = new List<T>(lTake.length);
    var i = 0;
    while (i < newIdx.length) {
      var lpos = lTake[i];
      newIdx[i] = (lpos != -1) ? left.raw(lpos) : right.raw(rTake[i]);
      i += 1;
    }

    return new ReIndexer(lTake, rTake, new Index(newIdx, left.scalarTag));
  }

  // ****** Fast algorithms for monotonic joins

  ReIndexer<T> innerJoinMonotonicUnique(Index<T> left, Index<T> right) {
    var scalar = left.scalarTag;

    var ll = left.length;
    var rl = right.length;

    if (ll == 0 || rl == 0) {
      return new ReIndexer([], [], new Index([], scalar));
    } else {
      // first, count
      int i = 0;
      int j = 0;
      int c = 0;

      T l = left.raw(i);
      T r = right.raw(j);
      while (i < ll && j < rl) {
        while (i < ll && scalar.lt(left.raw(i), r)) {
          l = left.raw(i);
          i += 1;
        }
        while (j < rl && scalar.lt(right.raw(j), l)) {
          r = right.raw(j);
          j += 1;
        }
        if (l == r) {
          c += 1;
          i += 1;
          j += 1;
        }
      }

      // now, fill up with values
      var res = new List<T>(c);
      var lft = new Int32List(c);
      var rgt = new Int32List(c);

      i = 0;
      j = 0;
      c = 0;

      l = left.raw(i);
      r = right.raw(j);
      while (i < ll && j < rl) {
        if (scalar.lt(l, r)) {
          i += 1;
          if (i < ll) l = left.raw(i);
        } else if (scalar.lt(r, l)) {
          j += 1;
          if (j < rl) r = right.raw(j);
        } else {
          res[c] = l;
          lft[c] = i;
          rgt[c] = j;
          i += 1;
          j += 1;
          if (i < left.length) l = left.raw(i);
          if (j < right.length) r = right.raw(j);
          c += 1;
        }
      }

      // consider two special cases that speed things up down the line
      if (c == ll) {
        return new ReIndexer(null, rgt, left);
      } else if (c == rl) {
        return new ReIndexer(lft, null, right);
      } else {
        return new ReIndexer(lft, rgt, new Index(res, scalar));
      }
    }
  }

  ReIndexer<T> innerJoinMonotonic(Index<T> left, Index<T> right) {
    var scalar = left.scalarTag;
    var nleft = left.length;
    var nright = right.length;

    // first pass counts
    int passThru(
        TripleArrayStore callback, List<int> l, List<int> r, List<T> res) {
      var lc = 0;
      var rc = 0;
      var rgrp = 0;
      var count = 0;
      if (nleft > 0 && nright > 0) {
        while (lc < nleft && rc < nright) {
          T lval = left.raw(lc);
          T rval = right.raw(rc);
          if (lval == rval) {
            callback.apply(l, r, res, lc, rc, lval, count);
            rc += 1;
            if (rc < nright && right.raw(rc) == lval) {
              rgrp += 1;
            } else {
              lc += 1;
              rc -= rgrp + 1;
              rgrp = 0;
            }
            count += 1;
          } else if (scalar.lt(lval, rval)) {
            lc += 1;
          } else {
            rc += 1;
          }
        }
      }
      return count;
    }

    // first pass counts
    var nobs = passThru(TNoOp, null, null, null);

//    var lIdx, rIdx, result = (array.empty<int>(nobs), array.empty<int>(nobs), array.empty<T>(nobs));
    var lIdx = array.empty /*<int>*/ (nobs);
    var rIdx = array.empty /*<int>*/ (nobs);
    var result = array.empty /*<int>*/ (nobs);

    // second pass populates results
    passThru(TStore, lIdx, rIdx, result);

    return new ReIndexer(lIdx, rIdx, new Index(result, left.scalarTag));
  }

  ReIndexer<T> innerJoinUnique(Index<T> left, Index<T> right) {
    // want to scan over the smaller one; make lft the smaller one
//    var szhint = (left.length > right.length) ? right.length : left.length;

    var res = []; //new Buffer<T>(szhint);
    var lft = []; //new Buffer<int>(szhint);
    var rgt = []; //new Buffer<int>(szhint);

    var switchLR = left.length > right.length;

    var ltmp = switchLR ? right : left;
    var rtmp = switchLR ? left : right;

    var i = 0;
    while (i < ltmp.length) {
      var k = ltmp.raw(i);
      var v = rtmp.getFirst(k);
      if (v != -1) {
        res.add(k);
        rgt.add(v);
        lft.add(i);
      }
      i += 1;
    }

    List<T> result = res;
    var lres = switchLR ? rgt : lft;
    var rres = switchLR ? lft : rgt;

    var st = left.scalarTag;
    return new ReIndexer(lres, rres, new Index(new Vec(result, st), st));
  }

  ReIndexer<T> outerJoinMonotonicUnique(Index<T> left, Index<T> right) {
    var scalar = left.scalarTag;

    var ll = left.length;
    var rl = right.length;

    if (ll == 0) {
      var lft = new Int32List(rl);
      var i = 0;
      while (i < rl) {
        lft[i] = -1;
        i += 1;
      }
      return new ReIndexer(lft, null, right);
    } else if (rl == 0) {
      var rgt = new Int32List(ll);
      var i = 0;
      while (i < ll) {
        rgt[i] = -1;
        i += 1;
      }
      return new ReIndexer(null, rgt, left);
    } else {
      // first count uniques
      var c = 0;
      var i = 0;
      var j = 0;
      T l = left.raw(0);
      T r = right.raw(0);
      while (i < ll && j < rl) {
        l = left.raw(i);
        r = right.raw(j);
        if (l == r) {
          c += 1;
          i += 1;
          j += 1;
        } else if (scalar.lt(l, r)) {
          c += 1;
          i += 1;
        } else {
          c += 1;
          j += 1;
        }
      }
      c += (ll - i);
      c += (rl - j);

      // then fill

      var res = new List<T>(c);
      var lft = new Int32List(c);
      var rgt = new Int32List(c);

      c = 0;
      i = 0;
      j = 0;
      l = left.raw(0);
      r = right.raw(0);
      while (i < ll && j < rl) {
        while (i < ll && scalar.lt(l, r)) {
          res[c] = l;
          lft[c] = i;
          rgt[c] = -1;
          i += 1;
          c += 1;
          if (i < ll) l = left.raw(i);
        }
        while (i < ll && j < rl && r == l) {
          res[c] = r;
          rgt[c] = j;
          lft[c] = i;
          j += 1;
          i += 1;
          c += 1;
          if (i < ll) l = left.raw(i);
          if (j < rl) r = right.raw(j);
        }
        while (j < rl && scalar.lt(r, l)) {
          res[c] = r;
          lft[c] = -1;
          rgt[c] = j;
          j += 1;
          c += 1;
          if (j < rl) r = right.raw(j);
        }
      }
      while (i < ll) {
        res[c] = left.raw(i);
        lft[c] = i;
        rgt[c] = -1;
        c += 1;
        i += 1;
      }
      while (j < rl) {
        res[c] = right.raw(j);
        rgt[c] = j;
        lft[c] = -1;
        c += 1;
        j += 1;
      }

      return new ReIndexer(lft, rgt, new Index(res, scalar));
    }
  }

  ReIndexer<T> outerJoinMonotonic(Index<T> left, Index<T> right) {
    var scalar = left.scalarTag;
    var nleft = left.length;
    var nright = right.length;

    // first pass counts
    int passThru(
        TripleArrayStore callback, List<int> l, List<int> r, List<T> res) {
      var lc = 0;
      var rc = 0;
      var done = false;
      var count = 0;
      if (nleft == 0) {
        if (callback == TNoOp) {
          count = nright;
        } else {
          while (rc < nright) {
            T v = right.raw(rc);
            callback.apply(l, r, res, -1, rc, v, rc);
            rc += 1;
          }
        }
      } else if (nright == 0) {
        if (callback == TNoOp) {
          count = nleft;
        } else while (lc < nleft) {
          T v = left.raw(lc);
          callback.apply(l, r, res, lc, -1, v, lc);
          lc += 1;
        }
      } else {
        while (!done) {
          if (lc == nleft) {
            if (callback == TNoOp) {
              count += nright - rc;
            } else {
              while (rc < nright) {
                T v = right.raw(rc);
                callback.apply(l, r, res, -1, rc, v, count);
                count += 1;
                rc += 1;
              }
            }
            done = true;
          } else if (rc == nright) {
            if (callback == TNoOp) {
              count += nleft - lc;
            } else {
              while (lc < nleft) {
                T v = left.raw(lc);
                callback.apply(l, r, res, lc, -1, v, count);
                count += 1;
                lc += 1;
              }
            }
            done = true;
          } else {
            T lval = left.raw(lc);
            T rval = right.raw(rc);
            if (lval == rval) {
              var ldups = 0;
              var rdups = 0;
              while (lc + ldups < nleft &&
                  lval == left.raw(lc + ldups)) ldups += 1;
              while (rc + rdups < nright &&
                  rval == right.raw(rc + rdups)) rdups += 1;
              var m = 0;
              while (m < ldups) {
                var n = 0;
                while (n < rdups) {
                  callback.apply(l, r, res, lc + m, rc + n, lval, count);
                  count += 1;
                  n += 1;
                }
                m += 1;
              }
              lc += ldups;
              rc += rdups;
            } else if (scalar.lt(lval, rval)) {
              callback.apply(l, r, res, lc, -1, lval, count);
              count += 1;
              lc += 1;
            } else {
              callback.apply(l, r, res, -1, rc, rval, count);
              count += 1;
              rc += 1;
            }
          }
        }
      }
      return count;
    }

    // first pass counts
    var nobs = passThru(TNoOp, null, null, null);

    var lIdx = array.empty /*<int>*/ (nobs);
    var rIdx = array.empty /*<int>*/ (nobs);
    var result = array.empty /*<T>*/ (nobs);

    // second pass populates results
    passThru(TStore, lIdx, rIdx, result);

    return new ReIndexer(lIdx, rIdx, new Index(result, scalar));
  }

  ReIndexer<T> outerJoinUnique(Index<T> left, Index<T> right) {
    // hits hashmap
//    var szhint = left.length + right.length;

    var res = []; //new Buffer<T>(szhint);
    var lft = []; //new Buffer<int>(szhint);
    var rgt = []; //new Buffer<int>(szhint);

    var i = 0;
    while (i < left.length) {
      var v = left.raw(i);
      var r = right.getFirst(v);
      res.add(v);
      lft.add(i);
      rgt.add(r);
      i += 1;
    }

    var j = 0;
    while (j < right.length) {
      var v = right.raw(j);
      if (left.getFirst(v) == -1) {
        res.add(v);
        rgt.add(j);
        lft.add(-1);
      }
      j += 1;
    }

    List<T> result = res;
    return new ReIndexer(lft, rgt, new Index(result, left.scalarTag));
  }

  ReIndexer<T> leftJoinMonotonicUnique(Index<T> left, Index<T> right) {
    var scalar = left.scalarTag;
    var rgt = new Int32List(left.length);

    var i = 0;
    var j = 0;
    var ll = left.length;
    var rl = right.length;

    while (i < ll && j < rl) {
      T l = left.raw(i);
      T r = l;

      while (j < rl && scalar.lt(right.raw(j), l)) {
        r = right.raw(j);
        j += 1;
      }

      if (j < rl && l == r) {
        rgt[i] = j;
      } else {
        rgt[i] = -1;
      }

      i += 1;
    }

    while (i < ll) {
      rgt[i] = -1;
      i += 1;
    }

    return new ReIndexer(null, rgt, left);
  }

  ReIndexer<T> leftJoinMonotonic(Index<T> left, Index<T> right) {
    var scalar = left.scalarTag;
    var nleft = left.length;
    var nright = right.length;

    int passThru(
        TripleArrayStore callback, List<int> l, List<int> r, List<T> res) {
      var lc = 0;
      var rc = 0;
      var rgrp = 0;
      var done = false;
      var count = 0;

      if (nleft > 0) {
        while (!done) {
          if (lc == nleft) {
            done = true;
          } else if (rc == nright) {
            if (callback == TNoOp) {
              count += nleft - lc;
            } else {
              while (lc < nleft) {
                T v = left.raw(lc);
                callback.apply(l, r, res, lc, -1, v, count);
                count += 1;
                lc += 1;
              }
            }
            done = true;
          } else {
            T lval = left.raw(lc);
            T rval = right.raw(rc);
            if (lval == rval) {
              callback.apply(l, r, res, lc, rc, lval, count);
              rc += 1;
              if (rc < nright && right.raw(rc) == lval) {
                rgrp += 1;
              } else {
                lc += 1;
                rc -= rgrp + 1;
                rgrp = 0;
              }
              count += 1;
            } else if (scalar.lt(lval, rval)) {
              callback.apply(l, r, res, lc, -1, lval, count);
              count += 1;
              lc += 1;
            } else {
              rc += 1;
            }
          }
        }
      }
      return count;
    }

    // first pass counts
    var nobs = passThru(TNoOp, null, null, null);

    var lIdx = array.empty /*<int>*/ (nobs);
    var rIdx = array.empty /*<int>*/ (nobs);
    var result = array.empty /*<T>*/ (nobs);

    // second pass populates results
    passThru(TStore, lIdx, rIdx, result);

    return new ReIndexer(lIdx, rIdx, new Index(result, scalar));
  }
//}
//
//private[saddle] object JoinerImpl {

  static indexJoin /*[@spec(Boolean, Int, Long, Double) T: ST: ORD]*/ (
          Index<T> left, Index<T> right, JoinType how) =>
      (new JoinerImpl<T>()).join(left, right, how);
}

// Private class to factorize indexes (ie, turn into enum representation)
/*private*/ class Factorizer<T> {
  Factorizer(int sz);

  Map map = {}; //new Locator<T>(sz); // backing hashmap
  List uniques = []; //new Buffer<T>(sz); // list of unique index keys seen
  int numUniq = 0; // number of distinct factors

  // Yields factor labels based on all the indexes processed in a successive manner.
  // Updates factor counts as well
  List<int> factorize(Index<T> idx) {
    var n = idx.length;
    var labels = new Int32List(n);

    var i = 0;
    while (i < n) {
      var v = idx.raw(i);
      var loc = map[v] ?? -1;
      if (loc != -1) {
        labels[i] = loc;
      } else {
        map[v] = numUniq;
        uniques.add(v);
        labels[i] = numUniq;
        numUniq += 1;
      }
      i += 1;
    }

    return labels;
  }
}

// helper trait to store three values into three arrays at location loc
/*private*/ abstract class TripleArrayStore<T> {
  apply(
      List<int> ar1, List<int> ar2, List<T> ar3, int v1, int v2, T v3, int loc);
}

final _TNoOp TNoOp = new _TNoOp();

/*private*/ class _TNoOp<T> implements TripleArrayStore<T> {
  apply(List<int> ar1, List<int> ar2, List<T> ar3, int v1, int v2, T v3,
      int loc) {}
}

final _TStore TStore = new _TStore();

/*private*/ class _TStore<T> extends TripleArrayStore<T> {
  apply(List<int> ar1, List<int> ar2, List<T> ar3, int v1, int v2, T v3,
      int loc) {
    ar1[loc] = v1;
    ar2[loc] = v2;
    ar3[loc] = v3;
  }
}
