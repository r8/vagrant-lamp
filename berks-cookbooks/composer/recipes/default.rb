#
# Cookbook Name:: composer
# Recipe:: default
#
# Copyright (c) 2016, David Joos
#

include_recipe 'composer::install'

if node['composer']['install_globally']
  include_recipe 'composer::global_configs'
end
