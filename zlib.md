[SourceCode 1.2.11](http://zlib.net/zlib-1.2.11.tar.gz)

## 解压 uncompress
tar zxf zlib-1.2.11.tar.gz

## for armhf
```
cd zlib-1.2.11 && mkdir -p build.armhf && cd build.armhf && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=<somewhere> \
             -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++ \
             -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc \
             -DCMAKE_SYSTEM_NAME=Linux \
             -DCMAKE_SYSTEM_PROCESSOR=arm \
             -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
             -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY && make -j 4 install
```

## for aarch64
```
cd zlib-1.2.11 && mkdir -p build.aarch64 && cd build.aarch64 && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=<somewhere> \
             -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ \
             -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
             -DCMAKE_SYSTEM_NAME=Linux \
             -DCMAKE_SYSTEM_PROCESSOR=arm \
             -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
             -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
             -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY && make -j 4 install
```
