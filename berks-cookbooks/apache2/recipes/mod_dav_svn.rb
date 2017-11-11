#
# Cookbook:: apache2
# Recipe:: mod_dav_svn
#
# Copyright:: 2008-2009, Chef Software, Inc.
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

include_recipe 'apache2::mod_dav'

package 'libapache2-svn' do
  case node['platform_family']
  when 'rhel', 'fedora', 'suse', 'amazon'
    package_name 'mod_dav_svn'
  else
    if platform?('debian') && node['platform_version'].to_i >= 8
      package_name 'libapache2-mod-svn'
    else
      package_name 'libapache2-svn'
    end
  end
end

case node['platform_family']
when 'rhel', 'fedora', 'suse', 'amazon'
  file "#{node['apache']['dir']}/conf.d/subversion.conf" do
    action :delete
    backup false
  end
end

apache_module 'dav_svn'
