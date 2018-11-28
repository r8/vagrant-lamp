# git Cookbook CHANGELOG

This file is used to list changes made in each version of the git cookbook.

## 9.0.1 (2018-06-02)

- Update the platforms we test on
- Remove extra attr_accessor in config and requires
- Bump git version to 2.17.1 to resolve CVE

## 9.0.0 (2018-03-08)

- Remove the dependency on the homebrew cookbook by not automatically installing homebrew in the git resource on macOS systems. Homebrew needs to be setup before this resource runs and that should probably be the very first thing you do on a macOS system
- Use the build_essential resource instead of including the default recipe. This requires version 5.0 or later of the build-essential cookbook and allows us to use the build_essential resource that will be built into Chef 14 when that ships
- Remove extra includes in the resources that weren't necessary
- Updated testing to include Fedora 27, Ubuntu 18.04, Debian 9, macOS 10.12, and Windows 2016

## 8.0.1 (2018-02-10)

- Resolve the new FC118 foodcritic warning
- Remove the ChefSpec matchers which are auto generated now
- Resolve FC104 warning

## 8.0.0 (2017-09-01)

### Breaking Changes

- macOS resource now properly executes and uses homebrew to install git instead of dmg and packages posted to SourceForge
- Default to Git 2.9.5 now, which properly compiles on Fedora / Amazon Linux

## Other Changes

- Fixed support for Amazon Linux on Chef 13
- Unified the package setup for source installs which fixes Amazon/Fedora
- Removed an entirely duplicate service provider
- Remove unused runit templates
- Properly fail when we're on an unsupported platform

## 7.0.0 (2017-09-01)

- Remove support for RHEL 5 which removes the need for the yum-epel cookbook
- Move templates out of the default directory now that we require Chef 12
- Remove support for Ubuntu 10.04
- Remove the version requirement on mac_os_x in the metadata
- Move maintainer information to the readme
- Expand Travis testing

## 6.1.0 (2017-05-30)

- Test with Local Delivery and not Rake
- Remove EOL platforms from the kitchen configs
- Use a SPDX standard license string
- Updated default versions documented in README to fix Issue #120.
- Remove class_eval and require chef 12.7+

## 6.0.0 (2017-02-14)

- Fail on deprecations is now enabled so we're fully Chef 13 compatible
- Define the chefspec matchers properly
- Remove the legacy platform mappings that fail on Chef 13
- Improve the test cookbook / integration tests
- Convert config LWRP to a custom resource and make it fully idempotent
- Require Chef 12.5 or later

## 5.0.2 (2017-01-18)

- Remove arch for the metadata
- Avoid deprecation warning during testing
- respond_to?(:chef_version) for < 12.6 compat

## 5.0.1 (2016-09-15)

- Clarify we require Chef 12.1 or later

## 5.0.0 (2016-09-02)

- Require Chef 12 or later
- Don't depend on the windows cookbook since windows_package is built into Chef 12
- Updates for testing

## v4.6.0 (2016-07-05)

- Added support for compiling git on suse
- Added the ability to pass a new group property to the config provider
- Documented the git_config provider
- Added the tar package on RHEL/Fedora for source installs as some minimal installs lack this package
- Added suse, opensuse, and opensuseleap as supported platforms in the metadata
- Switched to inspec for testing
- Switched to cookstyle for Ruby linting
- Added Travis integration testing of Debian 7/8

## v4.5.0 (2016-04-28)

- Update git versions to 2.8.1

## v4.4.1 (2016-03-31)

- PR #95 support 32 bit and 64 bit installs on windows @smurawski

## v4.4.0 (2016-03-23)

- PR #93 bump to latest git @ksubrama

## v4.3.7 (2016-02-03)

- PR #90 port node[git][server][export_all] to true/false @scalp42
- PR #89 make attributes more wrapper friendly @scalp42
- Update testing deps + rubocop fixes
- README fix @zverulacis

## v4.3.6 (2016-01-25)

- Windows fixes

## v4.3.5 (2015-12-15)

- Fixed installation on Windows nodes
- Removed the last of the Chef 10 compatibility code
- Added up to date contributing and testing docs
- Updated test deps in the Gemfile
- Removed test kitchen digital ocean config
- Test with kitchen-docker in Travis CI
- Removed uncessary windows cookbook entry from the Berksfile
- Added the chef standard rubocop.yml file and resolved all warnings
- Added chefignore file
- Removed bin dir
- Added maintainers.md and maintainers.toml files
- Added travis and supermarket version badges to the readme

