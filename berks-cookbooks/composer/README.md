[![Build Status](https://travis-ci.org/djoos-cookbooks/composer.png)](https://travis-ci.org/djoos-cookbooks/composer)

# composer cookbook

## Description

This cookbook provides an easy way to install Composer, a dependency manager for PHP.

More information?
http://getcomposer.org/

## Requirements

### Cookbooks:

* php
* windows

### Platforms:

* Ubuntu
* Debian
* RHEL
* CentOS
* Fedora
* Windows

## Attributes

* `node['composer']['url']` - Location of the source
* `node['composer']['install_dir']` - Installation target directory (absolute or relative path) if installing locally
* `node['composer']['bin']` - bin directory
* `node['composer']['install_globally']` - Installation method, ':source' or ':package' - default true
* `node['composer']['mask']` - Mask for composer.phar - 0755
* `node['composer']['link_type']` - link type for composer.phar link - default :symbolic
* `node['composer']['global_configs']` - Hash with global config options for users, eg. { "userX" => { "github-oauth" => { "github.com" => "userX_oauth_token" }, "vendor-dir" => "myvendordir" } } - default {}
* `node['composer']['home_dir']` - COMPOSER_HOME, defaults to nil (in which case install_dir will be used), please do read the [Composer documentation on COMPOSER_HOME](https://getcomposer.org/doc/03-cli.md#composer-home) when setting a custom home_dir
* `node['composer']['php_recipe']` - The php recipe to include, defaults to "php::default"
* `node['composer']['global_install']['install_dir']` - The default location to install the packages in for composer_install_global
* `node['composer']['global_install']['bin_dir']` - The default location to symlink the binaries when using composer_install_global

## Resources / Providers
This cookbook includes an LWRP for managing a Composer project and one for a global installation of composer packages

### `composer_project`

#### Actions
- :install: Reads the composer.json file from the current directory, resolves the dependencies, and installs them into project directory - this is the default action
- :require Create composer.json file using specified package and version and installs it with the dependencies.
- :update: Gets the latest versions of the dependencies and updates the composer.lock file
- :dump_autoload: Updates the autoloader without having to go through an install or update (eg. because of new classes in a classmap package)
- :remove Removes package from composer.json and uninstalls it

#### Attribute parameters
- project_dir: The directory where your project's composer.json can be found (name attribute)
- package: The package to require or remove when using those actions
- version: The version of the package to require or remove when using those actions, default *.*.* Be careful when uninstalling, the version has to match the installed package!
- vendor: Can be used to combine package and version, deprecated!
- dev: Install packages listed in require-dev, default false
- quiet: Do not output any message, default true
- optimize_autoloader: Optimize PSR0 packages to use classmaps, default false
- prefer_dist: use the dist installation method
- prefer_source: use the source installation method
- bin_dir, overwrites the composer bin dir
- user: the user to use when executing the composer commands
- group: the group to use when executing the composer commands
- umask: the umask to use when executing the composer commands
- environment: A hash of environment variables that will be available when running composer

#### Examples
```
# Install the project dependencies
composer_project "/path/to/project" do
    dev false
    quiet true
    prefer_dist false
    action :install
end

# Require the package in the project dir
composer_project "/path/to/project" do
    package 'vendor/package'
    version '*.*.*'
    dev false
    quiet true
    prefer_dist false
    action :require
end

# Update the project dependencies
composer_project "/path/to/project" do
    dev false
    quiet true
    action :update
end

# Dump-autoload in the project dir
composer_project "/path/to/project" do
    dev false
    quiet true
    action :dump_autoload
end

# Remove the package in the project dir
composer_project "/path/to/project" do
    package 'vendor/package'
    action :remove
end
```

### `composer_install_global`

#### Actions
- :install: Installs the package in the preferred global composer directory, putting binary symlinks in the preferred global binary directory (see attributes)
- :update: Gets the latest versions of the dependencies and updates the composer.lock file for the globally installed composer packages
- :remove Removes package from the global composer.json and uninstalls it

#### Attribute parameters
- package: The package to install or remove, name_attribute
- version: The version of the package to install or remove when using those actions, default *.*.* Be careful when uninstalling, the version has to match the installed package!
- install_dir: the directory in which to make the global installation, default: see the attributes
- bin_dir: the directory in which to make the symlinks to the binaries, default: see the attributes
- dev: Install packages listed in require-dev, default false
- quiet: Do not output any message, default true
- optimize_autoloader: Optimize PSR0 packages to use classmaps, default false
- prefer_dist: use the dist installation method
- prefer_source: use the source installation method

#### Examples
```
# Install a package globally
composer_install_global "package" do
    version '~4.1'
    action :install
end

# Update the package
composer_install_global "package" do
    action :update
end

# Remove the package from the global installation
composer_install_global "package" do
    action :remove
end
```

## Usage

1. include `recipe[composer]` in a run list
2. tweak the attributes via attributes/default.rb
--- OR ---
[override the attribute on a higher level](http://wiki.opscode.com/display/chef/Attributes#Attributes-AttributesPrecedence)

## References

* [Composer home page] (http://getcomposer.org/)

## License and Authors

Author: David Joos <development@davidjoos.com>
Copyright: 2016, David Joos

Author: David Joos <david.joos@escapestudios.com>
Author: Escape Studios Development <dev@escapestudios.com>
Copyright: 2012-2015, Escape Studios

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
