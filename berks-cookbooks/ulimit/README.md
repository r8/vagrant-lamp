# ulimit Cookbook

[![Build Status](https://travis-ci.org/bmhatfield/chef-ulimit.svg?branch=master)](https://travis-ci.org/bmhatfield/chef-ulimit) [![Cookbook Version](https://img.shields.io/cookbook/v/ulimit.svg)](https://supermarket.chef.io/cookbooks/ulimit)

This cookbook provides resources for managing ulimits configuration on nodes.

- `user_ulimit` resource for overriding various ulimit settings. It places configured templates into `/etc/security/limits.d/`, named for the user the ulimit applies to.
- `ulimit_domain` which allows for configuring complex sets of rules beyond those supported by the user_ulimit resource.

The cookbook also includes a recipe (`default.rb`) which allows ulimit overrides with the 'su' command on Ubuntu.

## Requirements

### Platforms

- Debian/Ubuntu and derivatives
- RHEL/Fedora and derivatives

### Chef

- Chef 12.7+

### Cookbooks

- none

## Attributes

- `node['ulimit']['pam_su_template_cookbook']` - Defaults to nil (current cookbook). Determines what cookbook the su pam.d template is taken from
- `node['ulimit']['users']` - Defaults to empty Mash. List of users with their limits, as below.

## Default Recipe

Instead of using the user_ulimit resource directly you may define user ulimits via node attributes. The definition may be made via an environment file, a role file, or in a wrapper cookbook. Note: The preferred way to use this cookbook is by directly defining resources as it is much easier to troubleshoot and far more robust.

### Example role configuration:

```ruby
"default_attributes": {
   "ulimit": {
      "users": {
         "tomcat": {
            "filehandle_limit": 8193,
               "process_limit": 61504
             },
            "hbase": {
               "filehandle_limit": 32768
             }
       }
    }
 }
```

To specify a change for all users change specify a wildcard resource or user name like so `user_ulimit "*"`

## Resources

### user_ulimit

The `user_ulimit` resource creates individual ulimit files that are installed into the `/etc/security/limits.d/` directory.

#### Actions:

- `create`
- `delete`

#### Properties

- `username` - Optional property to set the username if the resource name itself is not the username. See the example below.
- `filename` - Optional filename to use instead of naming the file based on the username
- `filehandle_limit` -
- `filehandle_soft_limit` -
- `filehandle_hard_limit` -
- `process_limit` -
- `process_soft_limit` -
- `process_hard_limit` -
- `memory_limit` -
- `core_limit` -
- `core_soft_limit` -
- `core_hard_limit` -
- `stack_soft_limit` -
- `stack_hard_limit` -
- `rtprio_limit` -
- `rtprio_soft_limit` -
- `rtprio_hard_limit` -

#### Examples

Example of a resource where the resource name is the username:

```ruby
user_ulimit "tomcat" do
  filehandle_limit 8192 # optional
  filehandle_soft_limit 8192 # optional; not used if filehandle_limit is set)
  filehandle_hard_limit 8192 # optional; not used if filehandle_limit is set)
  process_limit 61504 # optional
  process_soft_limit 61504 # optional; not used if process_limit is set)
  process_hard_limit 61504 # optional; not used if process_limit is set)
  memory_limit 1024 # optional
  core_limit 2048 # optional
  core_soft_limit 1024 # optional
  core_hard_limit 'unlimited' # optional
  stack_soft_limit 2048 # optional
  stack_hard_limit 2048 # optional
  rtprio_limit 60 # optional
  rtprio_soft_limit 60 # optional
  rtprio_hard_limit 60 # optional
end
```

Example where the resource name is not the username:

```ruby
user_ulimit 'set filehandle ulimits for our tomcat user' do
  username 'tomcat'
  filehandle_soft_limit 8192
  filehandle_hard_limit 8192
end
```

### ulimit_domain

Note: The `ulimit_domain` resource creates files named after the domain with no modifiers by default. To override this behavior, specify the `filename` parameter to the resource.

#### Actions:

- `create`
- `delete`

#### Examples:

```ruby
ulimit_domain 'my_user' do
  rule do
    item :nofile
    type :hard
    value 10000
  end
  rule do
    item :nofile
    type :soft
    value 5000
  end
end
```
