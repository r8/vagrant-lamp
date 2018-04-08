#
# Author:: Seth Chisamore <schisamo@chef.io>
# Cookbook:: php
# Resource:: pear_package
#
# Copyright:: 2011-2016, Chef Software, Inc <legal@chef.io>
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

property :package_name, String, name_property: true
property :version, [String, nil], default: nil
property :channel, String
property :options, String
property :directives, Hash, default: {}
property :zend_extensions, Array, default: []
property :preferred_state, String, default: 'stable'
property :binary, String, default: 'pear'
property :priority, [String, nil], default: nil

include PhpCookbook::Helpers

load_current_value do |new_resource|
  unless current_installed_version(new_resource).nil?
    version(current_installed_version(new_resource))
    Chef::Log.debug("Current version is #{version}") if version
  end
end

action :install do
  # If we specified a version, and it's not the current version, move to the specified version
  install_version = new_resource.version unless new_resource.version.nil? || new_resource.version == current_resource.version
  # Check if the version we want is already installed
  versions_match = candidate_version == current_installed_version(new_resource)

  # If it's not installed at all or an upgrade, install it
  if install_version || new_resource.version.nil? && !versions_match
    converge_by("install package #{new_resource.package_name} #{install_version}") do
      info_output = "Installing #{new_resource.package_name}"
      info_output << " version #{install_version}" if install_version && !install_version.empty?
      Chef::Log.info(info_output)
      install_package(new_resource.package_name, install_version)
    end
  end
end

# reinstall is just an install that always fires
action :reinstall do
  install_version = new_resource.version unless new_resource.version.nil?
  converge_by("reinstall package #{new_resource.package_name} #{install_version}") do
    info_output = "Installing #{new_resource.package_name}"
    info_output << " version #{install_version}" if install_version && !install_version.empty?
    Chef::Log.info(info_output)
    install_package(new_resource.package_name, install_version, force: true)
  end
end

action :upgrade do
  if current_resource.version != candidate_version
    orig_version = @current_resource.version || 'uninstalled'
    description = "upgrade package #{new_resource.package_name} version from #{orig_version} to #{candidate_version}"
    converge_by(description) do
      upgrade_package(new_resource.package_name, candidate_version)
    end
  end
end

action :remove do
  if removing_package?
    converge_by("remove package #{new_resource.package_name}") do
      remove_package(@current_resource.package_name, new_resource.version)
    end
  end
end

action :purge do
  if removing_package?
    converge_by("purge package #{new_resource.package_name}") do
      remove_package(@current_resource.package_name, new_resource.version)
    end
  end
end

action_class do
  include PhpCookbook::Helpers
end
