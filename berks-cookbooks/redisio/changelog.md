# redisio CHANGE LOG

## Unreleased

## 2.6.1 - Released 5/10/2017
  - Restrict aof-load-truncated to redis 3+ ([#343](https://github.com/brianbianco/redisio/pull/343))
  - Fix Redis 2.4.x config ([#344](https://github.com/brianbianco/redisio/pull/344))

## 2.6.0 - Released 5/9/2017
  - Update 'bind' config comments ([#293](https://github.com/brianbianco/redisio/pull/293))
  - Add disable_os_default recipe ([#224](https://github.com/brianbianco/redisio/pull/224))
  - Use the config's ulimits if set and is > max_clients ([#234](https://github.com/brianbianco/redisio/pull/234))
  - Add Travis config ([#299](https://github.com/brianbianco/redisio/pull/299))
  - Fix test failures (FoodCritic and Rubocop) ([#298](https://github.com/brianbianco/redisio/pull/298))
  - Fix TravisCI builds ([#300](https://github.com/brianbianco/redisio/pull/300))
  - Add repl-backlog-size, repl-backlog-ttl, and aof-load-truncated options ([#278](https://github.com/brianbianco/redisio/pull/278))
  - Add sentinel_bind to bind sentinel to different IPs ([#306](https://github.com/brianbianco/redisio/pull/306))
  - Cleanup deprecation warnings ([#301](https://github.com/brianbianco/redisio/pull/301))
  - Fix version detection with epoch version numbers from deb/ubuntu ([#294](https://github.com/brianbianco/redisio/pull/294))
  - Restrict VM redis config to <= 2.4 ([#322](https://github.com/brianbianco/redisio/pull/322))
  - Rename_commands should be checked for nil before empty ([#311](https://github.com/brianbianco/redisio/pull/311))
  - Fixup foodcritic, rubocop, and kitchen testing ([#324](https://github.com/brianbianco/redisio/pull/324))
    - Note: this drops support for Chef < 11
  - Add min-slaves redis options ([#313](https://github.com/brianbianco/redisio/pull/313))
  - Allow /etc/init start after sigterm from system or user ([#310](https://github.com/brianbianco/redisio/pull/310))
  - Check user existence with Etc, not ohai node attributes ([#303](https://github.com/brianbianco/redisio/pull/303))
  - Various systemd-related improvements ([#302](https://github.com/brianbianco/redisio/pull/302))
  - Update serverspec testing with correct OS's for systemd ([#329](https://github.com/brianbianco/redisio/pull/329))
  - Add kitchen-dokken testing to Travis ([#330](https://github.com/brianbianco/redisio/pull/330))
  - Add fedora-25 to kitchen testing and clean up kitchen config ([#331](https://github.com/brianbianco/redisio/pull/331))
  - Fix systemd paths for sentinel service ([#332](https://github.com/brianbianco/redisio/pull/332))
  - Add redis-package and sentinel to Travis kitchen verify ([#334](https://github.com/brianbianco/redisio/pull/334))
  - Add breadcrumb-file creation condition as attribute ([#268](https://github.com/brianbianco/redisio/pull/268))
  - Fix cluster options in README ([#333](https://github.com/brianbianco/redisio/pull/333))
  - Fix systemd loader to use descriptors instead of max_clients+32 ([#338](https://github.com/brianbianco/redisio/pull/338))
  - Add SELinux support ([#305](https://github.com/brianbianco/redisio/pull/305))
  - Make source of redis.conf template configurable ([#341](https://github.com/brianbianco/redisio/pull/341))
  - Support sentinel notification-script and client-reconfig-script ([#342](https://github.com/brianbianco/redisio/pull/342))

## 2.5.1 - never released

## 2.5.0 - Released 9/15/2016
  - Ubuntu 14 added as tested platform. (#264)
  - FreeBSD-10.3 support added. (#279)
    - installation from source is not supported
    - setting ulimits is not supported
  - Encrypted databag support added. (#228)
  - Systemd nofile limit fixed. (#228)
  - Announce-ip and announce-port directives for sentinel added. (#228)
  - Disabling safe_install in the install recipe allowed. (#284)
  - Protected-mode added as optional (#275, #289)
  - Fixes nil exception when installing sentinel on non-debian and non-rhel platforms (#288)

## 2.4.2 - Released 4/8/2016
  - Created a 2.4.1 tag but somehow the metadata file wasn't updated.  Instead
    of deleting a pushed tag, creating a new tag and updating metdatafile. Aside
    from the version number, this is an identical release to 2.4.1

## 2.4.1 -
  - Increases default clusternodetimeout value from 5 to 5000
  - Allows you to set version for package based install
  - Sets UID of redis data directory if it is present
  - Install resource should now only notify when an installation actually occurs
  - Adds config options
    - tcpbacklog
    - rdbcompression
    - rdbchecksum
    - dbfilename
    - slavereadyonly
    - repldisabletcpnodelay
    - slavepriority
    - listmaxziplistentries
    - listmaxziplistvalue
    - hllsparsemaxbytes



## 2.4.0 (unreleased on supermarket)  -
  - Add CentOS 7 support with systemd configs
  - Fixes bug in ulimit resource guard
  - Fixes bug in sentinel required parameters sanity check
  - Adds --no-same-owner to untar command during install to fix NFS related issues
  - Adds support for rename_commands config option
  - Adds option to stop chef from managing sentinel configs after writing once
  - Adds config option rename_commands

## 2.3.1 (unreleased on supermarket) -
  - Allow instance 'save' to be string or array
  - Adds sources_url and issues_url with guards to be Chef 12 compatible
  - Bumps Redis source version to 2.8.20
  - Fixes cluster settings with wrong attribute names
  - Monitor multiple masters with sentinel
    - Add support in sentinel resource for an array of masters to monitor, with backwards compatibility for the older attributes, fixes #73. Replaces #87.
    - Introduce a test-kitchen test for sentinel watching multiple masters.
    - Incidentally, fixes #193 as well, since it adds a master name attribute for each master.
  - Fixes path for pidfile in sentinel init script
  - Additional error checking and backwards compatibility for sentinel attribute keys


## 2.3.0 - Released 4/8/2015
  - Add support for installing by distribution package for CentOS (#180)
  - Add conditionals to check for redis 3 that was released recently (#183)
  - Prevent `usermod: user redis is currently logged in` (#176)
  - Use correct sentinel port in default sentinel instance (#157)
  - Sentinel instances attribute (`node['redisio']['sentinels']`) should behave like Redis instances attribute (#160)
  - Add Rakefile and unit tests for verifying issues fixed are actually resolved (#158)
  - Fix serverspec tests to properly use sysv-init scripts on systemd distributions (#185)
  - Update documentation to reflect correct current redis version used for source installs (#151)
  - Update documentation to indicate that ulimit and build-essential are both dependencies (#165)
  - Update documentation to reflect that uninstall recipe is no longer available
  - Update documentation to reflect correct mirror in README.md, change was from 2.1.0 (#175)
  - Update documentation to reflect that cookbook uses `node['redisio']`, not `node['redis']` (#174)
  - Markdown formatting improvements in the README.md (#168, #172)

## 2.2.4 - Released 10/4/2014
  - Updates installed version of redis to the latest stable (2.8.17)
  - Fixes backwards compatability bug with older version of redis (namely 2.6.x series) related to keyspaces

## 2.2.3 - Released 8/25/2014
  - Bug Fix: Repackages the chef supermarket releaes with gnutar instead of BSD tar

## 2.2.2 - Released 8/22/2014
  - Please refer to changelog for 2.0.0.
      - If moving from 1.7.x this release has many breaking changes. You will likely need to update your wrapper cookbook or role.
  - Added test-kitchen and serverspec coverage for both redis and redis_sentinel
  - Added cookbook testing information to readme
  - Bug fix for a fix that was introduced to resolve foodcritic rule fc002
  - Fix init script to use su instead of sudo for ubuntu debian fedora
  - Fix sentinel_enable recipe to properly run if using default attributes
  - Save property for redis config now is defined by using an array
  - Small changes to default configuration options to bring in line with redis defaults.
  - Added options for the following
      - tcp-keepalive

## 2.2.1 -
  - Allow sentinel to control both redis and redis-sentinel configs depending on attribute `redisio.sentinel.manage_config` state.

## 2.2.0 -
  - Adds behavior to allow the cookbook to NOT manage the redis config files as redis itself will write to them now if you are using sentinel

## 2.1.0 -
  - Adds options for the following
      - lua-time-limit
      - slowlog-logs-slower-than
      - slowlog-max-len
      - notify-keyspace-events
      - client-output-buffer-limit
      - hz
      - aof-rewrite-incremental-fsync
  - Removes the uninstall recipe and resource.
  - Adds the ability to skip the default recipe calling install and configure by setting redisio bypass_setup attribute to true
  - Adds support for redis sentinel [Thanks to rcleere, Ryan Walker]
  - Splits up the install resource into separate install and configure resources [Thanks to rcleere]
  - By default now calls _install_prereqs, install, and configure in the default recipe.
  - Changes default version of redis to install to 2.8.5
  - Now depends on the build-essential cookbook.
  - Fixes issue #76 - Default settings save as empty string breaks install
  - Switches mirror server from googlefiles to redis.io.  If you are using version of redis before 2.6.16 you will need to override the mirror server attribute
    to use the old site with archived versions.
  - Adds a Vagrant file!
  - maxmemory will be rounded when calculated as a percentage
  - Add stop-writes-on-bgsave-error config option
  - Changes default log level from verbose to notice
  - Adds configuration options for ziplists and active rehashing
  - Adds support for passing the address attribute as an array.  This is to support the redis 2.8 series which allows binding to multiple addresses
  - Fixes a bug where multiple redis instances were using the same swapfile (only for version of redis 2.4 and below)
  - Changes the job_control per instance attribute to a global one.
  - Adds a status command to the init.d script, uses this in the initd based service for checking status

## 2.0.0 - Never officially released
  ! THIS RELEASE HAS MANY BREAKING CHANGES       !
  ! Your old role file will most likely not work !

  - Supports redis 2.8 and its use of the empty string for stdout in the logfile option
  - Allows the user to specify required_start and required_start when using the init scripts
  - Warns a user if they have syslogenabled set to yes and also have logfile set

## 1.7.1 - Released 2/10/2014
  - Bumps default version of redis to 2.6.17
  - Changes the redis download mirror to redis.io
  - Fixes #76 - Default settings save as empty string breaks install. [Thanks to astlock]
  - Fixes bug with nil file resource for logfile. [Thanks to chrismoos]

## 1.7.0 - Released 7/25/2013
  - Adds support for address attribute as an array or string.  This is to support the feature that will be introduced in redis 2.8

## 1.6.0 - Release 6/27/2013
  - Fixes a bug when using a percentage for max memory. [Thanks to organicveggie]
  - Allows installation of redis into custom directory.  [Thanks to organicveggie, rcleere]
  - Bumps the default installed version of redis to the new stable, 2.6.14

## 1.5.0 - Released 3/30/2013
  - Forces maxmemory to a string inside of install provider so it will not explode if you pass in an int. [Thanks to sprack]
  - Strips leading directory from downloaded tarball, and extracts into a newly created directory.  This allows more versatility for where the package can be installed from (Github / BitBucket) [Thanks to dim]
  - Adds options for Redis Cluster [Thanks to jrallison]
  - Adds a call to ulimit into the init script, it was not honoring the limits set by the ulimit cookbook for some users.  [Thanks to mike-yesware]

## 1.4.1 - Released 2/27/2013
  - Removes left over debugging statement

## 1.4.0 - Released 2/27/2013
  - ACTUALLY fixes the use of upstart and redis.  Redis no longer daemonizes itself when using job_control type upstart and allows upstart to handle this
  - Adds dependency on the ulimit cookbook and allows you to set the ulimits for the redis instance users.
  - Adds associated node attribute for the ulimit.  It defaults to the special value 0, which causes the cookbook to use maxclients + 32.  32 is the number of file descriptors redis needs itself
  - You can disable the use of the ulimits by setting the node attribute for it to "false" or "nil"
  - Comments out the start on by default in the upstart script.  This will get uncommented by the upstart provider when the :enable action is called on it

## 1.3.2 - Released 2/26/2013
  - Changes calls to Chef::ShellOut to Mixlib::ShellOut

## 1.3.1 - Released 2/26/2013
  - Fixes bug in upstart script to create pid directory if it does not exist

## 1.3.0 - Released 2/20/2013
  - Adds upstart support.  This was a much requested feature.
  - Fixes bug in uninstall resource that would have prevented it from uninstalling named servers.
  - Reworks the init script to take into account the IP redis is listening on, and if it is listening on a socket.
  - Adds an attribute called "shutdown_save" which will explicitly call save on redis shutdown
  - Updates the README.md with a shorter and hopefully equally as useful usage section
  - maxmemory attribute now allows the use of percentages.  You must include a % sign after the value.
  - Bumps default version of redis to install to the current stable, 2.6.10

## 1.2.0 - Released 2/6/2013
  - Fixes bug related to where the template source resides when using the LWRP outside of the redisio cookbook
  - Fixes bug where the version method was not properly parsing version strings in redis 2.6.x, as the version string from redis-server -v changed
  - Fixes bug in default attributes for fedora default redis data directory
  - Now uses chefs service resource for each redis instance instead of using a custom redisio_service resource.  This cleans up many issues, including a lack of updated_by_last_action
  - The use of the redisio_service resource is deprecated.  Use the redis<port_number> instead.
  - The default version of redis has been bumped to the current stable, which is 2.6.9
  - Adds metadata.json to the gitignore file so that the cookbook can be submoduled.
  - Adds the ability to handle non standard bind address in the init scripts stop command
  - Adds attributes to allow redis to listen on a socket
  - Adds an attribute to allow redis service accounts to be created as system users, defaults this to true
  - Adds a per server "name" attribute that allows a server to use that instead of the port for its configuration files, service resource, and init script.
  - Shifts the responsbility for handling the case of default redis instances into the install recipe due to the behavior of arrays and deep merge

## 1.1.0 - Released 8/21/2012
  ! Warning breaking change !: The redis pidfile directory by default has changed, if you do not STOP redis before upgrading to the new version
                               of this cookbook, it will not be able to stop your instance properly via the redis service provider, or the init script.
                               If this happens to you, you can always log into the server and manually send a SIGTERM to redis

  - Changed the init script to run redis as the specified redis user
  - Updated the default version of redis to 2.4.16
  - Setup a new directory structure for redis pid files.  The install provider will now nest its pid directories in base_piddir/<port number>/redis_<port>.pid.
  - Added a RedisioHelper module in libraries.  The recipe_eval method inside is used to wrap nested resources to allow for the proper resource update propigation.  The install provider uses this.
  - The init script now properly respects the configdir attribute
  - Changed the redis data directories to be 775 instead of 755 (this allows multiple instances with different owners to write their data to the same shared dir so long as they are in a common group)
  - Changed default for maxclients to be 10000 instead of 0.  This is to account for the fact that maxclients no longer supports 0 as 'unlimited' in the 2.6 series
  - Added logic to replace hash-max-ziplist-entries, hash-max-ziplist-value with  hash-max-zipmap-entires, hash-max-zipmap-value when using 2.6 series
  - Added the ability to log to any file, not just syslog.  Please do make sure after you set your file with the logfile attribute you also set syslogenabled to 'no'

## 1.0.3 - Released 5/2/2012
  - Added changelog.md
  - Added a bunch more configuration options that were left out (default values left as they were before):
      - databases
      - slaveservestaledata
      - replpingslaveperiod
      - repltimeout
      - maxmemorysamples
      - noappendfsynconwrite
      - aofrewritepercentage
      - aofrewriteminsize

      It is worth nothing that since there is a configurable option for conf include files, and the fact that redis uses the most recently read configuration option... even if a new option where to show up, or and old one was not included they could be added using that pattern.


## 1.0.2 - Released 4/25/2012
 - Merged in pull request from meskyanichi which improved the README.md and added a .gitignore
 - Added a "safe_install" node attribute which will prevent redis from installing anything if it exists already.  Defaults to true.
 - Addedd a "redis_gem" recipe which will install the redis gem from ruby gems, added associated attributes.  See README for me

## 1.0.1 - Released 4/8/2012
 - Added some prequisite checks for RHEL based distributions
 - Minor typos and formatting fixes in metadata.rb and README.md

## 1.0.0 - Released 4/8/2012
 - Initial Release
