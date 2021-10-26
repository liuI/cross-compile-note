# 简介
arm/aarch64交叉编译构建镜像，集成arm-linux-gnueabihf-gcc/g++和aarch64-linux-gnu-gcc/g++，以及基本的构建工具，如cmake、make、autoconfig等，并已内置zlib-1.2.11、openssl-1.1.1l、boost-1.72.0、curl-7.79.1、cpprestsdk-2.10.18（aarch64依赖位于镜像内文件系统目录`/home/user/aarch64`, armhf依赖位于`/home/user/armhf`）.

这里假定将镜像构建的tag为`cross-compile-image`
# 交叉编译示例
## 1.基础项目结构
```
cross-demo/
├── CMakeLists.txt
└── main.cpp
```
CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.0.0)
project(hello-world VERSION 0.1.0)

include(CTest)
enable_testing()

find_package(Threads REQUIRED)
find_package(ZLIB REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(Boost REQUIRED COMPONENTS system filesystem thread iostreams)
find_package(CURL REQUIRED)
find_library(CPPREST NAMES cpprest)

add_executable(hello-world main.cpp)
target_link_libraries(
    hello-world
    ${Threads_LIBRARIES}
    ${Boost_LIBRARIES}
    ${OPENSSL_LIBRARIES}
    ${CPPREST}
    dl
    )
```
main.cpp
```cpp
#include <iostream>
#include <boost/filesystem.hpp>
#include <cpprest/json.h>

int main(int, char**) {
    std::cout << "Hello, world!\n";

    std::cout << "test root:/tmp " << boost::filesystem::exists("/tmp") << std::endl;

    std::cout << "test cpprest::web::json " << web::json::value::object({{"field1", web::json::value(true)}}).serialize();

    return 0;
}

```

## 2.启动临时镜像，并挂载项目目录至容器
```shell
#查看本地项目目录
> ls -l
drwxrwxr-x  3 liuquan liuquan      4096 10月 26 12:10 cross-demo

#启动docker，并挂载本地项目至容器/home/user/prj目录
> docker run --rm -it -v `pwd`/cross-demo:/home/user/prj cross-compile-image

# 出现如下提示表示已进入docker容器环境
user@d1aee16c2c56:~$ 

# 检查容器环境下的项目结构是否与本地一致
user@d1aee16c2c56:~$ tree -L 2 ~
/home/user
├── aarch64
│   ├── bin
│   ├── etc
│   ├── include
│   ├── lib
│   └── share
├── armhf
│   ├── bin
│   ├── etc
│   ├── include
│   ├── lib
│   └── share
├── prj                    # 可以看到项目已成功挂载至这里
│   ├── CMakeLists.txt
│   └── main.cpp
└── user-config.jam
```

## 3.使用cmake进行交叉编译
### 说明
cmake交叉编译，需要指定以下几个参数： CMAKE_SYSTEM_NAME, CMAKE_SYSTEM_PROCESSOR, CMAKE_SYSROOT, CMAKE_PRFIX_PATH, CMAKE_C_COMPILER, CMAKE_CXX_COMPILER, CMAKE_
### 3.1 针对armhf平台
```shell
user@d1aee16c2c56:~$ mkdir -p ~/prj/build.armhf && cd ~/prj/build.armhf
```
```
user@a8c4995ee984:~/prj/build.armhf$ cmake .. \
                                    -DCMAKE_SYSTEM_NAME=Linux \
                                    -DCMAKE_SYSTEM_PROCESSOR=arm \
                                    -DCMAKE_SYSROOT=/home/user/armhf \              # 指定到附加的armhf的库路径
                                    -DCMAKE_PREFIX_PATH=/home/user/armhf \          # 指定到附加的armhf的库路径
                                    -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc \    # C  交叉编译器
                                    -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++ \  # C++交叉编译器
                                    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
                                    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
                                    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
                                    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY

-- The C compiler identification is GNU 9.3.0
-- The CXX compiler identification is GNU 9.3.0
-- Check for working C compiler: /usr/bin/arm-linux-gnueabihf-gcc
-- Check for working C compiler: /usr/bin/arm-linux-gnueabihf-gcc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /usr/bin/arm-linux-gnueabihf-g++
-- Check for working CXX compiler: /usr/bin/arm-linux-gnueabihf-g++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Looking for pthread.h
-- Looking for pthread.h - found
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD - Failed
-- Looking for pthread_create in pthreads
-- Looking for pthread_create in pthreads - not found
-- Looking for pthread_create in pthread
-- Looking for pthread_create in pthread - found
-- Found Threads: TRUE  
-- Found ZLIB: /home/user/armhf/lib/libz.so (found version "1.2.11")            #已正确找到libz
-- Found OpenSSL: /home/user/armhf/lib/libcrypto.a (found version "1.1.1l")     #已正确找到libcrypto
-- Found Boost: /home/user/armhf/lib/cmake/Boost-1.72.0/BoostConfig.cmake (found version "1.72.0") found components: system filesystem thread iostreams 
-- Found CURL: /home/user/armhf/lib/libcurl.so (found version "7.79.1-DEV")  
-- Configuring done
-- Generating done
-- Build files have been written to: /home/user/prj/build.armhf
```
```
user@a8c4995ee984:~/prj/build.armhf$ make
Scanning dependencies of target hello-world
[ 50%] Building CXX object CMakeFiles/hello-world.dir/main.cpp.o
[100%] Linking CXX executable hello-world
[100%] Built target hello-world
```
```
user@a8c4995ee984:~/prj/build.armhf$ readelf -h ./hello-world 
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Shared object file)
  Machine:                           ARM                                      #elf类型为32位arm
  Version:                           0x1
  Entry point address:               0x45d1
  Start of program headers:          52 (bytes into file)
  Start of section headers:          46356 (bytes into file)
  Flags:                             0x5000400, Version5 EABI, hard-float ABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         9
  Size of section headers:           40 (bytes)
  Number of section headers:         31
  Section header string table index: 30

