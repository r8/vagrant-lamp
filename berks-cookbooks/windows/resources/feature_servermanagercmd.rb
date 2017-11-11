#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook:: windows
# Provider:: feature_servermanagercmd
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

property :feature_name, [Array, String], name_attribute: true
property :all, [true, false], default: false
property :timeout, Integer, default: 600

include Chef::Mixin::ShellOut
include Windows::Helper

action :install do
  unless installed?
    converge_by("install Windows feature #{new_resource.feature_name}") do
      check_reboot(shell_out("#{servermanagercmd} -install #{to_array(new_resource.feature_name).join(' ')}", returns: [0, 42, 127, 1003, 3010], timeout: new_resource.timeout), new_resource.feature_name)
    end
  end
end

action :remove do
  if installed?
    converge_by("removing Windows feature #{new_resource.feature_name}") do
      check_reboot(shell_out("#{servermanagercmd} -remove #{to_array(new_resource.feature_name).join(' ')}", returns: [0, 42, 127, 1003, 3010], timeout: new_resource.timeout), new_resource.feature_name)
    end
  end
end

action :delete do
  Chef::Log.warn('servermanagercmd does not support removing a feature from the image.')
end

# Exit codes are listed at http://technet.microsoft.com/en-us/library/cc749128(v=ws.10).aspx

action_class do
  def check_reboot(result, feature)
    if result.exitstatus == 3010 # successful, but needs reboot
      node.run_state['reboot_requested'] = true
      Chef::Log.warn("Require reboot to install #{feature}")
    elsif result.exitstatus == 1001 # failure, but needs reboot before we can do anything else
      node.run_state['reboot_requested'] = true
      Chef::Log.warn("Failed installing #{feature} and need to reboot")
    end
    result.error! # throw for any other bad results. The above results will also get raised, and should cause a reboot via the handler.
  end

  def installed?
    @installed ||= begin
      cmd = shell_out("#{servermanagercmd} -query", returns: [0, 42, 127, 1003], timeout: new_resource.timeout)
      cmd.stderr.empty? && (cmd.stdout =~ /^\s*?\[X\]\s.+?\s\[#{new_resource.feature_name}\]\s*$/i)
    end
  end

  # account for File System Redirector
  # http://msdn.microsoft.com/en-us/library/aa384187(v=vs.85).aspx
  def servermanagercmd
    @servermanagercmd ||= begin
      locate_sysnative_cmd('servermanagercmd.exe')
    end
  end
end
