[![Build Status](https://travis-ci.org/escapestudios-cookbooks/composer.png)](https://travis-ci.org/escapestudios-cookbooks/composer)

Description
===========

This cookbook provides an easy way to install Composer, a dependency manager for PHP.

More information?
http://getcomposer.org/

Requirements
============

## Cookbooks:

* php

This cookbook recommends the following cookbooks:

* windows

### Depending on your environment, these recommended cookbooks are actual dependencies (depends):
* Using the community PHP cookbook to get PHP installed? You'll need the php cookbook to be available.
* Running on Windows? You'll need the windows cookbook to be available.

## Platforms:

* Ubuntu
* Debian
* RHEL
* CentOS
* Fedora
* Windows

Attributes
==========

* `node['composer']['url']` - Location of the source
* `node['composer']['install_dir']` - Installation target directory (absolute or relative path) if installing locally
* `node['composer']['bin']` - bin directory
* `node['composer']['install_globally']` - Installation method, ':source' or ':package' - default true
* `node['composer']['mask']` - Mask for composer.phar - 0755
* `node['composer']['link_type']` - link type for composer.phar link - default :symbolic
* `node['composer']['global_configs']` - Hash with global config options for users, eg. { "userX" => { "github-oauth" => { "github.com" => "userX_oauth_token" }, "vendor-dir" => "myvendordir" } } - default {}
* `node['composer']['home_dir']` - COMPOSER_HOME, defaults to nil (in which case install_dir will be used), please do read the [Composer documentation on COMPOSER_HOME](https://getcomposer.org/doc/03-cli.md#composer-home) when setting a custom home_dir
* `node['composer']['php_recipe']` - The php recipe to include, defaults to "php::default"

Resources / Providers
=====================

This cookbook includes an LWRP for managing a Composer project

### `composer_project`

#### Actions
- :install: Reads the composer.json file from the current directory, resolves the dependencies, and installs them into vendor - this is the default action
- :require Create composer.json file using specified vendor and downloads vendor.
- :update: Gets the latest versions of the dependencies and updates the composer.lock file
- :dump_autoload: Updates the autoloader without having to go through an install or update (eg. because of new classes in a classmap package)
- :remove Removes vendor from composer.json and uninstalls

#### Attribute parameters
- project_dir: The directory where your project's composer.json can be found
- dev: Install packages listed in require-dev, default false
- quiet: Do not output any message, default true
- optimize_autoloader: Optimize PSR0 packages to use classmaps, default false

#### Examples
```
#install project vendors
composer_project "/path/to/project" do
    dev false
    quiet true
    prefer_dist false
    action :install
end

#require project vendor
composer_project "/path/to/project" do
    dev false
    quiet true
    prefer_dist false
    action :require 
end

#update project vendors
composer_project "/path/to/project" do
    dev false
    quiet true
    action :update
end

#dump-autoload for project
composer_project "/path/to/project" do
    dev false
    quiet true
    action :dump_autoload
end

#remove project vendor
composer_project "/path/to/project" do
    vendor 'repo/vendor'
    action :remove
end
```

Usage
=====

1) include `recipe[composer]` in a run list
2) tweak the attributes via attributes/default.rb
    --- OR ---
    override the attribute on a higher level (http://wiki.opscode.com/display/chef/Attributes#Attributes-AttributesPrecedence)

References
==========

* [Composer home page] (http://getcomposer.org/)

License and Authors
===================

Author: David Joos <david.joos@escapestudios.com>
Author: Escape Studios Development <dev@escapestudios.com>
Copyright: 2012-2014, Escape Studios

Unless otherwise noted, all files are released under the MIT license,
possible exceptions will contain licensing information in them.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
