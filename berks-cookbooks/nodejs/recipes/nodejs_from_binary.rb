#
# Author:: Julian Wilde (jules@jules.com.au)
# Cookbook:: nodejs
# Recipe:: install_from_binary
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

Chef::Recipe.send(:include, NodeJs::Helper)

# Shamelessly borrowed from http://docs.chef.io/dsl_recipe_method_platform.html
# Surely there's a more canonical way to get arch?
arch = if node['kernel']['machine'] =~ /armv6l/
         # FIXME: This should really check the version of node we're looking for
         # as it seems that they haven't build an `arm-pi` version in a while...
         # if it's old, return this, otherwise just return `node['kernel']['machine']`
         'arm-pi' # assume a raspberry pi
       elsif node['kernel']['machine'] =~ /aarch64/
         'arm64'
       elsif node['kernel']['machine'] =~ /x86_64/
         'x64'
       elsif node['kernel']['machine'] =~ /\d86/
         'x86'
       else
         node['kernel']['machine']
       end

# needed to uncompress the binary
package 'tar' if platform_family?('rhel', 'fedora', 'amazon', 'suse')

# package_stub is for example: "node-v6.9.1-linux-x64.tar.gz"
version = "v#{node['nodejs']['version']}/"
prefix = node['nodejs']['prefix_url']['node']

filename = "node-v#{node['nodejs']['version']}-linux-#{arch}.tar.gz"
archive_name = 'nodejs-binary'
binaries = ['bin/node']

binaries.push('bin/npm') if node['nodejs']['npm']['install_method'] == 'embedded'

if node['nodejs']['binary']['url']
  nodejs_bin_url = node['nodejs']['binary']['url']
  checksum = node['nodejs']['binary']['checksum']
else
  nodejs_bin_url = ::URI.join(prefix, version, filename).to_s
  checksum = node['nodejs']['binary']['checksum']["linux_#{arch}"]
end

ark archive_name do
  url nodejs_bin_url
  version node['nodejs']['version']
  checksum checksum
  has_binaries binaries
  action :install
end
