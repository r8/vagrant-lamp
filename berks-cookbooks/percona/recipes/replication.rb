#
# Cookbook Name:: percona
# Recipe:: replication
#

require "shellwords"

passwords = EncryptedPasswords.new(node, node["percona"]["encrypted_data_bag"])
server = node["percona"]["server"]
replication_sql = server["replication"]["replication_sql"]

# define access grants
template replication_sql do
  source "replication.sql.erb"
  variables(replication_password: passwords.replication_password)
  owner "root"
  group "root"
  mode "0600"
  sensitive true
  only_if do
    server["replication"]["host"] != "" || server["role"].include?("master")
  end
end

root_pass = passwords.root_password.to_s
root_pass = Shellwords.escape(root_pass).prepend("-p") unless root_pass.empty?

execute "mysql-set-replication" do  # ~FC009 - `sensitive`
  command "/usr/bin/mysql #{root_pass} < #{replication_sql}"
  action :nothing
  subscribes :run, resources("template[#{replication_sql}]"), :immediately
  sensitive true
end
