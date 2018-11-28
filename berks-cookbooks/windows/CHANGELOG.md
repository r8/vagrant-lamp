# windows Cookbook CHANGELOG

This file is used to list changes made in each version of the windows cookbook.

## 5.2.2 (2018-11-20)

- windows_share: Accounts to be revoked should be provided as an individually quoted string array

## 5.2.1 (2018-11-19)

- windows_share: Fix idempotency by not adding everyone by default

## 5.2.0 (2018-11-14)

- Support installing deleted features in windows_feature_dism

## 5.1.6 (2018-11-13)

- Add a warning to the readme regarding windows_share and windows_certificate now being included in Chef 14.7
- Deprecated win_friendly_path helper in favor of built-in helpers

## 5.1.5 (2018-11-07)

- Avoid deprecation warnings in windows_share and windows_certificate on Chef 14.7+ as these are now included in the chef-client itself.

## 5.1.4 (2018-10-30)

- Note the :verify action for windows_certificate in the readme
- certificate resource: auto set sensitive is passing password

## 5.1.3 (2018-10-11)

- Remove docs and test suite for windows tasks
- Changed variable name in log message for retrieving SMB share access
- Don't load the windows helper in windows_certificate

## 5.1.2 (2018-10-08)

- Fix typo in windows_feature_dism resource name

## 5.1.1 (2018-09-06)

- Require the win32-certstore gem and upgrade the gem as the resource runs so we get the most up to date version
- Remove redundant helper methods from the windows_certificate resource

## 5.1.0 (2018-08-29)

- Add an action to windows_user_privilege to remove a privilege
- Fix failing appveyor tests
- Require win32-certstore 0.1.8 which resolves several issues with the windows_certificate resource
- Avoid deprecation warnings with Chef 14.3+ by not loading resources that are now built into Chef

## 5.0.0 (2018-07-24)

### Breaking Changes

This release removes the windows_task and windows_path resources from this cookbook. This resources shipped in Chef 13.0 and 13.4 This raises the required version of chef-client for this cookbook to 13.4 or later.

## 4.3.4 (2018-07-18)

- Fix error message typo in windows_feature_powershell
- Use win32-certstore 0.1.7 for bugfixes

## 4.3.3 (2018-07-05)

- Fix failures on PS 3.0 in windows_feature_powershell

## 4.3.2 (2018-06-13)

- Don't error in windows_feature_dism when providing a source

## 4.3.1 (2018-06-11)

- Make sure to quote each individual user to grant share access to

## 4.3.0 (2018-06-11)

- Add the windows_user_privilege resource which can grant privileges like Logon As a Service
- Add windows_feature_powershell support for Windows 2008 R2 by not downcasing the feature names there and modifying the shell_out commands to make older output look like the 2012+ output
- windows_certificate resource has been reworked to use the new win32-certstore gem. This gem abstracts away much of the logic and will allow us to better support certificates on Windows, especially on non-english systems.
- Convert pester tests to InSpec for easier testing with ChefDK out of the box
- Added additional tests for better testing in AppVeyor
- Stop importing the servermanager module in windows_feature_powershell since we require PowerShell 3.0 and we don't need to do this there
- Improve the error messages in Windows feature to get the Windows versions right
- Increase readability in version logic with helpers in windows_feature resources

## 4.2.5 (2018-05-28)

- Add quoting to Path when creating new Share

## 4.2.4 (2018-05-14)

- Fix the platform version check in windows_share

## 4.2.3 (2018-05-07)

- Include the helper in the action class to prevent failures with the zipfile resource

## 4.2.2 (2018-04-24)

- Properly fail in windows_share on Windows 2008 R2 since we lack the cmdlets to manipulates shares on those systems.

## 4.2.1 (2018-04-17)

- Make sure shares can have spaces in the share name

## 4.2.0 (2018-04-16)

- Initial rewrite of windows_share to use PowerShell for share creation. This introduces multiple new properties and resolves a good number of longstanding issues. Please be sure to report any issues you see with this so we can stabilize this resource and include it in Chef 15!
- Resolve failures in windows_certificate

## 4.1.4 (2018-03-29)

- Raise in windows_feature_powershell if we're on PS < 3.0

## 4.1.3 (2018-03-28)

- Restore support for Windows 2008 R2 in windows_feature_dism

## 4.1.2 (2018-03-27)

- Improve creation messaging for shares
- Allow feature names to be case insensitive in windows_feature

## 4.1.1 (2018-03-23)

- Simplify delete action slightly in windows_pagefile
- Don't use win_friendly_path helper in windows_pagefile since we already coerce the path value

## 4.1.0 (2018-03-21)

