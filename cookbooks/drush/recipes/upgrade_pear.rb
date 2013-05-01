# 
# Author:: Mark Sonnabaum <mark.sonnabaum@acquia.com>
# Contributor:: Patrick Connolly <patrick@myplanetdigital.com>
# Cookbook Name:: drush
# Recipe:: upgrade_pear
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

# Drush PEAR channel requires >= 1.9.1 due to hosting
# on GitHub, where PEAR repo uses CNAME record.

# Chef resources need unique names in case in run_list twice.
php_pear "PEAR-drush" do
  package_name "PEAR"
  version "1.9.1"
  action :upgrade
end
