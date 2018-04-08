#
# Cookbook:: openssl
# Recipe:: upgrade
#
# Copyright:: 2015-2017, Chef Software, Inc. <legal@chef.io>
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

case node['platform_family']
when 'debian', 'ubuntu'
  packages = if platform?('debian') && node['platform_version'].to_i >= 9
               %w(libssl1.0.2 openssl)
             else
               %w(libssl1.0.0 openssl)
             end
when 'rhel', 'fedora', 'suse', 'amazon'
  packages = %w(openssl)
else
  packages = []
end

if packages.empty?
  Chef::Log.warn("The openssl::upgrade recipe does not currently support #{node['platform']}. If you believe it could please open a PR at https://github.com/chef-cookbooks/openssl")
else
  package packages do
    action :upgrade
    node['openssl']['restart_services'].each do |ssl_svc|
      notifies :restart, "service[#{ssl_svc}]"
    end
  end
end
