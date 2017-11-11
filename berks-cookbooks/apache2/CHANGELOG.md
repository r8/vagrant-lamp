# apache2 Cookbook Changelog

This file is used to list changes made in each version of the apache2 cookbook.

## v5.0.1 (2017-09-01)

- Test using dokken-images in kitchen-dokken
- Fix readme section for mod_php
- Replace the existing testing.md contents with a link to the Chef testing docs
- Fix mod_ldap failing on non-RHEL platforms
- Fix mod_dav_svn to install the correct packages on Debian 8/9

## v5.0.0 (2017-07-13)

### Breaking changes

- Support for Apache 2.2 has been fully removed so we can focus on providing a solid experience for Apache 2.4 and above. This removes support for RHEL 6, SLES 11, and Debian 7

### Other changes

- Fixed openSUSE support in multiple places and added integration testing for openSUSE in Travis

## v4.0.0 (2017-07-10)

### Breaking changes

- This cookbook now requires Chef 12.1 or later
- Support for Apache 2.2 on FreeBSD has been removed
- Support for Amazon Linux < 2013.09 has been removed
- Support for end of life releases of Fedora (< 24), CentOS (5), Debian (6), Linux Mint (17), and Ubuntu (12.04) have been removed
- Removed the deprecated recipes for mod_authz_default and mod_php5

### Other changes

- Switched many package resources to Chef 12+ multipackage style to speed up Chef converges and reduce log clutter
- mod_cache is now enabled when using mod_cache_disk and mod_cache_socache
- The mod_cloudflare recipe now sets up the Apt repo with https
- Improved support for Amazon Linux on Chef 13 and added Test Kitchen amazon testing
- Improved support for Debian and RHEL derivative platforms
- Improved Fedora support in multiple modules
- Improved error logging for unsupported platforms in the mod_negotiation and mod_unixd recipes
- Switched from Rake for testing to Delivery local mode
- Setup integration testing with kitchen-dokken for core platforms in Travis so that every PR is now fully tested
- Removed the EC2 and Docker kitchen files now that we have kitchen-dokken setup
- Removed apt, pacman, yum, and zypper from the Berksfile as they're no longer needed for testing
- Removed testing dependencies from the Gemfile as we're testing using ChefDK
- Added integration testing for new Debian releases

## v3.3.1 (2017-07-06)

- [GH-489] Fix OpenSuse service guard

## v3.3.0 (2017-04-11)

- [GH-478] Added support for the amazon platform_family, outside of RHEL
- [GH-474] Update Berksfile to allow fetching of newer
- [GH-473] Update copyright header format
- [GH-472] foodcritic: add sous-chefs rules
- add CODE_OF_CONDUCT
- [GH-471] FCGI paths should not be messed with on RHEL/CentOS 7\. CentOS 7 (and recent Fedoras) have Apache 2.4, where FCGI socket path and shared memory path is managed adequately without further involvement necessary (subdirectory is created under /var/run/httpd).
- [GH-470] Remove support for EOL Fedora < 18 / FreeBSD 9
- [GH-465] Testing updates
- [GH-469] Use the default cookbook style rules
- [GH-460] ServerSpec to InSpec migration
- [GH-461] Update comment header format & other Cookstyle fixes
- [GH-454] Test in Travis with Chef-DK and a Rakefile
- [GH-455] openSUSE Leap has it's own platform name
- [GH-279] leave stubs for rhel family `conf.d` files to avoid conflicts on package upgrade; no longer remove `conf.d`, just don't use it
- [GH-427] Add option to configure custom log level
- [GH-450] Ensure the lock_dir is owned by www-data for Apache 2.2 and 2.4 on Debian/Ubuntu
- Remove mod_auth_openid tests, as it is not part of the ASF release and plan to drop support for it and right now it is failing our tests
- [GH-440] Update default values in `apache.prefork` section of README
- [GH-443] fixed typo in copyright year
- Test on the latest chef with chef-zero
- Update supported platforms to Ubuntu 16.04, Debian 8.4, CentOS 7.2; deprecating Ubuntu 12.04
- [GH-422] Fix uniq for nil:NilClass error introduced in 3.2.2
- [GH-423] allow for apache 2.4 usage on RHEL < 7.0
- Cookbook is now part of the sous-chefs, but still maintained by the same folks
- mod_perl: No longer install libapache2-mpm-prefork
- mod_php: renamed mod_php5 to more generic mod_php; using php 7.0 where available