- Adds Caching for WIndows Feature Powershell resource using the same sort of logic we use on windows_feature_dism. This gives us a 3.5X speedup when no features need to be changed (subsequent runs after the change)
- Warn if we're on w2k12 and trying to use source/management properties in windows_feature_powershell since that doesn't work.
- Properly parse features into arrays so installing an array of features works in dism/powershell. This is the preferred way to install a number of features and will be faster than a large number of feature resources
- Fix description of properties for pagefile in the readme

## 4.0.2 (2018-03-20)

- Enable FC016 testing
- Enable FC059 testing
- Properly calculate available packages if source is passed in windows_feature_dism resource

## 4.0.1 (2018-03-07)

Fix the previous update to windows_feature_dism to use 'override' level of attributes not the normal level which persists to the node. Thanks to @Annih for pointing out the mistake here.

## 4.0.0 (2018-03-05)

### WARNING

This release contains a complete rewrite to windows_feature_dism resource and includes several behavior changes to windows_feature resource. Make sure to read the complete list of changes below before deploying this to production systems.

#### DISM feature caching Ohai plugin replacement

In the 3.X cookbook we installed an Ohai plugin that cached the state of features on the node, and we reloaded that plugin anytime we installed/removed a feature from the system. This greatly sped up Chef runs where no features were actually installed/removed (2nd run and later). Without the caching each resource would take about 1 second longer while it queried current feature state. Using Ohai to cache this data was problematic though due to incompatibilities with Chef Solo, the reliance on the ohai cookbook, and the addition of extra node data which had to be stored on the Chef Server.

In the 4.0 release instead of caching data via an Ohai plugin we just write directly to the node within the resource. This avoids the need to load in the ohai plugin and the various issues that come with that. In the end it's basically the exact same thing, but less impacting on end users and faster when the data needs to be updated.

#### Fail when feature is missing in windows_feature_dism

The windows_feature_dism resource had a rather un-Chef behavior in which it just warned you if a feature wasn't available on your platform and then continued on silently. This isn't how we handle missing packages in any of our package resource and because of that it's not going to be what anyone expects out of the box. If someone really wants SNMP installed and we can't install it we should fail instead of continuing on as if we did install it. So we'll now do the following things:

- When installing a feature that doesn't exist: fail
- When removing a feature that doesn't exist: continue since it is technically removed
- When deleting a feature that doesn't exist: continue since it is technically deleted

For some users, particularly those writing community cookbooks, this is going to be a breaking change. I'd highly recommend putting logic within your cookbooks to only install features on supported releases of Windows. If you'd just like it to continue even with a failure you can also use `ignore_failure true` on your resource although this produces a lot of failure messaging in logs.

#### Properly support features as an array in windows_feature_dism

We claimed to support installing features as an array in the windows_feature_dism resource previously, but it didn't actually work. The actual result was a warning that the array of features wasn't available on your platform since we compared the array to available features as if it was a string. We now properly support installation as a array and we do validation on each feature in the array to make sure the features are available on your Windows release.

#### Install as the default action in windows_feature_powershell

Due to some previous refactoring the :install action was not the default action for windows_feature_powershell. For all other package resources in Chef install is the default so this would likely lead to some unexpected behavior in cookbooks. This is technically a breaking change, but I suspect everyone assumed :install was always the default.

#### servermanagercmd.exe Support Removal

This cookbook previously supported servermanagercmd.exe, which was necessary for feature installation on Windows 2003 / 2008 (not R2) systems. Windows 2003 went full EOL in 2015 and 2008 went into extended support in 2015\. Neither releases are supported platforms for Chef or this cookbook so we've chosen to simplify the code and remove support entirely.

#### Remove the undocumented node['windows']['rubyzipversion'] attribute

This attribute was a workaround for a bug in the rubyzip gem YEARS ago that's just not necessary anymore. We also never documented this attribute and a resource shouldn't change behavior based on attributes.

## 3.5.2 (2018-03-01)

- Remove value_for_feature_provider helper which wasn't being used and was using deprecated methods
- Add all the Windows Core editions to the version helper
- Simplify / speedup how we find the font directory in windows_font
- Don't bother enabling why-run mode in the resources since it's enabled by default
- Don't include mixlib-shellout in the resources since it's included by default
- Fix installation messaging for windows_feature_powershell to properly show all features being installed
- Use powershell for the share creation / deletion in windows_share. This speeds up the runs and fixes some of the failures.

## 3.5.1 (2018-02-23)

- Add a new `shortcut_name` property to `windows_shortcut`
- Use Chef's built in registry_key_exists helper in `windows_printer_port`
- Fix the `source` coerce in `windows_font`

