[SourceCode](https://www.openssl.org/source/openssl-1.1.1l.tar.gz)

## 解压 uncompress
```bash
tar zxf openssl-1.1.1l.tar.gz
```
## for armhf
```bash
cd ./openssl-1.1.1l && ./Configure no-shared no-zlib linux-generic32 -fPIC --prefix=/ \
  --openssldir=/etc/ssl --cross-compile-prefix=arm-linux-gnueabihf- && \
  make -j 4 && make DESTDIR=<somewhere> install && make clean
```
## for aarch64
```bash
cd ./openssl-1.1.1l && ./Configure no-shared zlib linux-aarch64   -fPIC --prefix=/ \
  --openssldir=/etc/ssl --cross-compile-prefix=aarch64-linux-gnu- && \
  make -j 4 && make DESTDIR=<somewhere> install && make clean
```

## note
注意最后的那个make ```DESTDIR=<somewhere>``` install, DESTDIR所指向的为最终安装路径
