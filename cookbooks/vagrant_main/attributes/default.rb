override['mysql']['server_root_password'] = 'vagrant'
override['mysql']['server_repl_password'] = 'vagrant'
override['mysql']['server_debian_password'] = 'vagrant'
override['mysql']['bind_address'] = '0.0.0.0'

override['oh_my_zsh']['users'] = [{
  :login => 'vagrant',
  :theme => 'blinks',
  :plugins => ['git', 'gem']
}]

override['nodejs']['install_method'] = 'binary'
override['nodejs']['version'] = '0.10.13'
override['nodejs']['checksum'] = 'a102fad260d216b95611ddd57aeb6531c92ad1038508390654423feb1b51c059'
override['nodejs']['checksum_linux_x86'] = 'ea7332fcbbee8e33c2f7d9b0e75c9bb299f276b334b26752725aa8b9b0ee3c99'
override['nodejs']['checksum_linux_x64'] = 'dcbad86b863faf4a1e10fec9ecd7864cebbbb6783805f1808f563797ce5db2b8'

override['npm']['version'] = '1.3.11'

override['drush']['install_method'] = "git"
override['drush']['version'] = "8.x-6.x"
