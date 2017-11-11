#
# Cookbook:: apache2
# Recipe:: mod_php
#
# Copyright:: 2008-2017, Chef Software, Inc.
# Copyright:: 2014, OneHealth Solutions, Inc.
# Copyright:: 2014, Viverae, Inc.
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

if node['apache']['mpm'] != 'prefork'
  Chef::Log.warn('apache2::mod_php generally is expected to be run under a non-threaded MPM, such as prefork')
  Chef::Log.warn('See http://php.net/manual/en/faq.installation.php#faq.installation.apache2')
  Chef::Log.warn("Currently the apache2 cookbook is configured to use the '#{node['apache']['mpm']}' MPM")
end

case node['platform_family']
when 'debian'
  if node['platform'] == 'ubuntu' && node['platform_version'].to_f < 16.04
    package 'libapache2-mod-php5'
  elsif node['platform'] == 'debian' && node['platform_version'].to_f < 9
    package 'libapache2-mod-php5'
  else
    package 'libapache2-mod-php'
  end
when 'arch'
  package 'php-apache' do
    notifies :run, 'execute[generate-module-list]', :immediately
  end
when 'rhel', 'amazon', 'fedora', 'suse'
  package 'which'
  package 'php' do
    notifies :run, 'execute[generate-module-list]', :immediately
    not_if 'which php'
  end
when 'freebsd'
  package %w(php56 libxml2)

  %w(mod_php56).each do |pkg|
    package pkg do
      options '-I'
    end
  end
end unless node['apache']['mod_php']['install_method'] == 'source'

case node['platform_family']
when 'debian'
  # on debian plaform_family php creates newly named incompatible config
  file "#{node['apache']['dir']}/mods-available/php7.0.conf" do
    content '# conf is under mods-available/php.conf - apache2 cookbook\n'
  end

  file "#{node['apache']['dir']}/mods-available/php7.0.load" do
    content '# conf is under mods-available/php.load - apache2 cookbook\n'
  end
when 'rhel', 'fedora', 'suse', 'amazon'
  file "#{node['apache']['dir']}/conf.d/php.conf" do
    content '# conf is under mods-available/php.conf - apache2 cookbook\n'
    only_if { ::Dir.exist?("#{node['apache']['dir']}/conf.d") }
  end
end

template "#{node['apache']['dir']}/mods-available/php.conf" do
  source 'mods/php.conf.erb'
  mode '0644'
  notifies :reload, 'service[apache2]', :delayed
end

apache_module node['apache']['mod_php']['module_name'] do
  conf false
  filename node['apache']['mod_php']['so_filename']
end
