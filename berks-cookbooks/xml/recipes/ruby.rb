#
# Cookbook Name:: xml
# Recipe:: ruby
#
# Author:: Joseph Holsten (<joseph@josephholsten.com>)
#
# Copyright 2008-2013, Chef Software, Inc.
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

include_recipe 'chef-sugar'

execute 'apt-get update' do
  ignore_failure true
  action :nothing
end.run_action(:run) if 'debian' == node['platform_family']

node.default['build-essential']['compile_time'] = true
node.default['xml']['compiletime'] = true
include_recipe 'build-essential::default'
include_recipe 'xml::default'

if node['xml']['nokogiri']['use_system_libraries']
  if node['xml']['nokogiri']['version'].nil? ||
     version(node['xml']['nokogiri']['version']).satisfies?('> 1.6.1')
    Chef::Application.fatal!("You must specify a version less than or equal to 1.6.1 of nokogiri to use system libraries. You set: #{node['xml']['nokogiri']['version']}.")
  else
    ENV['NOKOGIRI_USE_SYSTEM_LIBRARIES'] = node['xml']['nokogiri']['use_system_libraries'].to_s
  end
end

chef_gem 'nokogiri' do
  version node['xml']['nokogiri']['version']
  action :install
end
