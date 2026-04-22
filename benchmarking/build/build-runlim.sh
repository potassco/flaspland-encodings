#!/bin/bash
git clone https://github.com/arminbiere/runlim
cd runlim/
./configure.sh && make
cp runlim ../programs/runlim
cd ..
