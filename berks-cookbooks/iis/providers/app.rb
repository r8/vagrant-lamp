#
# Author:: Kendrick Martin (kendrick.martin@webtrends.com)
# Contributor:: Adam Wayne (awayne@waynedigital.com)
# Cookbook Name:: iis
# Provider:: app
#
# Copyright:: 2011, Webtrends Inc.
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

action :add do
  if !@current_resource.exists
    cmd = "#{appcmd(node)} add app /site.name:\"#{new_resource.site_name}\""
    cmd << " /path:\"#{new_resource.path}\""
    cmd << " /applicationPool:\"#{new_resource.application_pool}\"" if new_resource.application_pool
    cmd << " /physicalPath:\"#{windows_cleanpath(new_resource.physical_path)}\"" if new_resource.physical_path
    cmd << " /enabledProtocols:\"#{new_resource.enabled_protocols}\"" if new_resource.enabled_protocols
    Chef::Log.debug(cmd)
    shell_out!(cmd)
    new_resource.updated_by_last_action(true)
    Chef::Log.info('App created')
  else
    Chef::Log.debug("#{new_resource} app already exists - nothing to do")
  end
end

action :config do
  was_updated = false
  cmd_current_values = "#{appcmd(node)} list app \"#{site_identifier}\" /config:* /xml"
  Chef::Log.debug(cmd_current_values)
  cmd_current_values = shell_out(cmd_current_values)
  if cmd_current_values.stderr.empty?
    xml = cmd_current_values.stdout
    doc = Document.new(xml)
    is_new_path = new_or_empty_value?(doc.root, 'APP/application/@path', new_resource.path.to_s)
    is_new_application_pool = new_or_empty_value?(doc.root, 'APP/application/@applicationPool', new_resource.application_pool.to_s)
    is_new_enabled_protocols = new_or_empty_value?(doc.root, 'APP/application/@enabledProtocols', new_resource.enabled_protocols.to_s)
    is_new_physical_path = new_or_empty_value?(doc.root, 'APP/application/virtualDirectory/@physicalPath', new_resource.physical_path.to_s)

    # only get the beginning of the command if there is something that changeds
    cmd = "#{appcmd(node)} set app \"#{site_identifier}\"" if ((new_resource.path && is_new_path) ||
                                                        (new_resource.application_pool && is_new_application_pool) ||
                                                        (new_resource.enabled_protocols && is_new_enabled_protocols))
    # adds path to the cmd
    cmd << " /path:\"#{new_resource.path}\"" if new_resource.path && is_new_path
    # adds applicationPool to the cmd
    cmd << " /applicationPool:\"#{new_resource.application_pool}\"" if new_resource.application_pool && is_new_application_pool
    # adds enabledProtocols to the cmd
    cmd << " /enabledProtocols:\"#{new_resource.enabled_protocols}\"" if new_resource.enabled_protocols && is_new_enabled_protocols
    Chef::Log.debug(cmd)

    if (cmd.nil?)
      Chef::Log.debug("#{new_resource} application - nothing to do")
    else
      shell_out!(cmd)
      was_updated = true
    end

    if ((new_resource.path && is_new_path) ||
      (new_resource.application_pool && is_new_application_pool) ||
      (new_resource.enabled_protocols && is_new_enabled_protocols))
      was_updated = true
    end

    if new_resource.physical_path && is_new_physical_path
      was_updated = true
      cmd = "#{appcmd(node)} set vdir /vdir.name:\"#{vdir_identifier}\""
      cmd << " /physicalPath:\"#{windows_cleanpath(new_resource.physical_path)}\""
      Chef::Log.debug(cmd)
      shell_out!(cmd)
    end
    if was_updated
      new_resource.updated_by_last_action(true)
      Chef::Log.info("#{new_resource} configured application")
    else
      Chef::Log.debug("#{new_resource} application - nothing to do")
    end
  else
    log "Failed to run iis_app action :config, #{cmd_current_values.stderr}" do
      level :warn
    end
  end
end

action :delete do
  if @current_resource.exists
    shell_out!("#{appcmd(node)} delete app \"#{site_identifier}\"")
    new_resource.updated_by_last_action(true)
    Chef::Log.info("#{new_resource} deleted")
  else
    Chef::Log.debug("#{new_resource} app does not exist - nothing to do")
  end
end

def load_current_resource
  @current_resource = Chef::Resource::IisApp.new(new_resource.name)
  @current_resource.site_name(new_resource.site_name)
  @current_resource.path(new_resource.path)
  @current_resource.application_pool(new_resource.application_pool)
  cmd = shell_out("#{appcmd(node)} list app")
  Chef::Log.debug("#{new_resource} list app command output: #{cmd.stdout}")
  regex = /^APP\s\"#{new_resource.site_name}#{new_resource.path}\"/
  Chef::Log.debug('Running regex')
  if cmd.stderr.empty?
    result = cmd.stdout.match(regex)
    Chef::Log.debug("#{new_resource} current_resource match output:#{result}")
    if result
      @current_resource.exists = true
    else
      @current_resource.exists = false
    end
  else
    log "Failed to run iis_app action :load_current_resource, #{cmd_current_values.stderr}" do
      level :warn
    end
  end
end

private

def site_identifier
  "#{new_resource.site_name}#{new_resource.path}"
end

# Ensure VDIR identifier has a trailing slash
def vdir_identifier
  site_identifier.end_with?('/') ? site_identifier : site_identifier + '/'
end
