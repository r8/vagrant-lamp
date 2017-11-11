#
# Cookbook:: apache2
# Definition:: apache_config
#
# Copyright:: 2008-2017, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

define :apache_config, enable: true do
  include_recipe 'apache2::default'

  conf_name = "#{params[:name]}.conf"
  params[:conf_path] = params[:conf_path] || "#{node['apache']['dir']}/conf-available"

  if params[:enable]
    execute "a2enconf #{conf_name}" do
      command "/usr/sbin/a2enconf #{conf_name}"
      notifies :restart, 'service[apache2]', :delayed
      not_if do
        ::File.symlink?("#{node['apache']['dir']}/conf-enabled/#{conf_name}") &&
          (::File.exist?(params[:conf_path]) ? ::File.symlink?("#{node['apache']['dir']}/conf-enabled/#{conf_name}") : true)
      end
    end
  else
    execute "a2disconf #{conf_name}" do
      command "/usr/sbin/a2disconf #{conf_name}"
      notifies :reload, 'service[apache2]', :delayed
      only_if { ::File.symlink?("#{node['apache']['dir']}/conf-enabled/#{conf_name}") }
    end
  end
end
