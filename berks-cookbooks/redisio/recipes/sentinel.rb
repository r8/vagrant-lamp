#
# Cookbook Name:: redisio
# Recipe:: sentinel
#
# Copyright 2013, Brian Bianco <brian.bianco@gmail.com>
# Copyright 2013, Rackspace Hosting <ryan.cleere@rackspace.com>
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
include_recipe 'redisio::_install_prereqs'
include_recipe 'redisio::install'
include_recipe 'ulimit::default'

redis = node['redisio']

sentinel_instances = redis['sentinels']
if sentinel_instances.nil?
  sentinel_instances = [
    {
      'sentinel_port' => '26379',
      'name' => 'mycluster',
      'masters' => [
        {
          'master_name' => 'mycluster_master',
          'master_ip' => '127.0.0.1',
          'master_port' => '6379'
        }
      ]
    }
  ]
end

redisio_sentinel 'redis-sentinels' do
  version redis['version'] if redis['version']
  sentinel_defaults redis['sentinel_defaults']
  sentinels sentinel_instances
  base_piddir redis['base_piddir']
end

bin_path = if node['redisio']['install_dir']
             ::File.join(node['redisio']['install_dir'], 'bin')
           else
             node['redisio']['bin_path']
           end

template '/lib/systemd/system/redis-sentinel@.service' do
  source 'redis-sentinel@.service'
  variables(
    bin_path: bin_path,
    limit_nofile: redis['default_settings']['maxclients'] + 32
  )
  only_if { node['redisio']['job_control'] == 'systemd' }
end

# Create a service resource for each sentinel instance, named for the port it runs on.
sentinel_instances.each do |current_sentinel|
  sentinel_name = current_sentinel['name']

  case node['redisio']['job_control']
  when 'initd'
    service "redis_sentinel_#{sentinel_name}" do
      # don't supply start/stop/restart commands, Chef::Provider::Service::*
      # do a fine job on it's own, and support systemd correctly
      supports start: true, stop: true, restart: true, status: false
    end
  when 'upstart'
    service "redis_sentinel_#{sentinel_name}" do
      provider Chef::Provider::Service::Upstart
      start_command "start redis_sentinel_#{sentinel_name}"
      stop_command "stop redis_sentinel_#{sentinel_name}"
      restart_command "restart redis_sentinel_#{sentinel_name}"
      supports start: true, stop: true, restart: true, status: false
    end
  when 'systemd'
    service "redis-sentinel@#{sentinel_name}" do
      provider Chef::Provider::Service::Systemd
      supports start: true, stop: true, restart: true, status: true
    end
  when 'rcinit'
    service "redis_sentinel_#{sentinel_name}" do
      provider Chef::Provider::Service::Freebsd
      supports start: true, stop: true, restart: true, status: true
    end
  else
    Chef::Log.error('Unknown job control type, no service resource created!')
  end
end
