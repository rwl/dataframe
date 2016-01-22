library saddle.stats;

import 'dart:typed_data';
import 'package:quiver/iterables.dart' show range;

/**
 * Mediator is an auxiliary class for O(N log k) rolling median. It is inspired by
 * AShelly's C99 implementation, which is (c) 2011 ashelly.myopenid.com and licensed
 * under the MIT license: http://www.opensource.org/licenses/mit-license
 *
 * Reference:
 *   http://stackoverflow.com/questions/5527437/rolling-median-in-c-turlach-implementation
 */
class Mediator {
  int winSz;
  Mediator(this.winSz) {
    if (winSz <= 0) {
      throw new ArgumentError("Window length must be > 0!");
    }

    data = new Float64List(winSz);
    loc = new List<int>(winSz);
    heap = new List<int>(winSz);
    sawNa = new List<bool>.generate(winSz, (_) => false);

    hMid = winSz / 2;

    i = 0;
    while (i < winSz) {
      data[i] = double.NAN;
      i += 1;
    }
  }

  // auxiliary data
  /*private*/ List<double> data; // circular buffer of values
  /*private*/ List<int> loc; // ith value's location within heap array
  /*private*/ List<
      int> heap; // orders data array into [max heap] :: median :: [min heap]
  /*private*/ List<bool> sawNa; // circular buffer of na markers
  /*private*/ var idx = 0; // position in circular buffer
  /*private*/ var naIdx = 0; // position in circular buffer
  /*private*/ var minCt = 0; // # items in minheap
  /*private*/ var maxCt = 0; // # items in maxheap
  /*private*/ var totCt = 0; // # items in data
  /*private*/ var nanCt = 0; // count of NA's in current window

  // heap array contains indexes of data array giving a max-mid-min heap structure centered at hMid:
  //   index: [0           ...            hMid           ...      winSz-1]
  //   value: [... | child2 child1 | max] mid  [min | child1 child2 | ...]
  //
  // such that data(heap(max)) <= data(heap(hMid)) <= data(heap(min))
  //
  // also, we maintain invariants:
  //   (a) size(minheap) <= size(maxheap)
  //   (b) size(minheap) >= size(maxheap) - 1

  /*private*/ var hMid; // heap(hMid) = x s.t. data(x) holds mid (between max/min heaps)

  // loc array is a reverse lookup for data into the heap, eg:
  //   loc(n) = -2  ==>  data(n) is maxheap child1
  //   loc(n) = +1  ==>  data(n) is minheap min

  // initialize auxiliary data
  /*private*/ var i;
//  while (i < winSz) {
//    data(i) = Double.NaN
//    i += 1
//  }

  double median() {
    var v = data[heap[hMid]];
    if ((totCt & 1) == 0) {
      return (v + data[heap[hMid - 1]]) / 2.0;
    } else {
      return v;
    }
  }

  void push(double v) {
    var oldNa = sawNa[naIdx];

    if (v != v) {
      // observing na
      sawNa[naIdx] = true;
      if (!oldNa) nanCt += 1;
    } else {
      // observing real value
      sawNa[naIdx] = false;
      if (oldNa) nanCt -= 1;

      insert(v);

      if (totCt < winSz) totCt += 1;
    }

    if (totCt + nanCt > winSz) {
      pop();
    }

    naIdx = (naIdx + 1) % winSz;
  }

  void pop() {
    // get location of least recently inserted value
    var l = (idx - totCt + winSz) % winSz;
    var p = loc[l];

    if (totCt > 0) {
      if (totCt == 1) {
        // don't need to do anything
      } else if (p > 0) {
        // item is in minheap
        swap(p, minCt);
        minCt -= 1;
        minSortDown(p);
        if (minCt < maxCt - 1) maxToMin();
      } else if (p < 0) {
        // item is in maxheap
        swap(-maxCt, p);
        maxCt -= 1;
        maxSortDown(p);
        if (maxCt < minCt) minToMax();
      } else {
        // item is mid
        if (maxCt > minCt) {
          // swap head of maxheap with mid
          swap(-1, 0);
          // drop head of maxheap
          swap(-maxCt, -1);
          maxCt -= 1;
          maxSortDown(-1);
        } else {
          // swap head of minheap with mid
          swap(0, 1);
          // drop head of minheap
          swap(1, minCt);
          minCt -= 1;
          minSortDown(1);
        }
      }

      totCt -= 1;

      // must null out this value
      data[l] = double.NAN;
    }
  }

  // returns true if heap[i] < heap[j]
  /*private*/ bool isless(int i, int j) =>
      data[heap[i + hMid]] < data[heap[j + hMid]];

  // swaps items i & j in heap, maintains indexes
  /*private*/ swap(int i, int j) {
    var iOff = i + hMid;
    var jOff = j + hMid;
    var t = heap[iOff];
    heap[iOff] = heap[jOff];
    heap[jOff] = t;
    loc[heap[iOff]] = i;
    loc[heap[jOff]] = j;
  }

  // swaps items i & j if i < j; returns true if swapped
  /*private*/ bool cas(int i, int j) {
    if (isless(i, j)) {
      swap(i, j);
      return true;
    } else {
      return false;
    }
  }

  // maintains minheap property for all items below i in heap
  /*private*/ minSortDown(int iIn) {
    var i = iIn * 2;
    while (i <= minCt) {
      if (i < minCt && isless(i + 1, i)) {
        i += 1;
      }
      if (!cas(i, i ~/ 2)) {
        i = minCt + 1; // break
      } else {
        i *= 2;
      }
    }
  }

