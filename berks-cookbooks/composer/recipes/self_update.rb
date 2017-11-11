#
# Cookbook Name:: composer
# Recipe:: self_update
#
# Copyright (c) 2016, David Joos
#

include_recipe 'composer::install'

execute 'composer-self_update' do
  cwd node['composer']['install_dir']
  command 'composer self-update'
  environment 'COMPOSER_HOME' => Composer.home_dir(node)
  action :run
  ignore_failure true
end
