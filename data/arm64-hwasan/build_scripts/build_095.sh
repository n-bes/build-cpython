#!/bin/bash
set -x
set -e
# print OS version
cat /etc/os-release
# print current env
env
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
export CFLAGS="-g -fsanitize=hwaddress -static-libhwasan"
export CCFLAGS="-g -fsanitize=hwaddress -static-libhwasan"
export CXXFLAGS="-g -fsanitize=hwaddress -static-libhwasan"
export CPPFLAGS="-g -fsanitize=hwaddress -static-libhwasan"
export LDFLAGS="-fsanitize=hwaddress -static-libhwasan"
export HWASAN_OPTIONS="detect_leaks=0:allocator_may_return_null=1:handle_segv=0"
cd /src/Python-3.12.4
set +e
if ! ./configure; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
