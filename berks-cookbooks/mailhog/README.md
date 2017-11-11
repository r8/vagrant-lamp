# chef-mailhog

[![CK Version](http://img.shields.io/cookbook/v/mailhog.svg)](https://supermarket.getchef.com/cookbooks/mailhog)

This cookbook installs [MailHog](https://github.com/mailhog/MailHog).

Attributes
-----

This cookbook contains the following attributes:

| Key                                              | Type    | Default                                                           | Description                                                                  |
|--------------------------------------------------|---------|-------------------------------------------------------------------|------------------------------------------------------------------------------|
| ['mailhog']['version']                           | String  | 0.2.0                                                             | Version of the MailHog to install                                            |
| ['mailhog']['install_method']                    | String  | binary                                                            | MailHog install method                                                       |
| ['mailhog']['binary']['url']                     | String  | nil                                                               | MailHog binary url                                                           |
| ['mailhog']['binary']['mode']                    | Integer | 0755                                                              | Access permissions to the MailHog binary file                                |
| ['mailhog']['binary']['path']                    | String  | /usr/local/bin/MailHog                                            | Location of the MailHog binary file                                          |
| ['mailhog']['binary']['prefix_url']              | String  | https://github.com/mailhog/MailHog/releases/download/v            | MailHog binary prefix url                                                    |
| ['mailhog']['binary']['checksum']['linux_386']   | String  | a72d1016b70964562c8a77a3b57637a77889ee61f3b22973e0a7beb17181d8da  | MailHog binary file checksum for linux_386                                   |
| ['mailhog']['binary']['checksum']['linux_amd64'] | String  | e8e9acb4fa4470f4d4c3a4bba312f335bfc28122ea723599531699f099b4c9a5  | MailHog binary file checksum for linux_amd64                                 |
| ['mailhog']['service']['owner']                  | String  | root                                                              | User that should own the mailhog service                                     |
| ['mailhog']['service']['group']                  | String  | root                                                              | Group that should own the mailhog service                                    |
| ['mailhog']['smtp']['ip']                        | String  | 0.0.0.0                                                           | Interface for SMTP server to bind to                                         |
| ['mailhog']['smtp']['port']                      | Integer | 1025                                                              | Port for SMTP server to bind to                                              |
| ['mailhog']['smtp']['outgoing']                  | String  | nil                                                               | JSON file defining outgoing SMTP servers                                     |
| ['mailhog']['api']['ip']                         | String  | 0.0.0.0                                                           | Interface for HTTP API server to bind to                                     |
| ['mailhog']['api']['port']                       | Integer | 8025                                                              | Port for HTTP API server to bind to                                          |
| ['mailhog']['ui']['ip']                          | String  | 0.0.0.0                                                           | Interface for HTTP UI server to bind to                                      |
| ['mailhog']['ui']['port']                        | Integer | 8025                                                              | Port for HTTP UI server to bind to                                           |
| ['mailhog']['cors-origin']                       | String  | nil                                                               | If set, a Access-Control-Allow-Origin header is returned for API endpoints   |
| ['mailhog']['hostname']                          | String  | mailhog.example                                                   | Hostname to use for EHLO/HELO and message IDs                                |
| ['mailhog']['storage']                           | String  | memory                                                            | Set message storage: memory / mongodb / maildir                              |
| ['mailhog']['mongodb']['ip']                     | String  | 127.0.0.1                                                         | Host for MongoDB                                                             |
| ['mailhog']['mongodb']['port']                   | Integer | 27017                                                             | Port for MongoDB                                                             |
| ['mailhog']['mongodb']['db']                     | String  | mailhog                                                           | MongoDB database name for message storage                                    |
| ['mailhog']['mongodb']['collection']             | String  | messages                                                          | MongoDB collection name for message storage                                  |
| ['mailhog']['jim']['enable']                     | Boolean | false                                                             | Set to true to enable Jim                                                    |
| ['mailhog']['jim']['accept']                     | Float   | 0.99                                                              | Chance of accepting an incoming connection                                   |
| ['mailhog']['jim']['disconnect']                 | Float   | 0.005                                                             | Chance of randomly disconnecting a session                                   |
| ['mailhog']['jim']['linkspeed']['affect']        | Float   | 0.1                                                               | Chance of applying a rate limit                                              |
| ['mailhog']['jim']['linkspeed']['max']           | Integer | 10240                                                             | Maximum link speed (in bytes per second)                                     |
| ['mailhog']['jim']['linkspeed']['min']           | Integer | 1024                                                              | Minimum link speed (in bytes per second)                                     |
| ['mailhog']['jim']['reject']['auth']             | Float   | 0.05                                                              | Chance of rejecting an AUTH command                                          |
| ['mailhog']['jim']['reject']['recipient']        | Float   | 0.05                                                              | Chance of rejecting a RCPT TO command                                        |
| ['mailhog']['jim']['reject']['sender']           | Float   | 0.05                                                              | Chance of rejecting a MAIL FROM command                                      |

Usage
-----

Include the mailhog recipe to install MailHog on your system:
```chef
include_recipe "mailhog::default"
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
Modified 2016 Gleb Levitin, dkd Internet Service GmbH

Licensed under MIT:
http://raw.github.com/r8/chef-mailhog/master/LICENSE
