#
# Cookbook Name:: percona
# Recipe:: cluster
#

include_recipe "percona::package_repo"

# Determine and set wsrep_sst_receive_address
if node["percona"]["cluster"]["wsrep_sst_receive_interface"]
  sst_interface = node["percona"]["cluster"]["wsrep_sst_receive_interface"]
  sst_port = node["percona"]["cluster"]["wsrep_sst_receive_port"]
  ip = Percona::ConfigHelper.bind_to(node, sst_interface)
  address = "#{ip}:#{sst_port}"
  node.set["percona"]["cluster"]["wsrep_sst_receive_address"] = address
end

# set default package attributes
version = node["percona"]["version"]
node.default["percona"]["cluster"]["package"] = value_for_platform_family(
  "debian" => "percona-xtradb-cluster-#{version.tr(".", "")}",
  "rhel" => "Percona-XtraDB-Cluster-#{version.tr(".", "")}"
)

# install packages
case node["platform_family"]
when "debian"
  package node["percona"]["cluster"]["package"] do
    # The package starts up immediately, then additional config is added and the
    # restart command fails to work. Instead, stop the database before changing
    # the configuration.
    notifies :stop, "service[mysql]", :immediately
  end
when "rhel"
  package "mysql-libs" do
    action :remove
    not_if "rpm -qa | grep -q '#{node["percona"]["cluster"]["package"]}'"
  end

  # This is required for `socat` per:
  # www.percona.com/doc/percona-xtradb-cluster/5.6/installation/yum_repo.html
  include_recipe "yum-epel"

  package node["percona"]["cluster"]["package"]
end

unless node["percona"]["skip_configure"]
  include_recipe "percona::configure_server"
end

# access grants
include_recipe "percona::access_grants" unless node["percona"]["skip_passwords"]
