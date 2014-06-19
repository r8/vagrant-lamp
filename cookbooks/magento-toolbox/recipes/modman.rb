#
# Cookbook Name:: magento-toolbox
# Recipe:: modman
#
# Copyright 2013, Sergey Storchay
#
# Licensed under MIT:
# http://raw.github.com/r8/magento-toolbox/master/LICENSE.txt

package "curl" do
  action :upgrade
end

command = "curl -L -o modman https://raw.github.com/colinmollenhour/modman/master/modman && chmod +x ./modman"

bash "download_modman" do
  cwd "#{Chef::Config[:file_cache_path]}"
  code <<-EOH
    #{command}
  EOH
end

if node["modman"]["install_globally"]
  bash "move_modman" do
    cwd "#{Chef::Config[:file_cache_path]}"
    code <<-EOH
      sudo mv modman #{node["modman"]["prefix"]}/bin/modman
    EOH
  end
end
