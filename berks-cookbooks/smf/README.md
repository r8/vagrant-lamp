SMF
===

## Description

Service Management Facility (SMF) is a tool in many Illumos and Solaris-derived operating systems
that treats services as first class objects of the system. It provides an XML syntax for 
declaring how the system can interact with and control a service.

The SMF cookbook contains providers for creating or modifying a service within the SMF framework.


## Requirements

Any operating system that uses SMF, ie Solaris, SmartOS, OpenIndiana etc.

The `smf` provider depends on the `builder` gem, which can be installed
via the `smf::default` recipe.

Requires the RBAC cookbook, which can be found at <https://supermarket.getchef.com/cookbooks/rbac>.

Processes can be run inside a project wrapper. In this case, look to the Resource Control cookbook,
which can be found at <https://supermarket.getchef.com/cookbooks/resource-control>. Note that the SMF LWRP
does not create or manage the project.


## Basic Usage

Note that we run the `smf::default` recipe before using LWRPs from this
cookbook.

```ruby
include_recipe 'smf'

smf 'my-service' do
  user 'non-root-user'
  start_command 'my-service start'
  start_timeout 10
  stop_command 'pkill my-service'
  stop_timeout  5
  restart_command 'my-service restart'
  restart_timeout 60
  environment 'PATH' => '/home/non-root-user/bin',
              'RAILS_ENV' => 'staging'
  locale 'C'
  manifest_type 'application'
  service_path  '/var/svc/manifest'
  notifies :restart, 'service[my-service]'
end

service 'my-service' do
  action :enable
end

service 'my-service' do
  action :restart
end
```


## Attributes

Ownership:
* `user` - User to run service commands as
* `group` - Group to run service commands as

RBAC
* `authorization` - What management and value authorizations should be
  created for this service. Defaults to the service name.

