#
# Cookbook Name:: redisio
# Recipe:: install
#
# Copyright 2013, Brian Bianco <brian.bianco@gmail.com>
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
if node['redisio']['package_install']
  package 'redisio_package_name' do
    package_name node['redisio']['package_name']
    version node['redisio']['version'] if node['redisio']['version']
    action :install
  end
else
  include_recipe 'redisio::_install_prereqs'
  include_recipe 'build-essential::default'

  redis = node['redisio']
  location = "#{redis['mirror']}/#{redis['base_name']}#{redis['version']}.#{redis['artifact_type']}"

  redisio_install 'redis-installation' do
    version redis['version'] if redis['version']
    download_url location
    safe_install redis['safe_install']
    install_dir redis['install_dir'] if redis['install_dir']
  end
end

include_recipe 'ulimit::default'
