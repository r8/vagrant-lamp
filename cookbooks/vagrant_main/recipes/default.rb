require_recipe "apt"
require_recipe "git"
require_recipe "zsh"
require_recipe "oh-my-zsh"
require_recipe "apache2"
require_recipe "mysql"
require_recipe "php"

# Install packages
%w{ screen mc subversion }.each do |a_package|
  package a_package
end

# Install ruby gems
%w{ rake }.each do |a_gem|
  gem_package a_gem
end
