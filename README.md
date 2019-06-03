# cross-compile-script

### 记录几个交叉编译时，常用库的编译指令
### 构建环境： Ubuntu 16.04 x64
### 构建工具： x86_64-linux-gnu-gcc(v5.4) cmake make
### 交叉编译工具链： arm-linux-gnueabihf-gcc arm-linux-gnueabihf-g++

默认根目录 /home/i/armhf
```
> armhf
> ├── boost
> ├── cpprest
> │   ├── include
> │   └── lib
> ├── curl
> │   ├── include
> │   └── lib
> ├── openssl
> │   ├── include
> │   └── lib
> └── zlib
> │   ├── include
> │   └── lib
```

新建文件/home/i/armhf/gcc-armhf.cmake，内容如下：
```cmake
SET(buildroot /home/i/armhf)

# this is required
SET(CMAKE_SYSTEM_NAME Linux)

# specify the cross compiler
SET(CMAKE_C_COMPILER   arm-linux-gnueabihf-gcc)
SET(CMAKE_CXX_COMPILER arm-linux-gnueabihf-g++)

# where is the target environment 
SET(CMAKE_FIND_ROOT_PATH 
    ${buildroot}/zlib
    ${buildroot}/openssl
    ${buildroot}/boost
    ${buildroot}/curl
    ${buildroot}/cpprest
    /usr/arm-linux-gnueabihf)

# search for programs in the build host directories (not necessary)
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# configure LIBRARY ROOT
SET(BOOST_ROOT ${buildroot}/boost)
SET(OPENSSL_ROOT_DIR ${buildroot}/openssl)
SET(ZLIB_ROOT ${buildroot}/zlib)
SET(CURL_ROOT ${buildroot}/curl)
```
