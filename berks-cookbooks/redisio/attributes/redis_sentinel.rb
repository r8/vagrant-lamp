# Cookbook Name:: redisio
# Attribute::default
#
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

config_dir = if node['platform_family'] == 'freebsd'
               '/usr/local/etc/redis'
             else
               '/etc/redis'
             end

default['redisio']['sentinel_defaults'] = {
  'user'                    => 'redis',
  'configdir'               => config_dir,
  'sentinel_bind'           => nil,
  'sentinel_port'           => 26379,
  'monitor'                 => nil,
  'down-after-milliseconds' => 30000,
  'can-failover'            => 'yes',
  'parallel-syncs'          => 1,
  'failover-timeout'        => 900000,
  'loglevel'                => 'notice',
  'logfile'                 => nil,
  'syslogenabled'           => 'yes',
  'syslogfacility'          => 'local0',
  'quorum_count'            => 2,
  'data_bag_name'           => nil,
  'data_bag_item'           => nil,
  'data_bag_key'            => nil,
  'announce-ip'             => nil,
  'announce-port'           => nil,
  'notification-script'     => nil,
  'client-reconfig-script'  => nil
}

# Manage Sentinel Config File
## Will write out the base config one time then no longer manage the config allowing sentinel to take over
default['redisio']['sentinel']['manage_config'] = true # Deprecated

default['redisio']['sentinels'] = nil
