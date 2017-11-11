# Poise-Archive Changelog

## v1.5.0

* Support for 7-Zip unpacking archives on drives other than the system root.
* Chef 13 support.

## v1.4.0

* Added support for using 7-Zip on Windows.
* Fixed handling of `.tar.xz` archives on RHEL and CentOS.

## v1.3.0

* Add support for unpacking directly from a URL.

## v1.2.1

* [#1](https://github.com/poise/poise-archive/issues/1) Restore file permissions
  for ZIP files.

## v1.2.0

* Add back a tar-binary provider called `GnuTar`, used by default on Linux.
* Support for ZIP files via RubyZip.
* Full Windows support, including with the `user` and `group` properties.

## v1.1.2

* Fix compat with older Ruby that doesn't include `Entry#symlink?`.

## v1.1.1

* Fix GNU tar longlink extension.

## v1.1.0

* Scrap the original tar implementation in favor of a 100% pure-Ruby solution.
  This should work on all platforms exactly the same. Hopefully.

## v1.0.0

* Initial release!
