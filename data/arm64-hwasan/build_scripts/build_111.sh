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
export CFLAGS="-g -fsanitize=hwaddress"
export CCFLAGS="-g -fsanitize=hwaddress"
export CXXFLAGS="-g -fsanitize=hwaddress"
export CPPFLAGS="-g -fsanitize=hwaddress"
export LDFLAGS="-fsanitize=hwaddress"
export HWASAN_OPTIONS="detect_leaks=0:allocator_may_return_null=1:handle_segv=0"
export LD_PRELOAD="/usr/lib/llvm-18/lib/clang/18/lib/linux/libclang_rt.hwasan-aarch64.so"
cd /src/Python-3.12.4
set +e
if ! ./configure; then
    cat config.log
    exit 1
else
    make
    ./python -m test -uall
fi
