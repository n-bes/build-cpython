FROM fedora:40@sha256:5ce8497aeea599bf6b54ab3979133923d82aaa4f6ca5ced1812611b197c79eb0
RUN yum update -y && \
    yum groupinstall -y "Development Tools" && \
    yum install -y \
        bzip2-devel \
        clang \
        gcc \
        gdb \
        libasan \
        libffi-devel \
        libhwasan \
        lld \
        llvm \
        openssl-devel \
        rsync \
        tk-devel \
        wget \
        xz-devel

WORKDIR /src/

RUN wget https://www.python.org/ftp/python/3.12.4/Python-3.12.4.tgz && \
    tar xzf Python-3.12.4.tgz && \
    rm Python-3.12.4.tgz
RUN wget https://www.python.org/ftp/python/3.13.0/Python-3.13.0b4.tgz && \
    tar xzf Python-3.13.0b4.tgz && \
    rm Python-3.13.0b4.tgz

COPY build_scripts .
