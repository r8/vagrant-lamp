users Cookbook CHANGELOG
========================
This file is used to list changes made in each version of the users cookbook.


v1.7.0 (2014-02-14)
-------------------
[COOK-4139] - users_manage resource always notifies
[COOK-4078] - users cookbook fails in why-run mode for .ssh directory
[COOK-3959] - Add support for Mac OS X to users cookbook


v1.6.0
------
### Bug
- **[COOK-3744](https://tickets.opscode.com/browse/COOK-3744)** - Allow passing an action option via the `data_bag` to the user resource


v1.5.2
------
### Bug
- **[COOK-3215](https://tickets.opscode.com/browse/COOK-3215)** - Make `group_id` optional

v1.5.0
------
- [COOK-2427] - Mistakenly released instead of sudo :-).

v1.4.0
------
- [COOK-2479] - Permit users cookbook to work with chef-solo if edelight/chef-solo-search is installed
- [COOK-2486] - specify precedence when setting node attribute

v1.3.0
------
- [COOK-1842] - allow specifying private SSH keys
- [COOK-2021] - Empty default recipe for including users LWRPs

v1.2.0
------
- [COOK-1398] - Provider manage.rb ignores username attribute
- [COOK-1582] - ssh_keys should take an array in addition to a string separated by new lines

v1.1.4
------
- [COOK-1396] - removed users get recreated
- [COOK-1433] - resolve foodcritic warnings
- [COOK-1583] - set passwords for users

v1.1.2
------
- [COOK-1076] - authorized_keys template not found in another cookbook

v1.1.0
------
- [COOK-623] - LWRP conversion
