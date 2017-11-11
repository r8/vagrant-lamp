# Redisio Cookbook

**Please read the changelog when upgrading from the 1.x series to the 2.x series**

[![Gitter chat](https://badges.gitter.im/brianbianco/redisio.svg)](https://gitter.im/brianbianco/redisio)
[![Build Status](https://travis-ci.org/brianbianco/redisio.svg?branch=master)](https://travis-ci.org/brianbianco/redisio)
[![Cookbook Version](https://img.shields.io/cookbook/v/redisio.svg)](https://supermarket.chef.io/cookbooks/redisio)

## Description

Website:: https://github.com/brianbianco/redisio

Installs and configures Redis server instances

## Requirements

This cookbook builds redis from source or install it from packages, so it should work on any architecture for the supported distributions.  Init scripts are installed into /etc/init.d/

It depends on the ulimit cookbook: https://github.com/bmhatfield/chef-ulimit and the build-essentials cookbook: https://github.com/opscode-cookbooks/build-essential


### Platforms

* Debian, Ubuntu
* CentOS, Red Hat, Fedora, Scientific Linux
* FreeBSD

### Testing

This cookbook is tested with rspec/chefspec and test-kitchen/serverspec.  Run `bundle install` to install required gems.

* rake spec
* rake integration
* knife cookbook test redisio -o ../
* kitchen test

Tested on:

* Centos 6.9
* Centos 7.3
* Debian 7.11
* Debian 8.7
* Fedora 25
* FreeBSD 10.3
* Ubuntu 14.04
* Ubuntu 16.04

## Usage

The redisio cookbook contains LWRP for installing, configuring and managing redis and redis_sentinel.

The install recipe can build, compile and install redis from sources or install from packages. The configure recipe will configure redis and setup service resources.  These resources will be named for the port of the redis server, unless a "name" attribute was specified.  Example names would be: service["redis6379"] or service["redismaster"] if the name attribute was "master".
_NOTE: currently installation from source is not supported for FreeBSD_

The most common use case for the redisio cookbook is to use the default recipe, followed by the enable recipe.

Another common use case is to use the default, and then call the service resources created by it from another cookbook.

It is important to note that changing the configuration options of redis does not make them take effect on the next chef run.  Due to how redis works, you cannot reload a configuration without restarting the redis service.  Redis does not offer a reload option, in order to have new options be used redis must be stopped and started.

You should make sure to set the ulimit for the user you want to run redis as to be higher than the max connections you allow.
_NOTE: setting ulimit is not supported on FreeBSD since the ulimit cookbook doesn't support FreeBSD_

The disable recipe just stops redis and removes it from run levels.

The cookbook also contains a recipe to allow for the installation of the redis ruby gem.

Redis-sentinel will write configuration and state data back into its configuration file.  This creates obvious problems when that config is managed by chef. By default, this cookbook will create the config file once, and then leave a breadcrumb that will guard against the file from being updated again.

### Recipes

* configure - This recipe is used to configure redis.
* default - This is used to install the pre-requisites for building redis, and to make the LWRPs available
* disable - This recipe can be used to disable the redis service and remove it from runlevels
* enable - This recipe can be used to enable the redis services and add it to runlevels
* install - This recipe is used to install redis.
* redis_gem - This recipe can be used to install the redis ruby gem
* sentinel - This recipe can be used to install and configure sentinel
* sentinel_enable - This recipe can be used to enable the sentinel service(s)
* disable_os_default - This recipe can be used to disable the default OS redis init script

### Role File Examples

##### Install redis and setup an instance with default settings on default port, and start the service through a role file

```ruby
run_list *%w[
  recipe[redisio]
  recipe[redisio::enable]
]

default_attributes({})
```

##### Install redis with packages and setup an instance with default settings on default port, and start the service through a role file

```ruby
run_list *%w[
  recipe[redisio]
  recipe[redisio::enable]
]

default_attributes({
  'redisio' => {
    package_install: true
    version:
  }
})
```

##### Install redis, give the instance a name, and use a unix socket

```ruby
run_list *%w[
  recipe[redisio]
  recipe[redisio::enable]
]

default_attributes({
  'redisio' => {
    'servers' => [
      {'name' => 'master', 'port' => '6379', 'unixsocket' => '/tmp/redis.sock', 'unixsocketperm' => '755'},
    ]
  }
})
```

##### Install redis and pull the password from an encrypted data bag

```ruby
run_list *%w[
  recipe[redisio]
  recipe[redisio::enable]
]

default_attributes({
  'redisio' => {
    'servers' => [
      {'data_bag_name' => 'redis', 'data_bag_item' => 'auth', 'data_bag_key' => 'password'},
    ]
  }
})
```

###### Data Bag

```
{
    "id": "auth",
    "password": "abcdefghijklmnopqrstuvwxyz"
}
```

##### Install redis and setup two instances on the same server, on different ports, with one slaved to the other through a role file

```ruby
run_list *%w[
  recipe[redisio]
  recipe[redisio::enable]
]

default_attributes({
  'redisio' => {
    'servers' => [
      {'port' => '6379'},
      {'port' => '6380', 'slaveof' => { 'address' => '127.0.0.1', 'port' => '6379' }}
    ]
  }
})
```

##### Install redis and setup two instances, on the same server, on different ports, with the default data directory changed to /mnt/redis, and the second instance named

```ruby
run_list *%w[
  recipe[redisio]
  recipe[redisio::enable]
]

default_attributes({
  'redisio' => {
    'default_settings' => {'datadir' => '/mnt/redis'},
    'servers' => [{'port' => '6379'}, {'port' => '6380', 'name' => "MyInstance"}]
  }
})
```

##### Install redis and setup three instances on the same server, changing the default data directory to /mnt/redis, each instance will use a different backup type, and one instance will use a different data dir

```ruby
run_list *%w[
  recipe[redisio]
  recipe[redisio::enable]
]

default_attributes({
  'redisio' => {
    'default_settings' => { 'datadir' => '/mnt/redis/'},
    'servers' => [
      {'port' => '6379','backuptype' => 'aof'},
      {'port' => '6380','backuptype' => 'both'},
      {'port' => '6381','backuptype' => 'rdb', 'datadir' => '/mnt/redis6381'}
    ]
  }
})
```

##### Install redis 2.4.11 (lower than the default version) and turn safe install off, for the event where redis is already installed.  This will use the default settings.  Keep in mind the redis version will not actually be updated until you restart the service (either through the LWRP or manually).

```ruby
run_list *%w[
  recipe[redisio]
  recipe[redisio::enable]
]

default_attributes({
  'redisio' => {
    'safe_install' => false,
    'version'      => '2.4.11'
  }
})
```

##### Install a single redis-sentinel to listen for a master on localhost and default port number

```ruby
run_list *%w[
  recipe[redisio::sentinel]
  recipe[redisio::sentinel_enable]
]
```

#### Install redis and setup two instances, on the same server, on different ports, the second instance configuration file will be overwriten by chef

```ruby
run_list *%w[
  recipe[redisio]
  recipe[redisio::enable]
]

default_attributes({
  'redisio' => {
    'servers' => [{'port' => '6379'}, {'port' => '6380', 'breadcrumb' => false}]
  }
})
```


## LWRP Examples

Instead of using my provided recipes, you can simply depend on the redisio cookbook in your metadata and use the LWRP's yourself.  I will show a few examples of ways to use the LWRPS, detailed breakdown of options are below
in the resources/providers section

### Install Resource

It is important to note that this call has certain expectations for example, it expects the redis package to be in the format `redis-VERSION.tar.gz'.

```ruby
redisio_install "redis-installation" do
  version '2.6.9'
  download_url 'http://redis.googlecode.com/files/redis-2.6.9.tar.gz'
  safe_install false
  install_dir '/usr/local/'
end
```

### Configure Resource

The servers resource expects an array of hashes where each hash is required to contain at a key-value pair of 'port' => '<port numbers>'.

```ruby
redisio_configure "redis-servers" do
  version '2.6.9'
  default_settings node['redisio']['default_settings']
  servers node['redisio']['servers']
  base_piddir node['redisio']['base_piddir']
end
```

### Sentinel Resource

The sentinel resource installs and configures all of your redis_sentinels defined in sentinel_instances

Using the sentinel resources:

```ruby
redisio_sentinel "redis-sentinels" do
  version '2.6.9'
  sentinel_defaults node['redisio']['sentinel_defaults']
  sentinels sentinel_instances
  base_piddir node['redisio']['base_piddir']
end
```

## Attributes

Configuration options, each option corresponds to the same-named configuration option in the redis configuration file;  default values listed

* `redisio['mirror']` - mirror server with path to download redis package, default is http://download.redis.io/releases/
* `redisio['base_name']` - the base name of the redis package to be downloaded (the part before the version), default is 'redis-'
* `redisio['artifact_type']` - the file extension of the package.  currently only .tar.gz and .tgz are supported, default is 'tar.gz'
* `redisio['version']` - the version number of redis to install (also appended to the `base_name` for downloading), default is '2.8.17'
* `redisio['safe_install']` - prevents redis from installing itself if another version of redis is installed, default is true
* `redisio['base_piddir']` - This is the directory that redis pidfile directories and pidfiles will be placed in.  Since redis can run as non root, it needs to have proper
                           permissions to the directory to create its pid.  Since each instance can run as a different user, these directories will all be nested inside this base one.
* `redisio['bypass_setup']` - This attribute allows users to prevent the default recipe from calling the install and configure recipes.
* `redisio['job_control']` - This deteremines what job control type will be used.  Currently supports 'initd' or 'upstart' options.  Defaults to 'initd'.

Default settings is a hash of default settings to be applied to to ALL instances.  These can be overridden for each individual server in the servers attribute.  If you are going to set logfile to a specific file, make sure to set syslog-enabled to no.

* `redisio['default_settings']` - { 'redis-option' => 'option setting' }

Available options and their defaults

```
'user'                    => 'redis' - the user to own the redis datadir, redis will also run under this user
'group'                   => 'redis' - the group to own the redis datadir
'homedir'                 => Home directory of the user. Varies on distribution, check attributes file
'shell'                   => Users shell. Varies on distribution, check attributes file
'systemuser'              => true - Sets up the instances user as a system user
'ulimit'                  => 0 - 0 is a special value causing the ulimit to be maxconnections +32.  Set to nil or false to disable setting ulimits
'configdir'               => '/etc/redis' - configuration directory
'name'                    => nil, Allows you to name the server with something other than port.  Useful if you want to use unix sockets
'tcpbacklog'              => '511',
'address'                 => nil, Can accept a single string or an array. When using an array, the FIRST value will be used by the init script for connecting to redis
'databases'               => '16',
'backuptype'              => 'rdb',
'datadir'                 => '/var/lib/redis',
'unixsocket'              => nil - The location of the unix socket to use,
'unixsocketperm'          => nil - The permissions of the unix socket,
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
'masterauth'              => nil,
'slaveservestaledata'     => 'yes',
'slavereadonly'           => 'yes',
'repldisklesssync'        => 'no', # Requires redis 2.8.18+
'repldisklesssyncdelay'   => '5', # Requires redis 2.8.18+
'replpingslaveperiod'     => '10',
'repltimeout'             => '60',
'repldisabletcpnodelay    => 'no',
'slavepriority'           => '100',
'requirepass'             => nil,
'rename_commands'         => nil, or a hash where each key is a redis command and the value is the command's new name.
'maxclients'              => 10000,
'maxmemory'               => nil,
'maxmemorypolicy'         => nil,
'maxmemorysamples'        => nil,
'appendfilename'          => nil,
'appendfsync'             => 'everysec',
'noappendfsynconrewrite'  => 'no',
'aofrewritepercentage'    => '100',
'aofrewriteminsize'       => '64mb',
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
'clusterenabled'             => 'no',
'clusterconfigfile'          => nil, # Defaults to redis instance name inside of template if cluster is enabled.
'clusternodetimeout'         => 5000,
'includes'                   => nil,
'breadcrumb'                 => true # Defaults to create breadcrumb lock-file.
```

* `redisio['servers']` - An array where each item is a set of key value pairs for redis instance specific settings.  The only required option is 'port'.  These settings will override the options in 'default_settings', if it is left `nil` it will default to `[{'port' => '6379'}]`. If set to `[]` (empty array), no instances will be created.

The redis_gem recipe  will also allow you to install the redis ruby gem, these are attributes related to that, and are in the redis_gem attributes file.

* `redisio['gem']['name']` - the name of the gem to install, defaults to 'redis'
* `redisio['gem']['version']` -  the version of the gem to install.  if it is nil, the latest available version will be installed.

The sentinel recipe's use their own attribute file.

* `redisio['sentinel_defaults']` - { 'sentinel-option' => 'option setting' }

```
'user'                    => 'redis',
'configdir'               => '/etc/redis',
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
'quorum_count'            => 2
```

* `redisio['redisio']['sentinel']['manage_config']` - Should the cookbook manage the redis and redis sentinel config files.  This is best set to false when using redis_sentinel as it will write state into both configuration files.

* `redisio['redisio']['sentinels']` - Array of sentinels to configure on the node. These settings will override the options in 'sentinel_defaults', if it is left `nil` it will default to `[{'port' => '26379', 'name' => 'mycluster', 'master_ip' => '127.0.0.1', 'master_port' => 6379}]`. If set to `[]` (empty array), no instances will be created.

You may also pass an array of masters to monitor like so:
```
[{
  'sentinel_port' => '26379',
  'name' => 'mycluster_sentinel',
  'masters' => [
    { 'master_name' => 'master6379', 'master_ip' => '127.0.0.1', 'master_port' => 6379 },
    { 'master_name' => 'master6380', 'master_ip' => '127.0.0.1', 'master_port' => 6380 }
  ]

}]
```

## Resources/Providers

### `install`

Actions:

* `run` - perform the install (default)
* `nothing` - do nothing

Attribute Parameters

* `version` - the version of redis to download / install
* `download_url` - the URL plus filename of the redis package to install
* `download_dir` - the directory to store the downloaded package
* `artifact_type` - the file extension of the package
* `base_name` - the name of the package minus the extension and version number
* `safe_install` - a true or false value which determines if a version of redis will be installed if one already exists, defaults to true

This resource expects the following naming conventions:

package file should be in the format <base_name><version_number>.<artifact_type>

package file after extraction should be inside of the directory <base_name><version_number>

```ruby
install "redis" do
  action [:run,:nothing]
end
```

### `configure`

Actions:

* `run` - perform the configure (default)
* `nothing` - do nothing

Attribute Parameters

* `version` - the version of redis to download / install
* `base_piddir` - directory where pid files will be created
* `user` - the user to run redis as, and to own the redis files
* `group` - the group to own the redis files
* `default_settings` - a hash of the default redis server settings
* `servers` - an array of hashes containing server configurations overrides (port is the only required)

```ruby
configure "redis" do
  action [:run,:nothing]
end
```

## License and Author

Author:: [Brian Bianco](<brian.bianco@gmail.com>)
Author\_Website:: http://www.brianbianco.com
Twitter:: [@brianwbianco ](http://twitter.com/brianwbianco)
IRC:: geekbri on freenode

Copyright 2013, Brian Bianco

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
