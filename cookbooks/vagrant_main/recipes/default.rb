require_recipe "git"
require_recipe "zsh"
require_recipe "oh-my-zsh"

# Install packages
%w{ mc subversion }.each do |a_package|
  package a_package
end
