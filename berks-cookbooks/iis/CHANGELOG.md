v4.1.0 (2015-03-04)
-------------------
- Removed iis_pool attribute 'set_profile_environment' incompatible with < IIS-8.
- Added pester test framework.
- Condensed and fixed change-log to show public releases only.
- Fixed bug where bindings were being overwritten by :config.
- Code-cleanup and cosmetic fixes.

v4.0.0 (2015-02-12)
-------------------
- [#91](https://github.com/chef-cookbooks/iis/pull/91) - bulk addition of new features
  - Virtual Directory Support (allows virtual directories to be added to both websites and to webapplications under sites).
  - section unlock and lock support (this is used to allow for the web.config of a site to define the authentication methods).
  - fixed issue with :add on pool provider not running all config (this was a known issue and is now resolved).
  - fixed issue with :config on all providers causing application pool recycles (every chef-client run).
  - moved to better method for XML checking of previous settings to detect changes (changed all check to use xml searching with appcmd instead of the previous method [none]).
- Improved pool resource with many more apppool properties that can be set.
- Fixed bug with default attribute inheritance.
- New recipe to enable ASP.NET 4.5.
- Skeleton serverspec+test-kitchen framework.
- Added Berksfile, Gemfile and .kitchen.yml to assist developers.
- Fixed issue [#107] function is_new_or_empty was returning reverse results.
- Removed dependency on "chef-client", ">= 3.7.0".
- Changed all files to UTF-8 file format.
- Fixed issue with iis_pool not putting ApplicationPoolIdentity and username/password.
- [#98] Fixed issues with bindings.
- added backwards compatibility for chef-client < 12.x.x Chef::Util::PathHelper.

v2.1.6 (2014-11-12)
-------------------
- [#78] Adds new_resource.updated_by_last_action calls

v2.1.5 (2014-09-15)
-------------------
- [#68] Add win_friendly_path to all appcmd.exe /physicalPath arguments

v2.1.4 (2014-09-13)
-------------------
- [#72] Adds chefspec matchers
- [#57] Fixes site_id not being updated on a :config action

v2.1.2 (2014-04-23)
-------------------
- [COOK-4559] Remove invalid UTF-8 characters


v2.1.0 (2014-03-25)
-------------------
[COOK-4426] -  feature order correction for proper installation
[COOK-4428] -  Add IIS FTP Feature Installation


v2.0.4 (2014-03-18)
-------------------
- [COOK-4420] Corrected incorrect feature names for mod_security


v2.0.2 (2014-02-25)
-------------------
- [COOK-4108] - Add documentation for the 'bindings' attribute in 'iis_site' LWRP


v2.0.0 (2014-01-03)
-------------------
Major version bump


v1.6.6
------
Adding extra windows platform checks to helper library


v1.6.4
------
### Bug
- **[COOK-4138](https://tickets.chef.io/browse/COOK-4138)** - iis cookbook won't load on non-Windows platforms


v1.6.2
------
### Improvement
- **[COOK-3634](https://tickets.chef.io/browse/COOK-3634)** - provide ability to set app pool managedRuntimeVersion to "No Managed Code"


v1.6.0
------
### Improvement
- **[COOK-3922](https://tickets.chef.io/browse/COOK-3922)** - refactor IIS cookbook to not require WebPI


v1.5.6
------
### Improvement
- **[COOK-3770](https://tickets.chef.io/browse/COOK-3770)** - Add Enabled Protocols to IIS App Recipe


v1.5.4
------
### New Feature
- **[COOK-3675](https://tickets.chef.io/browse/COOK-3675)** - Add recipe for CGI module

v1.5.2
------
### Bug
- **[COOK-3232](https://tickets.chef.io/browse/COOK-3232)** - Allow `iis_app` resource `:config` action with a virtual path

v1.5.0
------
### Improvement

- [COOK-2370]: add MVC2, escape `application_pool` and add options for
  recycling
- [COOK-2694]: update iis documentation to show that Windows 2012 and
  Windows 8 are supported

### Bug

- [COOK-2325]: `load_current_resource` does not load state of pool
  correctly, always sets running to false
- [COOK-2526]: Installing IIS after .NET framework will leave
  installation in non-working state
- [COOK-2596]: iis cookbook fails with indecipherable error if EULA
  not accepted

v1.4.0
------
* [COOK-2181] -Adding full module support to iis cookbook

v1.3.6
------
* [COOK-2084] - Add support for additional options during site creation
* [COOK-2152] - Add recipe for IIS6 metabase compatibility

v1.3.4
------
* [COOK-2050] - IIS cookbook does not have returns resource defined

v1.3.2
------
* [COOK-1251] - Fix LWRP "NotImplementedError"

v1.3.0
------
* [COOK-1301] - Add a recycle action to the iis_pool resource
* [COOK-1665] - app pool identity and new node[iis][component] attribute
* [COOK-1666] - Recipe to remove default site and app pool
* [COOK-1858] - Recipe misspelled

v1.2.0
------
* [COOK-1061] - `iis_site` doesn't allow setting the pool
* [COOK-1078] - handle advanced bindings
* [COOK-1283] - typo on pool
* [COOK-1284] - install iis application initialization
* [COOK-1285] - allow multiple host_header, port and protocol
* [COOK-1286] - allow directly setting which app pool on site creation
* [COOK-1449] - iis pool regex returns true if similar site exists
* [COOK-1647] - mod_ApplicationInitialization isn't RC

v1.1.0
------
* [COOK-1012] - support adding apps
* [COOK-1028] - support for config command
* [COOK-1041] - fix removal in app pools
* [COOK-835] - add app pool management
* [COOK-950] - documentation correction for version of IIS/OS

v1.0.2
------
* Ruby 1.9 compat fixes
* ensure carriage returns are removed before applying regex

v1.0.0
------
* [COOK-718] initial release
