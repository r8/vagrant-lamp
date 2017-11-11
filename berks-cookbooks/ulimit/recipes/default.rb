# Cookbook Name:: ulimit
# Recipe:: default
#
# Copyright 2012, Brightcove, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
ulimit = node['ulimit']

case node['platform']
  when "debian", "ubuntu"
    template "/etc/pam.d/su" do
      cookbook ulimit['pam_su_template_cookbook']
    end
    
    cookbook_file "/etc/pam.d/sudo" do
      cookbook node['ulimit']['ulimit_overriding_sudo_file_cookbook']
      source node['ulimit']['ulimit_overriding_sudo_file_name']
      mode "0644"
    end
end

if ulimit.has_key?('users')
  ulimit['users'].each do |user, attributes|
    user_ulimit user do
      attributes.each do |a, v|
        send(a.to_sym, v)
      end
    end
  end
end
