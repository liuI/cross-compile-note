```
wget https://github.com/openssl/openssl/archive/OpenSSL_1_0_2r.tar.gz
tar zxvf OpenSSL_1_0_2r.tar.gz
cd openssl-1.0.2r
./Configure --prefix=/buildroot/aarch64/openssl -fPIC os/compiler:linux-aarch64
make -j 8 CC="aarch64-linux-gnu-gcc" AR="aarch64-linux-gnu-ar r" RANLIB="aarch64-linux-gnu-ranlib" && make install
```
