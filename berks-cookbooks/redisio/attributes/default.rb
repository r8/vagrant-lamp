# Cookbook Name:: redisio
# Attribute::default
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

package_bin_path = '/usr/bin'
config_dir = '/etc/redis'
default_package_install = false

case node['platform']
when 'ubuntu', 'debian'
  shell = '/bin/false'
  homedir = '/var/lib/redis'
  package_name = 'redis-server'
when 'centos', 'redhat', 'scientific', 'amazon', 'suse', 'fedora'
  shell = '/bin/sh'
  homedir = '/var/lib/redis'
  package_name = 'redis'
when 'freebsd'
  shell = '/bin/sh'
  homedir = '/var/lib/redis'
  package_name = 'redis'
  package_bin_path = '/usr/local/bin'
  config_dir = '/usr/local/etc/redis'
  default_package_install = true
else
  shell = '/bin/sh'
  homedir = '/redis'
  package_name = 'redis'
end

# Overwite template used for the Redis Server config (not sentinel)
default['redisio']['redis_config']['template_cookbook'] = 'redisio'
default['redisio']['redis_config']['template_source'] = 'redis.conf.erb'

# Install related attributes
default['redisio']['safe_install'] = true
default['redisio']['package_install'] = default_package_install
default['redisio']['package_name'] =  package_name
default['redisio']['bypass_setup'] = false

# Tarball and download related defaults
default['redisio']['mirror'] = 'http://download.redis.io/releases/'
default['redisio']['base_name'] = 'redis-'
default['redisio']['artifact_type'] = 'tar.gz'
default['redisio']['base_piddir'] = '/var/run/redis'

# Version
default['redisio']['version'] = if node['redisio']['package_install']
                                  # latest version (only for package install)
                                  nil
                                else
                                  # force version for tarball
                                  '2.8.20'
                                end

# Custom installation directory
default['redisio']['install_dir'] = nil

# Job control related options (initd, upstart, or systemd)
default['redisio']['job_control'] = if node['init_package'] == 'systemd'
                                      'systemd'
                                    elsif node['platform_family'] == 'freebsd'
                                      'rcinit'
                                    else
                                      'initd'
                                    end

# Init.d script related options
default['redisio']['init.d']['required_start'] = []
default['redisio']['init.d']['required_stop'] = []

# Default settings for all redis instances, these can be overridden on a per server basis in the 'servers' hash
default['redisio']['default_settings'] = {
  'user'                    => 'redis',
  'group'                   => 'redis',
  'homedir'                 => homedir,
  'shell'                   => shell,
  'systemuser'              => true,
  'uid'                     => nil,
  'ulimit'                  => 0,
  'configdir'               => config_dir,
  'name'                    => nil,
  'tcpbacklog'              => '511',
  'address'                 => nil,
  'databases'               => '16',
  'backuptype'              => 'rdb',
  'datadir'                 => '/var/lib/redis',
  'unixsocket'              => nil,
  'unixsocketperm'          => nil,
  'timeout'                 => '0',
  'keepalive'               => '0',
  'loglevel'                => 'notice',
  'logfile'                 => nil,
  'syslogenabled'           => 'yes',
  'syslogfacility'          => 'local0',
  'shutdown_save'           => false,
  'save'                    => nil, # Defaults to ['900 1','300 10','60 10000'] inside of template.  Needed due to lack of hash subtraction
  'stopwritesonbgsaveerror' => 'yes',
  'rdbcompression'          => 'yes',
  'rdbchecksum'             => 'yes',
  'dbfilename'              => nil,
  'slaveof'                 => nil,
  'protected_mode'          => nil, # unspecified by default but could be set explicitly to 'yes' or 'no'
  'masterauth'              => nil,
  'slaveservestaledata'     => 'yes',
  'slavereadonly'           => 'yes',
  'repldisklesssync'        => 'no',
  'repldisklesssyncdelay'   => '5',
  'replpingslaveperiod'     => '10',
  'repltimeout'             => '60',
  'repldisabletcpnodelay'   => 'no',
  'replbacklogsize'         => '1mb',
  'replbacklogttl'          => 3600,
  'slavepriority'           => '100',
  'requirepass'             => nil,
  'rename_commands'         => nil,
  'maxclients'              => 10000,
  'maxmemory'               => nil,
  'maxmemorypolicy'         => nil,
  'maxmemorysamples'        => nil,
  'appendfilename'          => nil,
  'appendfsync'             => 'everysec',
  'noappendfsynconrewrite'  => 'no',
  'aofrewritepercentage'    => '100',
  'aofrewriteminsize'       => '64mb',
  'aofloadtruncated'        => 'yes',
  'luatimelimit'            => '5000',
  'slowloglogslowerthan'    => '10000',
  'slowlogmaxlen'           => '1024',
  'notifykeyspaceevents'    => '',
  'hashmaxziplistentries'   => '512',
  'hashmaxziplistvalue'     => '64',
  'listmaxziplistentries'   => '512',
  'listmaxziplistvalue'     => '64',
  'setmaxintsetentries'     => '512',
  'zsetmaxziplistentries'   => '128',
  'zsetmaxziplistvalue'     => '64',
  'hllsparsemaxbytes'       => '3000',
  'activerehasing'          => 'yes',
  'clientoutputbufferlimit' => [
    %w(normal 0 0 0),
    %w(slave 256mb 64mb 60),
    %w(pubsub 32mb 8mb 60)
  ],
  'hz'                         => '10',
  'aofrewriteincrementalfsync' => 'yes',
  'clusterenabled'            => 'no',
  'clusterconfigfile'        => nil, # Defaults to redis instance name inside of template if cluster is enabled.
  'clusternodetimeout'       => 5000,
  'includes'                 => nil,
  'data_bag_name'            => nil,
  'data_bag_item'            => nil,
  'data_bag_key'             => nil,
  'minslavestowrite'         => nil,
  'minslavesmaxlag'          => nil,
  'breadcrumb'               => true
}

# The default for this is set inside of the "install" recipe. This is due to the way deep merge handles arrays
default['redisio']['servers'] = nil

# Define binary path
default['redisio']['bin_path'] = if node['redisio']['package_install']
                                   package_bin_path
                                 else
                                   '/usr/local/bin'
                                 end