Dependency management:
* `include_default_dependencies` - Service should depend on file system
  and network services. Defaults to `true`. See [Dependencies](#dependencies)
  for more info.
* `dependency` - an optional array of hashes signifying service and path
  dependencies for this service to run. See [Dependencies](#dependencies).

Process management:
* `project` - Name of project to run commands in
* `start_command`
* `start_timeout`
* `stop_command` - defaults to `:kill`, which basically means it will destroy every PID generated from the start command
* `stop_timeout`
* `restart_command` - defaults to `stop_command`, then `start_command`
* `restart_timeout`
* `refresh_command` - by default SMF treats this as `true`. This will be called when the SMF definition changes or
  when a `notify :reload, 'service[thing]'` is called.
* `refresh_timeout`
* `duration` - Can be either `contract`, `wait`, `transient` or
  `child`, but defaults to `contract`. See the [Duration](#duration) section below.
* `environment` - Hash - Environment variables to set while running commands
* `ignore` - Array - Faults to ignore in subprocesses. For example, 
  if core dumps in children are handled by a master process and you 
  don't want SMF thinking the service is exploding, you can ignore 
  ["core", "signal"].
* `privileges` - Array - An array of privileges to be allowed for started processes.
  Defaults to ['basic', 'net_privaddr']
* `property_groups` - Hash - This should be in the form `{"group name" => {"type" => "application", "key" => "value", ...}}`
* `working_directory` - PWD that SMF should cd to in order to run commands
* `locale` - Character encoding to use (default "C")

Manifest/FMRI metadata:
* `service_path` - defaults to `/var/svc/manifest`
* `manifest_type` - defaults to `application`
* `stability` - String - defaults to "Evolving". Valid options are
  "Standard", "Stable", "Evolving", "Unstable", "External" and
  "Obsolete"

Deprecated:
* `credentials_user` - deprecated in favor of `user`


## Provider Actions

### :install (default)

This will drop a manifest XML file into `#{service_path}/#{manifest_type}/#{name}.xml`. If there is already a service
with a name that is matched by `new_resource.name` then the FMRI of our manifest will be set to the FMRI of the 
pre-existing service. In this case, our properties will be merged into the properties of the pre-existing service.

In this way, updates to recipes that use the SMF provider will not delete existing service properties, but will add 
or overwrite them.

Because of this, the SMF provider can be used to update properties for
services that are installed via a package manager.

### :delete

Remove an SMF definition. This stops the service if it is running.

### :add_rbac

This uses the `rbac` cookbook to define permissions that can then be applied to a user. This can be useful when local
users should manage services that are added via packages.

```ruby
smf "nginx" do
  action :add_rbac
end

rbac_auth "Allow my user to manage nginx" do
  user "my_user"
  auth "nginx"
end
```


## Resource Notes

### `user`, `working_directory` and `environment`

SMF does a remarkably good job running services as delegated users, and removes a lot of pain if you configure a 
service correctly. There are many examples online (blogs, etc) of users wrapping their services in shell scripts with 
`start`, `stop`, `restart` arguments. In general it seems as if the intention of these scripts is to take care of the
problem of setting environment variables and shelling out as another user.

The use of init scripts to wrap executables can be unnecessary with SMF, as it provides hooks for all of these use cases. 
When using `user`, SMF will assume that the `working_directory` is the user's home directory. This can be
easily overwritten (to `/home/user/app/current` for a Rails application, for example). One thing to be careful of is 
that shell profile files will not be loaded. For this reason, if environment variables (such as PATH) are different 
on your system or require additional entries arbitrary key/values may be set using the `environment` attribute.

All things considered, one should think carefully about the need for an init script when working with SMF. For 
well-behaved applications with simple configuration, an init script is overkill. Applications with endless command-line 
options or that need a real login shell (for instance ruby applications that use RVM) an init script may make life
easier.

### Role Based Authorization

By default the SMF definition creates authorizations based on the
service name. The service user is then granted these authorizations. If
the service is named `asplosions`, then `solaris.smf.manage.asplosions`
and `solaris.smf.value.asplosions` will be created.

The authorization can be changed by manually setting `authorization` on
the smf block:

```ruby
smf 'asplosions' do
  user 'monkeyking'
  start_command 'asplode'
  authorization 'booms'
end
```

This can be helpful if there are many services configured on a single
host, as multiple services can be collapsed into the same
authorizations. For instance: https://illumos.org/issues/4968 

### Dependencies

SMF allows services to explicitly list their dependencies on other
services. Among other things, this ensures that services are enabled in
the proper order on boot, so that a service doesn't fail to start
because another service has not yet been started.

By default, services created by the SMF LWRP depend on the following other services:
* svc:/milestone/sysconfig
* svc:/system/filesystem/local
* svc:/milestone/name-services
* svc:/milestone/network

On Solaris11, `svc:/milestone/sysconfig` is replaced with
`svc:/milestone/config`.

These are configured with the attribute `include_default_dependencies`,
which defaults to `true`.

Other dependencies can be specified with the `dependencies` attribute,
which takes an array of hashes as follows:

```ruby
smf 'redis'

smf 'redis-6999' do
  start_command "..."
  dependencies [
    {name: 'redis', fmris: ['svc:/application/management/redis'],
     grouping: 'require_all', restart_on: 'restart', type: 'service'}
  ]
end
```

Valid options for grouping:
* require_all - All listed FMRIs must be online
* require_any - Any of the listed FMRIs must be online
* exclude_all - None of the listed FMRIs can be online
* optional_all - FMRIs are either online or unable to come online

Valid options for restart_on:
* error - Hardware fault
* restart - Restarts service if the depedency is restarted
* refresh - Restarted if the dependency is restarted or refreshed for
  any reason
* none - Don't do anything

Valid options for type:
* service - expects dependency FMRIs to be other services ie: svc:/type/of/service:instance
* path - expects FMRIs to be paths, ie file://localhost/etc/redis/redis.conf

Note: the provider currently does not do any validation of these values. Also, type:path has not been extensively
tested. Use this at your own risk, or improve the provider's compatibility with type:path and submit a pull request!

### Duration

There are several different ways that SMF can track your service. By default it uses `contract`. 
Basically, this means that it will keep track of the PIDs of all daemonized processes generated from `start_command`.
If SMF sees that processes are cycling, it may try to restart the service. If things get too hectic, it
may think that your service is flailing and put it into maintenance mode. If this is normal for your service,
for instance if you have a master that occasionally reaps processes, you may want to specify additional
configuration options.

If you have a job that you want managed by SMF, but which is not daemonized, another duration option is
`transient`. In this mode, SMF will not watch any processes, but will expect that the main process exits cleanly.
This can be used, for instance, for a script that must be run at boot time, or for a script that you want to delegate
to particular users with Role Based Access Control. In this case, the script can be registered with SMF to run as root,
but with the start_command delegated to your user.

A third option is `wait`. This covers non-daemonized processes.

A fourth option is `child`.

### Ignore

Sometimes you have a case where your service behaves poorly. The Ruby server Unicorn, for example, has a master 
process that likes to kill its children. This causes core dumps that SMF will interpret to be a failing service.
Instead you can `ignore ["core", "signal"]` and SMF will stop caring about core dumps.

### Privileges

Some system calls require privileges generally only granted to superusers or particular roles. In Solaris, an
SMF definition can also set specific privileges for contracted processes.

By default the SMF provider will grant 'basic' and 'net_privaddr' permissions, but this can be set as follows:

```ruby
smf 'elasticsearch' do
  start_command 'elasticsearch'
  privileges ['basic', 'proc_lock_memory']
end
```

See the (privileges man page)[https://www.illumos.org/man/5/privileges] for more information.

### Property Groups

Property Groups are where you can store extra information for SMF to use later. They should be used in the
following format:

```ruby
smf "my-service" do
  start_command "do-something"
  property_groups({
    "config" => {
      "type" => "application",
      "my-property" => "property value"
    }
  })
end
```

`type` will default to `application`, and is used in the manifest XML to declare how the property group will be
used. For this reason, `type` can not be used as a property name (ie variable).

One way to use property groups is to pass variables on to commands, as follows:

```ruby
rails_env = node["from-chef-environment"]["rails-env"]

smf "unicorn" do
  start_command "bundle exec unicorn_rails -c /home/app_user/app/current/config/%{config/rails_env} -E %{config/rails_env} -D"
  start_timeout 300
  restart_command ":kill -SIGUSR2"
  restart_timeout 300
  working_directory "/home/app_user/app/current"
  property_groups({
    "config" => {
      "rails_env" => rails_env
    }
  })
end
```

This is especially handy if you have a case where your commands may come from role attributes, but can
only work if they have access to variables set in an environment or computed in a recipe.

### Stability

This is for reference more than anything, so that administrators of a service know what to expect of possible changes to 
the service definition.

See: <http://www.cuddletech.com/blog/pivot/entry.php?id=182>


## Working Examples

Please see the [examples](https://github.com/livinginthepast/smf/blob/master/EXAMPLES.md) page for
example usages.


## Cookbook upgrades, possible side effects

Changes to this cookbook may change the way that its internal checksums are generated for a service.
If you `notify :restart` any service from within the `smf` block or include a `refresh_command`, please
be aware that upgrading this cookbook may trigger a refresh or a registered notification on the first
subsequent chef run.

## Contributing

* fork
* file an issue to track updates/communication
* add tests
* rebase master into your branch
* issue a pull request

Please do not increment the cookbook version in a fork. Version updates
will be done on the master branch after any pull requests are merged.

When upstream changes are added to the master branch while you are
working on a contribution, please rebase master into your branch and
force push. A pull request should be able to be merged through a
fast-forward, without a merge commit.

## Testing

```bash
bundle
vagrant plugin install vagrant-smartos-zones
bundle exec strainer test
```
