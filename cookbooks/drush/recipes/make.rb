# 
# Author:: David King <dking@xforty.com>
# Cookbook Name:: drush
# Recipe:: make
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

# Make sure drush is installed first
include_recipe "drush"

# Install drush_make
# TODO: come up with a way to allow users to update drush_make
execute "install_drush_make" do
  command "drush dl drush_make-6.x-#{node['drush']['make']['version']} --destination=#{node['drush']['install_dir']}/commands"
  not_if "drush make --help"
end
