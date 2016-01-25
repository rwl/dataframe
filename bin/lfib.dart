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

import 'dart:io';
import 'package:dataframe/dataframe.dart';

/**
 * ========= Summary results of SmallCrush =========
 *  Version:               TestU01 1.2.3
 *  Generator:             STDIN
 *  Number of statistics:  15
 *  Total CPU time:        00:00:19.03
 *  The following tests gave p-values outside [0.001, 0.9990]:
 *  (eps  means a value < 1.0e-300):
 *  (eps1 means a value < 1.0e-15):
 *
 *        Test                          p-value
 *  ----------------------------------------------
 *  10  RandomWalk1 J                   0.9997
 *  ----------------------------------------------
 *  All other tests were passed
 *
 *
 * ========= Summary results of Crush =========
 *  Version:          TestU01 1.2.3
 *  Generator:        STDIN
 *  Number of statistics:  144
 *  Total CPU time:   01:00:08.48
 *
 *  All tests were passed
 *
 * ========= Summary results of BigCrush =========
 *  Version:          TestU01 1.2.3
 *  Generator:        STDIN
 *  Number of statistics:  160
 *  Total CPU time:   08:38:24.56
 *
 *  All tests were passed
 */
main(List<String> args) {
  var stream = new BufferedInputStream(RandomStream(LFib4(12345678910)));
  while (true) stdout.write(stream.read());
}