## v4.3.4 (2015-09-06)

- Fixing package_id on OSX
- Adding 2.5.1 data for Windows

## v4.3.3 (2015-07-27)

- # 76: Use checksum keyname instead of value in source recipe

## v4.3.2 (2015-07-27)

- Fixing up Windows provider (issue #73)
- Supporting changes to source_prefix in source provider (#62)

## v4.3.1 (2015-07-23)

- Fixing up osx_dmg_source_url

## v4.3.0 (2015-07-20)

- Removing references to node attributes from provider code
- Name-spacing of client resource property names
- Addition of windows recipe
- Creation of package recipe

## v4.2.4 (2015-07-19)

- Fixing source provider selection bug from 4.2.3

## v4.2.3 (2015-07-18)

- mac_os_x provider mapping
- various rubocops

## v4.2.2 (2015-04-23)

- Fix up action in Chef::Resource::GitService
- Adding matchers

## v4.2.1 (2015-04-17)

- Fixing Chef 11 support.
- Adding provider mapping file

## v4.2.0 (2015-04-15)

- Converting recipes to resources.
- Keeping recipe interface for backwards compat

## v4.1.0 (2014-12-23)

- Fixing windows package checksums
- Various test coverage additions

## v4.0.2 (2014-04-23)

- [COOK-4482] - Add FreeBSD support for installing git client

## v4.0.0 (2014-03-18)

- [COOK-4397] Only use_inline_resources on Chef 11

## v3.1.0 (2014-03-12)

- [COOK-4392] - Cleanup git_config LWRP

## v3.0.0 (2014-02-28)

[COOK-4387] Add git_config type [COOK-4388] Fix up rubocops [COOK-4390] Add integration tests for default and server suites

## v2.10.0 (2014-02-25)

- [COOK-4146] - wrong dependency in git::source for rhel 6
- [COOK-3947] - Git cookbook adds itself to the path every run

## v2.9.0

Updating to depend on cookbook yum ~> 3 Fixing style to pass rubocop Updating test scaffolding

## v2.8.4

fixing metadata version error. locking to 3.0

## v2.8.1

Locking yum dependency to '< 3'

## v2.8.0

### Bug

- [COOK-3433] - git::server does not correctly set git-daemon's base-path on Debian

## v2.7.0

### Bug

- **[COOK-3624](https://tickets.chef.io/browse/COOK-3624)** - Don't restart `xinetd` on each Chef client run
- **[COOK-3482](https://tickets.chef.io/browse/COOK-3482)** - Force git to add itself to the current process' PATH

### New Feature

- **[COOK-3223](https://tickets.chef.io/browse/COOK-3223)** - Support Omnios and SmartOS package installs

## v2.6.0

### Improvement

- **[COOK-3193](https://tickets.chef.io/browse/COOK-3193)** - Add proper debian packages

## v2.5.2

### Bug

- [COOK-2813]: Fix bad string interpolation in source recipe

## v2.5.0

- Relax runit version constraint (now depend on 1.0+).

## v2.4.0

- [COOK-2734] - update git versions

## v2.3.0

- [COOK-2385] - update git::server for `runit_service` resource support

## v2.2.0

- [COOK-2303] - git::server support for RHEL `platform_family`

## v2.1.4

- [COOK-2110] - initial test-kitchen support (only available in GitHub repository)
- [COOK-2253] - pin runit dependency

## v2.1.2

- [COOK-2043] - install git on ubuntu 12.04 not git-core

## v2.1.0

The repository didn't have pushed commits, and so the following changes from earlier-than-latest versions wouldn't be available on the community site. We're releasing 2.1.0 to correct this.

- [COOK-1943] - Update to git 1.8.0
- [COOK-2020] - Add setup option attributes to Git Windows package install

## v2.0.0

This version uses `platform_family` attribute, making the cookbook incompatible with older versions of Chef/Ohai, hence the major version bump.

- [COOK-1668] - git cookbook fails to run due to bad `platform_family` call
- [COOK-1759] - git::source needs additional package for rhel `platform_family`

## v1.1.2

- [COOK-2020] - Add setup option attributes to Git Windows package install

## v1.1.0

- [COOK-1943] - Update to git 1.8.0

## v1.0.2

- [COOK-1537] - add recipe for source installation

## v1.0.0

- [COOK-1152] - Add support for Mac OS X
- [COOK-1112] - Add support for Windows

## v0.10.0

- [COOK-853] - Git client installation on CentOS

## v0.9.0

- Current public release
