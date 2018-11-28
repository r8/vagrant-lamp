#
# Cookbook:: nodejs
# Attributes:: nodejs
#
# Copyright:: 2010-2017, Promet Solutions
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
when 'smartos', 'rhel', 'debian', 'fedora', 'mac_os_x', 'suse', 'amazon'
  default['nodejs']['install_method'] = 'package'
else
  default['nodejs']['install_method'] = 'source'
end

default['nodejs']['version'] = '8.12.0'

default['nodejs']['prefix_url']['node'] = 'https://nodejs.org/dist/'

default['nodejs']['source']['url']      = nil # Auto generated
default['nodejs']['source']['checksum'] = 'b4797843136edd9195c28221a1680ae52c29d867fc5fc1c99f7d6e2f2126a67b'

default['nodejs']['binary']['url'] = nil # Auto generated
default['nodejs']['binary']['checksum']['linux_x64'] = '3df19b748ee2b6dfe3a03448ebc6186a3a86aeab557018d77a0f7f3314594ef6'
default['nodejs']['binary']['checksum']['linux_x86'] = '56ecffbd8a656991f71e4b53ab00af333c97453062cadc20a2103b933088d24d'
default['nodejs']['binary']['checksum']['linux_arm64'] = '781ecf1ecb14b4c671ef0732988636282d6fb7071c4bd52567f663b008796bc9'

default['nodejs']['make_threads'] = node['cpu'] ? node['cpu']['total'].to_i : 2

default['nodejs']['manage_node'] = true
