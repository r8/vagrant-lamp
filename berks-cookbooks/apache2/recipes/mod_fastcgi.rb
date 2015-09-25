#
# Cookbook Name:: apache2
# Recipe:: mod_fastcgi
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

if platform_family?('debian')
  if node['apache']['mod_fastcgi']['install_method'] == 'source'
    package 'build-essential'
    package node['apache']['devel_package']
  else
    package 'libapache2-mod-fastcgi'
  end
elsif platform_family?('rhel')
  %W(gcc make libtool #{node['apache']['devel_package']} apr-devel apr).each do |package|
    yum_package package do
      action :upgrade
    end
  end
end

if platform_family?('rhel') || (platform_family?('debian') && node['apache']['mod_fastcgi']['install_method'] == 'source')
  src_filepath  = "#{Chef::Config['file_cache_path']}/fastcgi.tar.gz"
  remote_file 'download fastcgi source' do
    source node['apache']['mod_fastcgi']['download_url']
    path src_filepath
    backup false
  end

  if platform_family?('debian')
    top_dir = node['apache']['build_dir']
  else
    top_dir = node['apache']['lib_dir']
  end
  include_recipe 'apache2::default'
  bash 'compile fastcgi source' do
    notifies :run, 'execute[generate-module-list]', :immediately if platform_family?('rhel')
    not_if "test -f #{node['apache']['dir']}/mods-available/fastcgi.conf"
    cwd ::File.dirname(src_filepath)
    code <<-EOH
      tar zxf #{::File.basename(src_filepath)} &&
      cd mod_fastcgi-* &&
      cp Makefile.AP2 Makefile &&
      make top_dir=#{top_dir} && make install top_dir=#{top_dir}
    EOH
  end
end

apache_module 'fastcgi' do
  conf true
end
