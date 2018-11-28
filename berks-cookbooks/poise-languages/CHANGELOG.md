# Changelog

## v2.1.2

* Drop support for Chef that uses Ruby 2.1 (<= 12.13).
* Fix handling of RPM epoch prefixes in the system package resource.

## v2.1.1

* Fix the SCL repository enable command for RHEL.
* Internal refactoring of the system package installer.

## v2.1.0

* Allow customizing properties on the system package install resource via a block

## v2.0.5

* Fixes to work with the latest Chef (again).

## v2.0.4

* Fixes to work with the latest Chef.

## v2.0.3

* Correct the subscription repository name used for SCLs on RedHat.

## v2.0.2

* Don't try to use SCL providers on Amazon Linux.

## v2.0.1

* Don't error on `Chef::Decorator::Lazy` proxy objects for `candidate_version`.
* Retry system and SCL package installs because transient network failures.

## v2.0.0

* Backwards-incompatible change to SCL management to comply with their new repo
  packages and layout. Uses `centos-release-scl-rh` repo package or the
  `rhel-variant-rhscl` RedHat subscription.

## v1.4.0

* Use `poise-archive` to unpack static binary archives. This should work better
  on AIX and Solaris, as well as making it easier to add more archive formats in
  the future.

## v1.3.3

* [#3](https://github.com/poise/poise-languages/pull/3) Fix `static` binary
  installation on AIX and Solaris.
* Only run the candidate version check for `system` installs when we aren't
  passing in package_version.

## v1.3.2

* Handle static archive unpacking correctly when a single download is shared
  between two paths.

## v1.3.1

* Fix system package installs on OS X.

## v1.3.0

* `%{machine_label}` is available in URL template for static download.
* Automatically retry `remote_file` downloads to handle transient HTTP failures.
* All `*_shell_out` language command helpers use `poise_shell_out` to set `$HOME`
  and other environment variables by default.

## v1.2.0

* Support for installing development headers with SCL providers.
* Add `PoiseLanguages::Utils.shelljoin` for encoding command arrays with some
  bash metadata characters allowed.
* [#1](https://github.com/poise/poise-languages/pull/1) Fix typo in gemspec.

## v1.1.0

* Add helpers for installing from static archives.
* Improve auto-selection rules for system and SCL providers.
* Support SCL packages that depend on other SCL packages.
* Support Ruby 2.0 again.

## v1.0.0

* Initial release!
