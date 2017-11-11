Description
===========

This is a short-and-simple cookbook to provide a `user_ulimit` resource for overriding various ulimit settings. It places configured templates into `/etc/security/limits.d/`, named for the user the ulimit applies to.

It also provides a helper recipe (`default.rb`) for allowing ulimit overrides with the 'su' command on Ubuntu, which is disabled by default for some reason.

Finally, it also supplies a more advanced `ulimit_domain` resource, allowing you to configure a complex set of rules beyond those supported by the definition.

Requirements
============

Add to your repo, then depend upon this cookbook from wherever you need to override ulimits. (If you're on Ubuntu, you'll also need to add `recipe[ulimit]` to your runlist, or the files created by this cookbook will be ignored.)

Attributes
==========

* `node['ulimit']['pam_su_template_cookbook']` - Defaults to nil (current cookbook).  Determines what cookbook the su pam.d template is taken from
* `node['ulimit']['users']` - Defaults to empty Mash.  List of users with their limits, as below.

Usage
=====

Consume the `user_ulimit` resource like so:

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
end
```

You can also define limits using attributes on roles or nodes:

```
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

To specify a change for all users change specify a wildcard like so `user_ulimit "*"`

Domain LWRP
===========

Note: The `ulimit_domain` resource creates files named after the domain with no modifiers by default. To override this behavior, specify the `filename` parameter to the resource.

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
