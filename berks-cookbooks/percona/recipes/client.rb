#
# Cookbook Name:: percona
# Recipe:: client
#

include_recipe "percona::package_repo"

node["percona"]["client"]["packages"].each do |percona_client_pkg|
  package percona_client_pkg
end
