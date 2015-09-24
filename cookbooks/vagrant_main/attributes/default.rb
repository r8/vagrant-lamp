override['mysql']['version'] = '5.5'
override['mysql']['port'] = '3306'
override['mysql']['data_dir'] = '/var/lib/mysql'
override['mysql']['socket'] = '/var/run/mysqld/mysqld.sock'
override['mysql']['initial_root_password'] = 'vagrant'

override['percona']['apt']['keyserver'] = 'hkp://keyserver.ubuntu.com:80'

override['nodejs']['install_method'] = 'binary'
override['nodejs']['version'] = '0.12.0'
override['nodejs']['source']['checksum'] = '9700e23af4e9b3643af48cef5f2ad20a1331ff531a12154eef2bfb0bb1682e32'
override['nodejs']['binary']['checksum']['linux_x64'] = '3bdb7267ca7ee24ac59c54ae146741f70a6ae3a8a8afd42d06204647fe9d4206'
override['nodejs']['binary']['checksum']['linux_x86'] = 'd4130512228439bf9115b7057fe145b095c1e49fa8e62c8d3e192b3dd3fe821b'

override['npm']['version'] = '2.7.4'

override['postfix']['main']['relayhost'] = 'localhost:1025'

include_attribute 'vagrant_main::php'
