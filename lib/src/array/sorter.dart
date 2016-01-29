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

library saddle.array.sorter;

//import org.saddle.{array, ORD}
//import org.saddle.vec.VecBool
//import it.unimi.dsi.fastutil.chars.CharLists
//import it.unimi.dsi.fastutil.bytes.ByteLists
//import it.unimi.dsi.fastutil.shorts.ShortLists
//import it.unimi.dsi.fastutil.ints.IntLists
//import it.unimi.dsi.fastutil.floats.FloatLists
//import it.unimi.dsi.fastutil.longs.LongLists
//import it.unimi.dsi.fastutil.doubles.DoubleLists
//import org.joda.time.DateTime
//import org.saddle.scalar.ScalarTagTime

import 'package:quiver/iterables.dart' show enumerate, IndexedValue;

/**
* Typeclass interface for sorting implementations
*/
abstract class Sorter<T> {
  List<int> argSorted(List<T> arr);
  List<T> sorted(List<T> arr);
//}
//
//class Sorter {
  /*private*/ List<double> _nanToNegInf(List<double> arr) {
    var tmp = new List.from(arr);
    var i = 0;
    while (i < tmp.length) {
      var ti = tmp[i];
      if (ti != ti) {
        tmp[i] = double.NEGATIVE_INFINITY;
      }
      i += 1;
    }
    return tmp;
  }

//  /*private*/ nanToNegInf(arr: List[Float]): List[Float] = {
//    val tmp = arr.clone()
//    var i = 0
//    while (i < tmp.length) {
//      val ti = tmp(i)
//      if (ti != ti) tmp(i) = Float.NegativeInfinity
//      i += 1
//    }
//    tmp
//  }

//  def anySorter[T: ORD] {
//    new Sorter<T> {
//      def argSorted(arr: List<T>) = {
//        val res = range(0, arr.length)
//        val cmp = implicitly[ORD<T>]
//        res.sortWith((a, b) => cmp.compare(arr(a), arr(b)) < 0)
//      }
//
//      def sorted(arr: List<T>) = {
//        val res = arr.clone()
//        res.sorted
//      }
//    }
//  }

  static final DoubleSorter doubleSorter = new DoubleSorter();
}

/*
object boolSorter extends Sorter<bool> {
  def argSorted(arr: List<bool>) = VecBool.argSort(arr)
  def sorted(arr: List<bool>) = VecBool.sort(arr)
}

object byteSorter extends Sorter[Byte] {
  def argSorted(arr: List[Byte]) = {
    val res = range(0, arr.length)
    ByteLists.radixSortIndirect(res, arr, true)
    res
  }

  def sorted(arr: List[Byte]) = {
    val res = arr.clone()
    ByteLists.radixSort(res)
    res
  }
}

object charSorter extends Sorter[Char] {
  def argSorted(arr: List[Char]) = {
    val res = range(0, arr.length)
    CharLists.radixSortIndirect(res, arr, true)
    res
  }

  def sorted(arr: List[Char]) = {
    val res = arr.clone()
    CharLists.radixSort(res)
    res
  }
}

object shortSorter extends Sorter[Short] {
  def argSorted(arr: List[Short]) = {
    val res = range(0, arr.length)
    ShortLists.radixSortIndirect(res, arr, true)
    res
  }

  def sorted(arr: List[Short]) = {
    val res = arr.clone()
    ShortLists.radixSort(res)
    res
  }
}

object intSorter extends Sorter<int> {
  def argSorted(arr: List<int>) = {
    val res = range(0, arr.length)
    IntLists.radixSortIndirect(res, arr, true)
    res
  }

  def sorted(arr: List<int>) = {
    val res = arr.clone()
    IntLists.radixSort(res)
    res
  }
}

object floatSorter extends Sorter[Float] {
  def argSorted(arr: List[Float]) = {
    val tmp = nanToNegInf(arr)               // fastutil sorts NaN to PosInf
    val res = range(0, arr.length)
    FloatLists.radixSortIndirect(res, tmp, true)
    res
  }

  def sorted(arr: List[Float]) = {
    val res = nanToNegInf(arr)
    FloatLists.radixSort(res)
    res
  }
}

object longSorter extends Sorter[Long] {
  def argSorted(arr: List[Long]) = {
    val res = range(0, arr.length)
    LongLists.radixSortIndirect(res, arr, true)
    res
  }

  def sorted(arr: List[Long]) = {
    val res = arr.clone()
    LongLists.radixSort(res)
    res
  }
}

object timeSorter extends Sorter[DateTime] {
  def argSorted(arr: List[DateTime]) = {
    val res = range(0, arr.length)
    LongLists.radixSortIndirect(res, ScalarTagTime.time2LongList(arr), true)
    res
  }

  def sorted(arr: List[DateTime]) = {
    array.take(arr, argSorted(arr), ScalarTagTime.missing)
  }
}
*/

class DoubleSorter extends Sorter<double> {
  List<int> argSorted(List<double> arr) {
    var tmp = _nanToNegInf(arr); // fastutil sorts NaN to PosInf
//    var res = range(0, arr.length);
//    DoubleLists.radixSortIndirect(res, tmp, true);
    List<IndexedValue<double>> ivs = enumerate(tmp).toList(growable: false);
    ivs.sort((iv1, iv2) => iv1.value.compareTo(iv2.value));
    return ivs.map((iv) => iv.index).toList();
  }

  List<double> sorted(List<double> arr) {
    var res = _nanToNegInf(arr);
//    DoubleLists.radixSort(res);
    res.sort();
    return res;
  }
}
