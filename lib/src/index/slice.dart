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

//import org.saddle.Index

/**
 * Slice provides a methodology so that when it is applied to an index,
 * it produces an upper and lower integer offset at which to slice.
 */
abstract class Slice<T> /*[+T]*/ {
  /*(int, int)*/ apply /*[U >: T]*/ (Index /*[U]*/ idx);
}

// implementations

/**
 * Represent a slice from one key to another, inclusive.
 * @param k1 First key
 * @param k2 Second key
 * @tparam T Type of Key
 */
class SliceDefault<T> extends Slice<T> {
  SliceDefault(T k1, T k2);

  /*(int, int)*/ apply /*[U >: T]*/ (Index<U> idx) =>
      [idx.lsearch(k1), idx.rsearch(k2)];
}

/**
 * Represent a slice from zero to a key.
 * @param k Key to slice to
 * @tparam T Type of Key
 */
class SliceTo<T> extends Slice<T> {
  SliceTo(T k);

  /*(int, int)*/ apply /*[U >: T]*/ (Index<U> idx) => [0, idx.rsearch(k)];
}

/**
 * Represent a slice from key to end of index
 * @param k Key to slice from
 * @tparam T Type of Key
 */
class SliceFrom<T> extends Slice<T> {
  /*(int, int)*/ apply /*[U >: T]*/ (Index<U> idx) =>
      [idx.lsearch(k), idx.length];
}

/**
 * Represent a slice over the entire index
 */
class SliceAll extends Slice /*[Nothing]*/ {
  /*(int, int)*/ apply /*[U]*/ (Index<U> idx) => [0, idx.length];
}

// companion objects

class Slice {
  apply(T k1, T k2) => new SliceDefault(k1, k2);
}

class SliceFrom {
  apply(T k) => new SliceFrom(k);
}

class SliceTo {
  apply(T k) => new SliceTo(k);
}

class SliceAll {
  apply(T k) => new SliceAll();
}