## 3.5.0 (2018-02-23)

- Add Windows 2016 to the supported releases in the readme
- Add Windows 10 detection to the version helper
- Remove the Chefspec matchers. These are auto generated by ChefSpec now. If this causes your specs to fail upgrade ChefDK
- In `certificate_binding` support `hostnameport` option if address is a hostname
- Convert several tests to InSpec tests and add additional test scenarios
- Remove `required: true` on the name_properties, which serves no purpose and will be a Foodcritic rule in the next Foodcritic release
- Fix `windows_feature` logging to work when the user provides an array of features
- Don't both coercing a symbol into a symbol in the `windows_auto_run` resource.
- Switch `windows_font` over to the built in path helper in Chef, which a much more robust
- Don't coerce forward slashes to backslashes in the `windows_font` `source` property if the source is a URI
- Add a new `path` property to `windows_pagefile` for properly overriding the resource name
- Coerce backslashes to forward slashes in `windows_pagefile`'s `path` property so we do the right thing even if a user gives bad input
- Add a new `program_name` property in windows_auto_run for overriding the resource name
- Rename `program` property to `path` in windows_auto_run. The legacy name will continue to work, but cookbooks should be updated
- Coerce the `path` property to use backslashes in `windows_auto_run` so it works no matter what format of path the user provides
- Avoid writing out an extra space in `windows_auto_run`'s registry entry when the user doesn't specify an arg
- Added yard comments to many of the helper methods

## 3.4.4 (2018-01-19)

- Fix undefined method for 'ipv4_address' in windows_printer_port

## 3.4.3 (2018-01-04)

- Added missing parentheses around PersistKeySet flag that was preventing PowerShell from creating X509Certificate2 object

## 3.4.2 (2018-01-02)

- Add deprecation warnings for windows_path and windows_task which are now included in Chef 13\. These will be removed from this cookbook in Sept 2018.

## 3.4.1 (2017-12-06)

- Fix long-running filtering by replace LIKE with equality sign in the share resource
- Use logical OR instead of AND when trying to detect share permissions changing in the share resource
- Remove extra new_resource.updated_by_last_action in the windows_task resource that resulted in a Foodcritic warning

## 3.4.0 (2017-11-14)

- Add a root key property for the auto_run resource
- Fix a resource typo where a name_property was still written name_attribute
- Resolve FC108 warnings

## 3.3.0 (2017-11-06)

- Add new dns resource. See readme for examples
- Add BUILTIN\Users to SYSTEM_USERS for windows_task

## 3.2.0 (2017-10-17)

- Add management_tools property to windows_feature powershell provider which installs the various management tools
- Fix deprecations_namespace_collisions
- Add additional certificate store names
- Add the ability to define a timeout on windows_feature
- Multiple improvements to the font resource

  - Improved logging, particularly debug logging
  - Allow pulling the font from a remote location using remote_file
  - Fix some failures in fetching local fonts
  - Added a font_name property that allows you specify the local name of the font, which can be different from the name of the chef resource. This allows you to create more friendly resource names for your converge.
  - Handle font resources with backslashes in their source

- Remove source property from servermanagercmd provider as it does not support it.

- Remove converge_by around inner powershell_script resource to stop it always reporting as changed

- Change install feature guards to work on Windows 2008r2

- Allow dism feature installs to work on non-English systems

## 3.1.3 (2017-09-18)

### windows_task and windows_path deprecation

s of chef-client 13.0+ and 13.4+ windows_task and windows_path are now included in the Chef client. windows_task underwent a full rewrite that greatly improved the functionality and idempotency of the resource. We highly recommend using these new resources by upgrading to Chef 13.4 or later. If you are running these more recent Chef releases the windows_task and windows_path resources within chef-client will take precedence over those in this cookbook. In September 2018 we will release a new major version of this cookbook that removes windows_task and windows_path.

## 3.1.2 (2017-08-14)

- Revert "Require path in the share resource instead of raising if it's missing" which was causing failures due to a bug in the chef-client

## 3.1.1 (2017-06-13)

- Replace Windows 7 testing with Windows 10 testing
- Expand debug logging in the pagefile resource
- Require path in the share resource instead of raising if it's missing
- Make pagefile properly fail the run if the command fails to run

## 3.1.0 (2017-05-30)

- Updated resource documentation for windows_pagefile
- Declare windows_feature as why-runnable
- Remove action_class.class_eval usage and require 12.7+ as class_eval is causing issues with later versions of Chef

## 3.0.5 (2017-04-07)

- Add support for windows_task resource to run on non-English editions of Windows
- Ensure chef-client 12.6 compatibility with action_class.class_eval

