#
# Cookbook Name:: chef-vault
# Library:: chef_vault_item
#
# Author: Joshua Timberman <joshua@opscode.com>
#
# Copyright (c) 2013, Opscode, Inc.
# Copyright (c) 2014, Chef Software, Inc.
# Copyright (c) 2014, 2015 Bloomberg Finance L.P.
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

require 'chef-vault'

module ChefVaultCookbook
  # Helper method which provides a Recipe/Resource DSL for wrapping
  # creation of {ChefVault::Item}.
  # @note
  # Falls back to normal data bag item loading if the item is not
  # actually a Chef Vault item. This is controlled via
  # +node['chef-vault']['databag_fallback']+.
  # @example
  # item = chef_vault_item('secrets', 'bacon')
  # log 'Yeah buddy!' if item['_default']['type']
  # @param [String] bag Name of the data bag to load from.
  # @param [String] id Identifier of the data bag item to load.
  def chef_vault_item(bag, id)
    if ChefVault::Item.vault?(bag, id)
      ChefVault::Item.load(bag, id)
    elsif node['chef-vault']['databag_fallback']
      data_bag_item(bag, id)
    else
      raise "Trying to load a regular data bag item #{id} from #{bag}, and databag_fallback is disabled"
    end
  end

  # Helper method which provides an environment wrapper for a data bag.
  # This allows for easy access to current environment secrets inside
  # of an item.
  # @example
  # item = chef_vault_item_for_environment('secrets', 'bacon')
  # log 'Yeah buddy!' if item['type'] == 'applewood_smoked'
  # @param [String] bag Name of the data bag to load from.
  # @param [String] id Identifier of the data bag item to load.
  # @return [Hash]
  def chef_vault_item_for_environment(bag, id)
    item = chef_vault_item(bag, id)
    return {} unless item[node.chef_environment]
    item[node.chef_environment]
  end
end

Chef::Recipe.send(:include, ChefVaultCookbook)
Chef::Resource.send(:include, ChefVaultCookbook)
Chef::Provider.send(:include, ChefVaultCookbook)
