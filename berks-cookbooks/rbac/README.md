Role based access control
=========================

Solaris and Illumos provide sophisticated role-based access control for
delegating authorizations within the system. Using RBAC, users can be
given permissions to manage and update services without sudo.

This cookbook provides chef with LWRPs to manage RBAC and grant permissions.

At this time this cookbook ONLY manages SMF-related permissions (ie, ability
of non-priviliged users to start/stop SMF services), but in the future it may
be enhanced to support arbitrary Solaris permissions.

## Installation

In order to add the RBAC LWRPs to a chef run, add the following recipe 
to the run_list:

    rbac::default

This will do no work, but will load the providers.

## LWRPs

### rbac

Defines a set of authorizations that can be applied to SMF services and
authorized to users, without actually applying them to users.

Actions:
  * create (default)

Attributes:
  * name

Example:

```ruby
rbac "nginx" do
  action :create
end
```

This will update the authorizations file at `/etc/security/auth_attr`
with the following lines:

```
solaris.smf.manage.nginx:::Manage nginx Service States::
solaris.smf.value.nginx:::Change value of nginx Service::
```

Users who are given these authorizations can change properties of the
service as well as change its state (i.e. `svcadm disable|enable|restart|clear service`

### rbac_auth

Adds the rbac definition created by `auth` to the user `name`.

Actions:
  * add (default)

Attributes:
  * name - for descriptive purposes and to ensure that each LWRP call is uniquely
           identified in the chef run
  * user
  * auth

Example:

```ruby
rbac_auth "add nginx management permissions to my_user" do
  user "my_user"
  auth "nginx"
end
```

This adds both manage and value auths to user `my_user`.

## TODO

* separate manage auth from value auth
* ability to delete all rbac attributes
