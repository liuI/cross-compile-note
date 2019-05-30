#### armhf

- 创建cmake文件armhf-gcc.cmake：

```
# this is required
SET(CMAKE_SYSTEM_NAME Linux)

# specify the cross compiler
SET(CMAKE_C_COMPILER   arm-linux-gnueabihf-gcc)
SET(CMAKE_CXX_COMPILER arm-linux-gnueabihf-g++)

# where is the target environment 
SET(CMAKE_FIND_ROOT_PATH {to-boost-root} {to-openssl-root} /usr/arm-linux-gnueabihf)

# search for programs in the build host directories (not necessary)
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# configure LIBRARY ROOT
SET(BOOST_ROOT {to-boost-root})
SET(OPENSSL_ROOT_DIR {to-openssl-root})
```

- 构建

```
cd {cpprest-source-root}
mkdir build.armhf && cd build.armhf
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=armhf-gcc.cmake -DCMAKE_INSTALL_PREFIX=/buildroot/cpprest -DCPPREST_EXCLUDE_WEBSOCKETS=1 ../Release
make -j 8 && make install
```
