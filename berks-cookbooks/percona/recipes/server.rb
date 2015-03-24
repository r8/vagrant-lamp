#
# Cookbook Name:: percona
# Recipe:: server
#

include_recipe "percona::package_repo"

# install packages
case node["platform_family"]
when "debian"
  package node["percona"]["server"]["package"] do
    action :install
    options "--force-yes"
  end
when "rhel"
  # Need to remove this to avoid conflicts
  package "mysql-libs" do
    action :remove
    not_if "rpm -qa | grep #{node["percona"]["server"]["shared_pkg"]}"
  end

  # we need mysqladmin
  include_recipe "percona::client"

  package node["percona"]["server"]["package"] do
    action :install
  end
end

if node["percona"]["server"]["jemalloc"]
  package_name = value_for_platform_family(
    "debian" => "libjemalloc1",
    "rhel" => "jemalloc"
  )

  package package_name
end

unless node["percona"]["skip_configure"]
  include_recipe "percona::configure_server"
end

# access grants
unless node["percona"]["skip_passwords"]
  include_recipe "percona::access_grants"
  include_recipe "percona::replication"
end
