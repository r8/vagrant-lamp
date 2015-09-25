#
# Cookbook Name:: percona
# Recipe:: configure_server
#

percona = node["percona"]
server  = percona["server"]
conf    = percona["conf"]
mysqld  = (conf && conf["mysqld"]) || {}

# install chef-vault if needed
include_recipe "chef-vault" if node["percona"]["use_chef_vault"]

# construct an encrypted passwords helper -- giving it the node and bag name
passwords = EncryptedPasswords.new(node, percona["encrypted_data_bag"])

if node["percona"]["server"]["jemalloc"]
  package_name = value_for_platform_family(
    "debian" => "libjemalloc1",
    "rhel" => "jemalloc"
  )

  package package_name
end

template "/root/.my.cnf" do
  variables(root_password: passwords.root_password)
  owner "root"
  group "root"
  mode "0600"
  source "my.cnf.root.erb"
  sensitive true
  not_if { node["percona"]["skip_passwords"] }
end

if server["bind_to"]
  ipaddr = Percona::ConfigHelper.bind_to(node, server["bind_to"])
  if ipaddr && server["bind_address"] != ipaddr
    node.override["percona"]["server"]["bind_address"] = ipaddr
    node.save unless Chef::Config[:solo]
  end

  log "Can't find ip address for #{server["bind_to"]}" do
    level :warn
    only_if { ipaddr.nil? }
  end
end

datadir           = mysqld["datadir"] || server["datadir"]
logdir            = mysqld["logdir"] || server["logdir"]
tmpdir            = mysqld["tmpdir"] || server["tmpdir"]
includedir        = mysqld["includedir"] || server["includedir"]
user              = mysqld["username"] || server["username"]
slow_query_logdir = mysqld["slow_query_logdir"] || server["slow_query_logdir"]

# this is where we dump sql templates for replication, etc.
directory "/etc/mysql" do
  owner "root"
  group "root"
  mode "0755"
end

# setup the data directory
directory datadir do
  owner user
  group user
  recursive true
end

# setup the log directory
directory "log directory" do
  path logdir
  owner user
  group user
  recursive true
end

# setup the tmp directory
directory tmpdir do
  owner user
  group user
  recursive true
end

# setup the configuration include directory
unless includedir.empty?  # ~FC023
  directory includedir do # don't evaluate an empty `directory` resource
    owner user
    group user
    recursive true
  end
end

# setup slow_query_logdir directory
directory "slow query log directory" do
  path slow_query_logdir
  owner user
  group user
  recursive true
  not_if { slow_query_logdir.eql? logdir }
end

# define the service
service "mysql" do
  supports restart: true
  action server["enable"] ? :enable : :disable
end

# install db to the data directory
execute "setup mysql datadir" do
  command "mysql_install_db --defaults-file=#{percona["main_config_file"]} --user=#{user}" # rubocop:disable LineLength
  not_if "test -f #{datadir}/mysql/user.frm"
  action :nothing
end

# install SSL certificates before config phase
if node["percona"]["server"]["replication"]["ssl_enabled"]
  include_recipe "percona::ssl"
end

# setup the main server config file
template percona["main_config_file"] do
  if Array(server["role"]).include?("cluster")
    source "my.cnf.cluster.erb"
  else
    source "my.cnf.main.erb"
  end
  owner "root"
  group "root"
  mode "0644"
  sensitive true
  notifies :run, "execute[setup mysql datadir]", :immediately
  if node["percona"]["auto_restart"]
    notifies :restart, "service[mysql]", :immediately
  end
end

# now let's set the root password only if this is the initial install
unless node["percona"]["skip_passwords"]
  root_pw = passwords.root_password

  execute "Update MySQL root password" do  # ~FC009 - `sensitive`
    command "mysqladmin --user=root --password='' password '#{root_pw}'"
    only_if "mysqladmin --user=root --password='' version"
    sensitive true
  end
end

# setup the debian system user config
template "/etc/mysql/debian.cnf" do
  source "debian.cnf.erb"
  variables(debian_password: passwords.debian_password)
  owner "root"
  group "root"
  mode "0640"
  sensitive true
  if node["percona"]["auto_restart"]
    notifies :restart, "service[mysql]", :immediately
  end
  only_if { platform_family?("debian") }
end
