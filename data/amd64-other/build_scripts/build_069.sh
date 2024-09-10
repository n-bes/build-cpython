#!/bin/bash
set -x
set -e
# print OS version
cat /etc/os-release
# print current env
env
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
export CFLAGS="-g -fsanitize=thread -static-libtsan"
export CCFLAGS="-g -fsanitize=thread -static-libtsan"
export CXXFLAGS="-g -fsanitize=thread -static-libtsan"
export CPPFLAGS="-g -fsanitize=thread -static-libtsan"
export LDFLAGS="-fsanitize=thread -static-libtsan"
cd /src/Python-3.13.0b4
set +e
if ! ./configure --enable-optimizations; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
