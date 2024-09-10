#!/bin/bash
set -x
set -e
# print OS version
cat /etc/os-release
# print current env
env
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
export CFLAGS="-g -fsanitize=hwaddress"
export CCFLAGS="-g -fsanitize=hwaddress"
export CXXFLAGS="-g -fsanitize=hwaddress"
export CPPFLAGS="-g -fsanitize=hwaddress"
export LDFLAGS="-fsanitize=hwaddress"
export HWASAN_OPTIONS="detect_leaks=0:allocator_may_return_null=1:handle_segv=0"
export LD_PRELOAD="/usr/lib/gcc/aarch64-linux-gnu/13/libhwasan.so"
cd /src/Python-3.13.0b4
set +e
if ! ./configure; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
