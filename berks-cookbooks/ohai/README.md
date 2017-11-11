# ohai Cookbook

[![Build Status](https://travis-ci.org/chef-cookbooks/ohai.svg?branch=master)](https://travis-ci.org/chef-cookbooks/ohai) [![Build status](https://ci.appveyor.com/api/projects/status/lgok2kr6l007s8hf/branch/master?svg=true)](https://ci.appveyor.com/project/ChefWindowsCookbooks/ohai/branch/master) [![Cookbook Version](https://img.shields.io/cookbook/v/ohai.svg)](https://supermarket.chef.io/cookbooks/ohai)

Contains custom resources for adding Ohai hints and installing custom Ohai plugins. Handles path creation as well as the reloading of Ohai so that new data will be available during the same run.

## Requirements

### Platforms

- Debian/Ubuntu
- RHEL/CentOS/Scientific/Amazon/Oracle
- openSUSE / SUSE Enterprise Linux
- FreeBSD
- Windows

### Chef

- Chef 12.7+

### Cookbooks

- none

## Custom Resources

### `ohai_hint`

Creates Ohai hint files, which are consumed by Ohai plugins in order to determine if they should run or not.

#### Resource Attributes

- `hint_name` - The name of hints file and key. Should be string, default is name of resource.
- `content` - Values of hints. It will be used as automatic attributes. Should be Hash, default is empty Hash
- `compile_time` - Should the resource run at compile time. This defaults to true

#### Examples

Hint file installed to the default directory:

```ruby
ohai_hint 'ec2'
```

Hint file not installed at compile time:

```ruby
ohai_hint 'ec2' do
  compile_time false
end
```

Hint file installed with content:

```ruby
ohai_hint 'raid_present' do
  content Hash[:a, 'test_content']
end
```

#### ChefSpec Matchers

You can check for the creation or deletion of ohai hints with chefspec using these custom matches:

- create_ohai_hint
- delete_ohai_hint

### `ohai_plugin`

Installs custom Ohai plugins.

#### Resource Attributes

- `plugin_name` - The name to give the plugin on the filesystem. Should be string, default is name of resource.
- `path` - The path to your custom plugin directory. Defaults to a directory named 'plugins' under the directory 'ohai' in the Chef config dir.
- `source_file` - The source file for the plugin in your cookbook if not NAME.rb.
- `cookbook` - The cookbook where the source file exists if not the cookbook where the ohai_plugin resource is running from.
- `resource` - The resource type for the plugin file. Either `:cookbook_file` or `:template`. Defaults to `:cookbook_file`.
- `variables` - Usable only if `resource` is `:template`. Defines the template's variables.
- `compile_time` - Should the resource run at compile time. This defaults to `true`.

#### examples

Simple Ohai plugin installation:

```ruby
ohai_plugin 'my_custom_plugin'
```

Installation where the resource doesn't match the filename and you install to a custom plugins dir:

```ruby
ohai_plugin 'My Ohai Plugin' do
  name 'my_custom_plugin'
  path '/my/custom/path/'
end
```

Installation using a template:

```ruby
ohai_plugin 'My Templated Plugin' do
  name 'templated_plugin'
  resource :template
  variables node_type: :web_server
end
```

#### ChefSpec Matchers

You can check for the creation or deletion of ohai plugins with chefspec using these custom matches:

- create_ohai_plugin
- delete_ohai_plugin

## Maintainers

This cookbook is maintained by Chef's Community Cookbook Engineering team. Our goal is to improve cookbook quality and to aid the community in contributing to cookbooks. To learn more about our team, process, and design goals see our [team documentation](https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/COOKBOOK_TEAM.MD). To learn more about contributing to cookbooks like this see our [contributing documentation](https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/CONTRIBUTING.MD), or if you have general questions about this cookbook come chat with us in #cookbok-engineering on the [Chef Community Slack](http://community-slack.chef.io/)

## License

**Copyright:** 2011-2016, Chef Software, Inc.

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
