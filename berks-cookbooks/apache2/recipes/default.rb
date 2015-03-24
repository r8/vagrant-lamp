#
# Cookbook Name:: apache2
# Recipe:: default
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

package 'apache2' do
  package_name node['apache']['package']
end

%w(sites-available sites-enabled mods-available mods-enabled conf-available conf-enabled).each do |dir|
  directory "#{node['apache']['dir']}/#{dir}" do
    mode '0755'
    owner 'root'
    group node['apache']['root_group']
  end
end

%w(default 000-default).each do |site|
  link "#{node['apache']['dir']}/sites-enabled/#{site}" do
    action :delete
  end

  file "#{node['apache']['dir']}/sites-available/#{site}" do
    action :delete
    backup false
  end
end

directory "#{node['apache']['dir']}/conf.d" do
  action :delete
  recursive true
end

directory node['apache']['log_dir'] do
  mode '0755'
end

# perl is needed for the a2* scripts
package node['apache']['perl_pkg']

%w(a2ensite a2dissite a2enmod a2dismod a2enconf a2disconf).each do |modscript|
  link "/usr/sbin/#{modscript}" do
    action :delete
    only_if { ::File.symlink?("/usr/sbin/#{modscript}") }
  end

  template "/usr/sbin/#{modscript}" do
    source "#{modscript}.erb"
    mode '0700'
    owner 'root'
    group node['apache']['root_group']
    action :create
  end
end

unless platform_family?('debian')
  cookbook_file '/usr/local/bin/apache2_module_conf_generate.pl' do
    source 'apache2_module_conf_generate.pl'
    mode '0755'
    owner 'root'
    group node['apache']['root_group']
  end

  execute 'generate-module-list' do
    command "/usr/local/bin/apache2_module_conf_generate.pl #{node['apache']['lib_dir']} #{node['apache']['dir']}/mods-available"
    action :nothing
  end

  # enable mod_deflate for consistency across distributions
  include_recipe 'apache2::mod_deflate'
end

if platform_family?('freebsd')

  directory "#{node['apache']['dir']}/Includes" do
    action :delete
    recursive true
  end

  directory "#{node['apache']['dir']}/extra" do
    action :delete
    recursive true
  end
end

if platform_family?('suse')

  directory "#{node['apache']['dir']}/vhosts.d" do
    action :delete
    recursive true
  end

  %w(charset.conv default-vhost.conf default-server.conf default-vhost-ssl.conf errors.conf listen.conf mime.types mod_autoindex-defaults.conf mod_info.conf mod_log_config.conf mod_status.conf mod_userdir.conf mod_usertrack.conf uid.conf).each do |file|
    file "#{node['apache']['dir']}/#{file}" do
      action :delete
      backup false
    end
  end
end

%W(
  #{node['apache']['dir']}/ssl
  #{node['apache']['cache_dir']}
).each do |path|
  directory path do
    mode '0755'
    owner 'root'
    group node['apache']['root_group']
  end
end

directory node['apache']['lock_dir'] do
  mode '0755'
  if node['platform_family'] == 'debian' && node['apache']['version'] == '2.2'
    owner node['apache']['user']
  else
    owner 'root'
  end
  group node['apache']['root_group']
end

# Set the preferred execution binary - prefork or worker
template "/etc/sysconfig/#{node['apache']['package']}" do
  source 'etc-sysconfig-httpd.erb'
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  notifies :restart, 'service[apache2]', :delayed
  only_if  { platform_family?('rhel', 'fedora', 'suse') }
end

template "#{node['apache']['dir']}/envvars" do
  source 'envvars.erb'
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  notifies :reload, 'service[apache2]', :delayed
  only_if  { platform_family?('debian') }
end

template 'apache2.conf' do
  if platform_family?('rhel', 'fedora', 'arch', 'freebsd')
    path "#{node['apache']['conf_dir']}/httpd.conf"
  elsif platform_family?('debian')
    path "#{node['apache']['conf_dir']}/apache2.conf"
  elsif platform_family?('suse')
    path "#{node['apache']['conf_dir']}/httpd.conf"
  end
  action :create
  source 'apache2.conf.erb'
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  notifies :reload, 'service[apache2]', :delayed
end

%w(security charset).each do |conf|
  apache_conf conf do
    enable true
  end
end

apache_conf 'ports' do
  enable false
  conf_path node['apache']['dir']
end

if node['apache']['version'] == '2.4' && !platform_family?('freebsd')
  # on freebsd the prefork mpm is staticly compiled in
  include_recipe "apache2::mpm_#{node['apache']['mpm']}"
end

node['apache']['default_modules'].each do |mod|
  module_recipe_name = mod =~ /^mod_/ ? mod : "mod_#{mod}"
  include_recipe "apache2::#{module_recipe_name}"
end

web_app 'default' do
  template 'default-site.conf.erb'
  path "#{node['apache']['dir']}/sites-available/default.conf"
  enable node['apache']['default_site_enabled']
end

apache_site node['apache']['default_site_name'] do
  enable node['apache']['default_site_enabled']
end

service 'apache2' do
  service_name node['apache']['service_name']
  case node['platform_family']
  when 'rhel'
    reload_command '/sbin/service httpd graceful'
  when 'debian'
    provider Chef::Provider::Service::Debian
  when 'arch'
    service_name 'httpd'
  end
  supports [:start, :restart, :reload, :status]
  action [:enable, :start]
  only_if "#{node['apache']['binary']} -t", :environment => { 'APACHE_LOG_DIR' => node['apache']['log_dir'] }, :timeout => 10
end
