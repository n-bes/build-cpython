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
export CFLAGS="-g -fsanitize=hwaddress -mllvm -hwasan-globals=0"
export CCFLAGS="-g -fsanitize=hwaddress -mllvm -hwasan-globals=0"
export CXXFLAGS="-g -fsanitize=hwaddress -mllvm -hwasan-globals=0"
export CPPFLAGS="-g -fsanitize=hwaddress -mllvm -hwasan-globals=0"
export LDFLAGS="-fsanitize=hwaddress -mllvm -hwasan-globals=0"
export HWASAN_OPTIONS="detect_leaks=0:allocator_may_return_null=1:handle_segv=0"
export LD_PRELOAD="/usr/lib/llvm-19/lib/clang/19/lib/linux/libclang_rt.hwasan-aarch64.so"
cd /src/Python-3.13.0b4
set +e
if ! ./configure --enable-optimizations; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
