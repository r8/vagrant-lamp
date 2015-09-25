#
# Cookbook Name:: chef-vault
# Recipe:: default
#
# Author: Joshua Timberman <joshua@getchef.com>
#
# Copyright (c) 2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

chef_gem 'chef-vault' do
  version node['chef-vault']['version']
  compile_time true if Chef::Resource::ChefGem.instance_methods(false).
                                               include?(:compile_time)
  source node['chef-vault']['gem_source'] if node['chef-vault']['gem_source']
end

require 'chef-vault'
