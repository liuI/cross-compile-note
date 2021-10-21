## 准备工作:
新建文件 `~/user-config.jam`, 文件内容如下:
```
using gcc : armhf : arm-linux-gnueabihf-g++ ;
using gcc : aarch64 : aarch64-linux-gnu-g++ ;
```
## 获取源代码: 
[github](https://github.com/boostorg/boost/archive/refs/tags/boost-1.72.0.tar.gz)

## for armhf
```
./bootstrap.sh && ./b2 toolset=gcc-armhf --prefix=<somewhere> install && ./b2 --clean
```

## for aarch64
```
./bootstrap.sh && ./b2 toolset=gcc-aarch64 --prefix=<somewhere> install && ./b2 --clean
```
