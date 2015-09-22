apache2 Cookbook
================
[![Cookbook Version](https://img.shields.io/cookbook/v/apache2.svg?style=flat)](https://supermarket.chef.io/cookbooks/apache2)
[![Build Status](https://travis-ci.org/svanzoest-cookbooks/apache2.svg?branch=master)](https://travis-ci.org/svanzoest-cookbooks/apache2)
[![Dependency Status](http://img.shields.io/gemnasium/svanzoest-cookbooks/apache2.svg?style=flat)](https://gemnasium.com/svanzoest-cookbooks/apache2)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/svanzoest-cookbooks/apache2?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

This cookbook provides a complete Debian/Ubuntu style Apache HTTPD
configuration. Non-Debian based distributions such as Red Hat/CentOS,
ArchLinux and others supported by this cookbook will have a
configuration that mimics Debian/Ubuntu style as it is easier to
manage with Chef.

Debian-style Apache configuration uses scripts to manage modules and
sites (vhosts). The scripts are:

* a2ensite
* a2dissite
* a2enmod
* a2dismod
* a2enconf
* a2disconf

This cookbook ships with templates of these scripts for non
Debian/Ubuntu platforms. The scripts are used in the __Definitions__
below.

Requirements
============

## Ohai and Chef:

* Ohai: 0.6.12+
* Chef: 0.10.10+

As of v1.2.0, this cookbook makes use of `node['platform_family']` to
simplify platform selection logic. This attribute was introduced in
Ohai v0.6.12. The recipe methods were introduced in Chef v0.10.10. If
you must run an older version of Chef or Ohai, use [version 1.1.16 of
this cookbook](https://supermarket.chef.io/cookbooks/apache2/versions/1.1.16).

## Cookbooks:

This cookbook has no direct external dependencies.

Depending on your OS configuration and security policy, you may need
additional recipes or cookbooks for this cookbook's recipes to
converge on the node. In particular, the following Operating System
settings may affect the behavior of this cookbook:

* apt cache outdated
* SELinux enabled
* IPtables
* Compile tools
* 3rd party repositories

On Ubuntu/Debian, use Opscode's `apt` cookbook to ensure the package
cache is updated so Chef can install packages, or consider putting
apt-get in your bootstrap process or
[knife bootstrap template](http://docs.chef.io/knife_bootstrap.html)

On RHEL, SELinux is enabled by default. The `selinux` cookbook
contains a `permissive` recipe that can be used to set SELinux to
"Permissive" state. Otherwise, additional recipes need to be created
by the user to address SELinux permissions.

The easiest but **certainly not ideal way** to deal with IPtables is
to flush all rules. Chef Software does provide an `iptables` cookbook but is
migrating from the approach used there to a more robust solution
utilizing a general "firewall" LWRP that would have an "iptables"
provider. Alternately, you can use ufw, with Opscode's `ufw` and
`firewall` cookbooks to set up rules. See those cookbooks' READMEs for
documentation.

Build/compile tools may not be installed on the system by default.
Some recipes (e.g., `apache2::mod_auth_openid`) build the module from
source. Use Opscode's `build-essential` cookbook to get essential
build packages installed.

On ArchLinux, if you are using the `apache2::mod_auth_openid` recipe,
you also need the `pacman` cookbook for the `pacman_aur` LWRP. Put
`recipe[pacman]` on the node's expanded run list (on the node or in a
role). This is not an explicit dependency because it is only required
for this single recipe and platform; the pacman default recipe
performs `pacman -Sy` to keep pacman's package cache updated.

## Platforms:

The following platforms and versions are tested and supported using
[test-kitchen](http://kitchen.ci/)

* Ubuntu 12.04, 14.04
* Debian 7.6
* CentOS 6.5, 7.0

The following platform families are supported in the code, and are
assumed to work based on the successful testing on Ubuntu and CentOS.

* Red Hat (rhel)
* Fedora
* Amazon Linux

The following platforms are also supported in the code, have been
tested manually but are not tested under test-kitchen.

* SUSE/OpenSUSE
* ArchLinux
* FreeBSD

### Notes for RHEL Family:

On Red Hat Enterprise Linux and derivatives, the EPEL repository may
be necessary to install packages used in certain recipes. The
`apache2::default` recipe, however, does not require any additional
repositories. Opscode's `yum-epel` cookbook can be used to add the
EPEL repository. See __Examples__ for more information.

### Notes for FreeBSD:

Version 2.0 has been had some basic testing against FreeBSD 10.0 using
Chef 11.14.2 which has support for pkgng (CHEF-4637).

Tests
=====

This cookbook in the
[source repository](https://github.com/svanzoest-cookbooks/apache2/)
contains chefspec, serverspec and cucumber tests. This is an initial proof of
concept that will be fleshed out with more supporting infrastructure
at a future time.

Please see the CONTRIBUTING file for information on how to add tests
for your contributions.

Attributes
==========

This cookbook uses many attributes, broken up into a few different
kinds.

Platform specific
-----------------

In order to support the broadest number of platforms, several
attributes are determined based on the node's platform. See the
attributes/default.rb file for default values in the case statement at
the top of the file.

* `node['apache']['package']` - Package name for Apache2
* `node['apache']['perl_pkg']` - Package name for Perl
* `node['apache']['dir']` - Location for the Apache configuration
* `node['apache']['log_dir']` - Location for Apache logs
* `node['apache']['error_log']` - Location for the default error log
* `node['apache']['access_log']` - Location for the default access log
* `node['apache']['user']` - User Apache runs as
* `node['apache']['group']` - Group Apache runs as
* `node['apache']['binary']` - Apache httpd server daemon
* `node['apache']['conf_dir']` - Location for the main config file (e.g apache2.conf or httpd.conf)
* `node['apache']['docroot_dir']` - Location for docroot
* `node['apache']['cgibin_dir']` - Location for cgi-bin
* `node['apache']['icondir']` - Location for icons
* `node['apache']['cache_dir']` - Location for cached files used by Apache itself or recipes
* `node['apache']['pid_file']` - Location of the PID file for Apache httpd
* `node['apache']['lib_dir']` - Location for shared libraries
* `node['apache']['default_site_enabled']` - Default site enabled. Default is false.
* `node['apache']['ext_status']` - if true, enables ExtendedStatus for `mod_status`
* `node['apache']['locale'] - Locale to set in sysconfig or envvars and used for subprocesses and modules (like mod_dav and mod_wsgi). On debian systems Uses system-local if set to 'system', defaults to 'C'.

General settings
----------------

These are general settings used in recipes and templates. Default
values are noted.

* `node['apache']['version']` - Specifing 2.4 triggers apache 2.4 support. If the platform is known during our test to install 2.4 by default, it will be set to 2.4 for you. Otherwise it falls back to 2.2. This value should be specified as a string.
* `node['apache']['listen_addresses']` - Addresses that httpd should listen on. Default is any ("*").
* `node['apache']['listen_ports']` - Ports that httpd should listen on. Default is port 80.
* `node['apache']['contact']` - Value for ServerAdmin directive. Default "ops@example.com".
* `node['apache']['timeout']` - Value for the Timeout directive. Default is 300.
* `node['apache']['keepalive']` - Value for the KeepAlive directive. Default is On.
* `node['apache']['keepaliverequests']` - Value for MaxKeepAliveRequests. Default is 100.
* `node['apache']['keepalivetimeout']` - Value for the KeepAliveTimeout directive. Default is 5.
* `node['apache']['sysconfig_additional_params']` - Additionals variables set in sysconfig file. Default is empty.
* `node['apache']['default_modules']` - Array of module names. Can take "mod_FOO" or "FOO" as names, where FOO is the apache module, e.g. "`mod_status`" or "`status`".
* `node['apache']['mpm']` - With apache.version 2.4, specifies what Multi-Processing Module to enable. Default is "prefork".

The modules listed in `default_modules` will be included as recipes in `recipe[apache::default]`.

Prefork attributes
------------------

Prefork attributes are used for tuning the Apache HTTPD [prefork MPM](http://httpd.apache.org/docs/current/mod/prefork.html) configuration.

* `node['apache']['prefork']['startservers']` - initial number of server processes to start. Default is 16.
* `node['apache']['prefork']['minspareservers']` - minimum number of spare server processes. Default 16.
* `node['apache']['prefork']['maxspareservers']` - maximum number of spare server processes. Default 32.
* `node['apache']['prefork']['serverlimit']` - upper limit on configurable server processes. Default 400.
* `node['apache']['prefork']['maxrequestworkers']` - Maximum number of connections that will be processed simultaneously
* `node['apache']['prefork']['maxconnectionsperchild']` - Maximum number of request a child process will handle. Default 10000.

Worker attributes
-----------------

Worker attributes are used for tuning the Apache HTTPD [worker MPM](http://httpd.apache.org/docs/current/mod/worker.html)
configuration.

* `node['apache']['worker']['startservers']` - Initial number of server processes to start. Default 4
* `node['apache']['worker']['serverlimit']` - Upper limit on configurable server processes. Default 16.
* `node['apache']['worker']['minsparethreads']` - Minimum number of spare worker threads. Default 64
* `node['apache']['worker']['maxsparethreads']` - Maximum number of spare worker threads. Default 192.
* `node['apache']['worker']['maxrequestworkers']` - Maximum number of simultaneous connections. Default 1024.
* `node['apache']['worker']['maxconnectionsperchild']`  - Limit on the number of connections that an individual child server will handle during its life.

Event attributes
----------------

Event attributes are used for tuning the Apache HTTPD [event MPM](http://httpd.apache.org/docs/current/mod/event.html)
configuration.

* `node['apache']['event']['startservers']` - Initial number of child server processes created at startup. Default 4.
* `node['apache']['event']['serverlimit']` - Upper limit on configurable number of processes. Default 16.
* `node['apache']['event']['minsparethreads']` - Minimum number of spare worker threads. Default 64
* `node['apache']['event']['maxsparethreads']` - Maximum number of spare worker threads. Default 192.
* `node['apache']['event']['threadlimit']` - Upper limit on the configurable number of threads per child process. Default 192.
* `node['apache']['event']['threadsperchild']` - Number of threads created by each child process. Default 64.
* `node['apache']['event']['maxrequestworkers']` - Maximum number of connections that will be processed simultaneously.
* `node['apache']['event']['maxconnectionsperchild']`  - Limit on the number of connections that an individual child server will handle during its life.

Other/Unsupported MPM
---------------------

To use the cookbook with an unsupported mpm (other than prefork, event or worker):

* set `node['apache']['mpm']` to the name of the module (e.g. `itk`)
* in your cookbook, after `include_recipe 'apache2'` use the `apache_module` definition to enable/disable the required module(s)


mod\_auth\_openid attributes
----------------------------

The following attributes are in the `attributes/mod_auth_openid.rb`
file. Like all Chef attributes files, they are loaded as well, but
they're logistically unrelated to the others, being specific to the
`mod_auth_openid` recipe.

* `node['apache']['mod_auth_openid']['checksum']` - sha256sum of the tarball containing the source.
* `node['apache']['mod_auth_openid']['ref']` - Any sha, tag, or branch found from https://github.com/bmuller/mod_auth_openid
* `node['apache']['mod_auth_openid']['version']` - directory name version within the tarball
* `node['apache']['mod_auth_openid']['cache_dir']` - the cache directory is where the sqlite3 database is stored. It is separate so it can be managed as a directory resource.
* `node['apache']['mod_auth_openid']['dblocation']` - filename of the sqlite3 database used for directive `AuthOpenIDDBLocation`, stored in the `cache_dir` by default.
* `node['apache']['mod_auth_openid']['configure_flags']` - optional array of configure flags passed to the `./configure` step in the compilation of the module.

mod\_ssl attributes
-------------------

For general information on this attributes see http://httpd.apache.org/docs/current/mod/mod_ssl.html

* `node['apache']['mod_ssl']['cipher_suite']` - sets the SSLCiphersuite value to the specified string. The default is
  considered "sane" but you may need to change it for your local security policy, e.g. if you have PCI-DSS requirements. Additional
  commentary on the
  [original pull request](https://github.com/svanzoest-cookbooks/apache2/pull/15#commitcomment-1605406).
* `node['apache']['mod_ssl']['honor_cipher_order']` - Option to prefer the server's cipher preference order. Default 'On'.
* `node['apache']['mod_ssl']['insecure_renegotiation']` - Option to enable support for insecure renegotiation. Default 'Off'.
* `node['apache']['mod_ssl']['strict_sni_vhost_check']` - Whether to allow non-SNI clients to access a name-based virtual host. Default 'Off'.
* `node['apache']['mod_ssl']['session_cache']` - Configures the OCSP stapling cache. Default `shmcb:/var/run/apache2/ssl_scache`
* `node['apache']['mod_ssl']['session_cache_timeout']` - Number of seconds before an SSL session expires in the Session Cache. Default 300.
* `node['apache']['mod_ssl']['compression']` - 	Enable compression on the SSL level. Default 'Off'.
* `node['apache']['mod_ssl']['use_stapling']` - Enable stapling of OCSP responses in the TLS handshake. Default 'Off'.
* `node['apache']['mod_ssl']['stapling_responder_timeout']` - 	Timeout for OCSP stapling queries. Default 5
* `node['apache']['mod_ssl']['stapling_return_responder_errors']` - Pass stapling related OCSP errors on to client. Default 'Off'
* `node['apache']['mod_ssl']['stapling_cache']` - Configures the OCSP stapling cache. Default `shmcb:/var/run/ocsp(128000)`
* `node['apache']['mod_ssl']['pass_phrase_dialog']` - Configures SSLPassPhraseDialog. Default `builtin`
* `node['apache']['mod_ssl']['mutex']` - Configures SSLMutex. Default `file:/var/run/apache2/ssl_mutex`
* `node['apache']['mod_ssl']['directives']` - Hash for add any custom directive.

For more information on these directives and how to best secure your site see
- https://bettercrypto.org/
- https://wiki.mozilla.org/Security/Server_Side_TLS
- https://www.insecure.ws/linux/apache_ssl.html
- https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
- https://istlsfastyet.com/
- https://www.ssllabs.com/projects/best-practices/

Recipes
=======

Most of the recipes in the cookbook are for enabling Apache modules.
Where additional configuration or behavior is used, it is documented
below in more detail.

The following recipes merely enable the specified module: `mod_alias`,
`mod_auth_basic`, `mod_auth_digest`, `mod_authn_file`, `mod_authnz_ldap`,
`mod_authz_default`, `mod_authz_groupfile`, `mod_authz_host`,
`mod_authz_user`, `mod_autoindex`, `mod_cgi`, `mod_dav_fs`,
`mod_dav_svn`, `mod_deflate`, `mod_dir`, `mod_env`, `mod_expires`,
`mod_headers`, `mod_ldap`, `mod_log_config`, `mod_mime`,
`mod_negotiation`, `mod_proxy`, `mod_proxy_ajp`, `mod_proxy_balancer`,
`mod_proxy_connect`, `mod_proxy_http`, `mod_python`, `mod_rewrite`,
`mod_setenvif`, `mod_status`, `mod_wsgi`, `mod_xsendfile`.

On RHEL Family distributions, certain modules ship with a config file
with the package. The recipes here may delete those configuration
files to ensure they don't conflict with the settings from the
cookbook, which will use per-module configuration in
`/etc/httpd/mods-enabled`.

default
-------

The default recipe does a number of things to set up Apache HTTPd. It
also includes a number of modules based on the attribute
`node['apache']['default_modules']` as recipes.

mod\_auth\_cas
--------------

This recipe installs the proper package and enables the `auth_cas`
module. It can install from source or package. Package is the default,
set the attribute `node['apache']['mod_auth_cas']['from_source']` to
true to enable source installation. Modify the version to install by
changing the attribute
`node['apache']['mod_auth_cas']['source_revision']`. It is a version
tag by default, but could be master, or another tag, or branch.

The module configuration is written out with the `CASCookiePath` set,
otherwise an error loading the module may cause Apache to not start.

**Note**: This recipe does not work on EL 6 platforms unless
epel-testing repository is enabled (outside the scope of this
cookbook), or the package version 1.0.8.1-3.el6 or higher is otherwise
available to the system due to this bug:

https://bugzilla.redhat.com/show_bug.cgi?format=multiple&id=708550

mod\_auth\_openid
-----------------

**Changed via COOK-915**

This recipe compiles the module from source. In addition to
`build-essential`, some other packages are included for installation
like the GNU C++ compiler and development headers.

To use the module in your own cookbooks to authenticate systems using
OpenIDs, specify an array of OpenIDs that are allowed to authenticate
with the attribute `node['apache']['allowed_openids']`. Use the
following in a vhost to protect with OpenID authentication:

    AuthType OpenID require user <%= node['apache']['allowed_openids'].join(' ') %>
    AuthOpenIDDBLocation <%= node['apache']['mod_auth_openid']['dblocation'] %>

Change the DBLocation with the attribute as required; this file is in
a different location than previous versions, see below. It should be a
sane default for most platforms, though, see
`attributes/mod_auth_openid.rb`.

### Changes from COOK-915:

* `AuthType OpenID` instead of `AuthOpenIDEnabled On`.
* `require user` instead of `AuthOpenIDUserProgram`.
* A bug(?) in `mod_auth_openid` causes it to segfault when attempting
  to update the database file if the containing directory is not
  writable by the HTTPD process owner (e.g., www-data), even if the
  file is writable. In order to not interfere with other settings from
  the default recipe in this cookbook, the db file is moved.

mod\_fastcgi
------------

Install the fastcgi package and enable the module.

Only work on Debian/Ubuntu

mod\_fcgid
----------

Installs the fcgi package and enables the module. Requires EPEL on
RHEL family.

On RHEL family, this recipe will delete the fcgid.conf and on version
6+, create the /var/run/httpd/mod_fcgid` directory, which prevents the
emergency error:

    [emerg] (2)No such file or directory: mod_fcgid: Can't create shared memory for size XX bytes

mod\_php5
--------

Simply installs the appropriate package on Debian, Ubuntu and
ArchLinux.

On Red Hat family distributions including Fedora, the php.conf that
comes with the package is removed. On RHEL platforms less than v6, the
`php53` package is used.

* `node['apache']['mod_php5']['install_method']` - default `package` can be overridden to avoid package installs.

mod\_ssl
--------

Besides installing and enabling `mod_ssl`, this recipe will append
port 443 to the `node['apache']['listen_ports']` attribute array and
update the ports.conf.

Definitions
===========

The cookbook provides a few definitions. At some point in the future
these definitions may be refactored into lightweight resources and
providers as suggested by
[foodcritic rule FC015](http://acrmp.github.com/foodcritic/#FC015).

apache\_config
------------

Sets up configuration file for Apache from a template. The
template should be in the same cookbook where the definition is used. This is used by the `apache_conf` definition and is not often used directly.

It will use `a2enconf` and `a2disconf` to control the symlinking of configuration files between `conf-available` and `conf-enabled`.

Enable or disable an Apache config file in
`#{node['apache']['dir']}/conf-available` by calling `a2enmod` or
`a2dismod` to manage the symbolic link in
`#{node['apache']['dir']}/conf-enabled`. These config files should be created in your cookbook, and placed on the system using `apache_conf`

### Parameters:

* `name` - Name of the config enabled or disabled with the `a2enconf` or `a2disconf` scripts.
* `source`  - The location of a template file. The default `name.erb`.
* `cookbook` - The cookbook in which the configuration template is located (if it is not located in the current cookbook). The default value is the current cookbook.
* `enable` - Default true, which uses `a2enconf` to enable the config. If false, the config will be disabled with `a2disconf`.

### Examples:

Enable the example config.

``````
    apache_config 'example' do
      enable true
    end
``````

Disable a module:

``````
    apache_config 'disabled_example' do
      enable false
    end
``````

See the recipes directory for many more examples of `apache_config`.

apache\_conf
------------

Writes conf files to the `conf-available` folder, and passes enabled values to `apache_config`.

This definition should generally be called over `apache_config`.

### Parameters:

* `name` - Name of the config placed and enabled or disabled with the `a2enconf` or `a2disconf` scripts.
* `enable` - Default true, which uses `a2enconf` to enable the config. If false, the config will be disabled with `a2disconf`.
* `conf_path` - path to put the config in if you need to override the default `conf-available`.

### Examples:

Place and enable the example conf:

``````
    apache_conf 'example' do
      enable true
    end
``````

Place and disable (or never enable to begin with) the example conf:

``````
    apache_conf 'example' do
      enable false
    end
``````

Place the example conf, which has a different path than the default (conf-*):

``````
    apache_conf 'example' do
      conf_path '/random/example/path'
      enable false
    end
``````

apache\_mod
------------

Sets up configuration file for an Apache module from a template. The
template should be in the same cookbook where the definition is used.
This is used by the `apache_module` definition and is not often used
directly.

This will use a template resource to write the module's configuration
file in the `mods-available` under the Apache configuration directory
(`node['apache']['dir']`). This is a platform-dependent location. See
__apache\_module__.

### Parameters:

* `name` - Name of the template. When used from the `apache_module`,
  it will use the same name as the module.

### Examples:

Create `#{node['apache']['dir']}/mods-available/alias.conf`.

``````
    apache_mod "alias"
``````

apache\_module
--------------

Enable or disable an Apache module in
`#{node['apache']['dir']}/mods-available` by calling `a2enmod` or
`a2dismod` to manage the symbolic link in
`#{node['apache']['dir']}/mods-enabled`. If the module has a
configuration file, a template should be created in the cookbook where
the definition is used. See __Examples__.

### Parameters:

* `name` - Name of the module enabled or disabled with the `a2enmod` or `a2dismod` scripts.
* `identifier` - String to identify the module for the `LoadModule` directive. Not typically needed, defaults to `#{name}_module`
* `enable` - Default true, which uses `a2enmod` to enable the module. If false, the module will be disabled with `a2dismod`.
* `conf` - Default false. Set to true if the module has a config file, which will use `apache_mod` for the file.
* `filename` - specify the full name of the file, e.g.

### Examples:

Enable the ssl module, which also has a configuration template in `templates/default/mods/ssl.conf.erb`.

``````
    apache_module "ssl" do
      conf true
    end
``````

Enable the php5 module, which has a different filename than the module default:

``````
    apache_module "php5" do
      filename "libphp5.so"
    end
``````

Disable a module:

``````
    apache_module "disabled_module" do
      enable false
    end
``````

See the recipes directory for many more examples of `apache_module`.

apache\_site
------------

Enable or disable a VirtualHost in
`#{node['apache']['dir']}/sites-available` by calling a2ensite or
a2dissite to manage the symbolic link in
`#{node['apache']['dir']}/sites-enabled`.

The template for the site must be managed as a separate resource. To
combine the template with enabling a site, see `web_app`.

### Parameters:

* `name` - Name of the site.
* `enable` - Default true, which uses `a2ensite` to enable the site. If false, the site will be disabled with `a2dissite`.

web\_app
--------

Manage a template resource for a VirtualHost site, and enable it with
`apache_site`. This is commonly done for managing web applications
such as Ruby on Rails, PHP or Django, and the default behavior
reflects that. However it is flexible.

This definition includes some recipes to make sure the system is
configured to have Apache and some sane default modules:

* `apache2`
* `apache2::mod_rewrite`
* `apache2::mod_deflate`
* `apache2::mod_headers`

It will then configure the template (see __Parameters__ and
__Examples__ below), and enable or disable the site per the `enable`
parameter.

### Parameters:

Current parameters used by the definition:

* `name` - The name of the site. The template will be written to
  `#{node['apache']['dir']}/sites-available/#{params['name']}.conf`
* `cookbook` - Optional. Cookbook where the source template is. If
  this is not defined, Chef will use the named template in the
  cookbook where the definition is used.
* `template` - Default `web_app.conf.erb`, source template file.
* `enable` - Default true. Passed to the `apache_site` definition.

Additional parameters can be defined when the definition is called in
a recipe, see __Examples__.

### Examples:

The recommended way to use the `web_app` definition is in a application specific cookbook named "my_app".
The following example would look for a template named 'web_app.conf.erb' in your cookbook containing
the apache httpd directives defining the `VirtualHost` that would serve up "my_app".

``````
    web_app "my_app" do
       template 'web_app.conf.erb'
       server_name node['my_app']['hostname']
    end
``````

All parameters are passed into the template. You can use whatever you
like. The apache2 cookbook comes with a `web_app.conf.erb` template as
an example. The following parameters are used in the template:

* `server_name` - ServerName directive.
* `server_aliases` - ServerAlias directive. Must be an array of aliases.
* `docroot` - DocumentRoot directive.
* `application_name` - Used in RewriteLog directive. Will be set to the `name` parameter.
* `directory_index` - Allow overriding the default DirectoryIndex setting, optional
* `directory_options` - Override Options on the docroot, for example to add parameters like Includes or Indexes, optional.
* `allow_override` - Modify the AllowOverride directive on the docroot to support apps that need .htaccess to modify configuration or require authentication.

To use the default web_app, for example:

``````
    web_app "my_site" do
      server_name node['hostname']
      server_aliases [node['fqdn'], "my-site.example.com"]
      docroot "/srv/www/my_site"
      cookbook 'apache2'
    end
``````

The parameters specified will be used as:

* `@params[:server_name]`
* `@params[:server_aliases]`
* `@params[:docroot]`

In the template. When you write your own, the `@` is significant.

For more information about Definitions and parameters, see the
[Chef Wiki](http://docs.chef.io/definitions.html)

Usage
=====

Using this cookbook is relatively straightforward. Add the desired
recipes to the run list of a node, or create a role. Depending on your
environment, you may have multiple roles that use different recipes
from this cookbook. Adjust any attributes as desired. For example, to
create a basic role for web servers that provide both HTTP and HTTPS:

``````
    % cat roles/webserver.rb
    name "webserver"
    description "Systems that serve HTTP and HTTPS"
    run_list(
      "recipe[apache2]",
      "recipe[apache2::mod_ssl]"
    )
    default_attributes(
      "apache" => {
        "listen_ports" => ["80", "443"]
      }
    )
``````

For examples of using the definitions in your own recipes, see their
respective sections above.

License and Authors
===================

* Author:: Adam Jacob <adam@chef.io>
* Author:: Joshua Timberman <joshua@chef.io>
* Author:: Bryan McLellan <bryanm@widemile.com>
* Author:: Dave Esposito <esposito@espolinux.corpnet.local>
* Author:: David Abdemoulaie <github@hobodave.com>
* Author:: Edmund Haselwanter <edmund@haselwanter.com>
* Author:: Eric Rochester <err8n@virginia.edu>
* Author:: Jim Browne <jbrowne@42lines.net>
* Author:: Matthew Kent <mkent@magoazul.com>
* Author:: Nathen Harvey <nharvey@customink.com>
* Author:: Ringo De Smet <ringo.de.smet@amplidata.com>
* Author:: Sean OMeara <someara@chef.io>
* Author:: Seth Chisamore <schisamo@chef.io>
* Author:: Gilles Devaux <gilles@peerpong.com>
* Author:: Sander van Zoest <sander+cookbooks@vanzoest.com>
* Author:: Taylor Price <tayworm@gmail.com>

* Copyright:: 2009-2012, Chef Software, Inc
* Copyright:: 2011, Atriso
* Copyright:: 2011, CustomInk, LLC.
* Copyright:: 2013-2014, OneHealth Solutions, Inc.
* Copyright:: 2014, Viverae, Inc.
* Copyright:: 2015, Alexander van Zoest

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
