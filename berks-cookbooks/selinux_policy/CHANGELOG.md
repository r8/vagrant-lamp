# selinuxpolicy CHANGELOG

This file is used to changes made in each version of the selinuxpolicy cookbook.

## [2.3.0] (2018-11-XX)

- Further fixes for the earlier refactoring
- Repair CI jobs

## [2.2.0] (2018-11-21)

- Large refactoring to helpers and resources
- Add RHEL-8 packages


## [2.1.0] (2018-04-12)

- Port definition methods to check for already defined ports
- Cleanup resource cloning
- Deprecate support for Chef 12.x now it's EOL
- Fix Foodcritic warnings & update test platforms

## 2.0.1 (2017-04-21)

- Perform relabel (restorecon) using find to support regexes

## 2.0.0 (2017-02-23)

- This cookbook has been moved to the Sous Chefs org. See sous-chefs.org for more information
- Require Chef 12.1 or later
- Use compat_resource instead of requiring yum
- Don't install yum::dnf_yum_compat on Fedora since Chef has DNF support now
- Don't define attributes in the metadata as these aren't used
- Remove the Vagrantfile
- Add chef_version requirements to the metadata
- Test with ChefDK / Rake in Travis instead of gems
- Resolve Foodcritic, Cookstyle, and Chefspec warnings

## 1.1.1

- [7307850] (Adam Ward) Silence fcontext guard output
- [ad71437] (nitz) Restorecon is now done via shell_out
- [fa30813] (James Le Cuirot) Change yum dependency to ~> 4.0
- [cd9a8da] (nitz) Removed selinux enforcing from kitchen, unified runlists

## 1.1.0

- [daften] Added `file_type` for fcontext

## 1.0.1

- [backslasher] - Foodcritic and rubocop improvements

## 1.0.0

- [equick] - Validating ports better
- [backslasher] - FContext relabling for flies is now immediate. (Possibly breaking)
- [backslasher] - testing made slightly more elegant

## 0.9.6

- [jhmartin] - Updated README
- [backslasher] - Major revision of testing

## 0.9.5

- [backslasher] - Modified yum dependency

## 0.9.4

- [mhorbul] - Fixed state detection in boolean resource

## 0.9.3

- [backlsasher] - Fixed testing & kitchen
- [jbartko] - Added Fedora support

## 0.9.2

- [backslasher] - Ignoring nonexisting files in restorecon

## 0.9.1

- [backslasher] - Fixed issue with module being partially executed on machines with SELinux disabled

## 0.9.0

- [backslasher] - module overhaul: code refactoring, supporting new input, testing, new actions
- [backslasher] - fcontext overhaul: code refactoring, testing, new action

**Note**: I don't think I have any breaking changes here. If there are, I apologise and request that you create an issue with a test recipe that fails on the problem (so I can reproduce)

## 0.8.1

- [backslasher] - Added Travis CI harness
- [backslasher] - Fixed typo in README

## 0.8.0

- [backslasher] - Test overhaul. Now testing is somewhat reliable when using ports
- [backslasher] - Port search is a function
- [backslasher] - Port detection now supports ranges. No possibility to add ranges (yet)

## 0.7.2

- [shortdudey123] - ChefSpec matchers, helps testing

## 0.7.1

- [backslasher] - Forgot contributor

## 0.7.0

- [chewi] - Fixed prereq packages
- [backslasher] - Modified misleading comment
- [chewi] - Move helpers into a cookbook-specific module
- [chewi] - Prevent use_selinux from blowing up on systems without getenforce

## 0.6.5

- [backslasher] - Ubuntu installation warning

## 0.6.4

- [sauraus] - CentOS 7 support
- [sauraus] - Typos

## 0.6.3

- [backslasher] - Readme updates
- [kevans] - Added kitchen testing

## 0.6.2

- [kevans] - Support Chef 11.8.0 running shellout!()
- [backslasher] - Simplified support info
- [backslasher] - ASCIIed files

## 0.6.1

- [backslasher] - Migrated to `only_if` instead of if
- [backslasher] - README typos

## 0.6.0

- [joerg] - Added fcontext resource for managing file contexts under SELinux

## 0.5.0

- [backslasher] - Added RHEL5/derivatives support. Thanks to @knightorc.
- **Cookbook will break on RHEL7\. If anyone experiences this, please check required packages and create an issue/PR**
- [backslasher] - Machines without SELinux are (opionally) supported. Thanks to @knightroc.

## 0.4.0

- [backlasher] - Fixed foodcritic errors

## 0.3.0

- [backlasher] - Fixed `install.rb` syntax. Now it actually works

## 0.2.0

- [backlasher] - Added module resource. Currently supports deployment and removal (because that's what I need)
- [backlasher] - Added permissive resource

## 0.1.0

- [backlasher] - Initial release of selinuxpolicy

[v2.1.0]: https://github.com/sous-chefs/selinux_policy/compare/v2.0.1...v2.1.0
