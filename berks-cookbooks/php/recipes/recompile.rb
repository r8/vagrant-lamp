#
# Author::  David Kinzer (<dtkinzer@gmail.com>)
# Cookbook Name:: php
# Recipe:: recompile
#
# Copyright 2014, David Kinzer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

version = node['php']['version']
configure_options = node['php']['configure_options'].join(' ')
ext_dir_prefix = node['php']['ext_dir'] ? "EXTENSION_DIR=#{node['php']['ext_dir']}" : ''

node['php']['src_deps'].each do |pkg|
  package pkg do
    action 'install'
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/php-#{version}.tar.gz" do
  source "#{node['php']['url']}/php-#{version}.tar.gz/from/this/mirror"
  checksum node['php']['checksum']
  mode '0644'
  action 'create_if_missing'
end

bash 'un-pack php' do
  cwd Chef::Config[:file_cache_path]
  code "tar -zxf php-#{version}.tar.gz"
  creates "#{node['php']['url']}/php-#{version}"
end

bash 're-build php' do
  cwd "#{Chef::Config[:file_cache_path]}/php-#{version}"
  code <<-EOF
  (make clean)
  (#{ext_dir_prefix} ./configure #{configure_options})
  (make && make install)
  EOF
end
