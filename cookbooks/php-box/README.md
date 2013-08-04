chef-php-box
============

This cookbook provides an easy way to install Box CLI — tool that simplifies the Phar building process.

More info about Box itself can be found at [Box homepage](http://box-project.org).

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

* `default["php-box"]["install_globally"]` — Should we intall executable globally (default: "true")
* `default["php-box"]["prefix"]` — Location prefix of where the installation files will go if installing globally (default: "/usr/local")

License
-------

Copyright (c) 2013 Sergey Storchay, http://r8.com.ua

Licensed under MIT:
http://raw.github.com/r8/chef-php-box/master/LICENSE.txt
