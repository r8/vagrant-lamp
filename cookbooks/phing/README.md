chef-phing
============

This cookbook installs Phing via PEAR.

Requirements
------------

### Cookbooks:

* php

### Platforms:

* Ubuntu
* Debian
* RHEL
* CentOS
* Fedora

Attributes
----------

* `default["phing"]["install_method"]` — Phing installation method (only "pear" is currently supported)
* `default["phing"]["version"]` — When installing via PEAR, this is the preferred state (stable, beta, devel) or a specific x.y.z PEAR version (eg. 4.5.0) (default: "stable")
* `default["phing"]["allreleases"]` — URL of allreleases.xml for PEAR to install from preferred states (default: "http://pear.phing.info/rest/r/phing/allreleases.xml")

License
-------

Copyright (c) 2013 Sergey Storchay, http://r8.com.ua

Licensed under MIT:
http://raw.github.com/r8/chef-phing/master/LICENSE.txt
