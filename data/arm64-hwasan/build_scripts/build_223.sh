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
export CFLAGS="-g -fsanitize=hwaddress"
export CCFLAGS="-g -fsanitize=hwaddress"
export CXXFLAGS="-g -fsanitize=hwaddress"
export CPPFLAGS="-g -fsanitize=hwaddress"
export LDFLAGS="-fsanitize=hwaddress"
export HWASAN_OPTIONS="detect_leaks=0:allocator_may_return_null=1:handle_segv=0"
cd /src/Python-3.13.0b4
set +e
if ! ./configure --disable-gil; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
