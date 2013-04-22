# Description

It's a [chef](http://wiki.opscode.com/display/chef/Home) recipe

Install zsh package and use the [oh-my-zsh
plugin](https://github.com/robbyrussell/oh-my-zsh) to configure zsh

You can define it by configure like :

```
[:oh_my_zsh][:user] = [{
  :login => 'shingara',
  :theme => 'rachel',
  :plugins => ['gem', 'git', 'rails3', 'redis-cli', 'ruby']
}]

