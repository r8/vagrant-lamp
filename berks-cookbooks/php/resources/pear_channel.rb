#
# Author:: Seth Chisamore <schisamo@chef.io>
# Author:: Jennifer Davis <sigje@chef.io>
# Cookbook:: php
# Resource:: pear_channel
#
# Copyright:: 2011-2017, Chef Software, Inc <legal@chef.io>
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

property :channel_xml, kind_of: String
property :channel_name, kind_of: String, name_property: true
property :pear, kind_of: String, default: lazy { node['php']['pear'] }
# TODO: add authenticated channel support!
# property :username, :kind_of => String
# property :password, :kind_of => String

action :discover do
  unless exists?
    Chef::Log.info("Discovering pear channel #{new_resource}")
    execute "#{new_resource.pear} channel-discover #{new_resource.channel_name}" do
      action :run
    end
  end
end

action :add do
  unless exists?
    Chef::Log.info("Adding pear channel #{new_resource} from #{new_resource.channel_xml}")
    execute "#{new_resource.pear} channel-add #{new_resource.channel_xml}" do
      action :run
    end
  end
end

action :update do
  if exists?
    update_needed = false
    begin
      update_needed = true if shell_out("#{new_resource.pear} search -c #{new_resource.channel_name} NNNNNN").stdout =~ /channel-update/
    rescue Chef::Exceptions::CommandTimeout
      # CentOS can hang on 'pear search' if a channel needs updating
      Chef::Log.info("Timed out checking if channel-update needed...forcing update of pear channel #{new_resource}")
      update_needed = true
    end
    if update_needed
      description = "update pear channel #{new_resource}"
      converge_by(description) do
        Chef::Log.info("Updating pear channel #{new_resource}")
        shell_out!("#{new_resource.pear} channel-update #{new_resource.channel_name}")
      end
    end
  end
end

action :remove do
  if exists?
    Chef::Log.info("Deleting pear channel #{new_resource}")
    execute "#{new_resource.pear} channel-delete #{new_resource.channel_name}" do
      action :run
    end
  end
end

action_class do
  def exists?
    shell_out!("#{new_resource.pear} channel-info #{new_resource.channel_name}")
    true
  rescue Mixlib::ShellOut::ShellCommandFailed
    false
  end
end
