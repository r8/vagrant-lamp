override['apache']['mpm'] = 'prefork'

if node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 16.04
  override['mysql']['version'] = '5.7'
else
  override['mysql']['version'] = '5.6'
end

override['mysql']['port'] = '3306'
override['mysql']['initial_root_password'] = 'vagrant'

override['percona']['apt']['keyserver'] = 'hkp://keyserver.ubuntu.com:80'

override['nodejs']['repo'] = 'https://deb.nodesource.com/node_8.x'

override['postfix']['main']['relayhost'] = 'localhost:1025'
