#!/bin/bash

/p/course/cs537-swift/tests/tester/run-tests.sh -d /p/course/cs537-swift/tests/p2a $*
make -f Makefile.test clean
