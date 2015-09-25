#
# Cookbook Name:: percona
# Recipe:: monitoring
#

node["percona"]["plugins_packages"].each do |pkg|
  package pkg do
    version node["percona"]["plugins_version"]
  end
end