## 3.0.4 (2017-03-29)

- restoring the `cached_file` helper as downstream cookbooks use it.

## 3.0.3 (2017-03-28)

- Correct a typo in a Log message

## 3.0.2 (2017-03-21)

- Fix `windows_zipfile` resource to properly download and cache the zip archives

## 3.0.1 (2017-03-17)

- Fix `windows_share` to be fully idempotent. Fixes #447

## 3.0.0 (2017-03-15)

**Warning** This release includes multiple breaking changes as we refactored all existing resources and resolved many longstanding bugs. We highly recommend exercising caution and fully testing this new version before rolling it out to a production environment.

### Breaking changes

- This cookbook now requires Chef 12.6 or later and we highly recommend even more recent Chef 12 releases as they resolve critical Windows bugs and include new Windows specific functionality.
- The windows_package resource has been removed as it is built into chef-client 12.6+ and the built in version is faster / more robust.
- The powershell out helper has been removed as it is now included in chef-client 12.6+
- The default recipe no longer installs the various Windows rubygems required for non-omnibus chef-client installs. This was a leftover from Chef 10 and is no longer necessary, or desired, as we ship these gems in every Windows chef release.
- windows_feature has been heavily refactored and in doing so the method used to control the underlying providers has changed. You can no longer specify which windows_feature provider to use by setting `node['windows']['feature_provider']` or by setting the `provider` property on the resource itself. Instead you must set `install_method` to specify the correct underlying installation method. You can also now reference the resources directly by using `windows_feature_servermanagercmd`, `windows_feature_powershell` or `windows_feature_dism` instead of `windows_feature`

- Windows_font's `file` property has been renamed to `name` to avoid collisions with the Chef file resource.

### Other Changes

- All LWRPs in this cookbook have been refactored to be custom resources
- windows_path, windows_shortcut, and windows_zipfile have been updated to be idempotent with support for why-run mode and proper notification when the resources actually update
- windows_pagefile now validates the name of the pagefile to avoid cryptic error messages
- A new `share` resource has been added for setting up Windows shares
- TrustedPeople certificate store has been added to the list of allowed store_names in the certificate resources
- version helper constant definitions has been improved
- A new `all` property has been added to the Windows feature resource to install all dependent features. See the windows feature test recipe for usage examples.
- Windows feature now accepts an array of features, which greatly speeds up feature installs and simplifies recipe code
- The path resource now accepts paths with either forward slashes or backslashes and correctly adds the path using Windows style backslash.
- The powershell provider for windows_feature resource has been fixed to properly import ServerManager in the :remove action
- Testing has been switched from a Rakefile to the new Delivery local mode
- Several issues with testing the resources on non-Windows hosts in ChefSpec have been resolved
- A new `source` property has been added to the windows_feature_powershell resource
- Additional test suites have been added to Test Kitchen to cover all resources and those test suites are now being executed in AppVeyer on every PR
- Travis CI testing has been removed and all testing is being performed in AppVeyer

## 2.1.1 (2016-11-23)

- Make sure the ohai plugin is available when installing features

## 2.1.0 (2016-11-22)

- Reduce expensive executions of dism in windows_feature by using a new Ohai plugin
- Add guard around chef_version metadata for Opsworks and older Chef 12 clients
- Update the rakefile to the latest
- Add deprecation dates for the windows_package and powershell functionality that has been moved to core Chef. These will be removed 4/17 when we release Chef 13
- Provide helper method to get windows version info
- Allow defining http acl using SDDL

## 2.0.2 (2016-09-07)

- Added the powershell_out mixin back to allow for Chef 12.1-12.3 compatibility
- Set the dependency back to Chef 12.1

## 2.0.1 (2016-09-07)

- Clarify the platforms we support in the readme
- Require Chef 12.4 which included powershell_out

## 2.0.0 (2016-09-07)

This cookbook now requires Chef 12.1+. Resources (lwrps) that have been moved into the chef-client have been removed from this cookbook. While the functionality in the chef-client is similar, and in many cases improved, the names and properties have changed in some cases. Make sure to check <https://docs.chef.io/resources.html> for full documentation on each of these resources, and as usual carefully test your cookbooks before upgrading to this new release.

### Removed resources and helpers:

- windows_reboot provider
- windows_batch provider
- windows_registry provider
- Powershell out for only_if / not_if statements
- Windows Architecture Helper
- Reboot handler and the dependency on the chef_handler cookbook

#### Changes resource behavior

- For Chef clients 12.6 and later the windows_package provider will no longer be used as windows_package logic is now included in Chef. Chef 12.1 - 12.5.1 clients will continue to default to the windows_package provider in this cookbook for full compatibility.

