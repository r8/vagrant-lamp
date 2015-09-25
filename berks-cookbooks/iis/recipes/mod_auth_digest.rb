#
# Author:: Justin Schuhmann
# Cookbook Name:: iis
# Recipe:: mod_auth_basic
#
# Copyright:: Justin Schuhmann
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

include_recipe 'iis'

if Opscode::IIS::Helper.older_than_windows2008r2?
  feature = 'Web-Digest-Auth'
else
  feature = 'IIS-DigestAuthentication'
end

windows_feature feature do
  action :install
end

iis_section 'unlocks digest authentication control in web.config' do
  section 'system.webServer/security/authentication/digestAuthentication'
  action :unlock
end
