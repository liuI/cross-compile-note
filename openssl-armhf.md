```
wget https://github.com/openssl/openssl/archive/OpenSSL_1_0_2r.tar.gz
tar zxvf OpenSSL_1_0_2r.tar.gz
cd openssl-1.0.2r
./Configure --prefix=/home/i/armhf/openssl -fPIC os/compiler:arm-linux-gnueabihf
make -j 8 CC="arm-linux-gnueabihf-gcc" AR="arm-linux-gnueabihf-ar r" RANLIB="arm-linux-gnueabihf-ranlib" && make install
```
