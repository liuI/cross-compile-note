依赖openssl和zlib，在这两个库已编译的情况下：
```bash
tar zxvf curl-7.52.1.tar.gz && cd curl-7.52.1
mkdir build.armhf && cd build.armhf
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/home/i/armhf/curl \
      -DCMAKE_TOOLCHAIN_FILE=/home/i/armhf/gcc-armhf.cmake \
      -DHAVE_POSIX_STRERROR_R=1 \
      ..
make -j 8 && make install
```
