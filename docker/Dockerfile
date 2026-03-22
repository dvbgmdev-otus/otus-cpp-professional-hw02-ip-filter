FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libboost-test-dev \
    clang-tidy \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
