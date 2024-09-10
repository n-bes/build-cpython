#!/bin/bash
set -x
set -e
# print OS version
cat /etc/os-release
# print current env
env
rm /usr/bin/ld
ln -s /usr/bin/ld.lld /usr/bin/ld
export CC=clang
export CXX=clang++
export CFLAGS="-g -fsanitize=address -shared-libsan"
export CCFLAGS="-g -fsanitize=address -shared-libsan"
export CXXFLAGS="-g -fsanitize=address -shared-libsan"
export CPPFLAGS="-g -fsanitize=address -shared-libsan"
export LDFLAGS="-fsanitize=address -shared-libsan"
export ASAN_OPTIONS="detect_leaks=0:allocator_may_return_null=1:handle_segv=0"
export LD_PRELOAD="/usr/lib/clang/18/lib/x86_64-redhat-linux-gnu/libclang_rt.asan.so"
cd /src/Python-3.12.4
set +e
if ! ./configure --enable-optimizations; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
