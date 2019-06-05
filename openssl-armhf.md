
### 关于交叉编译时，--prefix和--openssldir选项
在只指定--prefix参数的情况下，如果指定的路径是自定义、非标准的路径，极有可能在目标板环境出现SSL证书错误；
原因时在没指定--openssldir参数的情况下，这个参数会与--prefix保持一致.在执行时，libcrypto会从--openssldir参数的路径中去找客户端证书，假如目标环境中不存在--openssldir参数的路径，那么SSL在握手期间，将找不到证书而导致SSL证书错误（当然，关掉SSL客户端证书认证是另一回事）。
所以最好是同时指定这两个参数，并且让--openssldir参数的值，与目标环境上的保持一致，以此来复用目标环境的证书（因为暂时不知道怎么额外添加证书目录），一般Debian的目录是“/etc/ssl”。
在编译结束、安装时，为了防止影响HOST环境的ssl， 需要在make install额外加入INSTALL_PREFIX参数，去指定安装的位置
而--prefix的值表示lib、include等文件的安装路径，在指定的INSTALL_PREFIX的情况下，那么这个参数也就可以为根“/”,所以编译指令为：

-------------
```
wget https://github.com/openssl/openssl/archive/OpenSSL_1_0_2r.tar.gz
tar zxvf OpenSSL_1_0_2r.tar.gz
cd openssl-1.0.2r
./Configure linux-generic32 no-asm shared --prefix=/ --openssldir=/etc/ssl --cross-compile-prefix=arm-linux-gnueabihf- -fPIC
make -j 8 && make install INSTALL_PREFIX=/home/i/armhf
```
