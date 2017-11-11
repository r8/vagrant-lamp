#
# Cookbook:: apache2
# Attributes:: mod_php
#
# Copyright:: 2014, Viverae, Inc.
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

default['apache']['mod_php']['install_method'] = 'package'
default['apache']['mod_php']['module_name'] = 'php5'
default['apache']['mod_php']['so_filename'] = 'libphp5.so'
default['apache']['mod_php']['so_filename'] = 'mod_php5.so' if node['platform_family'] == 'suse'

if node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 16.04
  default['apache']['mod_php']['module_name'] = 'php7'
  default['apache']['mod_php']['so_filename'] = 'libphp7.0.so'
end
if node['platform'] == 'debian' && node['platform_version'].to_f >= 9
  default['apache']['mod_php']['module_name'] = 'php7'
  default['apache']['mod_php']['so_filename'] = 'libphp7.0.so'
end
if node['platform'] == 'amazon'
  default['apache']['mod_php']['so_filename'] = 'libphp.so'
end
