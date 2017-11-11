runit Cookbook CHANGELOG
========================
This file is used to list changes made in each version of the runit cookbook.

UNRELEASED
----------

v1.7.4 (2015-10-13)
----------
* Ensure the service directory exists so that we will succeed when enabling services (#153)
* Fix regression where env directory contents were being deleted when the `env` attribute is empty. (#144, #158)
* Add `log_dir` attribute, used only when `default_logger` is true. (#135)
* Ensure svlogd configuration is linked into correct path (#83, #135)
* Update README and CHANGELOG for v1.7.0 to warn against known regressions (#144, #157)
* Avoid mutating resource options for Chef 12 compatability (#147, #150, #156)
* Fix regression regarding waiting for the service socket before running (#138, #142)
* Reimplement idempotence checks for `runit_service` resources (#137, #141)
* Enhance ChefSpec unit test coverage with specs that step into the LWRP (#139)
* Deduplicate ServerSpec integration test coverage using example groups (#140)

v1.7.2 (2015-06-19)
----------
* Re-add missing runit_service actions start, stop, reload and status

v1.7.0 (2015-06-18)
----------

**NOTE**: With the benefit of hindsight we can say that the changes contained in
this release merit a major version number change. Please be sure to test this
new version for compatibility with your systems before upgrading to version 1.7.

* Modernize runit_service provider by rewriting pure Ruby as LWRP (#107)
* Modernize integration tests by rewriting Minitest suites as ServerSpec (#107)
* Fix regression in support for alternate sv binary on debian platforms (#92, #123)
* Fix regression in default logger's config location (#117)
* Tighten permissions on environment variable config files from 0644 to 0640 (#125)
* Add `start_down` and `delete_downfile` attributes to support configuring services with default state of 'down' (#105)

v1.6.0 (2015-04-06)
--------------------
* Fedora 21 support
* Kitchen platform updates
* use imeyer’s packagecloud repo for RHEL
* fix converge_by usage
* do_action helper to set updated_by_last_action
* style fixes to provider

v1.5.18 (2015-03-13)
--------------------
* Add helper methods to detect installation presence

v1.5.16 (2015-02-11)
--------------------
* Allow removal of env files(nhuff)

v1.5.14 (2015-01-15)
--------------------
* Provide create action(clako)

v1.5.12 (2014-12-15)
--------------------
* prevent infinite loop inside docker container
* runit service failing inside docker container
* move to librarian-chef for kitchen dependency resolution
* update tests
* updates to chefspec matchers

v1.5.10 (2014-03-07)
--------------------
PR #53- Fix runit RPM file location for Chef provisionless Centos 5.9 Box Image


v1.5.9
------
Fix runit RPM file location for Chef provisionless Centos 5.9 Box Image

v1.5.8
------
Fixing string interpolation bug


v1.5.3
------
Fixing assignment/compare error


v1.5.1
------
### Bug
- **[COOK-3950](https://tickets.chef.io/browse/COOK-3950)** - runit cookbook should use full service path when checking running status


v1.5.0
------
### Improvement
- **[COOK-3267] - Improve testing suite in runit cookbook
- Updating test-kitchen harness
- Cleaning up style for rubocop


v1.4.4
------
fixing metadata version error. locking to < 3.0


v1.4.2
------
Locking yum dependency to '< 3'

v1.4.0
------
[COOK-3560] Allow the user to configure runit's timeout (-w) and verbose (-v) settings


v1.3.0
------
### Improvement
- **[COOK-3663](https://tickets.chef.io/browse/COOK-3663)** - Add ./check scripts support

### Bug
- **[COOK-3271](https://tickets.chef.io/browse/COOK-3271)** - Fix an issue where runit fails to install rpm package on rehl systems

v1.2.0
------
### New Feature
- **[COOK-3243](https://tickets.chef.io/browse/COOK-3243)** - Expose LSB init directory as a configurable

### Bug
- **[COOK-3182](https://tickets.chef.io/browse/COOK-3182)** - Do not hardcode rpmbuild location

### Improvement
- **[COOK-3175](https://tickets.chef.io/browse/COOK-3175)** - Add svlogd config file support
- **[COOK-3115](https://tickets.chef.io/browse/COOK-3115)** - Add ability to install 'runit' package from Yum

v1.1.6
------
### Bug
- [COOK-2353]: Runit does not update run template if the service is already enabled
- [COOK-3013]: Runit install fails on rhel if converge is only partially successful

v1.1.4
------
### Bug
- [COOK-2549]: cannot enable_service (lwrp) on Gentoo
- [COOK-2567]: Runit doesn't start at boot in Gentoo
- [COOK-2629]: runit tests have ruby 1.9 method chaning syntax
- [COOK-2867]: On debian, runit recipe will follow symlinks from /etc/init.d, overwrite /usr/bin/sv

v1.1.2
------
- [COOK-2477] - runit cookbook should enable EPEL repo for CentOS 5
- [COOK-2545] - Runit cookbook fails on Amazon Linux
- [COOK-2322] - runit init template is broken on debian

v1.1.0
------
- [COOK-2353] - Runit does not update run template if the service is already enabled
- [COOK-2497] - add :nothing to allowed actions

v1.0.6
------
- [COOK-2404] - allow sending sigquit
- [COOK-2431] - gentoo - it should create the runit-start template before calling it

v1.0.4
------
- [COOK-2351] - add `run_template_name` to allow alternate run script template

v1.0.2
------
- [COOK-2299] - runit_service resource does not properly start a non-running service

v1.0.0
------
- [COOK-2254] - (formerly CHEF-154) Convert `runit_service` definition to a service resource named `runit_service`.

This version has some backwards incompatible changes (hence the major
version bump). It is recommended that users pin the cookbook to the
previous version where it is a dependency until this version has been
tested in a non-production environment (use version 0.16.2):

    depends "runit", "<= 0.16.2"

If you use Chef environments, pin the version in the appropriate
environment(s).

**Changes of note**

1. The "runit" recipe must be included before the runit_service resource
can be used.
2. The `runit_service` definition created a separate `service`
resource for notification purposes. This is still available, but the
only actions that can be notified are `:start`, `:stop`, and `:restart`.
3. The `:enable` action blocks waiting for supervise/ok after the
service symlink is created.
4. User-controlled services should be created per the runit
documentation; see README.md for an example.
5. Some parameters in the definition have changed names in the
resource. See below.

The following parameters in the definition are renamed in the resource
to clarify their intent.

- directory -> sv_dir
- active_directory -> service_dir
- template_name -> use service_name (name attribute)
- nolog -> set "log" to false
- start_command -> unused (was previously in the "service" resource)
- stop_command -> unused (was previously in the "service" resource)
- restart_command -> unused (was previously in the "service" resource)

v0.16.2
-------
- [COOK-1576] - Do not symlink /etc/init.d/servicename to /usr/bin/sv on debian
- [COOK-1960] - default_logger still looks for sv-service-log-run template
- [COOK-2035] - runit README change

v0.16.0
-------
- [COOK-794] default logger and `no_log` for `runit_service` definition
- [COOK-1165] - restart functionality does not work right on Gentoo due to the wrong directory in the attributes
- [COOK-1440] - Delegate service control to normal user

v0.15.0
-------
- [COOK-1008] - Added parameters for names of different templates in runit
