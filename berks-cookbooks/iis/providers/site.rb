#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook Name:: iis
# Provider:: site
#
# Copyright:: 2011, Chef Software, Inc.
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
    cmd = "#{appcmd(node)} add site /name:\"#{new_resource.site_name}\""
    cmd << " /id:#{new_resource.site_id}" if new_resource.site_id
    cmd << " /physicalPath:\"#{windows_cleanpath(new_resource.path)}\"" if new_resource.path
    if new_resource.bindings
      cmd << " /bindings:\"#{new_resource.bindings}\""
    else
      cmd << " /bindings:#{new_resource.protocol}/*"
      cmd << ":#{new_resource.port}:" if new_resource.port
      cmd << new_resource.host_header if new_resource.host_header
    end

    # support for additional options -logDir, -limits, -ftpServer, etc...
    if new_resource.options
      cmd << " #{new_resource.options}"
    end
    shell_out!(cmd,  returns: [0, 42])

    configure

    if new_resource.application_pool
      shell_out!("#{appcmd(node)} set app \"#{new_resource.site_name}/\" /applicationPool:\"#{new_resource.application_pool}\"",  returns: [0, 42])
    end
    new_resource.updated_by_last_action(true)
    Chef::Log.info("#{new_resource} added new site '#{new_resource.site_name}'")
  else
    Chef::Log.debug("#{new_resource} site already exists - nothing to do")
  end
end

action :config do
  configure
end

