#
# Cookbook Name:: apache2
# Recipe:: mod_proxy_balancer
#
# Copyright 2008-2013, Chef Software, Inc.
# Copyright 2014, OneHealth Solutions, Inc.
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

if !platform_family?('freebsd') && node['apache']['version'] == '2.4'
  include_recipe 'apache2::mod_slotmem_shm'
end

apache_module 'proxy_balancer' do
  conf true
end
