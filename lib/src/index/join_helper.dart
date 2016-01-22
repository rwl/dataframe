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

//import org.saddle.array

import 'dart:typed_data';

import '../array/array.dart';

import 'join_type.dart';

/**
 * JoinHelper takes a factorized representation of a left and right index (ie, the
 * label identifiers are integers).
 *
 * Applying the class will return a left and right indexer each of whose length is
 * equal to the length of the joint index, and each of whose ith entry indicates the
 * location within the original corresponding (left/right) index which contributes to
 * the ith entry of the joint index.
 *
 * Also see [[org.saddle.array.take]] for more info
 */
/*private[saddle]*/ class JoinHelper {
  static JoinResult apply(List<int> leftLabels, List<int> rightLabels,
      int max_groups, JoinType how) {
    LabelMarker marker;
    JoinCounter counter;
    switch (how) {
      case JoinType.InnerJoin:
        marker = ijMarker;
        counter = ijCounter;
        break;
      case JoinType.OuterJoin:
        marker = ojMarker;
        counter = ojCounter;
        break;
      case JoinType.LeftJoin:
        marker = ljMarker;
        counter = ljCounter;
        break;
      case JoinType.RightJoin:
        throw new ArgumentError("Cannot call directly with RightJoin");
    }

    var count = 0;

    // create permutations which recover original input ordering
    var lcounts = labelCount(leftLabels, max_groups);
    var rcounts = labelCount(rightLabels, max_groups);

    var lUnsorter = unsorter(leftLabels, lcounts, max_groups);
    var rUnsorter = unsorter(rightLabels, rcounts, max_groups);

    // count number of output rows in join
    var i = 1;
    while (i <= max_groups) {
      var lc = lcounts[i];
      var rc = rcounts[i];
      count = counter.apply(lc, rc, count);
      i += 1;
    }

    // exclude NA group
    var lpos = lcounts[0];
    var rpos = rcounts[0];

    var lLabels = new Int32List(count);
    var rLabels = new Int32List(count);

    // create join factor labels
    i = 1;
    var pos = 0;
    while (i <= max_groups) {
      var lc = lcounts[i];
      var rc = rcounts[i];
      pos = marker.apply(lLabels, rLabels, lc, rc, lpos, rpos, pos);
      lpos += lc;
      rpos += rc;
      i += 1;
    }

    return new JoinResult(
        applyUnsorter(lUnsorter, lLabels), applyUnsorter(rUnsorter, rLabels));
  }

  // Calculates mapping of factor label to count seen in labels array
  static /*private*/ List<int> labelCount(List<int> labels, int numFactors) {
    var n = labels.length;

    // Create vector of factor counts seen in labels array, saving location 0 for N/A
    var counts = new Int32List(numFactors + 1);
    var i = 0;
    while (i < n) {
      counts[labels[i] + 1] += 1;
      i += 1;
    }

    return counts;
  }

  // Calculate permutation from sorted(labels) -> labels, so we can recover an array of factor labels
  // in the originally provided order.
  static /*private*/ List<int> unsorter(
      List<int> labels, List<int> counts, int numFactors) {
    var n = labels.length;

    // calculate running sum of label counts
    // - acts as a map from factor label to first offset within hypothetically sorted
    //   label array (in factor-ascending order)
    var where = new Int32List(numFactors + 1);
    var i = 1;
    while (i < numFactors + 1) {
      where[i] = where[i - 1] + counts[i - 1];
      i += 1;
    }

    // Build a permutation that maps from a position in a sorted label array
    // to a position in the original label array.
    var permuter = new Int32List(n);
    i = 0;
    while (i < n) {
      var w = labels[i] + 1; // ith factor label
      permuter[where[w]] = i; // permuter[loc in sorted array] = i
      where[w] += 1;
      i += 1;
    }

    return permuter;
  }

  static /*private*/ List<int> applyUnsorter(
      List<int> unsorter, List<int> labels) {
    if (unsorter.length > 0) {
      return array.take(unsorter, labels, () => -1);
    } else {
      var ll = labels.length;
      var ar = new Int32List(ll);
      var i = 0;
      while (i < ll) {
        ar[i] = -1;
        i += 1;
      }
      return ar;
    }
  }
}

