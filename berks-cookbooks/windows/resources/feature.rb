#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook:: windows
# Resource:: feature
#
# Copyright:: 2011-2018, Chef Software, Inc.
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

property :feature_name, [Array, String], name_property: true
property :source, String
property :all, [true, false], default: false
property :management_tools, [true, false], default: false
property :install_method, Symbol, equal_to: [:windows_feature_dism, :windows_feature_powershell, :windows_feature_servermanagercmd]
property :timeout, Integer, default: 600

action :install do
  run_default_subresource :install
end

action :remove do
  run_default_subresource :remove
end

action :delete do
  run_default_subresource :delete
end

action_class do
  # call the appropriate windows_feature resource based on the specified subresource
  # @return [void]
  def run_default_subresource(desired_action)
    raise 'Support for Windows feature installation via servermanagercmd.exe has been removed as this support is no longer needed in Windows 2008 R2 and above. You will need to update your cookbook to install either via dism or powershell (preferred).' if new_resource.install_method == :windows_feature_servermanagercmd

    subresource = new_resource.install_method || :windows_feature_dism
    declare_resource(subresource, new_resource.name) do
      action desired_action
      feature_name new_resource.feature_name
      source new_resource.source if new_resource.source
      all new_resource.all
      timeout new_resource.timeout
      management_tools new_resource.management_tools if subresource == :windows_feature_powershell
    end
  end
end
