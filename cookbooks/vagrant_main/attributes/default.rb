override['mysql']['server_root_password'] = 'vagrant'
override['mysql']['server_repl_password'] = 'vagrant'
override['mysql']['server_debian_password'] = 'vagrant'
override['mysql']['bind_address'] = '0.0.0.0'

override['oh_my_zsh']['users'] = [{
  :login => 'vagrant',
  :theme => 'blinks',
  :plugins => ['git', 'gem']
}]
