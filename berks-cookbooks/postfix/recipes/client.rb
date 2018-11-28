# Author:: Joshua Timberman(<joshua@chef.io>)
# Cookbook:: postfix
# Recipe:: client
#
# Copyright:: 2009-2017, Chef Software, Inc.
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

if Chef::Config[:solo]
  Chef::Log.info("#{cookbook_name}::#{recipe_name} is intended for use with Chef Server, use #{cookbook_name}::default with Chef Solo.")
  return
end

query = "role:#{node['postfix']['relayhost_role']}"
relayhost = ''
# if the relayhost_port attribute is not port 25, append to the relayhost
relayhost_port = node['postfix']['relayhost_port'].to_s != '25' ? ":#{node['postfix']['relayhost_port']}" : ''

# results = []

if node.run_list.roles.include?(node['postfix']['relayhost_role'])
  relayhost << node['ipaddress']
elsif node['postfix']['multi_environment_relay']
  results = search(:node, query)
  relayhost = results.map { |n| n['ipaddress'] }.first
else
  results = search(:node, "#{query} AND chef_environment:#{node.chef_environment}")
  relayhost = results.map { |n| n['ipaddress'] }.first
end

node.normal['postfix']['main']['relayhost'] = "[#{relayhost}]#{relayhost_port}"

include_recipe 'postfix'
