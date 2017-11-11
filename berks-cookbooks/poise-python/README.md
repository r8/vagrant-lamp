# Poise-Python Cookbook

[![Build Status](https://img.shields.io/travis/poise/poise-python.svg)](https://travis-ci.org/poise/poise-python)
[![Gem Version](https://img.shields.io/gem/v/poise-python.svg)](https://rubygems.org/gems/poise-python)
[![Cookbook Version](https://img.shields.io/cookbook/v/poise-python.svg)](https://supermarket.chef.io/cookbooks/poise-python)
[![Coverage](https://img.shields.io/codecov/c/github/poise/poise-python.svg)](https://codecov.io/github/poise/poise-python)
[![Gemnasium](https://img.shields.io/gemnasium/poise/poise-python.svg)](https://gemnasium.com/poise/poise-python)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

A [Chef](https://www.chef.io/) cookbook to provide a unified interface for
installing Python, managing Python packages, and creating virtualenvs.

## Quick Start

To install the latest available version of Python 2 and then use it to create
a virtualenv and install some packages:

```ruby
python_runtime '2'

python_virtualenv '/opt/myapp/.env'

python_package 'Django' do
  version '1.8'
end

pip_requirements '/opt/myapp/requirements.txt'
```

## Installing a Package From a URI

While using `python_package 'git+https://github.com/example/mypackage.git'` will
sometimes work, this approach is not recommended. Unfortunately pip's support
for installing directly from URI sources is limited and cannot support the API
used for the `python_package` resource. You can run the install either directly
from the URI or through an intermediary `git` resource:

```ruby
# Will re-install on every converge unless you add a not_if/only_if.
python_execute '-m pip install git+https://github.com/example/mypackage.git'

# Will only re-install when the git repository updates.
python_execute 'install mypackage' do
  action :nothing
  command '-m pip install .'
  cwd '/opt/mypackage'
end
git '/opt/mypackage' do
  repository 'https://github.com/example/mypackage.git'
  notifies :run, 'python_execute[install mypackage]', :immediately
end
```

## Supported Python Versions

This cookbook can install at least Python 2.7, Python 3, and PyPy on all
supported platforms (Debian, Ubuntu, RHEL, CentOS, Fedora).

### Windows Support

The latest version of `poise-python` includes basic support for managing Python
on Windows. This currently doesn't support Python 3.5, but everything should be
working. Consider this support tested but experimental at this time.

## Requirements

Chef 12.1 or newer is required.

## Attributes

Attributes are used to configure the default recipe.

* `node['poise-python']['install_python2']` – Install a Python 2.x runtime. *(default: true)*
* `node['poise-python']['install_python3']` – Install a Python 3.x runtime. *(default: false)*
* `node['poise-python']['install_pypy']` – Install a PyPy runtime. *(default: false)*

## Recipes

### `default`

The default recipe installs Python 2, 3, and/or PyPy based on the node
attributes. It is entirely optional and can be ignored in favor of direct use
of the `python_runtime` resource.

## Resources

### `python_runtime`

The `python_runtime` resource installs a Python interpreter.

```ruby
python_runtime '2'
```

#### Actions

* `:install` – Install the Python interpreter. *(default)*
* `:uninstall` – Uninstall the Python interpreter.

#### Properties

* `version` – Version of Python to install. If a partial version is given, use the
  latest available version matching that prefix. *(name property)*
* `get_pip_url` – URL to download the `get-pip.py` bootstrap script from.
  *(default: https://bootstrap.pypa.io/get-pip.py)*
* `pip_version` – Version of pip to install. If set to `true`, use the latest.
  If set to `false`, do not install pip. For backward compatibility, can also be
  set to a URL instead of `get_pip_url`. *(default: true)*
* `setuptools_version` – Version of Setuptools to install. If set to `true`, use
  the latest. If set to `false`, do not install Setuptools. *(default: true)*
* `virtualenv_version` – Version of virtualenv to install. If set to `true`,
  use the latest. If set to `false`, do not install virtualenv. Will never be
  installed if the `venv` module is already available, such as on Python 3.
  *(default: true)*
* `wheel_version` – Version of wheel to install. If set to `true`, use the
  latest. If set to `false`, do not install wheel.

#### Provider Options

The `poise-python` library offers an additional way to pass configuration
information to the final provider called "options". Options are key/value pairs
that are passed down to the `python_runtime` provider and can be used to control how it
installs Python. These can be set in the `python_runtime`
resource using the `options` method, in node attributes or via the
`python_runtime_options` resource. The options from all sources are merged
together in to a single hash.

When setting options in the resource you can either set them for all providers:

```ruby
python_runtime 'myapp' do
  version '2.7'
  options pip_version: false
end
```

or for a single provider:

```ruby
python_runtime 'myapp' do
  version '2.7'
  options :system, dev_package: false
end
```

Setting via node attributes is generally how an end-user or application cookbook
will set options to customize installations in the library cookbooks they are using.
You can set options for all installations or for a single runtime:

```ruby
# Global, for all installations.
override['poise-python']['options']['pip_version'] = false
# Single installation.
override['poise-python']['myapp']['version'] = 'pypy'
```

The `python_runtime_options` resource is also available to set node attributes
for a specific installation in a DSL-friendly way:

```ruby
python_runtime_options 'myapp' do
  version '3'
end
```

Unlike resource attributes, provider options can be different for each provider.
Not all providers support the same options so make sure to the check the
documentation for each provider to see what options the use.

### `python_runtime_options`

The `python_runtime_options` resource allows setting provider options in a
DSL-friendly way. See [the Provider Options](#provider-options) section for more
information about provider options overall.

```ruby
python_runtime_options 'myapp' do
  version '3'
end
```

#### Actions

* `:run` – Apply the provider options. *(default)*

#### Properties

* `resource` – Name of the `python_runtime` resource. *(name property)*
* `for_provider` – Provider to set options for.

All other attribute keys will be used as options data.

### `python_execute`

The `python_execute` resource executes a Python script using the configured runtime.

```ruby
python_execute 'myapp.py' do
  user 'myuser'
end
```

This uses the built-in `execute` resource and supports all the same properties.

#### Actions

* `:run` – Execute the script. *(default)*

#### Properties

* `command` – Script and arguments to run. Must not include the `python`. *(name attribute)*
* `python` – Name of the `python_runtime` resource to use. If not specified, the
  most recently declared `python_runtime` will be used. Can also be set to the
  full path to a `python` binary.
* `virtualenv` – Name of the `python_virtualenv` resource to use. This is
  mutually exclusive with the `python` property.

For other properties see the [Chef documentation](https://docs.chef.io/resource_execute.html#attributes).

### `python_package`

The `python_package` resource installs Python packages using
[pip](https://pip.pypa.io/).

```ruby
python_package 'Django' do
  version '1.8'
end
```

This uses the built-in `package` resource and supports the same actions and
properties. Multi-package installs are supported using the standard syntax.

#### Actions

* `:install` – Install the package. *(default)*
* `:upgrade` – Install using the `--upgrade` flag.
* `:remove` – Uninstall the package.

The `:purge` and `:reconfigure` actions are not supported.

#### Properties

* `group` – System group to install the package.
* `package_name` – Package or packages to install. *(name property)*
* `version` – Version or versions to install.
* `python` – Name of the `python_runtime` resource to use. If not specified, the
  most recently declared `python_runtime` will be used. Can also be set to the
  full path to a `python` binary.
* `user` – System user to install the package.
* `virtualenv` – Name of the `python_virtualenv` resource to use. This is
  mutually exclusive with the `python` property.
* `options` – Options to pass to `pip`.
* `install_options` – Options to pass to `pip install` (and similar commands).
* `list_options` – Options to pass to `pip list` (and similar commands).

For other properties see the [Chef documentation](https://docs.chef.io/resource_package.html#attributes).
The `response_file`, `response_file_variables`, and `source` properties are not
supported.

### `python_virtualenv`

The `python_virtualenv` resource creates Python virtual environments.

```ruby
python_virtualenv '/opt/myapp'
```

This will use the `venv` module if available, or `virtualenv` otherwise.

#### Actions

* `:create` – Create the virtual environment. *(default)*
* `:delete` – Delete the virtual environment.

#### Properties

* `group` – System group to create the virtualenv.
* `path` – Path to create the environment at. *(name property)*
* `pip_version` – Version of pip to install. If set to `true`, use the latest.
  If set to `false`, do not install pip. Can also be set to a URL to a copy of
  the `get-pip.py` script. *(default: true)*
* `python` – Name of the `python_runtime` resource to use. If not specified, the
  most recently declared `python_runtime` will be used. Can also be set to the
  full path to a `python` binary.
* `setuptools_version` – Version of Setuptools to install. If set to `true`, use
  the latest. If set to `false`, do not install Setuptools. *(default: true)*
* `system_site_packages` – Enable or disable visibilty of system packages in
  the environment. *(default: false)*
* `user` – System user to create the virtualenv.
* `wheel_version` – Version of wheel to install. If set to `true`, use the
  latest. If set to `false`, do not install wheel.

### `pip_requirements`

The `pip_requirements` resource installs packages based on a `requirements.txt`
file.

```ruby
pip_requirements '/opt/myapp/requirements.txt'
```

The underlying `pip install` command will run on every converge, but
notifications will only be triggered if a package is actually installed.

#### Actions

* `:install` – Install the requirements. *(default)*
* `:upgrade` – Install using the `--upgrade` flag.

#### Properties

* `path` – Path to the requirements file, or a folder containing the
  requirements file. *(name property)*
* `cwd` – Directory to run `pip` from. *(default: directory containing the
  `requirements.txt`)*
* `group` – System group to install the packages.
* `options` – Command line options for use with `pip install`.
* `python` – Name of the `python_runtime` resource to use. If not specified, the
  most recently declared `python_runtime` will be used. Can also be set to the
  full path to a `python` binary.
* `user` – System user to install the packages.
* `virtualenv` – Name of the `python_virtualenv` resource to use. This is
  mutually exclusive with the `python` property.

## Python Providers

### Common Options

These provider options are supported by all providers.

* `pip_version` – Override the pip version.
* `setuptools_version` – Override the Setuptools version.
* `version` – Override the Python version.
* `virtualenv_version` – Override the virtualenv version.
* `wheel_version` – Override the wheel version.

### `system`

The `system` provider installs Python using system packages. This is currently
only tested on platforms using `apt-get` and `yum` (Debian, Ubuntu, RHEL, CentOS
Amazon Linux, and Fedora) and is a default provider on those platforms. It may
work on other platforms but is untested.

```ruby
python_runtime 'myapp' do
  provider :system
  version '2.7'
end
```

#### Options

* `dev_package` – Install the package with the headers and other development
  files. Can be set to a string to select the dev package specifically.
  *(default: true)*
* `package_name` – Override auto-detection of the package name.
* `package_upgrade` – Install using action `:upgrade`. *(default: false)*
* `package_version` – Override auto-detection of the package version.

### `scl`

The `scl` provider installs Python using the [Software Collections](https://www.softwarecollections.org/)
packages. This is only available on RHEL, CentOS, and Fedora. SCL offers more
recent versions of Python than the system packages for the most part. If an SCL
package exists for the requested version, it will be used in preference to the
`system` provider.

```ruby
python_runtime 'myapp' do
  provider :scl
  version '3.4'
end
```

### `portable_pypy`

The `portable_pypy` provider installs Python using the [Portable PyPy](https://github.com/squeaky-pl/portable-pypy)
packages. These are only available for Linux, but should work on any Linux OS.

```ruby
python_runtime 'myapp' do
  provider :portable_pypy
  version 'pypy'
end
```

### `portable_pypy3`

The `portable_pypy3` provider installs Python 3 using the [Portable PyPy](https://github.com/squeaky-pl/portable-pypy)
packages. These are only available for Linux, but should work on any Linux OS.

```ruby
python_runtime 'myapp' do
  provider :portable_pypy3
  version 'pypy3'
end
```

#### Options

* `folder` – Folder to install PyPy in. *(default: /opt/<package name>)*
* `url` – URL to download the package from. *(default: automatic)*

### `deadsnakes`

*Coming soon!*

### `python-build`

*Coming soon!*

## Upgrading from the `python` Cookbook

The older `python` cookbook is not directly compatible with this one, but the
broad strokes overlap well. The `python::default` recipe is roughly equivalent
to the `poise-python::default` recipe. The `python::pip` and `python::virtualenv`
recipes are no longer needed as installing those things is now part of the
`python_runtime` resource. The `python::package` recipe corresponds with the
`system` provider for the `python_runtime` resource, and can generally be
replaced with `poise-python::default`. At this time there is no provider to
install from source so there is no replacement for the `python::source` recipe,
however this is planned for the future via a `python-build` provider.

The `python_pip` resource can be replaced with `python_package`, though the
`environment` property has been removed. The `python_virtualenv` resource can remain
unchanged except for the `interpreter` property now being `python` and the
`options` property has been removed.

## Sponsors

Development sponsored by [Bloomberg](http://www.bloomberg.com/company/technology/).

The Poise test server infrastructure is sponsored by [Rackspace](https://rackspace.com/).

## License

Copyright 2015-2017, Noah Kantrowitz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
