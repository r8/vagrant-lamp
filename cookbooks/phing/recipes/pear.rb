#
# Cookbook Name:: phing
# Recipe:: pear
#
# Copyright 2013, Sergey Storchay
#
# Licensed under MIT:
# http://raw.github.com/r8/php-phing/master/LICENSE.txt

include_recipe "php"

# If phing version is a preferred state, 
# get the latest version of that state
case node["phing"]["version"]
when "stable", "beta", "devel"
  require "rexml/document"
  require "open-uri"
  xml = REXML::Document.new(open(node["phing"]["allreleases"]))
  xml.root.each_element("r") do |release|
    if release.text("s") == node["phing"]["version"]
      node.default["phing"]["version"] = release.text("v")
      break
    end
  end
end

# Initialize Phing PEAR channel
channel = php_pear_channel "pear.phing.info" do
  action :discover
end

# Install Phing
php_pear "phing" do
  version node["phing"]["version"]
  channel channel.channel_name
  action :install
end
