# Poise-Python Changelog

## v1.7.0

* Support for Pip 10.
* Support for Chef 14.
* System package info for Ubuntu 18.04 and Debian 9, 10.

## v1.6.0

* Improved handling for Python 3.3.
* Updated PyPy release lists.
* Fix file permissions for non-root-owned virtualenvs.
* Support for Chef 13.

## v1.5.1

* Fix handling of packages with underscores in the name.

## v1.5.0

* Support new SCL structure and packages.

## v1.4.0

* Add system package names for Ubuntu 16.04.
* Add `options` and `cwd` properties to `pip_requirements` resource.
* Add `install_options` and `list_options` to `python_package` resource.

## v1.3.0

* Don't re-bootstrap very old pip if that is the configured version.
* Support for bootstrapping with a specific version of pip.
* [#40](https://github.com/poise/poise-python/pulls/40) Support for Python 3 system packages on Amazon Linux.
* Experimental Windows support.

## v1.2.1

* Compatibility with Pip 8.0.

## v1.2.0

* Add support for passing `user` and `group` to `pip_requirements`.
* Allow passing a virtualenv resource object to the `virtualenv` property.
* Update PyPy release versions.
* Make the `python_virtualenv` resource check for `./bin/python` for idempotence
  instead of the base path.
* Support for packages with extras in `python_package`.
* Support for point releases (7.1, 8.1, etc) of Debian in the `system` provider.

## v1.1.2

* Fix `PythonPackage#response_file_variables` for the Chef 12.6 initializer.

## v1.1.1

* Fix passing options to the `python_package` resource.

## v1.1.0

* Add a `:dummy` provider for `python_runtime` for unit testing or complex overrides.
* Support installing development headers for SCL packages.
* Refactor Portable PyPy provider to use new helpers from `poise-languages`. This
  means `portable_pypy` and `portable_pypy3` are now separate providers but the
  auto-selection logic should still work as before.

## v1.0.0

* Initial release!

