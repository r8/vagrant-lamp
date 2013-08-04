#
# Cookbook Name:: magento-toolbox
# Recipe:: n98-magerun
#
# Copyright 2013, Sergey Storchay
#
# Licensed under MIT:
# http://raw.github.com/r8/magento-toolbox/master/LICENSE.txt

include_recipe "php"

package "curl" do
  action :upgrade
end

command = "curl -o n98-magerun.phar https://raw.github.com/netz98/n98-magerun/master/n98-magerun.phar && chmod +x ./n98-magerun.phar"

bash "download_n98-magerun" do
  cwd "#{Chef::Config[:file_cache_path]}"
  code <<-EOH
    #{command}
  EOH
end

if node["n98-magerun"]["install_globally"]
  bash "move_n98-magerun" do
    cwd "#{Chef::Config[:file_cache_path]}"
    code <<-EOH
      sudo mv n98-magerun.phar #{node["n98-magerun"]["prefix"]}/bin/n98-magerun
    EOH
  end
end
