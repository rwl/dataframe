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

library saddle.index.joiner;

//import org.saddle._
//import scala.{ specialized => spec }

import 'reindexer.dart';
import 'join_type.dart';
import '../index.dart';

/**
 * Abstract interface for a Joiner instance
 */
/*private[saddle]*/ abstract class Joiner<T> /*[@spec(Int, Long, Double) T]*/ {
  ReIndexer<T> join(Index<T> left, Index<T> right, JoinType how);
}
