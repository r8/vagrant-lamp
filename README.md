Vagrant LAMP
============

My default LAMP development stack configuration for Vagrant.

Installation:
-------------

1. Install [vagrant](http://vagrantup.com/)

    $ gem install vagrant

2. Download and Install [VirtualBox](http://www.virtualbox.org/)

3. Download a vagrant box (name of the box is supposed to be lucid32)

    $ vagrant box add lucid32 http://files.vagrantup.com/lucid32.box

4. Clone this repository

5. Go to the repository folder and launch the box

    $ cd [repo]
    $ vagrant up

What's inside:
--------------

Installed packages:

* Apache
* MySQL
* php
* phpMyAdmin
* Xdebug with Webgrind
* zsh with [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
* git, subversion
* vim, screen, mc

Apache virtual hosts are created in `public` folder and configured with data bag `sites`.

Webgrind and phpMyAdmin are available on every domain. For example:

* http://test.com/phpmyadmin 
* http://test.com/webgrind