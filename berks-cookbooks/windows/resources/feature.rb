#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook:: windows
# Resource:: feature
#
# Copyright:: 2011-2017, Chef Software, Inc.
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

include Windows::Helper

def whyrun_supported?
  true
end

action :install do
  run_default_provider :install
end

action :remove do
  run_default_provider :remove
end

action :delete do
  run_default_provider :delete
end

action_class do
  def locate_default_provider
    if new_resource.install_method
      new_resource.install_method
    elsif ::File.exist?(locate_sysnative_cmd('dism.exe'))
      :windows_feature_dism
    elsif ::File.exist?(locate_sysnative_cmd('servermanagercmd.exe'))
      :windows_feature_servermanagercmd
    else
      :windows_feature_powershell
    end
  end

  def run_default_provider(desired_action)
    case locate_default_provider
    when :windows_feature_dism
      windows_feature_dism new_resource.name do
        action desired_action
        feature_name new_resource.feature_name
        source new_resource.source if new_resource.source
        all new_resource.all
        timeout new_resource.timeout
      end
    when :windows_feature_servermanagercmd
      windows_feature_servermanagercmd new_resource.name do
        action desired_action
        feature_name new_resource.feature_name
        all new_resource.all
        timeout new_resource.timeout
      end
    when :windows_feature_powershell
      windows_feature_powershell new_resource.name do
        action desired_action
        feature_name new_resource.feature_name
        source new_resource.source if new_resource.source
        all new_resource.all
        timeout new_resource.timeout
        management_tools new_resource.management_tools
      end
    end
  end
end
