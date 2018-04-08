#
# Author:: Paul Mooring (<paul@chef.io>)
# Cookbook:: windows
# Resource:: task
#
# Copyright:: 2012-2018, Chef Software, Inc.
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

# Passwords can't be loaded for existing tasks, making :modify both confusing
# and not very useful

require 'chef/mixin/shell_out'
require 'rexml/document'

include Chef::Mixin::PowershellOut

property :task_name, String, name_property: true, regex: [/\A[^\/\:\*\?\<\>\|]+\z/]
property :command, String
property :cwd, String
property :user, String, default: 'SYSTEM'
property :password, String
property :run_level, equal_to: [:highest, :limited], default: :limited
property :force, [true, false], default: false
property :interactive_enabled, [true, false], default: false
property :frequency_modifier, [Integer, String], default: 1
property :frequency, equal_to: [:minute,
                                :hourly,
                                :daily,
                                :weekly,
                                :monthly,
                                :once,
                                :on_logon,
                                :onstart,
                                :on_idle], default: :hourly
property :start_day, String
property :start_time, String
property :day, [String, Integer]
property :months, String
property :idle_time, Integer
property :exists, [true, false], desired_state: true
property :status, Symbol, desired_state: true
property :enabled, [true, false], desired_state: true

def load_task_hash(task_name)
  Chef::Log.debug 'Looking for existing tasks'

  # we use powershell_out here instead of powershell_out! because a failure implies that the task does not exist
  task_script = <<-EOH
    [Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
    schtasks /Query /FO LIST /V /TN \"#{task_name}\"
  EOH
  output = powershell_out(task_script).stdout.force_encoding('UTF-8')
  if output.empty?
    task = false
  else
    task = {}

    output.split("\n").map! { |line| line.split(':', 2).map!(&:strip) }.each do |field|
      if field.is_a?(Array) && field[0].respond_to?(:to_sym)
        task[field[0].gsub(/\s+/, '').to_sym] = field[1]
      end
    end
  end

  task
end

load_current_value do |desired|
  pathed_task_name = desired.task_name.start_with?('\\') ? desired.task_name : "\\#{desired.task_name}"

  task_hash = load_task_hash pathed_task_name

  task_name pathed_task_name
  if task_hash.respond_to?(:[]) && task_hash[:TaskName] == pathed_task_name
    exists true
    status :running if task_hash[:Status] == 'Running'
    enabled task_hash[:ScheduledTaskState] == 'Enabled' ? true : false
    cwd task_hash[:StartIn] unless task_hash[:StartIn] == 'N/A'
    command task_hash[:TaskToRun]
    user task_hash[:RunAsUser]
  else
    exists false
  end
end

action :create do
  Chef::Log.warn('The windows_task resource has been moved into the chef-client itself as of chef-client 13. This resource will be removed from the windows cookbook Sept 2018 (18 months after the Chef 13 release).')

  if current_resource.exists && !(task_need_update? || new_resource.force)
    Chef::Log.info "#{new_resource} task already exists - nothing to do"
  else
    converge_by("creating a new scheduled task #{new_resource.task_name}") do
      validate_user_and_password
      validate_interactive_setting
      validate_create_frequency_modifier
      validate_create_day
      validate_create_months
      validate_idle_time

      options = {}
      options['F'] = '' if new_resource.force || task_need_update?
      options['SC'] = schedule
      options['MO'] = new_resource.frequency_modifier if frequency_modifier_allowed
      options['I']  = new_resource.idle_time unless new_resource.idle_time.nil?
      options['SD'] = new_resource.start_day unless new_resource.start_day.nil?
      options['ST'] = new_resource.start_time unless new_resource.start_time.nil?
      options['TR'] = new_resource.command
      options['RU'] = new_resource.user
      options['RP'] = new_resource.password if use_password?
      options['RL'] = 'HIGHEST' if new_resource.run_level == :highest
      options['IT'] = '' if new_resource.interactive_enabled
      options['D'] = new_resource.day if new_resource.day
      options['M'] = new_resource.months unless new_resource.months.nil?

      run_schtasks 'CREATE', options
      cwd(new_resource.cwd) if new_resource.cwd
    end
  end
end

action :run do
  Chef::Log.warn('The windows_task resource has been moved into the chef-client itself as of chef-client 13. This resource will be removed from the windows cookbook Sept 2018 (18 months after the Chef 13 release).')

  if current_resource.exists
    if current_resource.status == :running
      Chef::Log.info "#{new_resource} task is currently running, skipping run"
    else
      converge_by("running scheduled task #{new_resource.task_name}") do
        run_schtasks 'RUN'
      end
    end
  else
    Chef::Log.debug "#{new_resource} task doesn't exists - nothing to do"
  end
end

action :change do
  Chef::Log.warn('The windows_task resource has been moved into the chef-client itself as of chef-client 13. This resource will be removed from the windows cookbook Sept 2018 (18 months after the Chef 13 release).')

  if current_resource.exists
    converge_by("changing scheduled task #{new_resource.task_name}") do
      validate_user_and_password
      validate_interactive_setting

      options = {}
      options['TR'] = new_resource.command if new_resource.command
      options['RU'] = new_resource.user if new_resource.user
      options['RP'] = new_resource.password if new_resource.password
      options['SD'] = new_resource.start_day unless new_resource.start_day.nil?
      options['ST'] = new_resource.start_time unless new_resource.start_time.nil?
      options['IT'] = '' if new_resource.interactive_enabled

      run_schtasks 'CHANGE', options
      cwd(new_resource.cwd) if new_resource.cwd != current_resource.cwd
    end
  else
    Chef::Log.debug "#{new_resource} task doesn't exists - nothing to do"
  end
end

action :delete do
  Chef::Log.warn('The windows_task resource has been moved into the chef-client itself as of chef-client 13. This resource will be removed from the windows cookbook Sept 2018 (18 months after the Chef 13 release).')

  if current_resource.exists
    converge_by("deleting scheduled task #{new_resource.task_name}") do
      # always need to force deletion
      run_schtasks 'DELETE', 'F' => ''
    end
  else
    Chef::Log.debug "#{new_resource} task doesn't exists - nothing to do"
  end
end

action :end do
  Chef::Log.warn('The windows_task resource has been moved into the chef-client itself as of chef-client 13. This resource will be removed from the windows cookbook Sept 2018 (18 months after the Chef 13 release).')

  if current_resource.exists
    if current_resource.status != :running
      Chef::Log.debug "#{new_resource} is not running - nothing to do"
    else
      converge_by("stopping scheduled task #{new_resource.task_name}") do
        run_schtasks 'END'
      end
    end
  else
    Chef::Log.fatal "#{new_resource} task doesn't exist - nothing to do"
    raise Errno::ENOENT, "#{new_resource}: task does not exist, cannot end"
  end
end

action :enable do
  Chef::Log.warn('The windows_task resource has been moved into the chef-client itself as of chef-client 13. This resource will be removed from the windows cookbook Sept 2018 (18 months after the Chef 13 release).')

  if current_resource.exists
    if current_resource.enabled
      Chef::Log.debug "#{new_resource} already enabled - nothing to do"
    else
      converge_by("enabling scheduled task #{new_resource.task_name}") do
        run_schtasks 'CHANGE', 'ENABLE' => ''
      end
    end
  else
    Chef::Log.fatal "#{new_resource} task doesn't exist - nothing to do"
    raise Errno::ENOENT, "#{new_resource}: task does not exist, cannot enable"
  end
end

action :disable do
  Chef::Log.warn('The windows_task resource has been moved into the chef-client itself as of chef-client 13. This resource will be removed from the windows cookbook Sept 2018 (18 months after the Chef 13 release).')

  if current_resource.exists
    if current_resource.enabled
      converge_by("disabling scheduled task #{new_resource.task_name}") do
        run_schtasks 'CHANGE', 'DISABLE' => ''
      end
    else
      Chef::Log.debug "#{new_resource} already disabled - nothing to do"
    end
  else
    Chef::Log.debug "#{new_resource} task doesn't exist - nothing to do"
  end
end

action_class do
  # rubocop:disable Style/StringLiteralsInInterpolation
  def run_schtasks(task_action, options = {})
    cmd = "schtasks /#{task_action} /TN \"#{new_resource.task_name}\" "
    options.keys.each do |option|
      cmd += "/#{option} "
      cmd += "\"#{options[option].to_s.gsub('"', "\\\"")}\" " unless options[option] == ''
    end
    Chef::Log.debug('running: ')
    Chef::Log.debug("    #{cmd}")
    shell_out!(cmd, returns: [0])
  end
  # rubocop:enable Style/StringLiteralsInInterpolation

  def task_need_update?
    # gsub needed as schtasks converts single quotes to double quotes on creation
    current_resource.command != new_resource.command.tr("'", '"') ||
      current_resource.user != new_resource.user
  end

  def cwd(folder)
    Chef::Log.debug 'looking for existing tasks'

    # we use shell_out here instead of shell_out! because a failure implies that the task does not exist
    xml_cmd = shell_out("schtasks /Query /TN \"#{new_resource.task_name}\" /XML")

    return if xml_cmd.exitstatus != 0

    doc = REXML::Document.new(xml_cmd.stdout)

    Chef::Log.debug 'Removing former CWD if any'
    doc.root.elements.delete('Actions/Exec/WorkingDirectory')

    unless folder.nil?
      Chef::Log.debug 'Setting CWD as #folder'
      cwd_element = REXML::Element.new('WorkingDirectory')
      cwd_element.add_text(folder)
      exec_element = doc.root.elements['Actions/Exec']
      exec_element.add_element(cwd_element)
    end

    temp_task_file = ::File.join(ENV['TEMP'], 'windows_task.xml')
    begin
      ::File.open(temp_task_file, 'w:UTF-16LE') do |f|
        doc.write(f)
      end

      options = {}
      options['RU'] = new_resource.user if new_resource.user
      options['RP'] = new_resource.password if new_resource.password
      options['IT'] = '' if new_resource.interactive_enabled
      options['XML'] = temp_task_file

      run_schtasks('DELETE', 'F' => '')
      run_schtasks('CREATE', options)
    ensure
      ::File.delete(temp_task_file)
    end
  end

  SYSTEM_USERS = ['NT AUTHORITY\SYSTEM', 'SYSTEM', 'NT AUTHORITY\LOCALSERVICE', 'NT AUTHORITY\NETWORKSERVICE', 'BUILTIN\USERS', 'USERS'].freeze

  def validate_user_and_password
    return unless new_resource.user && use_password?
    return unless new_resource.password.nil?
    Chef::Log.fatal "#{new_resource.task_name}: Can't specify a non-system user without a password!"
  end

  def validate_interactive_setting
    return unless new_resource.interactive_enabled && new_resource.password.nil?
    Chef::Log.fatal "#{new_resource} did not provide a password when attempting to set interactive/non-interactive."
  end

  def validate_create_day
    return unless new_resource.day
    unless [:weekly, :monthly].include?(new_resource.frequency)
      raise 'day attribute is only valid for tasks that run weekly or monthly'
    end
    return unless new_resource.day.is_a?(String) && new_resource.day.to_i.to_s != new_resource.day
    days = new_resource.day.split(',')
    days.each do |day|
      unless ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun', '*'].include?(day.strip.downcase)
        raise 'day attribute invalid.  Only valid values are: MON, TUE, WED, THU, FRI, SAT, SUN and *.  Multiple values must be separated by a comma.'
      end
    end
  end

  def validate_create_months
    return unless new_resource.months
    unless [:monthly].include?(new_resource.frequency)
      raise 'months attribute is only valid for tasks that run monthly'
    end
    return unless new_resource.months.is_a? String
    months = new_resource.months.split(',')
    months.each do |month|
      unless ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC', '*'].include?(month.strip.upcase)
        raise 'months attribute invalid. Only valid values are: JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC and *. Multiple values must be separated by a comma.'
      end
    end
  end

  def validate_idle_time
    return unless new_resource.frequency == :on_idle
    return if new_resource.idle_time.to_i > 0 && new_resource.idle_time.to_i <= 999
    raise "idle_time value #{new_resource.idle_time} is invalid.  Valid values for :on_idle frequency are 1 - 999."
  end

  def validate_create_frequency_modifier
    # Currently is handled in create action 'frequency_modifier_allowed' line. Does not allow for frequency_modifier for once,onstart,onlogon,onidle
    # Note that 'OnEvent' is not a supported frequency.
    return if new_resource.frequency.nil? || new_resource.frequency_modifier.nil?
    case new_resource.frequency
    when :minute
      unless new_resource.frequency_modifier.to_i > 0 && new_resource.frequency_modifier.to_i <= 1439
        raise "frequency_modifier value #{new_resource.frequency_modifier} is invalid.  Valid values for :minute frequency are 1 - 1439."
      end
    when :hourly
      unless new_resource.frequency_modifier.to_i > 0 && new_resource.frequency_modifier.to_i <= 23
        raise "frequency_modifier value #{new_resource.frequency_modifier} is invalid.  Valid values for :hourly frequency are 1 - 23."
      end
    when :daily
      unless new_resource.frequency_modifier.to_i > 0 && new_resource.frequency_modifier.to_i <= 365
        raise "frequency_modifier value #{new_resource.frequency_modifier} is invalid.  Valid values for :daily frequency are 1 - 365."
      end
    when :weekly
      unless new_resource.frequency_modifier.to_i > 0 && new_resource.frequency_modifier.to_i <= 52
        raise "frequency_modifier value #{new_resource.frequency_modifier} is invalid.  Valid values for :weekly frequency are 1 - 52."
      end
    when :monthly
      unless ('1'..'12').to_a.push('FIRST', 'SECOND', 'THIRD', 'FOURTH', 'LAST', 'LASTDAY').include?(new_resource.frequency_modifier.to_s.upcase)
        raise "frequency_modifier value #{new_resource.frequency_modifier} is invalid.  Valid values for :monthly frequency are 1 - 12, 'FIRST', 'SECOND', 'THIRD', 'FOURTH', 'LAST', 'LASTDAY'."
      end
    end
  end

  def use_password?
    @use_password ||= !SYSTEM_USERS.include?(new_resource.user.upcase)
  end

  def schedule
    case new_resource.frequency
    when :on_logon
      'ONLOGON'
    when :on_idle
      'ONIDLE'
    else
      new_resource.frequency
    end
  end

  def frequency_modifier_allowed
    case new_resource.frequency
    when :minute, :hourly, :daily, :weekly
      true
    when :monthly
      new_resource.months.nil? || %w(FIRST SECOND THIRD FOURTH LAST LASTDAY).include?(new_resource.frequency_modifier)
    else
      false
    end
  end
end
