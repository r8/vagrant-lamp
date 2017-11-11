# php Cookbook CHANGELOG

This file is used to list changes made in each version of the php cookbook.

## 4.5.0 (2017-07-11)

- Add reinstall chefspec matcher
- Switch from maintainers files to a simple readme section
- Remove allow_call_time_pass_reference and y2k_compliance config on Debian/Ubuntu as no supported PHP version supports it
- Initial Debian 9 support

## 4.4.0 (2017-06-27)

- Add a reinstall action to php_pear
- Added additional specs for package installs on different platforms

## 4.3.0 (2017-06-27)

- Remove fallback default php attributes that were used if we were on an unsupported platform. If we don't know the platform we don't support it and we should fail until we add proper support
- Add a few attributes needed for fpm support on opensuse. This is a work in progress to get full PHP support on opensuse
- Install xml deps and avoid using xml cookbook since it's been deprecated
- Expand the php_pear testing
- Remove double logging and log the correct package name in php_pear resource
- Cleanup readme example codes, improve formatting and remove references to LWRPs as they are just resources now

## 4.2.0 (2017-05-30)

- Make sure package intalls, php-fpm, and source installs work on Amazon linux
- Avoid symlink warning in the converges
- Simplify the package install logic
- Rename the inspec test to match the suite name so it actually runs
- Test on FreeBSD 11 / Amazon Linux
- Install 5.6.30 by default on source installs

## 4.1.0 (2017-05-30)

- Remove class_eval usage and require Chef 12.7+

## 4.0.0 (2017-04-20)

- Fix pear_channel resource to not fail on Chef 12.5 and 12.6
- Remove support for RHEL 5 as it is now EOL
- Resolve Amazon Linux failures on Chef 13
- Convert fpm_pool to a custom resource
- Fix php_pear failures on Chef 13
- Remove non-functional support for Windows
- Remove redundant Ubuntu version checks in the php_pear provider
- Expand testing to test all of the resources

## 3.1.1 (2017-04-20)

- Use the cookbook attribute as the default value of pear_channel pear property to provide better platform support

## 3.1.0 (2017-04-10)

- Use multi-package installs on supported platform_family(rhel debian suse amazon)
- Use a SPDX standardized license string in the metadata
- Update specs for the new Fauxhai data

## 3.0.0 (2017-03-27)

- Converted pear_channel LWRP into custom resource
- Removed use of pear node attribute from pear_channel resource
- Fix cookstyle issue with missing line on metadata.rb
- Clean up kitchen.dokken.yml file to eliminate duplication of testing suites.
- Eliminate duplicated resource from test cookbook that is in the default recipe.
- Rename php-test to standard cookbook testing cookbook of "test"
- Remove EOL ubuntu platform logic

**NOTE** Windows package installation is currently broken.

## 2.2.1 (2017-02-21)

- Fix double definition of ['php']['packages'] for rhel.

## 2.2.0 (2016-12-12)

- Use multipackage for installs to speed up chef runs
- Use all CPUs when building from source
- Remove need for apt/yum in testing
- Add opensuse to the metadata
- Migrate to inspec for integration testing

## 2.1.1 (2016-09-15)

- Fix recompile un-pack php creates
- Resolve cookstyle warnings

## 2.1.0 (2016-09-14)

- Fix source php version check
- Require Chef 12.1 not 12.0

## 2.0.0 (2016-09-07)

- Require Chef 12+
- Remove the dependency on the Windows cookbook which isn't necessary with Chef 12+

## 1.10.1 (2016-08-30)

- [fix] bug fixes related with Ubuntu 16.04 and PHP 7 support
- adding validator to listen attribute
- Fix node.foo.bar warnings

## v1.10.0 (2016-07-27)

- PR #167 Preventing user specified pool of www from being deleted at the end of the chef run on the first install
- PR #122 Add recipe for php module_imap
- PR #172 Fix uninstall action for resource php_fpm_pool

## v1.9.0 (2016-05-12)

Special thanks to @ThatGerber for getting the PR for this release together

- Added support for Ubuntu 16.04 and PHP 7
- Added support for different listen user/groups with FPM
- Cleaned up resource notification in the pear_channel provider to simplify code
- Fixed Ubuntu 14.04+ not being able to find the GMP library

## v1.8.0 (2016-02-25)

- Bumped the source install default version from 5.5.9 to 5.6.13
- Added a chefignore file to limit the files uploaded to the Chef server
- Added source_url and issues_url to the metadata.rb
- Added additional Chefspec matchers
- Added a Chef standard rubocop.yml file and resolved warnings
- Added serverspec for integration testing
- Remove legacy cloud Test Kitchen configs
- Added testing in Travis CI with kitchen-docker
- Added additional test suites to the Test Kitchen config
- Updated contributing and testing documentation
- Updated testing gem dependencies to the latest
- Added maintainers.md and maintainers.toml files
- Remove gitter chat from the readme
- Add cookbook version badge to the readme
- Added Fedora as a supported platform in the readme
- Add missing cookbook dependencies to the readme

