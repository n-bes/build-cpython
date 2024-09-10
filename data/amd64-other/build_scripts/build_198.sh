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
cd /src/Python-3.13.0b4
set +e
if ! ./configure --with-assertions --with-pydebug; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
