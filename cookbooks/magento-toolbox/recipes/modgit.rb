#
# Cookbook Name:: magento-toolbox
# Recipe:: modgit
#
# Copyright 2013, Sergey Storchay
#
# Licensed under MIT:
# http://raw.github.com/r8/magento-toolbox/master/LICENSE.txt

package "curl" do
  action :upgrade
end

command = "curl -o modgit https://raw.github.com/jreinke/modgit/master/modgit && chmod +x ./modgit"

bash "download_modgit" do
  cwd "#{Chef::Config[:file_cache_path]}"
  code <<-EOH
    #{command}
  EOH
end

if node["modgit"]["install_globally"]
  bash "move_modgit" do
    cwd "#{Chef::Config[:file_cache_path]}"
    code <<-EOH
      sudo mv modgit #{node["modgit"]["prefix"]}/bin/modgit
    EOH
  end
end
