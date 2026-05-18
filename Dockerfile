FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    gfortran \
    libopenmpi-dev \
    openmpi-bin \
    libopenblas-dev \
    dpkg-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN wget https://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz \
    && tar xzf hpl-2.3.tar.gz

# Write a clean Make file from scratch — no sed patching
COPY Make.linux /opt/hpl-2.3/Make.linux

# Build HPL
RUN cd /opt/hpl-2.3 && make arch=linux

WORKDIR /workspace
RUN cp /opt/hpl-2.3/bin/linux/xhpl /usr/local/bin/xhpl

ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

CMD ["/bin/bash"]
