#
# Author:: Richard Lavey (richard.lavey@calastone.com)
# Cookbook:: windows
# Resource:: http_acl
#
# Copyright:: 2015-2017, Calastone Ltd.
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

include Chef::Mixin::ShellOut
include Windows::Helper

property :url, String, name_property: true, required: true
property :user, String
property :sddl, String
property :exists, [true, false], desired_state: true

# See https://msdn.microsoft.com/en-us/library/windows/desktop/cc307236%28v=vs.85%29.aspx for netsh info

load_current_value do |desired|
  cmd_out = shell_out!("#{locate_sysnative_cmd('netsh.exe')} http show urlacl url=#{desired.url}").stdout
  Chef::Log.debug "netsh reports: #{cmd_out}"

  if cmd_out.include? desired.url
    exists true
    url desired.url
    # Checks first for sddl, because it generates user(s)
    sddl_match = cmd_out.match(/SDDL:\s*(?<sddl>.+)/)
    if sddl_match
      sddl sddl_match['sddl']
    else
      # if no sddl, tries to find a single user
      user_match = cmd_out.match(/User:\s*(?<user>.+)/)
      user user_match['user']
    end
  else
    exists false
  end
end

action :create do
  raise '`user` xor `sddl` can\'t be used together' if new_resource.user && new_resource.sddl
  raise 'When provided user property can\'t be empty' if new_resource.user && new_resource.user.empty?
  raise 'When provided sddl property can\'t be empty' if new_resource.sddl && new_resource.sddl.empty?

  if current_resource.exists
    sddl_changed = (
      new_resource.sddl &&
      current_resource.sddl &&
      current_resource.sddl.casecmp(new_resource.sddl) != 0
    )
    user_changed = (
      new_resource.user &&
      current_resource.user &&
      current_resource.user.casecmp(new_resource.user) != 0
    )

    if sddl_changed || user_changed
      converge_by("Changing #{new_resource.url}") do
        delete_acl
        apply_acl
      end
    else
      Chef::Log.debug("#{new_resource.url} already set - nothing to do")
    end
  else
    converge_by("Setting #{new_resource.url}") do
      apply_acl
    end
  end
end

action :delete do
  if current_resource.exists
    converge_by("Deleting #{new_resource.url}") do
      delete_acl
    end
  else
    Chef::Log.debug("#{new_resource.url} does not exist - nothing to do")
  end
end

action_class do
  def netsh_command
    locate_sysnative_cmd('netsh.exe')
  end

  def apply_acl
    if current_resource.sddl
      shell_out!("#{netsh_command} http add urlacl url=#{new_resource.url} sddl=\"#{new_resource.sddl}\"")
    else
      shell_out!("#{netsh_command} http add urlacl url=#{new_resource.url} user=\"#{new_resource.user}\"")
    end
  end

  def delete_acl
    shell_out!("#{netsh_command} http delete urlacl url=#{new_resource.url}")
  end
end
