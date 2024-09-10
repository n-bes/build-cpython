#!/bin/bash
set -x
set -e
# print OS version
cat /etc/os-release
# print current env
env
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
export CFLAGS="-fanalyzer -fdiagnostics-format=sarif-file"
export CCFLAGS="-fanalyzer -fdiagnostics-format=sarif-file"
export CXXFLAGS="-fanalyzer -fdiagnostics-format=sarif-file"
export CPPFLAGS="-fanalyzer -fdiagnostics-format=sarif-file"
cd /src/Python-3.13.0b4
set +e
if ! ./configure --with-assertions --with-pydebug; then
    cat config.log
    exit 1
else
    make
fi
rsync -aR --prune-empty-dirs --include "*/" --include "*.sarif" --exclude="*" / /sarif-data/
