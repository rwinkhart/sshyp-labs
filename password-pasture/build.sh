#!/usr/bin/env sh
rm -rf cmake-build-debug CMakeFiles cmake_install.cmake CMakeCache.txt Makefile
cmake ./
sleep 10  # prevents clock skew
make
