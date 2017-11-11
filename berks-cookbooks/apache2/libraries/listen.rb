# encoding: utf-8
#
# Cookbook:: apache2
# Libraries:: listen
#
# Copyright:: 2015, Ontario Systems, LLC
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
module Apache2
  # Provides method to convert node['apache']['listen_ports'] and node['apache']['listen_addresses'] into new node['apache']['listen']
  module Listen
    # @param node [Chef::Node] the chef node
    # @return [Hash] a hash indexed by address where the values are arrays of ports to listen to
    def merge_listen_attributes(node)
      (Apache2::Listen.converted_listen_ports_and_addresses(node) + node['apache']['listen']).uniq
    end

    module_function :merge_listen_attributes

    private_class_method

    def self.converted_listen_ports_and_addresses(node)
      return [] unless node['apache']['listen_ports'] || node['apache']['listen_addresses']
      Chef::Log.warn "node['apache']['listen_ports'] and node['apache']['listen_addresses'] are deprecated in favor of node['apache']['listen']. Please adjust your cookbooks"

      # Defaults to * for addresses or 80 / 443 for ports if not specified
      (node['apache']['listen_addresses'] || %w(*)).uniq.each_with_object([]) do |address, listen|
        (node['apache']['listen_ports'] || %w(80 443)).uniq.each do |port|
          listen << "#{address}:#{port}"
        end
      end
    end
  end
end