## v1.7.2 (2015-8-24)

- Correct spelling in fpm_pool_start_servers (was servres)

## v1.7.1 (2015-8-17)

- Correct permissions on ext_conf_dir folder (644 -> 755)

## v1.7.0 (2015-7-31)

- NOTICE - This version changes the way the ['php']['directives'] is placed into configuration files. Quotes are no longer automatically placed around these aditional directives. Please take care when rolling out this version.
- Allow additional PHP FPM config
- Add recipe to recompile PHP from source
- Move source dependencies to attributes file
- Misc bug fixes

## v1.6.0 (2015-7-6)

- Added ChefSpec matchers
- Added basic PHP-FPM Support (Pre-Release)
- Added support for FreeBSD
- Updated cookbook to use MySQL 6.0 cookbook
- Update cookbook to use php5enmod on supported platforms
- Allow users to override php-mysql package

## v1.5.0 (2014-10-06)

- Adding package_options attribute, utilizing in package resource

## v1.4.6 (2014-03-19)

- [COOK-4436] - Test this cookbook, not yum. Also test Fedora 20.
- [COOK-4427] - Add oracle as supported operating system

## v1.4.4 (2014-03-12)

- [COOK-4393] - Fix convergence bug in source install

## v1.4.2 (2014-02-27)

[COOK-4300] - Simplified and fixed pear/pecl logic. [Fixes #56 / #57]

## v1.4.0 (2014-02-27)

[COOK-3639] - Allow users to specify php.ini source template

## v1.3.14 (2014-02-21)

### Bug

- **[COOK-4186](https://tickets.opscode.com/browse/COOK-4186)** - Upgrade_package concatenates an empty version string when version is not set or is empty.

## v1.3.12 (2014-01-28)

Fix github issue 'Cannot find a resource for preferred_state'

## v1.3.10

Fixing my stove

## v1.3.8

Version bump to ensure artifact sanity

## v1.3.6

Version bump for toolchain

## v1.3.4

Adding platform_family check to include_recipe in source.rb

## v1.3.2

Fixing style cops. Updating test harness

## v1.3.0

### Bug

- **[COOK-3479](https://tickets.opscode.com/browse/COOK-3479)** - Added Windows support to PHP
- **[COOK-2909](https://tickets.opscode.com/browse/COOK-2909)** - Warnings about Chef::Exceptions::ShellCommandFailed is deprecated

## v1.2.6

### Bug

- **[COOK-3628](https://tickets.opscode.com/browse/COOK-3628)** - Fix PHP download URL
- **[COOK-3568](https://tickets.opscode.com/browse/COOK-3568)** - Fix Test Kitchen tests
- **[COOK-3402](https://tickets.opscode.com/browse/COOK-3402)** - When the `ext_dir` setting is present, configure php properly for the source recipe
- **[COOK-2926](https://tickets.opscode.com/browse/COOK-2926)** - Fix pear package detection when installing specific version

## v1.2.4

### Improvement

- **[COOK-3047](https://tickets.opscode.com/browse/COOK-3047)** - Sort directives in `php.ini`
- **[COOK-2928](https://tickets.opscode.com/browse/COOK-2928)** - Abstract `php.ini` directives into variables

### Bug

- **[COOK-2378](https://tickets.opscode.com/browse/COOK-2378)** - Fix `php_pear` for libevent

## v1.2.2

### Bug

- [COOK-3050]: `lib_dir` declared in wrong place for redhat
- [COOK-3102]: remove fileinfo recipe from php cookbook

### Improvement

- [COOK-3101]: use a method to abstract range of "el 5" versions in php recipes

## v1.2.0

### Improvement

- [COOK-2516]: Better support for SUSE distribution for php cookbook
- [COOK-3035]: update php::source to install 5.4.15 by default

### Bug

- [COOK-2463]: PHP PEAR Provider Installs Most Recent Version, Without Respect to Preferred State
- [COOK-2514]: php_pear: does not handle more exotic version strings

## v1.1.8

- [COOK-1998] - Enable override of PHP packages in attributes

## v1.1.6

- [COOK-2324] - adds Oracle linux support

## v1.1.4

- [COOK-2106] - `php_pear` cannot find available packages

## v1.1.2

- [COOK-1803] - use better regexp to match package name
- [COOK-1926] - support Amazon linux

## v1.1.0

- [COOK-543] - php.ini template should be configurable
- [COOK-1067] - support for PECL zend extensions
- [COOK-1193] - update package names for EPEL 6
- [COOK-1348] - rescue Mixlib::ShellOut::ShellCommandFailed (chef 0.10.10)
- [COOK-1465] - fix pear extension template

## v1.0.2

- [COOK-993] Add mhash-devel to centos php source libs
- [COOK-989] - bump version of php to 5.3.10
- Also download the .tar.gz instead of .tar.bz2 as bzip2 may not be in the base OS (e.g., CentOS 6 minimal)
