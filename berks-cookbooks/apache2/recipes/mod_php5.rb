#
# Cookbook Name:: apache2
# Recipe:: mod_php5
#
# Copyright 2008-2013, Chef Software, Inc.
# Copyright 2014, OneHealth Solutions, Inc.
# Copyright 2014, Viverae, Inc.
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
  Chef::Log.warn('apache2::mod_php5 generally is expected to be run under a non-threaded MPM, such as prefork')
  Chef::Log.warn('See http://php.net/manual/en/faq.installation.php#faq.installation.apache2')
  Chef::Log.warn("Currently the apache2 cookbook is configured to use the '#{node['apache']['mpm']}' MPM")
end

case node['platform_family']
when 'debian'
  package 'libapache2-mod-php5'
when 'arch'
  package 'php-apache' do
    notifies :run, 'execute[generate-module-list]', :immediately
  end
when 'rhel'
  package 'which'
  package 'php package' do
    if node['platform_version'].to_f < 6.0
      package_name 'php53'
    else
      package_name 'php'
    end
    notifies :run, 'execute[generate-module-list]', :immediately
    not_if 'which php'
  end
when 'fedora'
  package 'which'
  package 'php' do
    notifies :run, 'execute[generate-module-list]', :immediately
    not_if 'which php'
  end
when 'suse'
  package 'which'
  package 'php' do
    notifies :run, 'execute[generate-module-list]', :immediately
    not_if 'which php'
  end
when 'freebsd'
  %w(php5 mod_php5 libxml2).each do |pkg|
    package pkg
  end
end unless node['apache']['mod_php5']['install_method'] == 'source'

file "#{node['apache']['dir']}/conf.d/php.conf" do
  action :delete
  backup false
end

apache_module 'php5' do
  conf true
  filename node['apache']['mod_php5']['so_filename']
end