## v3.2.2 (2016-04-13)

- [GH-420] Allow auto-conversion if either of `apache.listen_ports` or `apache.listen_addresses` are set rather than '&&'. This ensures conversion occurs if only one of the two is set.

## v3.2.1 (2016-04-11)

- [GH-225] notify `restart` instead of `reload` service on `apache_conf`, `apache_config`
- Update to foodcritic 6

## v3.2.0 (2016-03-26)

- [GH-378] Deprecates `apache.listen_addresses` and `apache.listen_ports` in favor of [GH-409]
- [GH-409] `apache.listen` now accepts an array of `addr:port` strings
- [GH-358] FreeBSD: Update 10.1 support; Adds php 5.6 in collaboration with chef-cookbooks/php#119
- [GH-394] Have `apache.prefork.serverlimit` set ServerLimit directive on 2.4
- [GH-363] Escape '.' in regex for .htaccess/.htpasswd files
- [GH-365] Force log directory creation to be recursive
- [GH-368] Change the service creation to use the `apache.service_name` attribute throughout
- [GH-374] Make metadata.rb compatible with chef versions < 12.
- [GH-382] Fixed typo in node['platform_family'] for NameError in `mod_proxy_html`
- [GH-369] README: Added on Ubuntu `mod_fastcgi` requires `multiverse` apt repository to enabled.
- [GH-381] README: Add missing backtick
- [GH-384] README: Fix names for a2enconf and a2disconf
- [GH-393] README: mention availability of `mod_actions` support
- [GH-383] Debian: Add possibility to use other releases via `apache.default_release`
- [GH-377] Restart service when including `mod_headers` to allow healing of failed service because of missing directives.
- [GH-416] Change the default of `apache.mod_fastcgi.install_method` to 'package' all platforms, as `source` is no longer available.
- [GH-401] Move `mod_deflate` to `apache.default_modules` and no longer force installation on `debian` families.
- [GH-386] Do not install an extra mod_ssl package on SUSE Linux Enterprise
- [GH-335] Do not hardcoded reload/restart on more modern rhel platforms, allowing systemd on CentOS 7
- [GH-375] Install package `mod_ldap` on CentOS 7 (triggered by `apache.version` == 2.4)
- Update `apache.mod_ssl.cipher_suite` to latest from <https://bettercrypto.org/>
- README: Re-organize README to make it easier to find usage and remove old references.
- Added new standard and missing modules (Note: these may not be available natively on all operating systems)

  - [mod_http2](http://httpd.apache.org/docs/2.4/mod/mod_http2.html) - Support for the HTTP/2 transport layer. (available since 2.4.17)
  - [mod_authnz_fcgi](http://httpd.apache.org/docs/2.4/mod/mod_authnz_fcgi.html) - Enable FastCGI authorizer applications to authenticate and/or authorize clients. (available since 2.4.10)
  - [mod_cern_meta](http://httpd.apache.org/docs/2.4/mod/mod_cern_meta.html) - CERN httpd metafile semantics
  - [mod_ident](http://httpd.apache.org/docs/2.4/mod/mod_ident.html) - RFC 1413 ident lookups
  - [mod_privileges](http://httpd.apache.org/docs/2.4/mod/mod_privileges.html) - Support for Solaris privileges and for running virtual hosts under different user IDs.
  - [mod_socache_dc](http://httpd.apache.org/docs/2.4/mod/mod_socache_dc.html) - Distcache based shared object cache provider.
  - [mod_version](http://httpd.apache.org/docs/2.4/mod/mod_version.html) - Version dependent configuration
  - [mod_watchdog](http://httpd.apache.org/docs/2.4/mod/mod_watchdog.html) - Provides infrastructure for other modules to periodically run tasks

## v3.1.0 (2015-05-25)

- [GH-315] Fix `apache.default_site_name` .conf extension references to ensure deletion
- [GH-258] Use `apache.default_site_name` for consistency, minimize hardcoding of filenames
- [GH-259] Add `&& sleep 1` to end of apache restart command on rhel-based systems using apache2.2
- [GH-271] Remove FreeBSD 9.x, Red Hat and CentOS 5.x and OpenSUSE 11.x Series from tests and focus on newer releases
- [GH-276] Add psych gem to development gems
- [GH-293] Add `apache.mod_fastcgi.install_method` flag to allow install of mod_fastcgi from source (even on Debian family)
- [GH-285] Made `apache.devel_package` configurable based on platform, including support for Amazon Linux.
- [GH-316] Update Opscode references to Chef
- [GH-318] Apply default recipe in all definitions
- [GH-320] Add attribute to adjust `apache.default_site_port`
- [GH-321] Fix issue with default_site name in not_if guards
- [GH-322] Add `apache.mod_ssl.pkg_name` to allow custom mod_ssl package names. Set defaults for supported platforms including Amazon Linux
- [GH-323] Don't create the default site configuration file in `sites-available` unless it is enabled.
- [GH-324] Add `apache.mod_ssl.port` to set the default ssl port to something other than 443
- [GH-328] Add the ability to pass in a pipe as to log
- [GH-332] `SSLStrictSNIVHostCheck` is only written to config if enabled to avoid breaking apache prior to 2.2.12.
- [GH-334] Removed `iptables`, `god-monitor`, and `logrotate` recipes to avoid having external dependencies. These services should be managed in a wrapper cookbook going forward.
- [GH-339] Allow custom names for php so_filename (`node['apache']['mod_php5']['so_filename']`)

## v3.0.1 (2015-02-11)

- [GH-310] Ubuntu Apache 2.2 requires the lock_dir to be owned by www-data
- [GH-309] Clarify that apache.version is a string
- [GH-305] Restart service after MPM changes
- [GH-304] Don't install systemd module on Amazon Linux
- [GH-298] Add non-threaded MPM break notice for PHP users
- [GH-296] Create lock_dir automatically

## v3.0.0 (2014-11-30)

Major version update because of SSL Improvements and new platform MPM and Version defaults.

- [GH-286] Refactor MPM and Apache version defaults: default is now apache 2.4
- Note: set `apache.mpm` to `prefork` if you are using `mod_php` in Ubuntu >=14.04
- [GH-281] mod_ssl: Disable SSLv3 by default to protect against POODLE attack (CVE-2014-3566)
- [GH-280] mod_ssl: Major update with modern Cipher Suite, and best practices. Updated to a more modern default `apache.mod_ssl.cipher_suite`. Added the following additional mod_ssl attributes

  - `apache.mod_ssl.honor_cipher_order`
  - `apache.mod_ssl.insecure_renegotiation`
  - `apache.mod_ssl.strict_sni_vhost_check`
  - `apache.mod_ssl.session_cache_timeout`
  - `apache.mod_ssl.compression`
  - `apache.mod_ssl.use_stapling`
  - `apache.mod_ssl.stapling_responder_timeout`
  - `apache.mod_ssl.stapling_return_responder_errors`
  - `apache.mod_ssl.stapling_cache`
  - `apache.mod_ssl.pass_phrase_dialog`
  - `apache.mod_ssl.mutex`
  - `apache.mod_ssl.directives`

- [GH-278] Improved chefspec tests execution time

- [GH-277] Optimize files watching for Guard on Win32 platform

- [GH-270] Don't attempt start until after configuration is written

- [GH-268] Now uses chefspec 4.1

- [GH-267] Use Supermarket as the Berkshelf 3 source

- [GH-266] Rubocop based ruby style/syntax improvements
- [GH-264] mod_ssl: Add new attribute for to be ready to any custom directive
- [GH-249] Don't prepend Apache log path when requesting error logging to syslog
- [GH-247] Explicitly include mod_ldap before mod_authnz_ldap
- [GH-243] Expand mpm options for different distros/versions.
- [GH-239] Added `apache.mod_php5.install_method` attribute defaults to `package`. Install packages unless PHP is compiled from source.
- OneHealth Solutions was acquired by Viverae
- Remove ArchLinux pacman as a dependency and handle similar to apt, yum, zypper
- Adjust ubuntu apache 2.4 docroot_dir to match package (from /var/www to /var/www/html)
- [GH-238] Bump service config syntax check guard timeout to 10 seconds
- [GH-235] Removed `apache2::mpm_itk` which is not part of core and therefore should be its own cookbook
- [GH-234] /var/run/httpd/mod_fcgid directory now belongs to apache on Fedora/RHEL systems.
- [GH-233] Default web_app template should return 503 status code when maintenance file is present
- [GH-232] Cookbook now deletes a2* if they are symlinks before dropping template versions
- [GH-222] Set TraceEnable to off by default.
- [GH-213] Adjust chefspec to use the package resource on FreeBSD (previously freebsd_package)
- [GH-212] New attribute apache.locale which sets LANG. defaults to 'C'
- [GH-210] Clarify web_app definition usage around configuration templates.
- [GH-208] `apache_conf` now accepts `source` and `cookbook` parameters.

## v2.0.0 (2014-08-06)

Major version update because of major overhaul to support Apache 2.4 and a2enconf and a2endisconf changes.

- [GH-204] mod_auth_openid: Added `apache.mod_auth_openid.version` attribute
- FreeBSD support has been improved with the release of chef 11.14.2, portsnap is no longer used in favor of pkgng.
- [GH-157] - Apache will only be started when a configuration test passes, this allows the chef run to fix any broken configuration without failing the chef run.
- `apache.log_dir` directory is now 0755 on all platforms (including the debian platform family)
- [GH-166, GH-173] - `conf.d` is no longer used and replaced by `conf-available` and `conf-enabled` managed via the `a2enconf` and `a2disconf` scripts
- [GH-166, GH-173] - All configuration files need to end in `.conf` for them to be loaded
- [GH-173] - Perl is a required package on all platforms to support the a2* scripts as we now use the debian versions directly.
- [GH-193] - per MPM settings: `maxclients` is now `maxrequestworkers`
- [GH-194] - per MPM settings: `maxrequestsperchild` is now `maxconnectionsperchild`
- [GH-161] - Added support for CentOS 7
- [GH-180] - Improved SuSE support
- [GH-100] - Apache HTTP 2.4 support This provides Apache 2.4 support in a backwards compatible way. It adds the following new attributes:

  - `apache.version` - This defaults to `2.2` and if changed to `2.4`; it triggers and assumes 2.4 packages will be installed.
  - `apache.mpm` - In 2.4 mode, this specifies which mpm to install. Default is `prefork`.
  - `apache.run_dir`
  - `apache.lock_dir`
  - `apache.libexec_dir` replaces `apache.libexecdir`
  - `apache.prefork.maxrequestworkers` replaces `apache.prefork.maxclients`
  - `apache.prefork.maxconnectionsperchild` replaces `apache.prefork.maxrequestsperchild`
  - `apache.worker.threadlimit`
  - `apache.worker.maxrequestworkers` replaces `apache.worker.maxclients`
  - `apache.worker.maxconnectionsperchild`replaces `apache.worker.maxrequestsperchild`
  - `apache.event.startservers`
  - `apache.event.serverlimit`
  - `apache.event.minsparethreads`
  - `apache.event.maxsparethreads`
  - `apache.event.threadlimit`
  - `apache.event.threadsperchild`
  - `apache.event.maxrequestworkers`
  - `apache.event.maxconnectionsperchild`
  - `apache.itk.startservers`
  - `apache.itk.minspareservers`
  - `apache.itk.maxspareservers`
  - `apache.itk.maxrequestworkers`
  - `apache.itk.maxconnectionsperchild`

  Apache 2.4 Upgrade Notes:

  Since the changes between apache 2.2 and apache 2.4 are pretty significant, we are unable to account for all changes needed for your upgrade. Please take a moment to familiarize yourself with the Apache Software Foundation provided upgrade documentation before attempting to use this cookbook with apache 2.4\. See <http://httpd.apache.org/docs/current/upgrading.html>

  - This cookbook does not automatically specify which version of apache to install. We are at the mercy of the `package` provider. It is important, however, to make sure that you configure the `apache.version` attribute to match. For your convenience, we try to set reasonable defaults based on different platforms in our test suite.
  - `mod_proxy` - In 2.4 mode, `apache.proxy.order`, `apache.proxy.deny_from`, `apache.proxy.allow_from` are ignored, as the attributes can not be supported in a backwards compatible way. Please use `apache.proxy.require` instead.

## v1.11.0 (2014-07-25)

- [GH-152] - Checking if server_aliases is defined in example
- [GH-106] - Only turn rewrite on once in web_app.conf.erb
- [GH-156] - Correct mod_basic/digest recipe names in README
- Recipe iptables now includes the iptables::default recipe
- Upgrade test-kitchen to latest version
- Replaced minitest integration tests with serverspec tests
- Added chefspec tests

## v1.10.4 (2014-04-23)

- [COOK-4249] mod_proxy_http requires mod_proxy

## v1.10.2 (2014-04-09)

- [COOK-4490] - Fix minitest `apache_configured_ports` helper
- [COOK-4491] - Fix minitest: escape regex interpolation
- [COOK-4492] - Fix service[apache2] CHEF-3694 duplication
- [COOK-4493] - Fix template[ports.conf] CHEF-3694 duplication

As of 2014-04-04 and per [Community Cookbook Diversification](https://wiki.chef.io/display/chef/Community+Cookbook+Diversification) this cookbook now maintained by OneHealth Solutions. Please be patient as we get into the swing of things.

## v1.10.0 (2014-03-28)

- [COOK-3990] - Fix minitest failures on EL5
- [COOK-4416] - Support the ability to point to local apache configs
- [COOK-4469] - Use reload instead of restart on RHEL

## v1.9.6 (2014-02-28)

[COOK-4391] - uncommenting the PIDFILE line

## v1.9.4 (2014-02-27)

Bumping version for toolchain

## v1.9.1 (2014-02-27)

[COOK-4348] Allow arbitrary params in sysconfig

## v1.9.0 (2014-02-21)

### Improvement

- **[COOK-4076](https://tickets.chef.io/browse/COOK-4076)** - foodcritic: dependencies are not defined properly
- **[COOK-2572](https://tickets.chef.io/browse/COOK-2572)** - Add mod_pagespeed recipe to apache2

### Bug

- **[COOK-4043](https://tickets.chef.io/browse/COOK-4043)** - apache2 cookbook does not depend on 'iptables'
- **[COOK-3919](https://tickets.chef.io/browse/COOK-3919)** - Move the default pidfile for apache2 on Ubuntu 13.10 or greater
- **[COOK-3863](https://tickets.chef.io/browse/COOK-3863)** - Add recipe for mod_jk
- **[COOK-3804](https://tickets.chef.io/browse/COOK-3804)** - Fix incorrect datatype for apache/default_modules, use recipes option in metadata
- **[COOK-3800](https://tickets.chef.io/browse/COOK-3800)** - Cannot load modules that use non-standard module identifiers
- **[COOK-1689](https://tickets.chef.io/browse/COOK-1689)** - The perl package name should be configurable

## v1.8.14

Version bump for toolchain sanity

## v1.8.12

Fixing various style issues for travis

## v1.8.10

fixing metadata version error. locking to 3.0"

## v1.8.8

Version bump for toolchain sanity

## v1.8.6

Locking yum dependency to '< 3'

## v1.8.4

### Bug

- **[COOK-3769](https://tickets.chef.io/browse/COOK-3769)** - Fix a critical bug where the `apache_module` could not enable modules

## v1.8.2

### Bug

- **[COOK-3766](https://tickets.chef.io/browse/COOK-3766)** - Fix an issue where the `mod_ssl` recipe fails due to a missing attribute

## v1.8.0

### Bug

- **[COOK-3680](https://tickets.chef.io/browse/COOK-3680)** - Update template paths
- **[COOK-3570](https://tickets.chef.io/browse/COOK-3570)** - Apache cookbook breaks on RHEL / CentOS 6
- **[COOK-2944](https://tickets.chef.io/browse/COOK-2944)** - Fix foodcritic failures
- **[COOK-2893](https://tickets.chef.io/browse/COOK-2893)** - Improve mod_auth_openid recipe with guards and idempotency
- **[COOK-2758](https://tickets.chef.io/browse/COOK-2758)** - Fix use of non-existent attribute

### New Feature

- **[COOK-3665](https://tickets.chef.io/browse/COOK-3665)** - Add recipe for mod_userdir
- **[COOK-3646](https://tickets.chef.io/browse/COOK-3646)** - Add recipe for mod_cloudflare
- **[COOK-3213](https://tickets.chef.io/browse/COOK-3213)** - Add recipe for mod_info

### Improvement

- **[COOK-3656](https://tickets.chef.io/browse/COOK-3656)** - Parameterize apache2 binary
- **[COOK-3562](https://tickets.chef.io/browse/COOK-3562)** - Allow mod_proxy settings to be configured as attributes
- **[COOK-3326](https://tickets.chef.io/browse/COOK-3326)** - Fix default_test to use ServerTokens attribute
- **[COOK-2635](https://tickets.chef.io/browse/COOK-2635)** - Add support for SVG mime types
- **[COOK-2598](https://tickets.chef.io/browse/COOK-2598)** - FastCGI Module only works on Debian-based platforms
- **[COOK-1984](https://tickets.chef.io/browse/COOK-1984)** - Add option to configure the address apache listens to

## v1.7.0

### Improvement

- [COOK-3073]: make access.log location configurable per-platform
- [COOK-3074]: don't hardcode the error.log location in the default site config
- [COOK-3268]: don't hardcode DocumentRoot and cgi-bin locations in `default_site`

### New Feature

- [COOK-3184]: Add `mod_filter` recipe to Apache2-cookbook
- [COOK-3236]: Add `mod_action` recipe to Apache2-cookbook

## v1.6.6

1.6.4 had a missed step in the automated release, long live 1.6.6.

### Bug

- [COOK-3018]: apache2_module does duplicate delayed restart of apache2 service when conf = true
- [COOK-3027]: Default site enable true, then false, does not disable default site
- [COOK-3109]: fix apache lib_dir arch attribute regexp

## v1.6.2

- [COOK-2535] - `mod_auth_openid` requires libtool to run autogen.sh
- [COOK-2667] - Typo in usage documentation
- [COOK-2461] - `apache2::mod_auth_openid` fails on some ubuntu systems
- [COOK-2720] - Apache2 minitest helper function `ran_recipe` is not portable

## v1.6.0

- [COOK-2372] - apache2 mpm_worker: add ServerLimit attribute (default to 16)

## v1.5.0

The `mod_auth_openid` attributes are changed. The upstream maintainer deprecated the older release versions, and the source repository has releases available at specific SHA1SUM references. The new attribute, `node['apache']['mod_auth_openid']['ref']` is used to set this.

- [COOK-2198] - `apache::mod_auth_openid` compiles from source, but does not install make on debian/ubuntu
- [COOK-2224] - version conflict between cucumber and other gems
- [COOK-2248] - `apache2::mod_php5` uses `not_if` "which php" without ensuring package 'which' is installed
- [COOK-2269] - Set allow list for mod_status incase external monitor scripts need
- [COOK-2276] - cookbook apache2 documentation regarding listening ports doesn't match default attributes
- [COOK-2296] - `mod_auth_openid` doesn't have tags/releases for the version I need for features and fixes
- [COOK-2323] - Add Oracle linux support

## v1.4.2

- [COOK-1721] - fix logrotate recipe

## v1.4.0

- [COOK-1456] - iptables enhancements
- [COOK-1473] - apache2 does not disable default site when setting "`default_site_enabled`" back to false
- [COOK-1824] - the apache2 cookbook needs to specify which binary is used on rhel platform
- [COOK-1916] - Download location wrong for apache2 `mod_auth_openid` >= 0.7
- [COOK-1917] - Improve `mod_auth_openid` recipe to handle module upgrade more gracefully
- [COOK-2029] - apache2 restarts on every run on RHEL and friends, generate-module-list on every run.
- [COOK-2036] - apache2: Cookbook style

## v1.3.2

- [COOK-1804] - fix `web_app` definition parameter so site can be disabled.

## v1.3.0

- [COOK-1738] - Better configuration for `mod_include` and some overrides in `web_app` definition
- [COOK-1470] - Change SSL Ciphers to Mitigate BEAST attack

## v1.2.0

- [COOK-692] - delete package conf.d files in module recipes, for EL
- [COOK-1693] - Foodcritic finding for unnecessary string interpolation
- [COOK-1757] - platform_family and better style / usage practices

## v1.1.16

re-releasing as .16 due to error on tag 1.1.14

- [COOK-1466] - add `mod_auth_cas` recipe
- [COOK-1609] - apache2 changes ports.conf twice per run when using apache2::mod_ssl

## v1.1.12

- [COOK-1436] - restore apache2 web_app definition
- [COOK-1356] - allow ExtendedStatus via attribute
- [COOK-1403] - add mod_fastcgi recipe

## v1.1.10

- [COOK-1315] - allow the default site to not be enabled
- [COOK-1328] - cookbook tests (minitest, cucumber)

## v1.1.8

- Some platforms with minimal installations that don't have perl won't have a `node['languages']['perl']` attribute, so remove the conditional and rely on the power of idempotence in the package resource.
- [COOK-1214] - address foodcritic warnings
- [COOK-1180] - add `mod_logio` and fix `mod_proxy`

## v1.1.6

FreeBSD users: This release requires the `freebsd` cookbook. See README.md.

- [COOK-1025] - freebsd support in mod_php5 recipe

## v1.1.4

- [COOK-1100] - support amazon linux

## v1.1.2

- [COOK-996] - apache2::mod_php5 can cause PHP and module API mismatches
- [COOK-1083] - return string for v_f_p and use correct value for default

## v1.1.0

- [COOK-861] - Add `mod_perl` and apreq2
- [COOK-941] - fix `mod_auth_openid` on FreeBSD
- [COOK-1021] - add a commented-out LoadModule directive to keep apxs happy
- [COOK-1022] - consistency for icondir attribute
- [COOK-1023] - fix platform test for attributes
- [COOK-1024] - fix a2enmod script so it runs cleanly on !bash
- [COOK-1026] - fix `error_log` location on FreeBSD

## v1.0.8

- COOK-548 - directory resource doesn't have backup parameter

## v1.0.6

- COOK-915 - update to `mod_auth_openid` version 0.6, see **Recipes/mod_auth_openid** below.
- COOK-548 - Add support for FreeBSD.

## v1.0.4

- COOK-859 - don't hardcode module paths

## v1.0.2

- Tickets resolved in this release: COOK-788, COOK-782, COOK-780

## v1.0.0

- Red Hat family support is greatly improved, all recipes except `god_monitor` converge.
- Recipe `mod_auth_openid` now works on RHEL family distros
- Recipe `mod_php5` will now remove config from package on RHEL family so it doesn't conflict with the cookbook's.
- Added `php5.conf.erb` template for `mod_php5` recipe.
- Create the run state directory for `mod_fcgid` to prevent a startup error on RHEL version 6.
- New attribute `node['apache']['lib_dir']` to handle lib vs lib64 on RHEL family distributions.
- New attribute `node['apache']['group']`.
- Scientific Linux support added.
- Use a file resource instead of the generate-module-list executed perl script on RHEL family.
- "default" site can now be disabled.
- web_app now has an "enable" parameter.
- Support for dav_fs apache module.
- Tickets resolved in this release: COOK-754, COOK-753, COOK-665, COOK-624, COOK-579, COOK-519, COOK-518
- Fix node references in template for a2dissite
- Use proper user and group attributes on files and templates.
- Replace the anemic README.rdoc with this new and improved superpowered README.md :).
