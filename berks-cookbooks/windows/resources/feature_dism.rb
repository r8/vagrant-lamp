#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook:: windows
# Provider:: feature_dism
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
property :timeout, Integer, default: 600

include Chef::Mixin::ShellOut
include Windows::Helper

action :install do
  Chef::Log.warn("Requested feature #{new_resource.feature_name} is not available on this system.") unless available?
  unless !available? || installed?
    converge_by("install Windows feature #{new_resource.feature_name}") do
      addsource = new_resource.source ? "/LimitAccess /Source:\"#{new_resource.source}\"" : ''
      addall = new_resource.all ? '/All' : ''
      shell_out!("#{dism} /online /enable-feature #{to_array(new_resource.feature_name).map { |feature| "/featurename:#{feature}" }.join(' ')} /norestart #{addsource} #{addall}", returns: [0, 42, 127, 3010], timeout: new_resource.timeout)
      # Reload ohai data
      reload_ohai_features_plugin(new_resource.action, new_resource.feature_name)
    end
  end
end

action :remove do
  if installed?
    converge_by("removing Windows feature #{new_resource.feature_name}") do
      shell_out!("#{dism} /online /disable-feature #{to_array(new_resource.feature_name).map { |feature| "/featurename:#{feature}" }.join(' ')} /norestart", returns: [0, 42, 127, 3010], timeout: new_resource.timeout)
      # Reload ohai data
      reload_ohai_features_plugin(new_resource.action, new_resource.feature_name)
    end
  end
end

action :delete do
  raise Chef::Exceptions::UnsupportedAction, "#{self} :delete action not support on #{win_version.sku}" unless supports_feature_delete?
  if available?
    converge_by("deleting Windows feature #{new_resource.feature_name} from the image") do
      shell_out!("#{dism} /online /disable-feature #{to_array(new_resource.feature_name).map { |feature| "/featurename:#{feature}" }.join(' ')} /Remove /norestart", returns: [0, 42, 127, 3010], timeout: new_resource.timeout)
      # Reload ohai data
      reload_ohai_features_plugin(new_resource.action, new_resource.feature_name)
    end
  end
end

action_class do
  def installed?
    @installed ||= begin
      install_ohai_plugin unless node['dism_features']

      # Compare against ohai plugin instead of costly dism run
      node['dism_features'].key?(new_resource.feature_name) && node['dism_features'][new_resource.feature_name] =~ /Enable/
    end
  end

  def available?
    @available ||= begin
      install_ohai_plugin unless node['dism_features']

      # Compare against ohai plugin instead of costly dism run
      node['dism_features'].key?(new_resource.feature_name) && node['dism_features'][new_resource.feature_name] !~ /with payload removed/
    end
  end

  def reload_ohai_features_plugin(take_action, feature_name)
    ohai "Reloading Dism_Features Plugin - Action #{take_action} of feature #{feature_name}" do
      action :reload
      plugin 'dism_features'
    end
  end

  def install_ohai_plugin
    Chef::Log.info("node['dism_features'] data missing. Installing the dism_features Ohai plugin")

    ohai_plugin 'dism_features' do
      compile_time true
      cookbook 'windows'
    end
  end

  def supports_feature_delete?
    win_version.major_version >= 6 && win_version.minor_version >= 2
  end

  # account for File System Redirector
  # http://msdn.microsoft.com/en-us/library/aa384187(v=vs.85).aspx
  def dism
    @dism ||= begin
      locate_sysnative_cmd('dism.exe')
    end
  end
end
