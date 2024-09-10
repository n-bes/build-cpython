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
export CFLAGS="-g -fsanitize=hwaddress -mllvm -hwasan-globals=0"
export CCFLAGS="-g -fsanitize=hwaddress -mllvm -hwasan-globals=0"
export CXXFLAGS="-g -fsanitize=hwaddress -mllvm -hwasan-globals=0"
export CPPFLAGS="-g -fsanitize=hwaddress -mllvm -hwasan-globals=0"
export LDFLAGS="-fsanitize=hwaddress -mllvm -hwasan-globals=0"
export HWASAN_OPTIONS="detect_leaks=0:allocator_may_return_null=1:handle_segv=0"
export LD_PRELOAD="/usr/lib/llvm-18/lib/clang/18/lib/linux/libclang_rt.hwasan-aarch64.so"
cd /src/Python-3.13.0b4
set +e
if ! ./configure --with-assertions --with-pydebug; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
