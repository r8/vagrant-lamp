#
# Cookbook Name:: phing
# Recipe:: default
#
# Copyright 2013, Sergey Storchay
#
# Licensed under MIT:
# http://raw.github.com/r8/php-phing/master/LICENSE.txt

include_recipe "php"

include_recipe "phing::#{node["phing"]["install_method"]}"
