# chef-mailhog

[![CK Version](http://img.shields.io/cookbook/v/mailhog.svg)](https://supermarket.getchef.com/cookbooks/mailhog)

This cookbook installs [MailHog](https://github.com/mailhog/MailHog).

Usage
-----

Include the mailhog recipe to install MailHog on your system:
```chef
include_recipe "mailhog"
```

MailHog service is installed and managed via `runit`.

Requirements
------------

### Cookbooks:

* runit

### Platforms:

* Ubuntu
* Debian
* RHEL
* CentOS
* Fedora

License
-------

Copyright (c) 2015 Sergey Storchay, http://r8.com.ua

Licensed under MIT:
http://raw.github.com/r8/chef-mailhog/master/LICENSE
