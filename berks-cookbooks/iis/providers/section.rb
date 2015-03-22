#
# Author:: Justin Schuhmann
# Cookbook Name:: iis
# Resource:: lock
#
# Copyright:: Justin Schuhmann
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

require 'chef/mixin/shell_out'
require 'rexml/document'

include Chef::Mixin::ShellOut
include REXML
include Opscode::IIS::Helper

action :lock do
  @current_resource.exists = is_new_value?(doc.root, "CONFIG/@overrideMode", "Deny")

  unless @current_resource.exists
    cmd = "#{appcmd(node)} lock config -section:\"#{new_resource.section}\""
    Chef::Log.debug(cmd)
    shell_out!(cmd, :returns => new_resource.returns)
    new_resource.updated_by_last_action(true)
    Chef::Log.info("IIS Config command run")
  else
    Chef::Log.debug("#{new_resource.section} already locked - nothing to do")
  end
end

action :unlock do
  @current_resource.exists = is_new_value?(doc.root, "CONFIG/@overrideMode", "Allow")

  unless @current_resource.exists
    cmd = "#{appcmd(node)} unlock config -section:\"#{new_resource.section}\""
    Chef::Log.debug(cmd)
    shell_out!(cmd, :returns => new_resource.returns)
    new_resource.updated_by_last_action(true)
    Chef::Log.info("IIS Config command run")
  else
    Chef::Log.debug("#{new_resource.section} already unlocked - nothing to do")
  end
end

def load_current_resource
  @current_resource = Chef::Resource::IisSection.new(new_resource.section)
  @current_resource.section(new_resource.section)
end

def doc
  cmd_current_values = "#{appcmd(node)} list config \"\" -section:#{new_resource.section} /config:* /xml"
  Chef::Log.debug(cmd_current_values)
  cmd_current_values = shell_out(cmd_current_values)
  if cmd_current_values.stderr.empty?
      xml = cmd_current_values.stdout
      return Document.new(xml)
  end

  cmd_current_values.error!  
end
