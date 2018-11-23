centos 6.6编译安装mongodb v4.0说明文档

1. 升级gcc编译器版本为gcc 5.4.0
   wget http://mirror.koddos.net/gcc/releases/gcc-5.4.0/gcc-5.4.0.tar.gz
   tar xzf gcc-5.4.0.tar.gz
   cd gcc-5.4.0

   ./contrib/download_prerequisites
   ./configure  --prefix=`pwd`/gcc_bin --enable-checking=release --enable-languages=c,c++ --disable-multilib
   make -j 16 && make install

2. 安装libcurl相关库
   yum install libcurl-devel

3. 升级python版本为python 2.7.13 (参考：https://www.cnblogs.com/gne-hwz/p/8586430.html)
   wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz

   tar zxf Python-2.7.13.tgz && cd Python-2.7.13
   ./configure --prefix=/usr/local/python-2.7.13
   make -j2 && make install

   mv /usr/bin/python /usr/bin/python.2.6.6
   ln -sf /usr/local/python-2.7.13/bin/python2.7 /usr/bin/python
   mkdir /usr/lib/python2.7/site-packages -p
   cp /usr/local/python-2.7.13/lib/python2.7/site-packages/README /usr/lib/python2.7/site-packages/
   但安装完后我们python2.7.13的模块还是空了，连setuptools工具都没有，pip也没有，我们yum安装功能也用不了

   1）先解决yum问题,输入下面命令查看旧版python的全名应该会有一个python2.6
    ls /usr/bin |grep python
    编辑yum的脚本文件
    vi /usr/bin/yum
    修改 #!/usr/bin/python 为 #!/usr/bin/python.2.6.6

   2）将setuptools模块安装到新版python2.7目录lib/site-packages/下
    在http://distfiles.macports.org/py-setuptools/下载源码包并编译安装
    wget http://distfiles.macports.org/py-setuptools/setuptools-38.6.0.zip
    unzip setuptools-38.6.0.zip
    使用新版本的python安装: python setup.py install

    这里如果报错，Compression requires the (missing) zlib module。缺少zlib模块
        先安装缺少的模块 
	        yum install zlib 
	        yum install zlib-devel 
	    将python2.7.5重新进行编译安装
	        cd /home/Python-2.7.5
	    编译，如果有报错，先跳过，直接下一步
	        make
	    安装
	        make install
	    进入到setuptools-38.6.0目录
	        cd /home/setuptools-38.6.0
	    再次安装，应该不会再报错了
	        python setup.py install

   3）pip模块的安装
    在https://pypi.python.org/pypi/pip下载源码包并编译安装
    wget https://files.pythonhosted.org/packages/c4/44/e6b8056b6c8f2bfd1445cc9990f478930d8e3459e9dbf5b8e2d2922d64d3/pip-9.0.3.tar.gz
    tar xzf pip-9.0.3.tar.gz
    由于pip安装包依赖于setuptools模块，所以可以直接安装：python setup.py install
    查看pip版本：/usr/local/python-2.7.13/bin/pip -V

    或者也可以通过如下方式安装最新pip：
    wget https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    /usr/local/python-2.7.13/bin/pip -V

    到这里，就完成了python版本的基本升级，后面就可以通过pip进行软件安装

4. 编译mongo
  1) 安装python相关模块
    cd mongo
    /usr/local/python-2.7.13/bin/pip2 install -r buildscripts/requirements.txt

  2）编译mongodb

    不需要升级系统指定gcc、g++版本的mongodb v4.0编译方式，修改SConstruct中如下内容：
    env_vars.Add('CC',
        help='Select the C compiler to use',
        default=['/root/data1/works/projs/deps/gcc-5.4.0/gcc_bin/bin/gcc'])

  	env_vars.Add('CXX',
        help='Select the C++ compiler to use',
        default=['/root/data1/works/projs/deps/gcc-5.4.0/gcc_bin/bin/g++'])

    env_vars.Add('LIBPATH',
        help='Adds paths to the linker search path',
        converter=variable_shlex_converter,
        default=['/root/data1/works/projs/deps/gcc-5.4.0/gcc_bin/lib64'])

    env_vars.Add('LINKFLAGS',
        help='Sets flags for the linker',
        converter=variable_shlex_converter,
        default=["-static-libgcc", "-static-libstdc++"])

  cd mongo
  python2 buildscripts/scons.py all

