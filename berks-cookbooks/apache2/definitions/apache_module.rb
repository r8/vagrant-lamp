#
# Cookbook Name:: apache2
# Definition:: apache_module
#
# Copyright 2008-2013, Chef Software, Inc.
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

define :apache_module, :enable => true, :conf => false, :restart => false do
  include_recipe 'apache2::default'

  params[:filename]    = params[:filename] || "mod_#{params[:name]}.so"
  params[:module_path] = params[:module_path] || "#{node['apache']['libexec_dir']}/#{params[:filename]}"
  params[:identifier]  = params[:identifier] || "#{params[:name]}_module"

  apache_mod params[:name] if params[:conf]

  file "#{node['apache']['dir']}/mods-available/#{params[:name]}.load" do
    content "LoadModule #{params[:identifier]} #{params[:module_path]}\n"
    mode '0644'
  end

  if params[:enable]
    execute "a2enmod #{params[:name]}" do
      command "/usr/sbin/a2enmod #{params[:name]}"
      if params[:restart]
        notifies :restart, 'service[apache2]', :delayed
      else
        notifies :reload, 'service[apache2]', :delayed
      end
      not_if do
        ::File.symlink?("#{node['apache']['dir']}/mods-enabled/#{params[:name]}.load") &&
          (::File.exist?("#{node['apache']['dir']}/mods-available/#{params[:name]}.conf") ? ::File.symlink?("#{node['apache']['dir']}/mods-enabled/#{params[:name]}.conf") : true)
      end
    end
  else
    execute "a2dismod #{params[:name]}" do
      command "/usr/sbin/a2dismod #{params[:name]}"
      if params[:restart]
        notifies :restart, 'service[apache2]', :delayed
      else
        notifies :reload, 'service[apache2]', :delayed
      end
      only_if { ::File.symlink?("#{node['apache']['dir']}/mods-enabled/#{params[:name]}.load") }
    end
  end
end
