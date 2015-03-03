#
# Cookbook Name:: composer
# Recipe:: default
#
# Copyright 2012-2014, Escape Studios
#

include_recipe 'composer::install'

if node['composer']['install_globally']
  include_recipe 'composer::global_configs'
end