  // maintains maxheap property for all items below i in heap
  /*private*/ maxSortDown(int iIn) {
    var i = iIn * 2;
    while (i >= -maxCt) {
      if (i > -maxCt && isless(i, i - 1)) {
        i -= 1;
      }
      if (!cas(i ~/ 2, i)) {
        i = -(maxCt + 1); // break
      } else {
        i *= 2;
      }
    }
  }

  // maintains minheap property for all items above i in heap, including median
  // returns true if median changed
  /*private*/ bool minSortUp(int iIn) {
    var i = iIn;
    while (i > 0 && cas(i, i ~/ 2)) i /= 2;
    return i == 0;
  }

  // maintains maxheap property for all items above i in heap, including median
  // returns true if median changed
  /*private*/ bool maxSortUp(int iIn) {
    var i = iIn;
    while (i < 0 && cas(i ~/ 2, i)) i /= 2;
    return i == 0;
  }

  // rebalance toward maxheap
  /*private*/ minToMax() {
    maxCt += 1; // make room on maxheap
    swap(minCt, -maxCt); // swap element from minheap
    minCt -= 1;
    if (maxSortUp(-maxCt) && (minCt != 0) && cas(1, 0)) {
      minSortDown(1);
    }
  }

  // rebalance toward minheap
  /*private*/ maxToMin() {
    minCt += 1; // make room on minheap
    swap(-maxCt, minCt); // swap element from maxheap
    maxCt -= 1;
    if (minSortUp(minCt) && cas(0, -1)) {
      maxSortDown(-1);
    }
  }

  /*private*/ insert(double v) {
    // save old value
    var old = data[idx];

    // store new value
    data[idx] = v;

    // first element?
    if (totCt == 0) {
      loc[idx] = 0;
      heap[hMid] = idx;
    } else {
      if (totCt < winSz) {
        // room in buffer
        if (maxCt > minCt) {
          // add to minheap
          minCt += 1;
          loc[idx] = minCt;
          heap[hMid + minCt] = idx;
          if (minSortUp(minCt) && cas(0, -1)) {
            maxSortDown(-1);
          }
        } else {
          // add to maxheap
          maxCt += 1;
          loc[idx] = -maxCt;
          heap[hMid - maxCt] = idx;
          if (maxSortUp(-maxCt) && (minCt != 0) && cas(1, 0)) {
            minSortDown(1);
          }
        }
      } else {
        // overwriting old value
        var reSort = true;
        var p = loc[idx];

        if (p > 0) {
          // new item was inserted in minheap
          if (minCt < (winSz - 1) / 2) {
            minCt += 1;
          } else if (v > old) {
            minSortDown(p);
            reSort = false;
          }
          if (reSort && minSortUp(p) && cas(0, -1)) {
            maxSortDown(-1);
          }
        } else if (p < 0) {
          // new item was inserted in maxheap
          if (maxCt < winSz / 2) {
            maxCt += 1;
          } else if (v < old) {
            maxSortDown(p);
            reSort = false;
          }
          if (reSort && maxSortUp(p) && (minCt != 0) && cas(1, 0)) {
            minSortDown(1);
          }
        } else {
          // new item was inserted at median
          if ((maxCt != 0) && maxSortUp(-1)) {
            maxSortDown(-1);
          }
          if ((minCt != 0) && minSortUp(1)) {
            minSortDown(1);
          }
        }
      }
    }

    idx = (idx + 1) % winSz;
  }

  /*private*/ printMaxHeap() {
    var buf = new StringBuffer();
    if (maxCt > 0) {
      buf.write("${data[heap[-1 + hMid]]}");
    }
    var i = 2;
    while (i <= maxCt) {
      buf.write(" |${data[heap[-i + hMid]]} ");
      i += 1;
      if (i <= maxCt) {
        buf.write("${data[heap[-i + hMid]]}");
      }
      i += 1;
    }
    print(buf.toString());
  }

  /*private*/ printMinHeap() {
    var buf = new StringBuffer();
    if (minCt > 0) {
      buf.write("${data[heap[1 + hMid]]}");
    }
    var i = 2;
    while (i <= minCt) {
      buf.write(" |${data[heap[i + hMid]]} ");
      i += 1;
      if (i <= minCt) {
        buf.write("${data[heap[i + hMid]]}");
      }
      i += 1;
    }
    print(buf.toString());
  }

  debug() {
    var buf = new StringBuffer();
    buf.writeln("Med: ${median()}");
    buf.writeln("Obs: $totCt");
    buf.writeln("NAs: $nanCt");
    buf.writeln("+H:  $maxCt");
    buf.writeln("-H:  $minCt");
    buf.writeln("-------------------- DATA LAYOUT --------------------");
    buf.write("Max: ");
    printMaxHeap();
    buf.writeln("Mid: ${data[heap[hMid]]}");
    buf.write("Min: ");
    printMinHeap();
    buf.writeln("---------------------- ARRAYS -----------------------");
    buf.writeln("  i |       DATA |       HEAP |         LOC | sawNA |");
    buf.writeln("-----------------------------------------------------");
    for (var i in range(winSz)) {
      var star1 = i == idx ? "*" : " ";
      var star2 = i == naIdx ? " *" : "  ";
      buf.writeln(
          "$star1$i|${data[i]}|${heap[i]}|${loc[i]} |${sawNa[i]}$star2|");
    }
    buf.write("-----------------------------------------------------");
    print(buf.toString());
  }
}
