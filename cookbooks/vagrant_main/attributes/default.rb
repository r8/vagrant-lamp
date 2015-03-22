default['mysql']['initial_root_password'] = 'vagrant'
default['mysql']['version'] = '5.5'
default['mysql']['port'] = '3306'

override['percona']['apt_keyserver'] = 'keyserver.ubuntu.com'

override['npm']['version'] = '1.3.11'

override['drush']['install_method'] = "git"
override['drush']['version'] = "8.x-6.x"

include_attribute 'vagrant_main::php'
