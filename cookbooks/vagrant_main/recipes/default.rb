require_recipe "apt"
require_recipe "git"
require_recipe "zsh"
require_recipe "oh-my-zsh"
require_recipe "apache2"
require_recipe "apache2::mod_rewrite"
require_recipe "mysql"
require_recipe "php"
require_recipe "apache2::mod_php5"

# Install packages
%w{ vim screen mc subversion }.each do |a_package|
  package a_package
end

# Install ruby gems
%w{ rake }.each do |a_gem|
  gem_package a_gem
end

# Setup vhost_alias
apache_module "vhost_alias" do
  conf true
end
