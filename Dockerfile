FROM ubuntu:20.04
LABEL maintainer="liu.i@outlook.com"

# update apt source
RUN sed -i 's/http:\/\/archive.ubuntu.com/http:\/\/mirrors.163.com/g' /etc/apt/sources.list
RUN sed -i 's/http:\/\/security.ubuntu.com/http:\/\/mirrors.163.com/g' /etc/apt/sources.list

# install packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install --no-install-recommends -y apt-transport-https dirmngr gnupg2 lsb-release ca-certificates \
    sudo software-properties-common wget curl tree vim pkg-config cmake make automake binutils binutils-aarch64-linux-gnu binutils-arm-linux-gnueabihf gcc g++ gcc-7 g++-7 \
    gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf g++-aarch64-linux-gnu g++-arm-linux-gnueabihf gcc-multilib-arm-linux-gnueabihf gdb git \
    libcpprest-dev openssl libssl-dev libboost-all-dev libboost-context-dev libboost-test-dev libzmq5 libyaml-cpp-dev libnm-dev libsdl1.2-dev libsdl-image1.2 libceres1 libzmq5-dev \
    && rm -rf /var/lib/apt/lists/*

# add user 'user' & add to sudo group
RUN useradd -ms /bin/bash user && yes 1234 | passwd user && adduser user sudo && echo 'user ALL=(ALL)NOPASSWD:ALL' > /etc/sudoers
USER user
WORKDIR /home/user

#copy source code
RUN mkdir -p /home/user/aarch64 /home/user/armhf /home/user/source-code
COPY source-code/zlib-1.2.11.tar.gz /tmp/
COPY source-code/openssl-1.1.1l.tar.gz /tmp/
COPY source-code/boost_1_72_0.tar.bz2 /tmp/
COPY source-code/curl-7_79_1.tar.gz /tmp/
COPY source-code/cpprestsdk-2.10.18.tar.gz /tmp/

#uncompress
RUN tar jxf /tmp/boost_1_72_0.tar.bz2 -C source-code && \
    tar zxf /tmp/zlib-1.2.11.tar.gz -C source-code && \
    tar zxf /tmp/openssl-1.1.1l.tar.gz -C source-code && \
    tar zxf /tmp/curl-7_79_1.tar.gz -C source-code && \
    tar zxf /tmp/cpprestsdk-2.10.18.tar.gz -C source-code && \
    sudo rm -rf /tmp/*

#for compile zlib
RUN cd ~/source-code/zlib-1.2.11/ && mkdir build.armhf && cd build.armhf && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=/home/user/armhf \
             -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++ \
             -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc \
             -DCMAKE_SYSTEM_NAME=Linux \
             -DCMAKE_SYSTEM_PROCESSOR=arm \
             -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
             -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
             && make -j 4 install
RUN cd ~/source-code/zlib-1.2.11/ && mkdir build.aarch64 && cd build.aarch64 && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=/home/user/aarch64 \
             -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ \
             -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
             -DCMAKE_SYSTEM_NAME=Linux \
             -DCMAKE_SYSTEM_PROCESSOR=arm \
             -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
             -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
             && make -j 4 install

#for compile openssl
RUN cd ~/source-code/openssl-1.1.1l && ./Configure no-shared zlib linux-generic32 -fPIC --prefix=/ --openssldir=/etc/ssl --cross-compile-prefix=arm-linux-gnueabihf- -L/home/user/armhf/lib   && make -j 4 && make DESTDIR=/home/user/armhf/   install && make clean
RUN cd ~/source-code/openssl-1.1.1l && ./Configure no-shared zlib linux-aarch64   -fPIC --prefix=/ --openssldir=/etc/ssl --cross-compile-prefix=aarch64-linux-gnu-   -L/home/user/aarch64/lib && make -j 4 && make DESTDIR=/home/user/aarch64/ install && make clean

#for compile boost
RUN echo "using gcc : armhf : arm-linux-gnueabihf-g++ ;\nusing gcc : aarch64 : aarch64-linux-gnu-g++ ;" > /home/user/user-config.jam
RUN cd ~/source-code/boost_1_72_0 && ./bootstrap.sh && ./b2 --prefix=/home/user/armhf toolset=gcc-armhf install && ./b2 --clean && ./b2 --prefix=/home/user/aarch64 toolset=gcc-aarch64 install && ./b2 --clean 

#for compile curl
RUN cd ~/source-code/curl-curl-7_79_1 && mkdir build.armhf && cd build.armhf && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=/home/user/armhf \
             -DCMAKE_SYSROOT=/home/user/armhf \
             -DCMAKE_PREFIX_PATH=/home/user/armhf \
             -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc \
             -DCMAKE_SYSTEM_NAME=Linux \
             -DCMAKE_SYSTEM_PROCESSOR=arm \
             -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
             -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
             -DHAVE_POLL_FINE=1 \
             && make -j 4 install
RUN cd ~/source-code/curl-curl-7_79_1 && mkdir build.aarch64 && cd build.aarch64 && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=/home/user/aarch64 \
             -DCMAKE_SYSROOT=/home/user/aarch64 \
             -DCMAKE_PREFIX_PATH=/home/user/aarch64 \
             -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
             -DCMAKE_SYSTEM_NAME=Linux \
             -DCMAKE_SYSTEM_PROCESSOR=arm \
             -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
             -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
             -DHAVE_POLL_FINE=1 \
             && make -j 4 install

#for compile cpprestsdk
RUN cd ~/source-code/cpprestsdk-2.10.18 && mkdir build.armhf && cd build.armhf && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=/home/user/armhf \
             -DCMAKE_SYSROOT=/home/user/armhf \
             -DCMAKE_PREFIX_PATH=/home/user/armhf \
             -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc \
             -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++ \
             -DCMAKE_SYSTEM_NAME=Linux \
             -DCMAKE_SYSTEM_PROCESSOR=arm \
             -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
             -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
             -DBUILD_TESTS=OFF -DBUILD_SAMPLES=OFF \
             -DCPPREST_EXCLUDE_WEBSOCKETS=1 \
             && make -j 4 && make install
RUN cd ~/source-code/cpprestsdk-2.10.18 && mkdir build.aarch64 && cd build.aarch64 && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=/home/user/aarch64 \
             -DCMAKE_SYSROOT=/home/user/aarch64 \
             -DCMAKE_PREFIX_PATH=/home/user/aarch64 \
             -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
             -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ \
             -DCMAKE_SYSTEM_NAME=Linux \
             -DCMAKE_SYSTEM_PROCESSOR=arm \
             -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
             -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
             -DBUILD_TESTS=OFF -DBUILD_SAMPLES=OFF \
             -DCPPREST_EXCLUDE_WEBSOCKETS=1 \
             && make -j 4 && make install

#clean
RUN rm -rf ~/source-code && cd ~
