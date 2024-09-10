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
