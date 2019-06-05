```
wget https://github.com/openssl/openssl/archive/OpenSSL_1_0_2r.tar.gz
tar zxvf OpenSSL_1_0_2r.tar.gz
cd openssl-1.0.2r
./Configure linux-generic32 --cross-compile-prefix=arm-linux-gnueabihf- --prefix=/home/i/armhf/openssl -fPIC no-asm shared
make -j 8 && make install
```
