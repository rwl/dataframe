
This file consists of a few main programs to generate an infinite stream of raw
random bytes to stdin; designed to feed into the TestU01 battery of tests:

    http://www.iro.umontreal.ca/~simardr/testu01/tu01.html

A stdin wrapper that I used for the latter can be found within

    http://code.google.com/p/csrng/

In particular the file test/TestU01_raw_stdin_input_with_log.c

which can be used to replicate the results in "TestU01: A C Library for Empirical
Testing of Random Number Generators"; L'Ecuyer and Simard; 2007.

For example, after compiling per instructions, can run:

    dart run xor64.dart | ./TestU01_raw_stdin_input_with_log --normal
