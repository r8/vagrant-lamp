#
# Cookbook:: apache2
# Recipe:: mod_fastcgi
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

if node['apache']['mod_fastcgi']['install_method'] == 'package'
  package node['apache']['mod_fastcgi']['package']
else
  if platform_family?('debian')
    package 'build-essential'
    package node['apache']['devel_package']
  elsif platform_family?('rhel', 'fedora', 'amazon')
    package %W(gcc make libtool #{node['apache']['devel_package']} apr-devel apr)
  else
    Chef::Log.warn("mod_fastcgi cannot be installed from source on the #{node['platform']} platform")
  end

  src_filepath = "#{Chef::Config['file_cache_path']}/fastcgi.tar.gz"
  remote_file 'download fastcgi source' do
    source node['apache']['mod_fastcgi']['download_url']
    path src_filepath
    backup false
  end

  top_dir = if platform_family?('debian')
              node['apache']['build_dir']
            else
              node['apache']['lib_dir']
            end
  include_recipe 'apache2::default'
  bash 'compile fastcgi source' do
    notifies :run, 'execute[generate-module-list]', :immediately if platform_family?('rhel', 'fedora', 'amazon')
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
