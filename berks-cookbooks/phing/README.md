chef-phing
============

This cookbook installs Phing

Requirements
------------

### Cookbooks:

* php
* composer

### Platforms:

* Ubuntu
* Debian
* RHEL
* CentOS
* Fedora

Attributes
----------

* `default["phing"]["install_method"]` — Phing installation method ("composer" or  "pear" are currently supported)
* `default["phing"]["preferred_state"]` — When installing via PEAR, this is the preferred state (stable, alpha, beta, devel). default: "stable"
* `default["phing"]["install_dir"]` — Target path for Composer installation method
* `default["phing"]["prefix"]` — Prefix for Phing binary when installing via Composer
* `default["phing"]["version"]` — Phing version when installing via Composer

License
-------

Copyright (c) 2015 Sergey Storchay, http://r8.com.ua

Licensed under MIT:
http://raw.github.com/r8/chef-phing/master/LICENSE.txt
