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

library saddle.buffer;

//import org.saddle._
//import org.saddle.Buffer

import '../buffer.dart';

/**
 * Buffer instance for Any type
 */
class BufferAny<T> /*[T: ST]*/ extends Buffer<T> {
  BufferAny([int sz = 16]);

  var list = new Array.ofDim<T>(sz);
//  var count = 0;
  var remain = sz;

  apply(int loc) => list(loc);

  add(T i) {
    if (remain == 0) {
      remain = list.length;
      val newList = new Array.ofDim<T>(remain * 2);
      Array.copy(list, 0, newList, 0, list.length);
      list = newList;
    }

    list[count] = i;
    count += 1;
    remain -= 1;
  }

  Array<T> toArray() {
    val newList = new Array.ofDim<T>(count);
    Array.copy(list, 0, newList, 0, count);
    newList;
  }
}

//class BufferAny {
//  apply/*[T: ST]*/(int sz) => new BufferAny<T>(sz);
//  apply/*[T: ST]*/() => new BufferAny<T>();
//}
