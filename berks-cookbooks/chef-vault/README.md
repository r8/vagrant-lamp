# chef-vault Cookbook

[![Build Status](https://travis-ci.org/chef-cookbooks/chef-vault.svg?branch=master)](https://travis-ci.org/chef-cookbooks/chef-vault) [![Cookbook Version](https://img.shields.io/cookbook/v/chef-vault.svg)](https://supermarket.chef.io/cookbooks/chef-vault)

This cookbook is responsible for installing the `chef-vault` gem and
providing some helper methods to load encrypted data bags that are in
The Vault. It also provides a resource that can be used to store
secrets as a Chef Vault item in a recipe.

Chef Vault is a library originally written by Nordstrom's infrastructure
operations team that helps manage encrypted data bags.

* https://github.com/chef/chef-vault

## Requirements

This cookbook should work on any system/platform that is supported by
Chef.

This cookbook is specifically tested on Ubuntu and CentOS platforms
using Test Kitchen. See `.kitchen.yml` for platforms and test suites.

The helper methods in this cookbook use the Chef Vault v2 API, so the
default version will match `~> 2.2` to ensure a reasonably updated
version of the gem is installed.

## Helper Methods

This cookbook provides a nice helper method for the Chef Recipe DSL so
you can write:

    chef_vault_item("secrets", "dbpassword")

Instead of:

    ChefVault::Item.load("secrets", "dbpassword")

This has logic in place to fall back to using data bags if the desired item
isn't encrypted. If the vault item fails to load because of missing vault
metadata (a `vaultname_keys` data bag), then `chef_vault_item` will attempt to
load the specified item as a regular Data Bag Item with
`Chef::DataBagItem.load`. This is intended to be used only for testing, and
not as a fall back to avoid issues loading encrypted items.

This cookbook also provides a handy wrapper if you are storing multiple
environment settings within your encrypted items. Using this following
helper:
```ruby
item = chef_vault_item_for_environment('secrets', 'passwords')
```

Instead of (or any combination of such expression):
```ruby
item = chef_vault_item('secrets', 'passwords')[node.chef_environment]
```

## Attributes

* `node['chef-vault']['version']` - Specify a version of the
  chef-vault gem if required. Default is `~> 2.2`, as that version was
  used for testing.

## Resources

### chef_vault_secret

The `chef_vault_secret` resource can be used in recipes to store
secrets in Chef Vault items. Where possible and relevant, this
resource attempts to map behavior and functionality to the `knife
vault` sub-commands.

#### Actions

The actions generally map to the `knife vault` sub-commands, with an
exception that `create` does an update, because the resource enforces
declarative state. To get the `knife vault create` behavior, use
`create_if_missing`.

* `:create` - *Default action*. Creates the item, or updates it if it
  already exists.
* `:create_if_missing` - Calls the `create` action unless it exists.
* `:delete` - Deletes the item *and* the item's keys ("id"_keys).

#### Attributes

* `id` - *Name attribute*. The name of the data bag item.
* `data_bag` - *Required*. The data bag that contains the item.
* `admins` - A list of admin users who should have access to the item.
  Corresponds to the "admin" option when using the chef-vault knife
  plugin. Can be specified as a comma separated string or an array.
  See examples, below.
* `clients` - A search query for the nodes' API clients that should
  have access to the item.
* `search` - Search query that would match the same used for the
  clients, gets stored as a field in the item.
* `raw_data` - The raw data, as a Ruby Hash, that will be stored in
  the item. See examples, below.

At least one of `admins` or `clients` should be specified, otherwise
nothing will have access to the item.

#### Examples

From the test cookbook embedded in this repository.

```ruby
chef_vault_secret 'clean-energy' do
  data_bag 'green'
  raw_data({'auth' => 'Forged in a mold'})
  admins 'hydroelectric'
  search '*:*'
end
```

Assuming that the `green` data bag exists, this will create the
`clean-energy` item as a ChefVault encrypted item, which also creates
`clean-energy_keys` that has the list of admins, clients, and the
shared secrets. For example, the content looks like this in plaintext:

```json
{
  "id": "clean-energy",
  "auth": {
    "encrypted_data": "y+l7H4okLu4wisryCaIT+7XeAgomcdgFo3v3p6RKWnXvgvimdzjFGMUfdGId\nq+pP\n",
    "iv": "HLr0uyy9BrieTDmS0TbbmA==\n",
    "version": 1,
    "cipher": "aes-256-cbc"
  }
}
```

And the encrypted data decrypted using the specified client:

```sh
$ knife vault show green clean-energy -z -u hydroelectric -k clients/hydroelectric.pem
auth: Forged in a mold
id:   clean-energy
```

Another example, showing multiple admins allowed access to an item
using a comma-separated string, or an array:

```ruby
chef_vault_secret 'root-password' do
  admins 'jtimberman,paulmooring'
  data_bag 'secrets'
  raw_data({'auth' => 'DontUseThisPasswordForRoot'})
  search '*:*'
end
chef_vault_secret 'root-password' do
  admins ['jtimberman', 'paulmooring']
  data_bag 'secrets'
  raw_data({'auth' => 'DontUseThisPasswordForRoot'})
  search '*:*'
end
```

Internally, the provider will convert the admins array to a
comma-delimited string.

When using the `chef_vault_secret` resource, the `data_bag` must exist
first. If it doesn't, you can create it in your recipe with a
`ruby_block`:

```ruby
begin
  data_bag('secrets')
rescue
  ruby_block "create-data_bag-secrets" do
    block do
      Chef::DataBag.validate_name!('secrets')
      databag = Chef::DataBag.new
      databag.name('secrets')
      databag.save
    end
    action :create
  end
end
```

Or, use the `cheffish` gem, which provides resources for Chef objects
(nodes, roles, data bags, etc):

```ruby
chef_data_bag 'secrets'
```

Note that there is a bug in versions of cheffish prior to 0.5.beta.3.
Also, cheffish requires the `openssl-pkcs8` gem, which has C
extensions, so openssl development headers and C build tools need to
be installed. To use this, you can create a recipe like the one in
the [test cookbook](test/fixtures/cookbooks/test/recipes/chef_vault_secret.rb).

## Usage

Include the recipe before using the Chef Vault library in recipes.

    include_recipe 'chef-vault'
    secret_stuff = ChefVault::Item.load("secrets", "a_secret")

Or, use the helper library method:

    secret_stuff = chef_vault_item("secrets", "a_secret")

If you need a specific version of the `chef-vault` RubyGem, then
specify it with the attribute, `node['chef-vault']['version']`.

To use the `chef_vault_secret` resource in your cookbooks' recipes,
declare a dependency on this cookbook, and then use the resource as
described in the Examples above.

## Contributing

This repository contains a `CONTRIBUTING` file that describes the
contribution process for Chef cookbooks.

## License and Authors

- Author: Joshua Timberman <joshua@chef.io>
- Copyright (c) 2013 Opscode, Inc. <legal@opscode.com>
- Copyright (c) 2014-2015 Chef Software, Inc. <legal@chef.io>
- Copyright (c) 2014, 2015 Bloomberg Finance L.P.

License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
