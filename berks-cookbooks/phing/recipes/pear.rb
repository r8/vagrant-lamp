#
# Cookbook Name:: phing
# Recipe:: pear
#
# Copyright 2013, Sergey Storchay
#
# Licensed under MIT:
# http://raw.github.com/r8/php-phing/master/LICENSE.txt

include_recipe "php"

# Initialize Phing PEAR channel
channel = php_pear_channel "pear.phing.info" do
  action :discover
end

# Install Phing
php_pear "phing" do
  preferred_state node["phing"]["preferred_state"]
  channel channel.channel_name
  action :install
end
