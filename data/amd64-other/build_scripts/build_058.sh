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
# export LD_PRELOAD="/usr/lib/gcc/x86_64-redhat-linux/14/libasan.so"
export LD_PRELOAD="/usr/lib64/libasan.so.8.0.0"
cd /src/Python-3.13.0b4
set +e
if ! ./configure --disable-gil; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
