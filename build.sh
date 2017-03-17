#!/bin/bash

cd breakpad
make clean
./configure --prefix=$HOME/local
make -j8
make install
