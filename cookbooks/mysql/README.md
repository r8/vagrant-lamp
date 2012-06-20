Description
===========

Installs and configures MySQL client or server.

Requirements
============

Platform
--------

* Debian, Ubuntu
* CentOS, Red Hat, Fedora

Tested on:

* Debian 5.0
* Ubuntu 10.04
* CentOS 5.5

Cookbooks
---------

Requires Opscode's openssl cookbook for secure password generation. See _Attributes_ and _Usage_ for more information.

Requires a C compiler and Ruby development package in order to build mysql gem with native extensions. On Debian and Ubuntu systems this is satisfied by installing the "build-essential" and "ruby-dev" packages before running Chef. See USAGE below for information on how to handle this during a Chef run.

Resources and Providers
=======================

The LWRP that used to ship as part of this cookbook has been refactored into the [database](https://github.com/opscode/cookbooks/tree/master/database) cookbook.  Please see the README for details on updated usage.

Attributes
==========

* `mysql['server_root_password']` - Set the server's root password with this, default is a randomly generated password with `OpenSSL::Random.random_bytes`.
* `mysql['server_repl_password']` - Set the replication user 'repl' password with this, default is a randomly generated password with `OpenSSL::Random.random_bytes`.
* `mysql['server_debian_password']` - Set the debian-sys-maint user password with this, default is a randomly generated password with `OpenSSL::Random.random_bytes`.
* `mysql['bind_address']` - Listen address for MySQLd, default is node's ipaddress.
* `mysql['data_dir']` - Location for mysql data directory, default is "/var/lib/mysql"
* `mysql['conf_dir']` - Location for mysql conf directory, default is "/etc/mysql"
* `mysql['ec2_path']` - location of mysql data_dir on EC2 nodes, default "/mnt/mysql"

Performance tuning attributes, each corresponds to the same-named parameter in my.cnf; default values listed

* `mysql['tunable']['key_buffer']`          = "250M"
* `mysql['tunable']['max_connections']`     = "800"
* `mysql['tunable']['wait_timeout']`        = "180"
* `mysql['tunable']['net_write_timeout']`   = "30"
* `mysql['tunable']['net_write_timeout']`   = "30"
* `mysql['tunable']['back_log']`            = "128"
* `mysql['tunable']['table_cache']`         = "128"
* `mysql['tunable']['max_heap_table_size']` = "32M"
* `mysql['tunable']['expire_logs_days']`    = "10"
* `mysql['tunable']['max_binlog_size']`     = "100M"

Usage
=====

On client nodes, use the client (or default) recipe:

    include_recipe "mysql::client"

This will install the MySQL client libraries and development headers on the system. It will also install the Ruby Gem `mysql`, so that the cookbook's LWRP (above) can be used. This is done during the compile-phase of the Chef run. On platforms that are known to have a native package (currently Debian, Ubuntu, Red hat, Centos, Fedora and SUSE), the package will be installed. Other platforms will use the RubyGem.

This creates a resource object for the package and does the installation before other recipes are parsed. You'll need to have the C compiler and such (ie, build-essential on Ubuntu) before running the recipes, but we already do that when installing Chef :-).

On server nodes, use the server recipe:

    include_recipe "mysql::server"

On Debian and Ubuntu, this will preseed the mysql-server package with the randomly generated root password in the recipe file. On other platforms, it simply installs the required packages. It will also create an SQL file, /etc/mysql/grants.sql, that will be used to set up grants for the root, repl and debian-sys-maint users.

The recipe will perform a `node.save` unless it is run under `chef-solo` after the password attributes are used to ensure that in the event of a failed run, the saved attributes would be used.

**Chef Solo Note**: These node attributes are stored on the Chef server when using `chef-client`. Because `chef-solo` does not connect to a server or save the node object at all, to have the same passwords persist across `chef-solo` runs, you must specify them in the `json_attribs` file used. For example:

    {
      "mysql": {
        "server_root_password": "iloverandompasswordsbutthiswilldo",
        "server_repl_password": "iloverandompasswordsbutthiswilldo",
        "server_debian_password": "iloverandompasswordsbutthiswilldo"
      },
      "run_list":["recipe[mysql::server]"]
    }

On EC2 nodes, use the `server_ec2` recipe and the mysql data dir will be set up in the ephmeral storage.

    include_recipe "mysql::server_ec2"

When the `ec2_path` doesn't exist we look for a mounted filesystem (eg, EBS) and move the data_dir there.

The client recipe is already included by server and 'default' recipes.

For more infromation on the compile vs execution phase of a Chef run:

* http://wiki.opscode.com/display/chef/Anatomy+of+a+Chef+Run

License and Author
==================

Author:: Joshua Timberman (<joshua@opscode.com>)
Author:: AJ Christensen (<aj@opscode.com>)
Author:: Seth Chisamore (<schisamo@opscode.com>)
Author:: Brian Bianco (<brian.bianco@gmail.com>)

Copyright:: 2009-2011 Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
