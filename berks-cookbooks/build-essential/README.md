# build-essential Cookbook

[![Cookbook Version](http://img.shields.io/cookbook/v/build-essential.svg)][cookbook] [![Build Status](https://travis-ci.org/chef-cookbooks/build-essential.svg?branch=master)](https://travis-ci.org/chef-cookbooks/build-essential)

Installs packages required for compiling C software from source. Use this cookbook if you wish to compile C programs, or install RubyGems with native extensions. Contains a resource, 'build_essential', as as well as a default recipe that simply calls that same resource.

Note: The functionality of this cookbook is now built into Chef 14+ in the [build_essential resource](https://docs.chef.io/resource_build_essential.html). This cookbook is no longer being maintained and all future changes will be done directly in the chef-client. We highly recommend you update your chef-client to the latest release and if possible migrate to using the build_essential resources instead of the recipe in this cookbook.

## Requirements

### Platforms

- Debian/Ubuntu
- RHEL/CentOS/Scientific/Amazon/Oracle
- openSUSE / SUSE Enterprise Linux
- SmartOS
- Fedora
- Mac OS X 10.9+
- FreeBSD

### Chef

- Chef 12.7+

### Cookbooks

- seven_zip
- mingw

**Note for Debian platform family:** On Debian platform-family systems, it is recommended that `apt-get update` be run, to ensure that the package cache is updated. It's not in the scope of this cookbook to do that, as it can [create a duplicate resource](https://tickets.chef.io/browse/CHEF-3694). We recommend using the [apt](https://supermarket.chef.io/cookbooks/apt) cookbook to do this.

## Attributes

Attribute                                  |            Default            | Description
------------------------------------------ | :---------------------------: | -----------------------------------------------------
`node['build-essential']['compile_time']`  |            `false`            | Execute resources at compile time
`node['build-essential']['msys2']['path']` | `#{ENV['SYSTEMDRIVE']\\msys2` | Destination for msys2 build tool chain (Windows only)

## Usage

### Recipe Usage

The recipe simply calls the build_essential resource, but it ideal for adding to roles or node run lists.

Include the build-essential recipe in your run list:

```sh
knife node run_list add NODE "recipe[build-essential::default]"
```

or add the build-essential recipe as a dependency and include it from inside another cookbook:

```ruby
include_recipe 'build-essential::default'
```

### Gems with C extensions

For RubyGems that include native C extensions you wish to use with Chef, you should do the following.

- Set the `compile_time` attribute to true in your wrapper cookbook or role:

  ```ruby
   # Wrapper attribute
   default['build-essential']['compile_time'] = true
  ```

  ```ruby
   # Role
   default_attributes(
     'build-essential' => {
       'compile_time' => true
     }
   )
  ```

- Ensure that the C libraries, which include files and other assorted "dev"

  type packages, are installed in the compile phase after the build-essential

  recipe is executed. For example:

  ```ruby
   include_recipe 'build-essential::default'

   package('mypackage-devel') { action :nothing }.run_action(:install)
  ```

- Use the `chef_gem` resource in your recipe to install the gem with the native

  extension:

  ```ruby
   chef_gem 'gem-with-native-extension'
  ```

### Resource Usage

The cookbook includes a resource 'build_essential' that can be included in your cookbook to install the necessary build-essential packages

Simple package installation during the client run:

```ruby
build_essential 'some name you choose'
```

Package installation during the compile phase:

```ruby
build_essential 'some name you choose' do
  compile_time false
end
```

## Maintainers

This cookbook is maintained by Chef's Community Cookbook Engineering team. Our goal is to improve cookbook quality and to aid the community in contributing to cookbooks. To learn more about our team, process, and design goals see our [team documentation](https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/COOKBOOK_TEAM.MD). To learn more about contributing to cookbooks like this see our [contributing documentation](https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/CONTRIBUTING.MD), or if you have general questions about this cookbook come chat with us in #cookbok-engineering on the [Chef Community Slack](http://community-slack.chef.io/)

## License

**Copyright:** 2009-2016, Chef Software, Inc.

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[cookbook]: https://supermarket.chef.io/cookbooks/build-essential
[travis]: http://travis-ci.org/chef-cookbooks/build-essential
