Description
===========

Installs and configures Microsoft Internet Information Services (IIS) 7.0/7.5/8.0

Requirements
============

Platform
--------

* Windows Vista
* Windows 7
* Windows 8
* Windows Server 2008 (R1, R2)
* Windows Server 2012
* Windows Server 2012R2

Windows 2003R2 is *not* supported because it lacks Add/Remove Features.

Cookbooks
---------

* windows

Attributes
==========

* `node['iis']['home']` - IIS main home directory. default is `%WINDIR%\System32\inetsrv`
* `node['iis']['conf_dir']` - location where main IIS configs lives. default is `%WINDIR%\System32\inetsrv\config`
* `node['iis']['pubroot']` - . default is `%SYSTEMDRIVE%\inetpub`
* `node['iis']['docroot']` - IIS web site home directory. default is `%SYSTEMDRIVE%\inetpub\wwwroot`
* `node['iis']['log_dir']` - location of IIS logs. default is `%SYSTEMDRIVE%\inetpub\logs\LogFiles`
* `node['iis']['cache_dir']` - location of cached data. default is `%SYSTEMDRIVE%\inetpub\temp`

Resource/Provider
=================

iis_site
---------

Allows easy management of IIS virtual sites (ie vhosts).

### Actions

- `:add` - add a new virtual site
- `:config` - apply configuration to an existing virtual site
- `:delete` - delete an existing virtual site
- `:start` - start a virtual site
- `:stop` - stop a virtual site
- `:restart` - restart a virtual site

### Attribute Parameters

- `product_id` - name attribute. Specifies the ID of a product to install.
- `site_name` - name attribute.
- `site_id` - if not given IIS generates a unique ID for the site
- `path` - IIS will create a root application and a root virtual directory mapped to this specified local path
- `protocol` - http protocol type the site should respond to. valid values are :http, :https. default is :http
- `port` - port site will listen on. default is 80
- `host_header` - host header (also known as domains or host names) the site should map to. default is all host headers
- `options` - additional options to configure the site
- `bindings` - Advanced options to configure the information required for requests to communicate with a Web site. See http://www.iis.net/configreference/system.applicationhost/sites/site/bindings/binding for parameter format. When binding is used, port protocol and host_header should not be used.
- `application_pool` - set the application pool of the site
- `options` - support for additional options -logDir, -limits, -ftpServer, etc...
- `log_directory` - specifies the logging directory, where the log file and logging-related support files are stored.
- `log_period` - specifies how often iis creates a new log file
- `log_truncsize` - specifies the maximum size of the log file (in bytes) after which to create a new log file.

### Examples

```ruby
# stop and delete the default site
iis_site 'Default Web Site' do
  action [:stop, :delete]
end
```

```ruby
# create and start a new site that maps to
# the physical location C:\inetpub\wwwroot\testfu
iis_site 'Testfu Site' do
  protocol :http
  port 80
  path "#{node['iis']['docroot']}/testfu"
  action [:add,:start]
end
```

```ruby
# do the same but map to testfu.chef.io domain
iis_site 'Testfu Site' do
  protocol :http
  port 80
  path "#{node['iis']['docroot']}/testfu"
  host_header "testfu.chef.io"
  action [:add,:start]
end
```

```ruby
# create and start a new site that maps to
# the physical C:\inetpub\wwwroot\testfu
# also adds bindings to http and https
# binding http to the ip address 10.12.0.136,
# the port 80, and the host header www.domain.com
# also binding https to any ip address,
# the port 443, and the host header www.domain.com
iis_site 'FooBar Site' do
  bindings "http/10.12.0.136:80:www.domain.com,https/*:443:www.domain.com
  path "#{node['iis']['docroot']}/testfu"
  action [:add,:start]
end
```

iis_config
-----------
Runs a config command on your IIS instance.

### Actions

- `:config` - Runs the configuration command

### Attribute Parameters

- `cfg_cmd` - name attribute. What ever command you would pass in after "appcmd.exe set config"

### Example

```ruby
# Sets up logging
iis_config "/section:system.applicationHost/sites /siteDefaults.logfile.directory:\"D:\\logs\"" do
    action :config
end
```

```ruby
# Loads an array of commands from the node
cfg_cmds = node['iis']['cfg_cmd']
cfg_cmds.each do |cmd|
    iis_config "#{cmd}" do
        action :config
    end
end
```

iis_pool
---------
Creates an application pool in IIS.

### Actions

- `:add` - add a new application pool
- `:config` - apply configuration to an existing application pool
- `:delete` - delete an existing application pool
- `:start` - start a application pool
- `:stop` - stop a application pool
- `:restart` - restart a application pool
- `:recycle` - recycle an application pool

