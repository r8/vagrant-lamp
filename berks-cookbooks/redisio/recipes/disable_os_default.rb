#
# Cookbook Name:: redisio
# Recipe:: disable_os_default
#
# Copyright 2013, Brian Bianco <brian.bianco@gmail.com>
#
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

# disable the default OS redis init script
service_name = case node['platform']
               when 'debian', 'ubuntu'
                 'redis-server'
               when 'redhat', 'centos', 'fedora', 'scientific', 'suse', 'amazon'
                 'redis'
               end

service service_name do
  action [:stop, :disable]
  only_if { service_name }
end
