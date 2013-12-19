#
# Cookbook Name:: php-box
# Recipe:: default
#
# Copyright 2013, Sergey Storchay
#
# Licensed under MIT:
# http://raw.github.com/r8/chef-php-box/master/LICENSE.txt

include_recipe "php"

template "#{node['php']['ext_conf_dir']}/phar.ini" do
  source "phar.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

package "curl" do
  action :upgrade
end

command = "curl -Ls http://box-project.org/installer.php | php"

bash "download_box" do
  cwd "#{Chef::Config[:file_cache_path]}"
  code <<-EOH
    #{command}
  EOH
end

if node["php-box"]["install_globally"]
  bash "move_box" do
    cwd "#{Chef::Config[:file_cache_path]}"
    code <<-EOH
      sudo mv box.phar #{node["php-box"]["prefix"]}/bin/box
    EOH
  end
end