### Attribute Parameters

#### Root Items
- `pool_name` - name attribute. Specifies the name of the pool to create.
- `runtime_version` - specifies what .NET version of the runtime to use.
- `pipeline_mode` - specifies what pipeline mode to create the pool with, valid values are :Integrated or :Classic, the default is :Integrated
- `no_managed_code` - allow Unmanaged Code in setting up IIS app pools is shutting down. - default is true - optional

#### Add Items
- `start_mode` - Specifies the startup type for the application pool - default :OnDemand (:OnDemand, :AlwaysRunning) - optional
- `auto_start` - When true, indicates to the World Wide Web Publishing Service (W3SVC) that the application pool should be automatically started when it is created or when IIS is started. - boolean: default true - optional
- `queue_length` - Indicates to HTTP.sys how many requests to queue for an application pool before rejecting future requests. - default is 1000 - optional
- `thirty_two_bit` - set the pool to run in 32 bit mode, valid values are true or false, default is false - optional

#### Process Model Items
- `max_proc` - specifies the number of worker processes associated with the pool.
- `load_user_profile` - This property is used only when a service starts in a named user account. - Default is false - optional
- `pool_identity` - the account identity that they app pool will run as, valid values are :SpecificUser, :NetworkService, :LocalService, :LocalSystem, :ApplicationPoolIdentity
- `pool_username` - username for the identity for the application pool
- `pool_password` password for the identity for the application pool is started. Default is true - optional
- `logon_type` - Specifies the logon type for the process identity. (For additional information about [logon types](http://msdn.microsoft.com/en-us/library/aa378184%28VS.85%29.aspx), see the LogonUser Function topic on Microsoft's MSDN Web site.) - Available [:LogonBatch, :LogonService] - default is :LogonBatch - optional
- `manual_group_membership` - Specifies whether the IIS_IUSRS group Security Identifier (SID) is added to the worker process token. When false, IIS automatically uses an application pool identity as though it were a member of the built-in IIS_IUSRS group, which has access to necessary file and system resources. When true, an application pool identity must be explicitly added to all resources that a worker process requires at runtime. - default is false - optional
- `idle_timeout` - Specifies how long (in minutes) a worker process should run idle if no new requests are received and the worker process is not processing requests. After the allocated time passes, the worker process should request that it be shut down by the WWW service. - default is '00:20:00' - optional
- `shutdown_time_limit` - Specifies the time that the W3SVC service waits after it initiated a recycle. If the worker process does not shut down within the shutdownTimeLimit, it will be terminated by the W3SVC service. - default is '00:01:30' - optional
- `startup_time_limit` - Specifies the time that IIS waits for an application pool to start. If the application pool does not startup within the startupTimeLimit, the worker process is terminated and the rapid-fail protection count is incremented. - default is '00:01:30' - optional
- `pinging_enabled` - Specifies whether pinging is enabled for the worker process. - default is true - optional
- `ping_interval` - Specifies the time between health-monitoring pings that the WWW service sends to a worker process - default is '00:00:30' - optional
- `ping_response_time` - Specifies the time that a worker process is given to respond to a health-monitoring ping. After the time limit is exceeded, the WWW service terminates the worker process - default is '00:01:30' - optional

#### Recycling Items
- `disallow_rotation_on_config_change` - The DisallowRotationOnConfigChange property specifies whether or not the World Wide Web Publishing Service (WWW Service) should rotate worker processes in an application pool when the configuration has changed. - Default is false - optional
- `disallow_overlapping_rotation` - Specifies whether the WWW Service should start another worker process to replace the existing worker process while that process
- `recycle_after_time` - specifies a pool to recycle at regular time intervals, d.hh:mm:ss, d optional
- `recycle_at_time` - schedule a pool to recycle at a specific time, d.hh:mm:ss, d optional
- `private_mem` - specifies the amount of private memory (in kilobytes) after which you want the pool to recycle

#### Failure Items
- `load_balancer_capabilities` - Specifies behavior when a worker process cannot be started, such as when the request queue is full or an application pool is in rapid-fail protection. - default is :HttpLevel - optional
- `orphan_worker_process` - Specifies whether to assign a worker process to an orphan state instead of terminating it when an application pool fails. - default is false - optional
- `orphan_action_exe` - Specifies an executable to run when the WWW service orphans a worker process (if the orphanWorkerProcess attribute is set to true). You can use the orphanActionParams attribute to send parameters to the executable. - optional
- `orphan_action_params` - Indicates command-line parameters for the executable named by the orphanActionExe attribute. To specify the process ID of the orphaned process, use %1%. - optional
- `rapid_fail_protection` - Setting to true instructs the WWW service to remove from service all applications that are in an application pool - default is true - optional
- `rapid_fail_protection_interval` - Specifies the number of minutes before the failure count for a process is reset. - default is '00:05:00' - optional
- `rapid_fail_protection_max_crashes` - Specifies the maximum number of failures that are allowed within the number of minutes specified by the rapidFailProtectionInterval attribute. - default is 5 - optional
- `auto_shutdown_exe` - Specifies an executable to run when the WWW service shuts down an application pool. - optional
- `auto_shutdown_params` - Specifies command-line parameters for the executable that is specified in the autoShutdownExe attribute. - optional

#### CPU Items
- `cpu_action` - Configures the action that IIS takes when a worker process exceeds its configured CPU limit. The action attribute is configured on a per-application pool basis. - Available options [:NoAction, :KillW3wp, :Throttle, :ThrottleUnderLoad] - default is :NoAction - optional
- `cpu_limit` - Configures the maximum percentage of CPU time (in 1/1000ths of one percent) that the worker processes in an application pool are allowed to consume over a period of time as indicated by the resetInterval attribute. If the limit set by the limit attribute is exceeded, an event is written to the event log and an optional set of events can be triggered. These optional events are determined by the action attribute. - default is 0 - optional
- `cpu_reset_interval` - Specifies the reset period (in minutes) for CPU monitoring and throttling limits on an application pool. When the number of minutes elapsed since the last process accounting reset equals the number specified by this property, IIS resets the CPU timers for both the logging and limit intervals. - default is '00:05:00' - optional
- `cpu_smp_affinitized` - Specifies whether a particular worker process assigned to an application pool should also be assigned to a given CPU. - default is false - optional
- `smp_processor_affinity_mask` - Specifies the hexadecimal processor mask for multi-processor computers, which indicates to which CPU the worker processes in an application pool should be bound. Before this property takes effect, the smpAffinitized attribute must be set to true for the application pool. - default is 4294967295 - optional
- `smp_processor_affinity_mask_2` - Specifies the high-order DWORD hexadecimal processor mask for 64-bit multi-processor computers, which indicates to which CPU the worker processes in an application pool should be bound. Before this property takes effect, the smpAffinitized attribute must be set to true for the application pool. - default is 4294967295 - optional

### Example

```ruby
# creates a new app pool
iis_pool 'myAppPool_v1_1' do
  runtime_version "2.0"
  pipeline_mode :Classic
  action :add
end
```

iis_app
--------

Creates an application in IIS.

### Actions

- `:add` - add a new application pool
- `:delete` - delete an existing application pool

### Attribute Parameters

- `site_name` - name attribute. The name of the site to add this app to
- `path` -The virtual path for this application
- `application_pool` - The pool this application belongs to
- `physical_path` - The physical path where this app resides.
- `enabled_protocols` - The enabled protocols that this app provides (http, https, net.pipe, net.tcp, etc)

### Example

```ruby
# creates a new app
iis_app "myApp" do
  path "/v1_1"
  application_pool "myAppPool_v1_1"
  physical_path "#{node['iis']['docroot']}/testfu/v1_1"
  enabled_protocols "http,net.pipe"
  action :add
end
```

iis_vdir
---------

Allows easy management of IIS virtual directories (i.e. vdirs).

### Actions

- :add: - add a new virtual directory
- :delete: - delete an existing virtual directory
- :config: - configure a virtual directory

### Attribute Parameters

- `application_name`: name attribute. Specifies the name of the application attribute.  This is the name of the website or application you are adding it to.
- `path`: The virtual directory path on the site.
- `physical_path`: The physical path of the virtual directory on the disk.
- `username`: (optional) The username required to logon to the physical_path. If set to "" will clear username and password.
- `password`: (optional) The password required to logon to the physical_path
- `logon_method`: (optional, default: :ClearText) The method used to logon (:Interactive, :Batch, :Network, :ClearText). For more information on these types, see "LogonUser Function", Read more at [MSDN](http://msdn2.microsoft.com/en-us/library/aa378184.aspx)
- `allow_sub_dir_config`: (optional, default: true) Boolean that specifies whether or not the Web server will look for configuration files located in the subdirectories of this virtual directory. Setting this to false can improve performance on servers with very large numbers of web.config files, but doing so prevents IIS configuration from being read in subdirectories.

### Examples

```ruby
# add a virtual directory to default application
iis_vdir 'Default Web Site/' do
  action :add
  path '/Content/Test'
  physical_path 'C:\wwwroot\shared\test'
end
```

```ruby
# add a virtual directory to an application under a site
iis_vdir 'Default Web Site/my application' do
  action :add
  path '/Content/Test'
  physical_path 'C:\wwwroot\shared\test'
end
```

```ruby
# adds a virtual directory to default application which points to a smb share. (Remember to escape the "\"'s)
iis_vdir 'Default Web Site/' do
  action :add
  path '/Content/Test'
  physical_path '\\\\sharename\\sharefolder\\1'
end
```

```ruby
# configure a virtual directory to have a username and password
iis_vdir 'Default Web Site/' do
  action :config
  path '/Content/Test'
  username 'domain\myspecialuser'
  password 'myspecialpassword'
end
```

```ruby
# delete a virtual directory from the default application
iis_vdir 'Default Web Site/' do
  action :delete
  path '/Content/Test'
end
```

iis_section
---------

Allows for the locking/unlocking of sections ([listed here](http://www.iis.net/configreference) or via the command `appcmd list config \"\"  /config:* /xml`)

This is valuable to allow the `web.config` of an individual application/website control it's own settings.

### Actions

- `:lock`: - locks the `section` passed
- `:unlock`: - unlocks the `section` passed

### Attribute Parameters

- `section`: The name of the section to lock.
- `returns`: The result of the `shell_out` command.

### Examples

```ruby
# Sets the IIS global windows authentication to be locked globally
iis_section 'locks global configuration of windows auth' do
  section 'system.webServer/security/authentication/windowsAuthentication'
  action :lock
end
```

```ruby
# Sets the IIS global Basic authentication to be locked globally
iis_section 'locks global configuration of Basic auth' do
  section 'system.webServer/security/authentication/basicAuthentication'
  action :lock
end
```

```ruby
# Sets the IIS global windows authentication to be unlocked globally
iis_section 'unlocked web.config globally for windows auth' do
  action :unlock
  section 'system.webServer/security/authentication/windowsAuthentication'
end
```

```ruby
# Sets the IIS global Basic authentication to be unlocked globally
iis_section 'unlocked web.config globally for Basic auth' do
  action :unlock
  section 'system.webServer/security/authentication/basicAuthentication'
end
```

iis_module
--------

Manages modules globally or on a per site basis.

### Actions

- `:add` - add a new module
- `:delete` - delete a module

### Attribute Parameters

- `module_name` - The name of the module to add or delete
- `type` - The type of module
- `precondition` - precondition for module
- `application` - The application or site to add the module to

### Example

```ruby
# Adds a module called "My 3rd Party Module" to mySite/
iis_module "My 3rd Party Module" do
  application "mySite/"
  precondition "bitness64"
  action :add
end
```

```ruby
# Adds a module called "MyModule" to all IIS sites on the server
iis_module "MyModule"
```


Usage
=====

default
-------

Installs and configures IIS 7.0/7.5/8.0 using the default configuration.

mod_*
-----

This cookbook also contains recipes for installing individual IIS modules (extensions).  These recipes can be included in a node's run_list to build the minimal desired custom IIS installation.

* `mod_aspnet` - installs ASP.NET runtime components
* `mod_aspnet45` - installs ASP.NET 4.5 runtime components
* `mod_auth_basic` - installs Basic Authentication support
* `mod_auth_windows` - installs Windows Authentication (authenticate clients by using NTLM or Kerberos) support
* `mod_compress_dynamic` - installs dynamic content compression support. *PLEASE NOTE* - enabling dynamic compression always gives you more efficient use of bandwidth, but if your server's processor utilization is already very high, the CPU load imposed by dynamic compression might make your site perform more slowly.
* `mod_compress_static` - installs static content compression support
* `mod_iis6_metabase_compat` - installs IIS 6 Metabase Compatibility component.
* `mod_isapi` - installs ISAPI (Internet Server Application Programming Interface) extension and filter support.
* `mod_logging` - installs and enables HTTP Logging (logging of Web site activity), Logging Tools (logging tools and scripts) and Custom Logging (log any of the HTTP request/response headers, IIS server variables, and client-side fields with simple configuration) support
* `mod_management` - installs Web server Management Console which supports management of local and remote Web servers
* `mod_security` - installs URL Authorization (Authorizes client access to the URLs that comprise a Web application), Request Filtering (configures rules to block selected client requests) and IP Security (allows or denies content access based on IP address or domain name) support.
* `mod_tracing` -  installs support for tracing ASP.NET applications and failed requests.

Note: Not every possible IIS module has a corresponding recipe. The foregoing recipes are included for convenience, but users may also place additional IIS modules that are installable as Windows features into the ``node['iis']['components']`` array.

License and Author
==================

* Author:: Seth Chisamore (<schisamo@chef.io>)
* Author:: Julian Dunn (<jdunn@chef.io>)
* Author:: Justin Schuhmann (<jmschu02@gmail.com>)

Copyright:: 2011-2015, Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