```

## 3.2 针对aarch64
```shell
user@d1aee16c2c56:~$ mkdir -p ~/prj/build.aarch64 && cd ~/prj/build.aarch64
```
```shell
user@a8c4995ee984:~/prj/build.aarch64$ cmake .. \
                                    -DCMAKE_SYSTEM_NAME=Linux \
                                    -DCMAKE_SYSTEM_PROCESSOR=arm \
                                    -DCMAKE_SYSROOT=/home/user/aarch64 \              # 指定到附加的aarch64的库路径
                                    -DCMAKE_PREFIX_PATH=/home/user/aarch64 \          # 指定到附加的aarch64的库路径
                                    -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \        # C  交叉编译器
                                    -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ \      # C++交叉编译器
                                    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
                                    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
                                    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
                                    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY
        
-- The C compiler identification is GNU 9.3.0
-- The CXX compiler identification is GNU 9.3.0
-- Check for working C compiler: /usr/bin/aarch64-linux-gnu-gcc
-- Check for working C compiler: /usr/bin/aarch64-linux-gnu-gcc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /usr/bin/aarch64-linux-gnu-g++
-- Check for working CXX compiler: /usr/bin/aarch64-linux-gnu-g++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Looking for pthread.h
-- Looking for pthread.h - found
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD - Failed
-- Looking for pthread_create in pthreads
-- Looking for pthread_create in pthreads - not found
-- Looking for pthread_create in pthread
-- Looking for pthread_create in pthread - found
-- Found Threads: TRUE  
-- Found ZLIB: /home/user/aarch64/lib/libz.so (found version "1.2.11") 
-- Found OpenSSL: /home/user/aarch64/lib/libcrypto.a (found version "1.1.1l")  
-- Found Boost: /home/user/aarch64/lib/cmake/Boost-1.72.0/BoostConfig.cmake (found version "1.72.0") found components: system filesystem thread iostreams 
-- Found CURL: /home/user/aarch64/lib/libcurl.so (found version "7.79.1-DEV")  
-- Configuring done
-- Generating done
-- Build files have been written to: /home/user/prj/build.aarch64
```
```shell
user@a8c4995ee984:~/prj/build.aarch64$ make
Scanning dependencies of target hello-world
[ 50%] Building CXX object CMakeFiles/hello-world.dir/main.cpp.o
[100%] Linking CXX executable hello-world
[100%] Built target hello-world
```
```shell
user@a8c4995ee984:~/prj/build.aarch64$ readelf -h ./hello-world 
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 03 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - GNU
  ABI Version:                       0
  Type:                              DYN (Shared object file)
  Machine:                           AArch64
  Version:                           0x1
  Entry point address:               0xde90
  Start of program headers:          64 (bytes into file)
  Start of section headers:          153992 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         9
  Size of section headers:           64 (bytes)
  Number of section headers:         30
  Section header string table index: 29
```
