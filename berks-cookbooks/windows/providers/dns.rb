#
# Author:: Richard Lavey (richard.lavey@calastone.com)
# Cookbook Name:: windows
# Provider:: dns
#
# Copyright:: 2015, Calastone Ltd.
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

# See this for info on DNSCMD
# https://technet.microsoft.com/en-gb/library/cc772069.aspx#BKMK_10

include Chef::Mixin::ShellOut
include Windows::Helper

# Support whyrun
def whyrun_supported?
  true
end

action :create do
  if @current_resource.exists
    needs_change = (@new_resource.record_type != @current_resource.record_type) ||
                   (@new_resource.ttl > 0 && @new_resource.ttl != @current_resource.ttl) ||
                   (@new_resource.target.is_a?(String) && @new_resource.target != @current_resource.target) ||
                   (@new_resource.target.is_a?(Array) && !(@new_resource.target - @current_resource.target).empty?)

    if needs_change
      converge_by("Changing #{@new_resource.host_name}") do
        update_dns
      end
    else
      Chef::Log.debug("#{@new_resource.host_name} already exists - nothing to do")
    end
  else
    converge_by("Creating #{@new_resource.host_name}") do
      update_dns
    end
  end
end

action :delete do
  if @current_resource.exists
    converge_by("Deleting #{@current_resource.host_name}") do
      execute_command! 'recorddelete', "#{@current_resource.record_type} /f"
    end
  else
    Chef::Log.debug("#{@new_resource.host_name} does not exist - nothing to do")
  end
end

def load_current_resource
  # validate the new resource params : A records should be an array
  if @new_resource.record_type == 'A' && @new_resource.target.is_a?(String)
    raise 'target property must be an array for record_type A'
  end

  @current_resource = Chef::Resource::WindowsDns.new(@new_resource.name)
  @current_resource.host_name(@new_resource.host_name)
  @current_resource.dns_server(@new_resource.dns_server)

  parts = @current_resource.host_name.scan(/(\w+)\.(.*)/)
  @host = parts[0][0]
  @domain = parts[0][1]

  fetch_attributes
end

private

def fetch_attributes
  @command = locate_sysnative_cmd('dnscmd.exe')
  cmd = shell_out("#{@command} #{@current_resource.dns_server} /enumrecords #{@domain} #{@host}")
  Chef::Log.debug "dnscmd reports: #{cmd.stdout}"

  # extract values from returned text
  if cmd.stdout.include?('DNS_ERROR_NAME_DOES_NOT_EXIST')
    @current_resource.exists = false
    @current_resource.target([])
  elsif cmd.exitstatus == 0
    @current_resource.exists = true

    m = cmd.stdout.scan(/(\d+)\s(A)\s+(\d+\.\d+\.\d+\.\d+)/)
    if m.empty?
      m = cmd.stdout.scan(/(\d+)\s(CNAME)\s+((?:\w+\.)+)/)
      if m.empty?
        @current_resource.exists = false
        @current_resource.target([])
      else
        # We have a cname record
        @current_resource.record_type('CNAME')
        @current_resource.ttl(m[0][0].to_i)
        @current_resource.target(m[0][2].chomp('.'))
      end
    else
      # we have A entries
      @current_resource.record_type('A')
      @current_resource.ttl(m[0][0].to_i)
      addresses = []
      m.each do |match|
        addresses.push(match[2])
      end
      @current_resource.target(addresses)
    end
  else
    raise "dnscmd returned error #{cmd.exitstatus} : #{cmd.stderr} #{cmd.stdout}"
  end
end

def update_dns
  ttl = @new_resource.ttl if @new_resource.ttl > 0

  if @current_resource.record_type != @new_resource.record_type
    # delete current record(s) as we're changing the type
    execute_command! 'recorddelete', "#{@current_resource.record_type} /f"
  end

  if @new_resource.record_type == 'A'
    # delete existing records that are no longer defined
    (@current_resource.target - @new_resource.target).each do |address|
      Chef::Log.info "Deleting #{address}"
      execute_command! 'recorddelete', "A #{address} /f"
    end

    # add new records that don't exist
    # if ttl has changed then update all records
    addresses = if @current_resource.ttl == @new_resource.ttl
                  (@new_resource.target - @current_resource.target)
                else
                  @new_resource.target
                end
    addresses.each do |address|
      Chef::Log.info "Adding/Changing #{address}"
      execute_command! 'recordadd', "#{ttl} A #{address}"
    end
  else
    execute_command! 'recordadd', "#{ttl} CNAME #{@new_resource.target}"
  end
end

def execute_command!(mode, options)
  shell_out!("#{@command} #{@current_resource.dns_server} /#{mode} #{@domain} #{@host} #{options}")
end
