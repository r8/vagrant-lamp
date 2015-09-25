#
# Author:: Joshua Timberman <joshua@getchef.com>
# Copyright:: Copyright (c) 2014, Chef Software, Inc. <legal@getchef.com>
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider/lwrp_base'
begin
  require 'chef-vault'
rescue LoadError
  Chef::Log.debug("could not load chef-vault whilst loading #{__FILE__}, it should be")
  Chef::Log.debug('available after running the chef-vault recipe.')
end

class Chef::Provider::ChefVaultSecret < Chef::Provider::LWRPBase
  use_inline_resources if defined?(:use_inline_resources)

  def whyrun_supported?
    true
  end

  action :create do
    converge_by("create #{new_resource.id} in #{new_resource.data_bag} with Chef::Vault") do
      item = ChefVault::Item.new(new_resource.data_bag, new_resource.id)
      item.raw_data = new_resource.raw_data.merge('id' => new_resource.id)
      Chef::Log.debug("#{new_resource.id} search query: '#{new_resource.search}'")
      item.search(new_resource.search)
      Chef::Log.debug("#{new_resource.clients} clients: '#{new_resource.clients}'")
      item.clients(new_resource.clients)
      Chef::Log.debug("#{new_resource.admins} admins (users): '#{new_resource.admins}'")
      item.admins(join_comma)
      item.save
    end
  end

  # this is for those who want the behavior of `knife vault create`.
  action :create_if_missing do
    action_create unless vault_item_exists?
  end

  action :delete do
    converge_by("remove #{new_resource.id} and #{new_resource.id}_keys from #{new_resource.data_bag}") do
      chef_data_bag_item new_resource.id do
        action :delete
      end
      chef_data_bag_item [new_resource.id, 'keys'].join('_') do
        action :delete
      end
    end
  end

  def load_current_resource
    begin
      Chef::Log.debug("Attempting to load #{new_resource.id} from #{new_resource.data_bag}")
      json = ::ChefVault::Item.load(new_resource.data_bag, new_resource.id)
      resource = Chef::Resource::ChefVaultSecret.new(new_resource.id)
      resource.raw_data json.to_hash
      self.current_resource = resource
    rescue Net::HTTPServerException => e
      if e.response.code == '404'
        self.current_resource = nil
      else
        raise
      end
    rescue ChefVault::Exceptions::KeysNotFound
      self.current_resource = nil
    rescue OpenSSL::PKey::RSAError
      raise "#{$!.message} - on #{Chef::Config[:client_key]}, is the vault item encrypted with this client/user?"
    end
  end

  def join_comma
    admins = new_resource.admins
    case admins
    when String
      admins
    when Array
      admins.join(',')
    end
    admins
  end

  def vault_item_exists?
    !current_resource.nil?
  end
end
