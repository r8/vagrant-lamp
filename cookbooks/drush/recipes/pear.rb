# 
# Author:: Mark Sonnabaum <mark.sonnabaum@acquia.com>
# Contributor:: Patrick Connolly <patrick@myplanetdigital.com>
# Cookbook Name:: drush
# Recipe:: pear
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

include_recipe "php"

# If drush version is a preferred state, get the latest version of that state
case node['drush']['version']
when 'stable', 'beta', 'devel'
  require 'rexml/document'
  require 'open-uri'
  xml = REXML::Document.new(open(node['drush']['allreleases']))
  xml.root.each_element('r') do |release|
    if release.text('s') == node['drush']['version']
      node.default['drush']['version'] = release.text('v')
      break
    end
  end
end

# Initialize drush PEAR channel
dc = php_pear_channel "pear.drush.org" do
  action :discover
end

# Install drush
php_pear "drush" do
  version node['drush']['version']
  channel dc.channel_name
  action :install
end
