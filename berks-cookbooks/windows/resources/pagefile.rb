#
# Author:: Kevin Moser (<kevin.moser@nordstrom.com>)
# Cookbook:: windows
# Resource:: pagefile
#
# Copyright:: 2012-2017, Nordstrom, Inc.
# Copyright:: 2017, Chef Software, Inc.
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

property :name, String, name_property: true
property :system_managed, [true, false]
property :automatic_managed, [true, false], default: false
property :initial_size, Integer
property :maximum_size, Integer

include Chef::Mixin::ShellOut
include Windows::Helper

action :set do
  pagefile = new_resource.name
  initial_size = new_resource.initial_size
  maximum_size = new_resource.maximum_size
  system_managed = new_resource.system_managed
  automatic_managed = new_resource.automatic_managed

  if automatic_managed
    set_automatic_managed unless automatic_managed?
  else
    unset_automatic_managed if automatic_managed?

    # Check that the resource is not just trying to unset automatic managed, if it is do nothing more
    if (initial_size && maximum_size) || system_managed
      validate_name
      create(pagefile) unless exists?(pagefile)

      if system_managed
        set_system_managed(pagefile) unless max_and_min_set?(pagefile, 0, 0)
      else
        unless max_and_min_set?(pagefile, initial_size, maximum_size)
          set_custom_size(pagefile, initial_size, maximum_size)
        end
      end
    end
  end
end

action :delete do
  validate_name
  pagefile = new_resource.name
  delete(pagefile) if exists?(pagefile)
end

action_class do
  def validate_name
    return if /^.:.*.sys/ =~ new_resource.name
    raise "#{new_resource.name} does not match the format DRIVE:\\path\\file.sys for pagefiles. Example: C:\\pagefile.sys"
  end

  def exists?(pagefile)
    @exists ||= begin
      Chef::Log.debug("Checking if #{pagefile} exists by runing: #{wmic} pagefileset where SettingID=\"#{get_setting_id(pagefile)}\" list /format:list")
      cmd = shell_out("#{wmic} pagefileset where SettingID=\"#{get_setting_id(pagefile)}\" list /format:list", returns: [0])
      cmd.stderr.empty? && (cmd.stdout =~ /SettingID=#{get_setting_id(pagefile)}/i)
    end
  end

  def max_and_min_set?(pagefile, min, max)
    @max_and_min_set ||= begin
      Chef::Log.debug("Checking if #{pagefile} min: #{min} and max #{max} are set")
      cmd = shell_out("#{wmic} pagefileset where SettingID=\"#{get_setting_id(pagefile)}\" list /format:list", returns: [0])
      cmd.stderr.empty? && (cmd.stdout =~ /InitialSize=#{min}/i) && (cmd.stdout =~ /MaximumSize=#{max}/i)
    end
  end

  def create(pagefile)
    converge_by("create pagefile #{pagefile}") do
      Chef::Log.debug("Running #{wmic} pagefileset create name=\"#{win_friendly_path(pagefile)}\"")
      cmd = shell_out("#{wmic} pagefileset create name=\"#{win_friendly_path(pagefile)}\"")
      check_for_errors(cmd.stderr)
    end
  end

  def delete(pagefile)
    converge_by("remove pagefile #{pagefile}") do
      Chef::Log.debug("Running #{wmic} pagefileset where SettingID=\"#{get_setting_id(pagefile)}\" delete")
      cmd = shell_out("#{wmic} pagefileset where SettingID=\"#{get_setting_id(pagefile)}\" delete")
      check_for_errors(cmd.stderr)
    end
  end

  def automatic_managed?
    @automatic_managed ||= begin
      Chef::Log.debug('Checking if pagefiles are automatically managed')
      cmd = shell_out("#{wmic} computersystem where name=\"%computername%\" get AutomaticManagedPagefile /format:list")
      cmd.stderr.empty? && (cmd.stdout =~ /AutomaticManagedPagefile=TRUE/i)
    end
  end

  def set_automatic_managed
    converge_by('set pagefile to Automatic Managed') do
      Chef::Log.debug("Running #{wmic} computersystem where name=\"%computername%\" set AutomaticManagedPagefile=True")
      cmd = shell_out("#{wmic} computersystem where name=\"%computername%\" set AutomaticManagedPagefile=True")
      check_for_errors(cmd.stderr)
    end
  end

  def unset_automatic_managed
    converge_by('set pagefile to User Managed') do
      Chef::Log.debug("Running #{wmic} computersystem where name=\"%computername%\" set AutomaticManagedPagefile=False")
      cmd = shell_out("#{wmic} computersystem where name=\"%computername%\" set AutomaticManagedPagefile=False")
      check_for_errors(cmd.stderr)
    end
  end

  def set_custom_size(pagefile, min, max)
    converge_by("set #{pagefile} to InitialSize=#{min} & MaximumSize=#{max}") do
      Chef::Log.debug("Running #{wmic} pagefileset where SettingID=\"#{get_setting_id(pagefile)}\" set InitialSize=#{min},MaximumSize=#{max}")
      cmd = shell_out("#{wmic} pagefileset where SettingID=\"#{get_setting_id(pagefile)}\" set InitialSize=#{min},MaximumSize=#{max}", returns: [0])
      check_for_errors(cmd.stderr)
    end
  end

  def set_system_managed(pagefile) # rubocop: disable Style/AccessorMethodName
    converge_by("set #{pagefile} to System Managed") do
      Chef::Log.debug("Running #{wmic} pagefileset where SettingID=\"#{get_setting_id(pagefile)}\" set InitialSize=0,MaximumSize=0")
      cmd = shell_out("#{wmic} pagefileset where SettingID=\"#{get_setting_id(pagefile)}\" set InitialSize=0,MaximumSize=0", returns: [0])
      check_for_errors(cmd.stderr)
    end
  end

  def get_setting_id(pagefile)
    pagefile = win_friendly_path(pagefile)
    pagefile = pagefile.split('\\')
    "#{pagefile[1]} @ #{pagefile[0]}"
  end

  def check_for_errors(stderr)
    raise stderr.chomp unless stderr.empty?
  end

  def wmic
    @wmic ||= locate_sysnative_cmd('wmic.exe')
  end
end
