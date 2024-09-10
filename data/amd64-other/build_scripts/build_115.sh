#!/bin/bash
set -x
set -e
# print OS version
cat /etc/os-release
# print current env
env
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
export CFLAGS="-g -fsanitize=thread"
export CCFLAGS="-g -fsanitize=thread"
export CXXFLAGS="-g -fsanitize=thread"
export CPPFLAGS="-g -fsanitize=thread"
export LDFLAGS="-fsanitize=thread"
cd /src/Python-3.12.4
set +e
if ! ./configure; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
