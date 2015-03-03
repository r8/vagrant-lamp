#
# Cookbook Name:: resource-control
# Resource:: project
#
# Copyright 2012, Wanelo, Inc.
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
require 'fileutils'
require 'digest/md5'

actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :comment, :kind_of => [String, NilClass], :default => nil
attribute :users, :kind_of => [String, Array, NilClass], :default => nil

attribute :project_limits, :kind_of => [Hash, NilClass], :default => nil
attribute :task_limits, :kind_of => [Hash, NilClass], :default => nil
attribute :process_limits, :kind_of => [Hash, NilClass], :default => nil



# Save a checksum out to a file, for future chef runs
#
def save_checksum
  Chef::Log.debug("Saving checksum for project #{self.name}: #{self.checksum}")
  ::FileUtils.mkdir_p(Chef::Config.checksum_path)
  f = ::File.new(checksum_file, 'w')
  f.write self.checksum
end

# Load current resource from checksum file and projects database.
# This should only ever be called on @current_resource, never on new_resource.
#
def load
  @checksum ||= ::File.exists?(checksum_file) ? ::File.read(checksum_file) : ''
  Chef::Log.debug("Loaded checksum for project #{self.name}: #{@checksum}")

  project_from_db = Mixlib::ShellOut.new("projects -l #{self.name}")
  project_from_db.run_command
  @current_attribs = project_from_db.stdout
end

def checksum
  @checksum ||= Digest::MD5.hexdigest("#{self.comment}#{self.users.inspect}#{self.project_limits.to_s}#{self.task_limits.to_s}#{self.process_limits.to_s}")
end

def checksum_file
  "#{Chef::Config.checksum_path}/solaris-project--#{self.name}"
end

# Check whether @current_resource includes a limit key.
# Do not call this on new_resources.
#
def includes?(key)
  @current_attribs.include?(key)
end
