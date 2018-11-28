# Git Cookbook

[![Build Status](https://travis-ci.org/chef-cookbooks/git.svg?branch=master)](https://travis-ci.org/chef-cookbooks/git) [![Cookbook Version](https://img.shields.io/cookbook/v/git.svg)](https://supermarket.chef.io/cookbooks/git)

Installs git_client from package or source. Optionally sets up a git service under xinetd.

## Scope

This cookbook is concerned with the Git SCM utility. It does not address ecosystem tooling or related projects.

## Requirements

### Platforms

The following platforms have been tested with Test Kitchen:

```
|---------------+-------|
| centos-6      | X     |
|---------------+-------|
| centos-7      | X     |
|---------------+-------|
| fedora        | X     |
|---------------+-------|
| debian-8      | X     |
|---------------+-------|
| debian-9      | X     |
|---------------+-------|
| ubuntu-14.04  | X     |
|---------------+-------|
| ubuntu-16.04  | X     |
|---------------+-------|
| openSUSE Leap | X     |
|---------------+-------|
```

### Chef

- Chef 12.7+

### Cookbooks

- 'build-essential' 5.0 or later - For compiling from source

## Usage

Add `git::default`, `git::source` or `git::windows` to your run_list OR add `depends 'git', '~> 4.3'` to your cookbook's metadata.rb. include_recipe one of the recipes from your cookbook OR use the git_client resource directly, the same way you'd use core Chef resources (file, template, directory, package, etc).

## Resources Overview

- `git_client`: Manages a Git client installation on a machine. Acts as a singleton when using the (default) package provider. Source provider available as well.
- `git_service`: Sets up a Git service via xinetd. WARNING: This is insecure and will probably be removed in the future
- `git_config`: Sets up Git configuration on a node.

### git_client

The `git_client` resource manages the installation of a Git client on a machine.

`Note`: on macOS systems homebrew must first be installed on the system before running this resource. Prior to version 9.0 of this cookbook homebrew was automatically installed.

#### Example

```ruby
git_client 'default' do
  action :install
end
```

#### Example of source install

```ruby
git_client 'source' do
  provider Chef::Provider::GitClient::Source
  source_version '2.14.2'
  source_checksum 'a03a12331d4f9b0f71733db9f47e1232d4ddce00e7f2a6e20f6ec9a19ce5ff61'
  action :install
end
```

### git_config

The `git_config` resource manages the configuration of Git client on a machine.

#### Example

```ruby
git_config 'url.https://github.com/.insteadOf' do
  value 'git://github.com/'
  scope 'system'
  options '--add'
end
```

#### Properties

Currently, there are distinct sets of resource properties, used by the providers for source, package, macos, and windows.

# used by linux package providers

- `package_name` - Package name to install on Linux machines. Defaults to a calculated value based on platform.
- `package_version` - Defaults to nil.
- `package_action` - Defaults to `:install`

# used by source providers

- `source_prefix` - Defaults to '/usr/local'
- `source_url` - Defaults to a calculated URL based on source_version
- `source_version` - Defaults to 2.8.1
- `source_use_pcre` - configure option for build. Defaults to false
- `source_checksum` - Defaults to a known value for the 2.8.1 source tarball

# used by the Windows package providers

- `windows_display_name` - Windows display name
- `windows_package_url` - Defaults to the Internet
- `windows_package_checksum` - Defaults to the value for 2.8.1

## Recipes

This cookbook ships with ready to use, attribute driven recipes that utilize the `git_client` and `git_service` resources. As of cookbook 4.x, they utilize the same attributes layout scheme from the 3.x. Due to some overlap, it is currently impossible to simultaneously install the Git client as a package and from source by using the "manipulate a the node attributes and run a recipe" technique. If you need both, you'll need to utilize the git_client resource in a recipe.

## Attributes

### Windows

- `node['git']['version']` - git version to install
- `node['git']['url']` - URL to git package
- `node['git']['checksum']` - package SHA256 checksum
- `node['git']['display_name']` - `windows_package` resource Display Name (makes the package install idempotent)

### Linux

- `node['git']['prefix']` - git install directory
- `node['git']['version']` - git version to install
- `node['git']['url']` - URL to git tarball
- `node['git']['checksum']` - tarball SHA256 checksum
- `node['git']['use_pcre']` - if true, builds git with PCRE enabled

## Maintainers

This cookbook is maintained by Chef's Community Cookbook Engineering team. Our goal is to improve cookbook quality and to aid the community in contributing to cookbooks. To learn more about our team, process, and design goals see our [team documentation](https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/COOKBOOK_TEAM.MD). To learn more about contributing to cookbooks like this see our [contributing documentation](https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/CONTRIBUTING.MD), or if you have general questions about this cookbook come chat with us in #cookbok-engineering on the [Chef Community Slack](http://community-slack.chef.io/)

## License

**Copyright:** 2009-2017, Chef Software, Inc.

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