#### Additional changes

- Updated and expanded testing
- Fixed the windows_feature powershell provider to run on Windows 2008 / 2008 R2
- Added TrustedPublisher as a valid cert store_name
- Updated the certificate_binding resource to respect the app_id property
- Added why-run support to the auto_run resource

## 1.44.3 (2016-08-16)

- Remove support for ChefSpec <4.1 in the matchers
- Add missing Chefspec matchers

## 1.44.2 (2016-08-15)

- Add missing windows_font matcher
- Add chef_version to the metadata
- Switch from Rubocop to Cookstyle and use our improved Rakefile
- Remove test deps from the Gemfile that are in ChefDK

## v1.44.1

- [PR 375](https://github.com/chef-cookbooks/windows/pull/375) - Fix comparison of string to number in platform_version
- [PR 376](https://github.com/chef-cookbooks/windows/pull/376) - Switch to cookstyle, update gem deps and other minor stuff
- [PR 377](https://github.com/chef-cookbooks/windows/pull/377) - add test and check for feature installation through powershell

## v1.44.0

- [PR 372](https://github.com/chef-cookbooks/windows/pull/372) - Support Server 2008 for feature installs via PowerShell

## v1.43.0

- [PR 369](https://github.com/chef-cookbooks/windows/pull/369) - Add a enable_windows_task matcher

## v1.42.0

- [PR 365](https://github.com/chef-cookbooks/windows/pull/365) - Escape command quotes when passing to schtasks

## v1.41.0

- [PR 364](https://github.com/chef-cookbooks/windows/pull/364) - Configurable font source

## v1.40.0

- [PR 357](https://github.com/chef-cookbooks/windows/pull/357) - Fixes for schtasks
- [PR 359](https://github.com/chef-cookbooks/windows/pull/359) - take bundler out of the appveyor build
- [PR 356](https://github.com/chef-cookbooks/windows/pull/356) - Misc fixes and updates
- [PR 355](https://github.com/chef-cookbooks/windows/pull/355) - bump and pin rubocop, fix broken cop
- [PR 348](https://github.com/chef-cookbooks/windows/pull/348) - Make notify work for `windows_task`

## v1.39.2

- [PR 329](https://github.com/chef-cookbooks/windows/pull/329) - Silence `compile_time` warning for `chef_gem`
- [PR 338](https://github.com/chef-cookbooks/windows/pull/338) - ChefSpec matchers for `windows_certificate`
- [PR 341](https://github.com/chef-cookbooks/windows/pull/341) - Updated rubocop and FoodCritic compliance
- [PR 336](https://github.com/chef-cookbooks/windows/pull/336) - Fixed where clause compliance with PS v1/v2

## v1.39.1

- [PR 325](https://github.com/chef-cookbooks/windows/pull/325) - Raise an error if a bogus feature is given to the powershell `windows_feature` provider
- [PR 326](https://github.com/chef-cookbooks/windows/pull/326) - Fix `windows_font` and copy the font file before installation

## v1.39.0

- [PR 305](https://github.com/chef-cookbooks/windows/pull/305) - Added `months` attribute to `windows_task` and allow `frequency_modifier` to accept values 'FIRST', 'SECOND', 'THIRD', 'FOURTH', 'LAST', and 'LASTDAY' for monthly frequency
- [PR 310](https://github.com/chef-cookbooks/windows/pull/310) - Fix `windows_task` breaks when there is a space in the user name
- [PR 314](https://github.com/chef-cookbooks/windows/pull/314) - fixes reboot handling on some chef versions below 11.12
- [PR 317](https://github.com/chef-cookbooks/windows/pull/317) - Adds a `disable_windows_task` matcher
- [PR 311](https://github.com/chef-cookbooks/windows/pull/311) - Implements the `cwd` attribute of `windows_task`
- [PR 318](https://github.com/chef-cookbooks/windows/pull/318) - Use dsl instead of manual resource instanciation
- [PR 303](https://github.com/chef-cookbooks/windows/pull/303) - Fix `http_acl` idempotency when user name contains a space
- [PR 257](https://github.com/chef-cookbooks/windows/pull/257) - Speed up windows_feature dism provider
- [PR 319](https://github.com/chef-cookbooks/windows/pull/319) - Add a `.kitchen.cloud.yml` for kitchen testing on Azure
- [PR 315](https://github.com/chef-cookbooks/windows/pull/315) - Deprecate `windows_package` and forward to `Chef::Provider::Package::Windows` when running 12.6 or higher

## v1.38.4

- [PR 295](https://github.com/chef-cookbooks/windows/pull/295) - Escape `http_acl` username
- [PR 293](https://github.com/chef-cookbooks/windows/pull/293) - Separating assignments to `code_script` and `guard_script` as they should be different scripts and not hold the same reference
- [Issue 298](https://github.com/chef-cookbooks/windows/issues/298) - `windows_certificate_binding` is ignoring `store_name` attribute and always saving to `MY`
- [Issue 296](https://github.com/chef-cookbooks/windows/pull/302) - Fixes `windows_certificate` idempotentcy on chef 11 clients

## v1.38.3

- Make `windows_task` resource idempotent (double quotes need to be single when comparing)
- [Issue 245](https://github.com/chef-cookbooks/windows/issues/256) - Fix `No resource, method, or local variable named`password' for `Chef::Provider::WindowsTask'` when `interactive_enabled` is `true`

## v1.38.2

- Lazy-load windows-pr gem library files. Chef 12.5 no longer includes the windows-pr gem. Earlier versions of this cookbook will not compile on Chef 12.5.

## v1.38.1 (2015-07-28)

- Publishing without extended metadata

## v1.38.0 (2015-07-27)

- Do not set new_resource.password to nil, Fixes #219, Fixes #220
- Add `windows_certificate` resource #212
- Add `windows_http_acl` resource #214

## v1.37.0 (2015-05-14)

- fix `windows_package` `Chef.set_resource_priority_array` warning
- update `windows_task` to support tasks in folders
- fix `windows_task` delete action
- replace `windows_task` name attribute with 'task_name'
- add :end action to 'windows_task'
- Tasks created with the `windows_task` resource default to the SYSTEM account
- The force attribute for `windows_task` makes the :create action update the definition.
- `windows_task` :create action will force an update of the task if the user or command differs from the currently configured setting.
- add default provider for `windows_feature`
- add a helper to make sure `WindowsRebootHandler` works in ChefSpec
- added a source and issues url to the metadata for Supermarket
- updated the Gemfile and .kitchen.yml to reflect the latest test-kitchen windows guest support
- started tests using the kitchen-pester verifier

## v1.36.6 (2014-12-18)

- reverting all chef_gem compile_time work

## v1.36.5 (2014-12-18)

- Fix zipfile provider

## v1.36.4 (2014-12-18)

- Fix Chef chef_gem with Chef::Resource::ChefGem.method_defined?(:compile_time)

## v1.36.3 (2014-12-18)

- Fix Chef chef_gem below 12.1.0

## v1.36.2 (2014-12-17)

- Being explicit about usage of the chef_gem's compile_time property.
- Eliminating future deprecation warnings in Chef 12.1.0

## v1.36.1 (2014-12-17)

- [PR 160](https://github.com/chef-cookbooks/windows/pull/160) - Fix Chef 11.10 / versions without windows_package in core

## v1.36.0 (2014-12-16)

- [PR 145](https://github.com/chef-cookbooks/windows/pull/145) - do not fail on non-existant task
- [PR 144](https://github.com/chef-cookbooks/windows/pull/144) - Add a zip example to the README
- [PR 110](https://github.com/chef-cookbooks/windows/pull/110) - More zip documentation
- [PR 148](https://github.com/chef-cookbooks/windows/pull/148) - Add an LWRP for font installation
- [PR 151](https://github.com/chef-cookbooks/windows/pull/151) - Fix windows_package on Chef 12, add integration tests
- [PR 129](https://github.com/chef-cookbooks/windows/pull/129) - Add enable/disable actions to task LWRP
- [PR 115](https://github.com/chef-cookbooks/windows/pull/115) - require Chef::Mixin::PowershellOut before using it
- [PR 88](https://github.com/chef-cookbooks/windows/pull/88) - Code 1003 from servermanagercmd.exe is valid

## v1.34.8 (2014-10-31)

- [Issue 137](https://github.com/chef-cookbooks/windows/issues/137) - windows_path resource breaks with ruby 2.x

## v1.34.6 (2014-09-22)

- [Chef-2009](https://github.com/chef/chef/issues/2009) - Patch to work around a regression in [Chef](https://github.com/chef/chef)

## v1.34.2 (2014-08-12)

- [Issue 99](https://github.com/chef-cookbooks/windows/issues/99) - Remove rubygems / Internet wmi-lite dependency (PR #108)

## v1.34.0 (2014-08-04)

- [Issue 99](https://github.com/chef-cookbooks/windows/issues/99) - Use wmi-lite to fix Chef 11.14.2 break in rdp-ruby-wmi dependency

## v1.32.1 (2014-07-15)

- Fixes broken cookbook release

## v1.32.0 (2014-07-11)

- Add ChefSpec resource methods to allow notification testing (@sneal)
- Add use_inline_resources to providers (@micgo)
- [COOK-4728] - Allow reboot handler to be used as an exception handler
- [COOK-4620] - Ensure win_friendly_path doesn't error out when ALT_SEPARATOR is nil

## v1.31.0 (2014-05-07)

- [COOK-2934] - Add windows_feature support for 2 new DISM attributes: all, source

## v1.30.2 (2014-04-02)

- [COOK-4414] - Adding ChefSpec matchers

## v1.30.0 (2014-02-14)

- [COOK-3715] - Unable to create a startup task with no login
- [COOK-4188] - Add powershell_version method to return Powershell version

## v1.12.8 (2014-01-21)

- [COOK-3988] Don't unescape URI before constructing it.

## v1.12.6 (2014-01-03)

- [COOK-4168] Circular dep on powershell - moving powershell libraries into windows. removing dependency on powershell

## v1.12.4

Fixing depend/depends typo in metadata.rb

## v1.12.2

### Bug

- **[COOK-4110](https://tickets.chef.io/browse/COOK-4110)** - feature_servermanager installed? method regex bug

## v1.12.0

### Bug

- **[COOK-3793](https://tickets.chef.io/browse/COOK-3793)** - parens inside parens of README.md don't render

### New Feature

- **[COOK-3714](https://tickets.chef.io/browse/COOK-3714)** - Powershell features provider and delete support.

## v1.11.0

### Improvement

- **[COOK-3724](https://tickets.chef.io/browse/COOK-3724)** - Rrecommend built-in resources over cookbook resources
- **[COOK-3515](https://tickets.chef.io/browse/COOK-3515)** - Remove unprofessional comment from library
- **[COOK-3455](https://tickets.chef.io/browse/COOK-3455)** - Add Windows Server 2012R2 to windows cookbook version helper

### Bug

- **[COOK-3542](https://tickets.chef.io/browse/COOK-3542)** - Fix an issue where `windows_zipfile` fails with LoadError
- **[COOK-3447](https://tickets.chef.io/browse/COOK-3447)** - Allow Overriding Of The Default Reboot Timeout In windows_reboot_handler
- **[COOK-3382](https://tickets.chef.io/browse/COOK-3382)** - Allow windows_task to create `on_logon` tasks
- **[COOK-2098](https://tickets.chef.io/browse/COOK-2098)** - Fix and issue where the `windows_reboot` handler is ignoring the reboot time

### New Feature

- **[COOK-3458](https://tickets.chef.io/browse/COOK-3458)** - Add support for `start_date` and `start_time` in `windows_task`

## v1.10.0

### Improvement

- [COOK-3126]: `windows_task` should support the on start frequency
- [COOK-3127]: Support the force option on task create and delete

## v1.9.0

### Bug

- [COOK-2899]: windows_feature fails when a feature install requires a reboot
- [COOK-2914]: Foodcritic failures in Cookbooks
- [COOK-2983]: windows cookbook has foodcritic failures

### Improvement

- [COOK-2686]: Add Windows Server 2012 to version.rb so other depending chef scripts can detect Windows Server 2012

## v1.8.10

When using Windows qualified filepaths (C:/foo), the #absolute? method for URI returns true, because "C" is the scheme.

This change checks that the URI is http or https scheme, so it can be passed off to remote_file appropriately.

- [COOK-2729] - allow only http, https URI schemes

## v1.8.8

- [COOK-2729] - helper should use URI rather than regex and bare string

## v1.8.6

- [COOK-968] - `windows_package` provider should gracefully handle paths with spaces
- [COOK-222] - `windows_task` resource does not declare :change action
- [COOK-241] - Windows cookbook should check for redefined constants
- [COOK-248] - Windows package install type is case sensitive

## v1.8.4

- [COOK-2336] - MSI That requires reboot returns with RC 3010 and causes chef run failure
- [COOK-2368] - `version` attribute of the `windows_package` provider should be documented

## v1.8.2

**Important**: Use powershell in nodes expanded run lists to ensure powershell is downloaded, as powershell has a dependency on this cookbook; v1.8.0 created a circular dependency.

- [COOK-2301] - windows 1.8.0 has circular dependency on powershell

## v1.8.0

- [COOK-2126] - Add checksum attribute to `windows_zipfile`
- [COOK-2142] - Add printer and `printer_port` LWRPs
- [COOK-2149] - Chef::Log.debug Windows Package command line
- [COOK-2155] -`windows_package` does not send checksum to `cached_file` in `installer_type`

## v1.7.0

- [COOK-1745] - allow for newer versions of rubyzip

## v1.6.0

- [COOK-2048] - undefined method for Falseclass on task :change when action is :nothing (and task doesn't exist)
- [COOK-2049] - Add `windows_pagefile` resource

## v1.5.0

- [COOK-1251] - Fix LWRP "NotImplementedError"
- [COOK-1921] - Task LWRP will return true for resource exists when no other scheduled tasks exist
- [COOK-1932] - Include :change functionality to windows task lwrp

## v1.4.0:

- [COOK-1571] - `windows_package` resource (with msi provider) does not accept spaces in filename
- [COOK-1581] - Windows cookbook needs a scheduled tasks LWRP
- [COOK-1584] - `windows_registry` should support all registry types

## v1.3.4

- [COOK-1173] - `windows_registry` throws Win32::Registry::Error for action :remove on a nonexistent key
- [COOK-1182] - windows package sets start window title instead of quoting a path
- [COOK-1476] - zipfile lwrp should support :zip action
- [COOK-1485] - package resource fails to perform install correctly when "source" contains quote
- [COOK-1519] - add action :remove for path lwrp

## v1.3.2

- [COOK-1033] - remove the `libraries/ruby_19_patches.rb` file which causes havoc on non-Windows systems.
- [COOK-811] - add a timeout parameter attribute for `windows_package`

## v1.3.0

- [COOK-1323] - Update for changes in Chef 0.10.10.

  - Setting file mode doesn't make sense on Windows (package provider
  - and `reboot_handler` recipe)
  - Prefix ::Win32 to avoid namespace collision with Chef::Win32
  - (`registry_helper` library)
  - Use chef_gem instead of gem_package so gems get installed correctly under the Ruby environment Chef runs in (reboot_handler recipe, zipfile provider)

## v1.2.12

- [COOK-1037] - specify version for rubyzip gem
- [COOK-1007] - `windows_feature` does not work to remove features with dism
- [COOK-667] - shortcut resource + provider for Windows platforms

## v1.2.10

- [COOK-939] - add `type` parameter to `windows_registry` to allow binary registry keys.
- [COOK-940] - refactor logic so multiple values get created.

## v1.2.8

- FIX: Older Windows (Windows Server 2003) sometimes return 127 on successful forked commands
- FIX: `windows_package`, ensure we pass the WOW* registry redirection flags into reg.open

## v1.2.6

- patch to fix [CHEF-2684], Open4 is named Open3 in Ruby 1.9
- Ruby 1.9's Open3 returns 0 and 42 for successful commands
- retry keyword can only be used in a rescue block in Ruby 1.9

## v1.2.4

- `windows_package` - catch Win32::Registry::Error that pops up when searching certain keys

## v1.2.2

- combined numerous helper libarires for easier sharing across libaries/LWRPs
- renamed Chef::Provider::WindowsFeature::Base file to the more descriptive `feature_base.rb`
- refactored `windows_path` LWRP

  - :add action should MODIFY the the underlying ENV variable (vs CREATE)
  - deleted greedy :remove action until it could be made more idempotent

- added a `windows_batch` resource/provider for running batch scripts remotely

## v1.2.0

- [COOK-745] gracefully handle required server restarts on Windows platform

  - WindowsRebootHandler for requested and pending reboots
  - `windows_reboot` LWRP for requesting (receiving notifies) reboots
  - `reboot_handler` recipe for enabling WindowsRebootHandler as a report handler

- [COOK-714] Correct initialize misspelling

- RegistryHelper - new `get_values` method which returns all values for a particular key.

## v1.0.8

- [COOK-719] resource/provider for managing windows features
- [COOK-717] remove `windows_env_vars` resource as env resource exists in core chef
- new `Windows::Version` helper class
- refactored `Windows::Helper` mixin

## v1.0.6

- added `force_modify` action to `windows_registry` resource
- add `win_friendly_path` helper
- re-purpose default recipe to install useful supporting windows related gems

## v1.0.4

- [COOK-700] new resources and improvements to the `windows_registry` provider (thanks Paul Morton!)

  - Open the registry in the bitednes of the OS
  - Provide convenience methods to check if keys and values exit
  - Provide convenience method for reading registry values
  - NEW - `windows_auto_run` resource/provider
  - NEW - `windows_env_vars` resource/provider
  - NEW - `windows_path` resource/provider

- re-write of the `windows_package` logic for determining current installed packages

- new checksum attribute for `windows_package` resource...useful for remote packages

## v1.0.2

- [COOK-647] account for Wow6432Node registry redirecter
- [COOK-656] begin/rescue on win32/registry

## v1.0.0

- [COOK-612] initial release