action :delete do
  if @current_resource.exists
    Chef::Log.info("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"")
    shell_out!("#{appcmd(node)} delete site /site.name:\"#{new_resource.site_name}\"",  returns: [0, 42])
    new_resource.updated_by_last_action(true)
    Chef::Log.info("#{new_resource} deleted")
  else
    Chef::Log.debug("#{new_resource} site does not exist - nothing to do")
  end
end

action :start do
  if !@current_resource.running
    shell_out!("#{appcmd(node)} start site /site.name:\"#{new_resource.site_name}\"",  returns: [0, 42])
    new_resource.updated_by_last_action(true)
    Chef::Log.info("#{new_resource} started")
  else
    Chef::Log.debug("#{new_resource} already running - nothing to do")
  end
end

action :stop do
  if @current_resource.running
    Chef::Log.info("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"")
    shell_out!("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"",  returns: [0, 42])
    new_resource.updated_by_last_action(true)
    Chef::Log.info("#{new_resource} stopped")
  else
    Chef::Log.debug("#{new_resource} already stopped - nothing to do")
  end
end

action :restart do
  shell_out!("#{appcmd(node)} stop site /site.name:\"#{new_resource.site_name}\"",  returns: [0, 42])
  sleep 2
  shell_out!("#{appcmd(node)} start site /site.name:\"#{new_resource.site_name}\"",  returns: [0, 42])
  new_resource.updated_by_last_action(true)
  Chef::Log.info("#{new_resource} restarted")
end

def load_current_resource
  @current_resource = Chef::Resource::IisSite.new(new_resource.name)
  @current_resource.site_name(new_resource.site_name)
  cmd = shell_out("#{appcmd(node)} list site")
  Chef::Log.debug(appcmd(node))
  # 'SITE "Default Web Site" (id:1,bindings:http/*:80:,state:Started)'
  Chef::Log.debug("#{new_resource} list site command output: #{cmd.stdout}")
  if cmd.stderr.empty?
    result = cmd.stdout.gsub(/\r\n?/, "\n") # ensure we have no carriage returns
    result = result.match(/^SITE\s\"(#{new_resource.site_name})\"\s\(id:(.*),bindings:(.*),state:(.*)\)$/)
    Chef::Log.debug("#{new_resource} current_resource match output: #{result}")
    if result
      @current_resource.site_id(result[2].to_i)
      @current_resource.exists = true
      @current_resource.bindings(result[3])
      @current_resource.running = (result[4] =~ /Started/) ? true : false
    else
      @current_resource.exists = false
      @current_resource.running = false
    end
  else
    log "Failed to run iis_site action :config, #{cmd.stderr}" do
      level :warn
    end
  end
end

private
  def configure
    was_updated = false
    cmd_current_values = "#{appcmd(node)} list site \"#{new_resource.site_name}\" /config:* /xml"
    Chef::Log.debug(cmd_current_values)
    cmd_current_values = shell_out(cmd_current_values)
    if cmd_current_values.stderr.empty?
      xml = cmd_current_values.stdout
      doc = Document.new(xml)
      is_new_bindings = new_value?(doc.root, 'SITE/@bindings', new_resource.bindings.to_s)
      is_new_physical_path = new_or_empty_value?(doc.root, 'SITE/site/application/virtualDirectory/@physicalPath', new_resource.path.to_s)
      is_new_port_host_provided = !"#{XPath.first(doc.root, 'SITE/@bindings')},".include?("#{new_resource.protocol}/*:#{new_resource.port}:#{new_resource.host_header},")
      is_new_site_id = new_value?(doc.root, 'SITE/site/@id', new_resource.site_id.to_s)
      is_new_log_directory = new_or_empty_value?(doc.root, 'SITE/logFiles/@directory', new_resource.log_directory.to_s)
      is_new_log_period = new_or_empty_value?(doc.root, 'SITE/logFile/@period', new_resource.log_period.to_s)
      is_new_log_trunc = new_or_empty_value?(doc.root, 'SITE/logFiles/@truncateSize', new_resource.log_truncsize.to_s)
      is_new_application_pool = new_value?(doc.root, 'SITE/site/application/@applicationPool', new_resource.application_pool)

      if (new_resource.bindings && is_new_bindings)
        was_updated = true
        cmd = "#{appcmd(node)} set site /site.name:\"#{new_resource.site_name}\""
        cmd << " /bindings:\"#{new_resource.bindings}\""
        shell_out!(cmd)
        new_resource.updated_by_last_action(true)
      elsif (((new_resource.port || new_resource.host_header || new_resource.protocol) && is_new_port_host_provided) && !new_resource.bindings)
        was_updated = true
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /bindings:#{new_resource.protocol}/*:#{new_resource.port}:#{new_resource.host_header}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
        new_resource.updated_by_last_action(true)
      end

      if new_resource.application_pool && is_new_application_pool
        was_updated = true
        cmd = "#{appcmd(node)} set app \"#{new_resource.site_name}/\" /applicationPool:\"#{new_resource.application_pool}\""
        Chef::Log.debug(cmd)
        shell_out!(cmd,  returns: [0, 42])
      end
      
      if new_resource.path && is_new_physical_path
        was_updated = true
        cmd = "#{appcmd(node)} set vdir \"#{new_resource.site_name}/\""
        cmd << " /physicalPath:\"#{windows_cleanpath(new_resource.path)}\""
        Chef::Log.debug(cmd)
        shell_out!(cmd)
      end

      if new_resource.site_id && is_new_site_id
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /id:#{new_resource.site_id}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
        new_resource.updated_by_last_action(true)
      end

      if new_resource.log_directory && is_new_log_directory
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /logFile.directory:#{windows_cleanpath(new_resource.log_directory)}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
        new_resource.updated_by_last_action(true)
      end

      if new_resource.log_period && is_new_log_period
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /logFile.period:#{new_resource.log_period}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
        new_resource.updated_by_last_action(true)
      end

      if new_resource.log_truncsize && is_new_log_trunc
        cmd = "#{appcmd(node)} set site \"#{new_resource.site_name}\""
        cmd << " /logFile.truncateSize:#{new_resource.log_truncsize}"
        Chef::Log.debug(cmd)
        shell_out!(cmd)
        new_resource.updated_by_last_action(true)
      end

      if was_updated
        new_resource.updated_by_last_action(true)
        Chef::Log.info("#{new_resource} configured site '#{new_resource.site_name}'")
      else
        Chef::Log.debug("#{new_resource} site - nothing to do")
      end
    else
      log "Failed to run iis_site action :config, #{cmd_current_values.stderr}" do
        level :warn
      end
    end
  end
