#
# Cookbook Name:: resource-control
# Provider:: project
#
# Copyright 2011, Wanelo, Inc.
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

def load_current_resource
  @current_project = Chef::Resource::ResourceControlProject.new(new_resource.name)
  @current_project.load
  @limits ||= {}
end

action :create do
  validate!

  create_or_update_project
  configure_limits_for 'project', new_resource.project_limits
  configure_limits_for 'task', new_resource.task_limits
  configure_limits_for 'process', new_resource.process_limits
  clear_limits
  set_limits

  new_resource.updated_by_last_action(project_changed?)

  new_resource.save_checksum
end


private

def project
  @project ||= new_resource.name
end

def project_exists?
  cmd = Mixlib::ShellOut.new("projects -l #{project}")
  cmd.run_command
  begin
    cmd.error!
    true
  rescue Exception
    false
  end
end

def project_changed?
  @current_project.checksum != new_resource.checksum
end

def validate!
  raise ArgumentError.new('name may not include spaces') if new_resource.name.match(/\s/)
  raise ArgumentError.new('comment may not include colons or newlines') if new_resource.comment &&
      new_resource.comment.match(/(:|\n)/)
end

# create a new project or update its comment
def create_or_update_project
  Chef::Log.debug("creating or updating project : #{project}, users: #{new_resource.users}, comment: #{new_resource.comment}")

  command = []
  command << (project_exists? ? 'projmod' : 'projadd')
  command << "-c \"#{new_resource.comment}\""
  command << "-U \"#{Array(new_resource.users).join(',')}\"" if new_resource.users
  command << project

  Chef::Log.debug("executing command: #{command.join(' ')}")

  cmd = Mixlib::ShellOut.new(command.join(' '))
  cmd.run_command
  cmd.error!
end

# write out current list of limits to projects database
def set_limits
  unless @limits.keys.empty?
    Chef::Log.debug("setting limits for project : #{project} : #{@limits.inspect}")

    command = %w[projmod]
    @limits.each_pair do |control, limits|
      command << '-K'
      command << "\"#{control}=#{limits}\""
    end
    command << project

    Chef::Log.debug("executing command: #{command.join(' ')}")

    cmd = Mixlib::ShellOut.new(command.join(' '))
    cmd.run_command
    cmd.error!
  end
end

def configure_limits_for(type, limit_hash)
  return unless limit_hash
  limit_hash.each_pair do |limit, values|
    @limits["#{type}.#{limit}"] = values_to_limits(values)
  end
end

def values_to_limits(values)
  values = [values].flatten.map { |v| value_to_limit(v) }
  values.join(',')
end

def value_to_limit(value)
  v = []
  if value.is_a?(Hash)
    value = Mash.new(value)
    v << (value['level'].nil? ? 'privileged' : value['level'])
    v << value['value']
    if value['deny']
      v << 'deny'
    elsif value['signal']
      v << "signal=#{value['signal']}"
    else
      v << 'none'
    end
  else
    v << 'privileged'
    v << value
    v << 'none'
  end
  "(#{v.join(',')})"
end

# remove all currently set limits, in case we are updating an existing project with empty values
def clear_limits
  if @limits.keys.empty? && project_changed?
    Chef::Log.debug("clearing all limits for project : #{project}")
    limits = %w[ project.cpu-cap            project.cpu-shares          project.max-crypto-memory
                 project.max-locked-memory  project.max-msg-ids         project.max-port-ids
                 project.max-processes      project.max-sem-ids         project.max-shm-ids
                 project.max-shm-memory     project.max-lwps            project.max-tasks
                 project.max-contracts      task.max-cpu-time           task.max-lwps
                 task.max-processes         process.max-cpu-time        process.max-file-descriptor
                 process.max-file-size      process.max-core-size       process.max-data-size
                 process.max-stack-size     process.max-address-space   process.max-port-events
                 process.max-sem-nsems      process.max-sem-ops         process.max-msg-qbytes
                 process.max-msg-messages ].select { |k| @current_project.includes?(k) }.map { |l| "-K \"#{l}\"" }.join(' ')
    return if limits.empty?
    cmd = Mixlib::ShellOut.new("projmod -r #{limits} #{project}")
    cmd.run_command
    cmd.error!
  end
end
