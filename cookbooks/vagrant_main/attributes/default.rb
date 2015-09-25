override['apache']['mpm'] = 'prefork'

override['mysql']['version'] = '5.5'
override['mysql']['port'] = '3306'
override['mysql']['data_dir'] = '/var/lib/mysql'
override['mysql']['socket'] = '/var/run/mysqld/mysqld.sock'
override['mysql']['initial_root_password'] = 'vagrant'

override['percona']['apt']['keyserver'] = 'hkp://keyserver.ubuntu.com:80'

override['nodejs']['install_method'] = 'binary'
override['nodejs']['version'] = '4.1.1'
override['nodejs']['source']['checksum'] = '6a610935ff52de713cf2af6a26002322e24fd7933a444436f0817a2b84e15a58'
override['nodejs']['binary']['checksum']['linux_x64'] = 'f5f7e11a503c997486d50d8683741a554bdda1d1181125a05ac5844cb29d1572'
override['nodejs']['binary']['checksum']['linux_x86'] = '3f9836b8a7e6e3d6591af6ef59e6055255439420518c3f77e0e65832a8486be1'

override['postfix']['main']['relayhost'] = 'localhost:1025'

include_attribute 'vagrant_main::php'
