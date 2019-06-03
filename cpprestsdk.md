#### armhf

- 构建

```
cd {cpprest-source-root}
mkdir build.armhf && cd build.armhf
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_TOOLCHAIN_FILE=/home/i/armhf/armhf-gcc.cmake \
      -DCMAKE_INSTALL_PREFIX=/home/i/armhf/cpprest \
      -DCPPREST_EXCLUDE_WEBSOCKETS=1 \
      ../Release
make -j 8 && make install
```
