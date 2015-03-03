#
# Cookbook Name:: apache2
# Recipe:: mod_unixd
#
# Copyright 2014, OneHealth Solutions, Inc.
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

# on platform_family debian this module is staticly linked into apache2
if node['apache']['version'] == '2.4' && !platform_family?('debian')
  apache_module 'unixd'
else
  log 'Ignoring apache2::mod_unixd. Not available until apache 2.4'
end
