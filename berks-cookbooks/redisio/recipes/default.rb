#
# Cookbook Name:: redisio
# Recipe:: default
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

# debian 6.0.x fails the build_essential recipe without an apt-get update prior to run
if platform?('debian', 'ubuntu')
  execute 'apt-get-update-periodic' do
    command 'apt-get update'
    ignore_failure true
    only_if do
      !File.exist?('/var/lib/apt/periodic/update-success-stamp') ||
        File.mtime('/var/lib/apt/periodic/update-success-stamp') < Time.now - 86400
    end
  end
end

unless node['redisio']['package_install']
  include_recipe 'redisio::_install_prereqs'
  include_recipe 'build-essential::default'
end

unless node['redisio']['bypass_setup']
  include_recipe 'redisio::install'
  include_recipe 'redisio::configure'
end
