#
# Cookbook Name:: percona
# Recipe:: monitoring
#

node["percona"]["plugins_packages"].each do |pkg|
  package pkg do
    action :install
    version node["percona"]["plugins_version"]
  end
end
