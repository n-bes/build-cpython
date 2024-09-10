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
cd /src/Python-3.12.4
set +e
if ! ./configure --enable-optimizations; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
