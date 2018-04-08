#
# Cookbook:: nodejs
# Resource:: npm
#
# Author:: Sergey Balbeko <sergey@balbeko.com>
#
# Copyright:: 2012-2017, Sergey Balbeko
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

resource_name :npm_package

# backwards compatibility for the old resource name
provides :nodejs_npm

property :package, name_property: true
property :version, String
property :path, String
property :url, String
property :json, [String, true]
property :npm_token, String
property :options, Array, default: []
property :user, String
property :group, String

def initialize(*args)
  super
  @run_context.include_recipe 'nodejs::npm' if node['nodejs']['manage_node']
end

action :install do
  execute "install NPM package #{new_resource.package}" do
    cwd new_resource.path
    command "npm install #{npm_options}"
    user new_resource.user
    group new_resource.group
    environment npm_env_vars
    not_if { package_installed? }
  end
end

action :uninstall do
  execute "uninstall NPM package #{new_resource.package}" do
    cwd new_resource.path
    command "npm uninstall #{npm_options}"
    user new_resource.user
    group new_resource.group
    environment npm_env_vars
    only_if { package_installed? }
  end
end

action_class do
  include NodeJs::Helper

  def npm_env_vars
    env_vars = {}
    env_vars['HOME'] = ::Dir.home(new_resource.user) if new_resource.user
    env_vars['USER'] = new_resource.user if new_resource.user
    env_vars['NPM_TOKEN'] = new_resource.npm_token if new_resource.npm_token

    env_vars
  end

  def package_installed?
    new_resource.package && npm_package_installed?(new_resource.package, new_resource.version, new_resource.path, new_resource.npm_token)
  end

  def npm_options
    options = ''
    options << ' -global' unless new_resource.path
    new_resource.options.each do |option|
      options << " #{option}"
    end
    options << " #{npm_package}"
  end

  def npm_package
    if new_resource.json
      new_resource.json.is_a?(String) ? new_resource.json : nil
    elsif new_resource.url
      new_resource.url
    elsif new_resource.package
      new_resource.version ? "#{new_resource.package}@#{new_resource.version}" : new_resource.package
    else
      Chef::Log.error("No good options found to install #{new_resource.package}")
    end
  end
end
