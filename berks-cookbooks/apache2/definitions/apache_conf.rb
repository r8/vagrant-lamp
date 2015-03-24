#
# Cookbook Name:: apache2
# Definition:: apache_conf
#
# Copyright 2008-2013, Opscode, Inc.
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

define :apache_conf, :enable => true do
  conf_name = "#{params[:name]}.conf"
  params[:conf_path] = params[:conf_path] || "#{node['apache']['dir']}/conf-available"

  file "#{params[:conf_path]}/#{params[:name]}" do
    action :delete
  end

  template "#{params[:conf_path]}/#{conf_name}" do
    source params[:source] || "#{conf_name}.erb"
    cookbook params[:cookbook] if params[:cookbook]
    owner 'root'
    group node['apache']['root_group']
    backup false
    mode '0644'
    notifies :reload, 'service[apache2]', :delayed
  end

  if params[:enable]
    apache_config params[:name] do
      enable true
    end
  end
end
