#
# Cookbook:: apache2
# Recipe:: default
#
# Copyright:: 2008-2017, Chef Software, Inc.
# Copyright:: 2014-2015, Alexander van Zoest
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
  default_release node['apache']['default_release'] unless node['apache']['default_release'].nil?
end

%w(sites-available sites-enabled mods-available mods-enabled conf-available conf-enabled).each do |dir|
  directory "#{apache_dir}/#{dir}" do
    mode '0755'
    owner 'root'
    group node['apache']['root_group']
  end
end

%w(default default.conf 000-default 000-default.conf).each do |site|
  link "#{apache_dir}/sites-enabled/#{site}" do
    action :delete
    not_if { site == "#{node['apache']['default_site_name']}.conf" && node['apache']['default_site_enabled'] }
  end

  file "#{apache_dir}/sites-available/#{site}" do
    action :delete
    backup false
    not_if { site == "#{node['apache']['default_site_name']}.conf" && node['apache']['default_site_enabled'] }
  end
end

directory node['apache']['log_dir'] do
  mode '0755'
  recursive true
end

# perl is needed for the a2* scripts
package node['apache']['perl_pkg']

package 'perl-Getopt-Long-Descriptive' if platform?('fedora')

%w(a2ensite a2dissite a2enmod a2dismod a2enconf a2disconf).each do |modscript|
  link "/usr/sbin/#{modscript}" do
    action :delete
    only_if { ::File.symlink?("/usr/sbin/#{modscript}") }
  end

  template "/usr/sbin/#{modscript}" do
    source "#{modscript}.erb"
    mode '0700'
    owner 'root'
    variables(
      apachectl: apachectl,
      apache_dir: apache_dir
    )
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
    command "/usr/local/bin/apache2_module_conf_generate.pl #{node['apache']['lib_dir']} #{apache_dir}/mods-available"
    action :nothing
  end
end

if platform_family?('freebsd')
  directory "#{apache_dir}/Includes" do
    action :delete
    recursive true
  end

  directory "#{apache_dir}/extra" do
    action :delete
    recursive true
  end
end

if platform_family?('suse')
  directory "#{apache_dir}/vhosts.d" do
    action :delete
    recursive true
  end

  %w(charset.conv default-vhost.conf default-server.conf default-vhost-ssl.conf errors.conf listen.conf mime.types mod_autoindex-defaults.conf mod_info.conf mod_log_config.conf mod_status.conf mod_userdir.conf mod_usertrack.conf uid.conf).each do |file|
    file "#{apache_dir}/#{file}" do
      action :delete
      backup false
    end
  end
end

%W(
  #{apache_dir}/ssl
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
  if node['platform_family'] == 'debian'
    owner node['apache']['user']
  else
    owner 'root'
  end
  group node['apache']['root_group']
end

# Set the preferred execution binary - prefork or worker
template "/etc/sysconfig/#{apache_platform_service_name}" do
  source 'etc-sysconfig-httpd.erb'
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  notifies :restart, 'service[apache2]', :delayed
  variables(
    apache_binary: apache_binary,
    apache_dir: apache_dir
  )
  only_if { platform_family?('rhel', 'amazon', 'fedora', 'suse') }
end

template "#{apache_dir}/envvars" do
  source 'envvars.erb'
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  notifies :reload, 'service[apache2]', :delayed
  only_if  { platform_family?('debian') }
end

template 'apache2.conf' do
  if platform_family?('debian')
    path "#{apache_conf_dir}/apache2.conf"
  else
    path "#{apache_conf_dir}/httpd.conf"
  end
  action :create
  source 'apache2.conf.erb'
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  variables(
    apache_binary: apache_binary,
    apache_dir: apache_dir
  )
  notifies :reload, 'service[apache2]', :delayed
end

%w(security charset).each do |conf|
  apache_conf conf do
    enable true
  end
end

template 'ports.conf' do
  path "#{apache_dir}/ports.conf"
  source 'ports.conf.erb'
  mode '0644'
  notifies :restart, 'service[apache2]', :delayed
end

if node['apache']['mpm_support'].include?(node['apache']['mpm'])
  include_recipe "apache2::mpm_#{node['apache']['mpm']}"
else
  Chef::Log.warn("apache2: #{node['apache']['mpm']} module is not supported and must be handled separately!")
end

node['apache']['default_modules'].each do |mod|
  module_recipe_name = mod =~ /^mod_/ ? mod : "mod_#{mod}"
  include_recipe "apache2::#{module_recipe_name}"
end

if node['apache']['default_site_enabled']
  web_app node['apache']['default_site_name'] do
    template 'default-site.conf.erb'
    enable node['apache']['default_site_enabled']
  end
end

service 'apache2' do
  service_name apache_platform_service_name
  supports [:start, :restart, :reload, :status]
  action [:enable, :start]
  only_if "#{apache_binary} -t", environment: { 'APACHE_LOG_DIR' => node['apache']['log_dir'] }, timeout: node['apache']['httpd_t_timeout']
end
