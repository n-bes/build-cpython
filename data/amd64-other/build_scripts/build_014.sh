#!/bin/bash
set -x
set -e
# print OS version
cat /etc/os-release
# print current env
env
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
export CFLAGS="-g -fsanitize=address -static-libasan"
export CCFLAGS="-g -fsanitize=address -static-libasan"
export CXXFLAGS="-g -fsanitize=address -static-libasan"
export CPPFLAGS="-g -fsanitize=address -static-libasan"
export LDFLAGS="-fsanitize=address -static-libasan"
export ASAN_OPTIONS="detect_leaks=0:allocator_may_return_null=1:handle_segv=0"
cd /src/Python-3.12.4
set +e
if ! ./configure; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
