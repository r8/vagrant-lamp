# chef-vault

This file is used to list changes made in each version of the chef-vault cookbook.

## 3.0.0 (2017-06-02)

- Convert the LWRP to a custom resource and require Chef 12.9 or later
- Use a SPDX standard license string
- Resolve foodcritic warnings
- Switch testing to local delivery from Rake
- Update the readme with proper links to the chef-vault project

## 2.1.1 (2016-10-18)
- Fixes deletion of items using chef_vault_secret resource

## 2.1.0 (2016-10-14)
- Remove chef 11 compatibility in chef_gem usage
- adding options attribute to the chef_gem resource

## 2.0.0 (2016-09-16)
- Avoid deprecation notices
- Add chef_version metadata
- Testing updates
- Require Chef 12.1

## v1.3.3 (2016-03-14)

- Restore Chef 11 compatibility
- Fix installing chef-vault gems from a custom source
- Fix uninitialized constant error

## v1.3.2 (2015-10-22)

- Adding Chef 11 guards on provides methods

## v1.3.1 (2015-09-30)

- Refactor of the chef-vault resource, adding environment property
- Various test fixes

## v1.3.0 (2015-04-09)

- 28, Fixes chef vault item loading and regular data bag fallback
- 24, Add ability to specify source for chef-vault gem installation

## v1.2.5 (2015-03-19)

- 22, fixes `chef_gem` compile time usage, also in conjunction with `chef-sugar` and Chef 11

## v1.2.4 (2015-02-18)

- ripping out the `chef_gem` `compile_time` stuff

## v1.2.3 (2015-02-18)

- `chef_gem` `Chef::Resource::ChefGem.method_defined?(:compile_time)`

## v1.2.2 (2015-02-18)

- Fixing `chef_gem`c for Chef below 12.1.0

## v1.2.1 (2015-02-17)

- Being explicit about usage of the `chef_gem`'s `compile_time` property.
- Eliminating future deprecation warnings in Chef 12.1.0.

## v1.2.0 (2015-02-04)

- COOK-4672: Make the library helper into a module instead of adding into Chef::Recipe
- Prevent variable masking
- Fix inverted existence check for `current_resource`

## v1.1.5 (2014-09-25)

- Adding ChefVault::Exceptions::SecretDecryption exception handling

## v1.1.4 (2014-09-12)

- Fix loading of current resource in `chef_vault_secret` (Nathan Huff)
- Allow `chef_vault_item` to fall back to plain data bags
- Set default version of `chef-vault` gem to one required by libraries

## v1.1.2 (2014-06-02)

### Bug

- **[COOK-4591](https://tickets.opscode.com/browse/COOK-4591)** - resource to create chef-vault-encrypted-items in recipes

## v1.1.0 (2014-06-02)

- [COOK-4591]: add a resource to create chef-vault-encrypted-items in recipes

## v1.0.4 (2014-01-14)

- Provide an fallback to regular data bag item loading when a "development mode" attribute is set.

## v1.0.2 (2013-09-10)

- Add Chef::Recipe helper method (`chef_vault_item`)

## v1.0.0 (2013-09-10)

- Initial Release
