#
# Cookbook Name:: composer
# Attributes:: default
#
# Copyright 2012-2013, Escape Studios
#

default[:composer][:install_globally] = true
default[:composer][:prefix] = "/usr/local"
default[:composer][:url] = "https://getcomposer.org/installer"
default[:composer][:install_dir] = nil