/*private[saddle] case*/ class JoinResult {
  final List<int> lIdx, rIdx;
  JoinResult(this.lIdx, this.rIdx);
}

// Wrapper traits for inner logic; not anonymous functions to avoid boxing

// Input:  L/R label arrays, L/R count of current label, L/R position of current label, position in join
// Output: new join position
// Effect: updates label arrays
/*private*/ abstract class LabelMarker {
  int apply(List<int> lLabels, List<int> rLabels, int lc, int rc, int lpos,
      int rpos, int pos);
}

// Input:  L/R count of current label
// Output: new count value
// Effect: None
/*private*/ abstract class JoinCounter {
  int apply(int lc, int rc, int count);
}

final JoinCounter ijCounter = new IjCounter();
final JoinCounter ojCounter = new OjCounter();
final JoinCounter ljCounter = new LjCounter();

/*private*/ class IjCounter extends JoinCounter {
  int apply(int lc, int rc, int count) => count + lc * rc;
}

/*private*/ class OjCounter extends JoinCounter {
  int apply(int lc, int rc, int count) =>
      (rc > 0 && lc > 0) ? count + lc * rc : count + lc + rc;
}

/*private*/ class LjCounter extends JoinCounter {
  int apply(int lc, int rc, int count) =>
      (rc > 0) ? count + lc * rc : count + lc;
}

final LabelMarker ijMarker = new IjMarker();
final LabelMarker ojMarker = new OjMarker();
final LabelMarker ljMarker = new LjMarker();

/*private*/ class IjMarker extends LabelMarker {
  int apply(List<int> lLabels, List<int> rLabels, int lc, int rc, int lpos,
      int rpos, int pos) {
    if (rc > 0 && lc > 0) {
      var j = 0;
      while (j < lc) {
        var offset = pos + j * rc;
        var k = 0;
        while (k < rc) {
          lLabels[offset + k] = lpos + j;
          rLabels[offset + k] = rpos + k;
          k += 1;
        }
        j += 1;
      }
    }
    return pos + lc * rc;
  }
}

/*private*/ class OjMarker extends LabelMarker {
  int apply(List<int> lLabels, List<int> rLabels, int lc, int rc, int lpos,
      int rpos, int pos) {
    if (rc == 0) {
      var j = 0;
      while (j < lc) {
        lLabels[pos + j] = lpos + j;
        rLabels[pos + j] = -1;
        j += 1;
      }
      return pos + lc;
    } else if (lc == 0) {
      var j = 0;
      while (j < rc) {
        lLabels[pos + j] = -1;
        rLabels[pos + j] = rpos + j;
        j += 1;
      }
      return pos + rc;
    } else {
      var j = 0;
      while (j < lc) {
        var offset = pos + j * rc;
        var k = 0;
        while (k < rc) {
          lLabels[offset + k] = lpos + j;
          rLabels[offset + k] = rpos + k;
          k += 1;
        }
        j += 1;
      }
      return pos + lc * rc;
    }
  }
}

/*private*/ class LjMarker extends LabelMarker {
  int apply(List<int> lLabels, List<int> rLabels, int lc, int rc, int lpos,
      int rpos, int pos) {
    if (rc == 0) {
      var j = 0;
      while (j < lc) {
        lLabels[pos + j] = lpos + j;
        rLabels[pos + j] = -1;
        j += 1;
      }
      return pos + lc;
    } else {
      var j = 0;
      while (j < lc) {
        var offset = pos + j * rc;
        var k = 0;
        while (k < rc) {
          lLabels[offset + k] = lpos + j;
          rLabels[offset + k] = rpos + k;
          k += 1;
        }
        j += 1;
      }
      return pos + lc * rc;
    }
  }
}
