# encoding: utf-8
# Copyright:: 2012-2017, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node['postfix']['maps'].each do |type, maps|
  if node['platform_family'] == 'debian'
    package "postfix-#{type}" if %w(pgsql mysql ldap cdb).include?(type)
  end

  separator = if %w(pgsql mysql ldap memcache sqlite).include?(type)
                ' = '
              else
                ' '
              end
  maps.each do |file, content|
    execute "update-postmap-#{file}" do
      command "postmap #{file}"
      environment PATH: "#{ENV['PATH']}:/opt/omni/bin:/opt/omni/sbin" if platform_family?('omnios')
      action :nothing
    end if %w(btree cdb dbm hash sdbm).include?(type)
    template "#{file}-#{type}" do
      path file
      source 'maps.erb'
      only_if "postconf -m | grep -q #{type}"
      variables(
        map: content,
        separator: separator
      )
      if %w(btree cdb dbm hash sdbm).include?(type)
        notifies :run, "execute[update-postmap-#{file}]"
      end
      notifies :restart, 'service[postfix]'
    end
  end
end
