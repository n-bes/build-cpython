FROM ubuntu:24.04@sha256:2e863c44b718727c860746568e1d54afd13b2fa71b160f5cd9058fc436217b30
RUN apt-get update -y && \
    apt-get install -y \
        autoconf \
        build-essential \
        clang \
        clang-tools \
        curl \
        gcc \
        gdb \
        gnupg \
        libbz2-dev \
        liblzma-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        lld \
        lsb-release \
        make \
        pkg-config \
        rsync \
        software-properties-common \
        tk-dev \
        wget \
        wget \
        xz-utils \
        zlib1g-dev

WORKDIR /src/

RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    /src/llvm.sh 19
RUN wget https://www.python.org/ftp/python/3.12.4/Python-3.12.4.tgz && \
    tar xzf Python-3.12.4.tgz && \
    rm Python-3.12.4.tgz
RUN wget https://www.python.org/ftp/python/3.13.0/Python-3.13.0b4.tgz && \
    tar xzf Python-3.13.0b4.tgz && \
    rm Python-3.13.0b4.tgz
COPY build_scripts .
