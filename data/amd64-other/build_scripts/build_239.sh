#!/bin/bash
set -x
set -e
# print OS version
cat /etc/os-release
# print current env
env
ln -s /usr/bin/lld-19 /usr/local/bin/lld
ln -s /usr/bin/clang-19 /usr/local/bin/clang
ln -s /usr/bin/clang++-19 /usr/local/bin/clang++
rm /usr/bin/ld
ln -s /usr/lib/llvm-19/bin/ld.lld /usr/bin/ld
export CC=/usr/local/bin/clang
export CXX=/usr/local/bin/clang++
export CFLAGS="-g -fsanitize=thread -shared-libsan"
export CCFLAGS="-g -fsanitize=thread -shared-libsan"
export CXXFLAGS="-g -fsanitize=thread -shared-libsan"
export CPPFLAGS="-g -fsanitize=thread -shared-libsan"
export LDFLAGS="-fsanitize=thread -shared-libsan"
cd /src/Python-3.13.0b4
set +e
if ! ./configure; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
