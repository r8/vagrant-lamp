#
# Cookbook:: apache2
# Recipe:: mpm_worker
#
# Copyright:: 2013, OneHealth Solutions, Inc.
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

# OpenSuse distributes packages with workers compiled into the httpd bin
if platform_family?('suse')
  package %w(apache2-event apache2-prefork) do
    action :remove
  end

  package 'apache2-worker'
else
  # apache_module('mpm_itk') { enable false }
  apache_module('mpm_event') { enable false }
  apache_module('mpm_prefork') { enable false }

  apache_module 'mpm_worker' do
    conf true
    restart true
  end
end
