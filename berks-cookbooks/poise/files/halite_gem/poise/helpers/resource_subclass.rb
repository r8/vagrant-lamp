#
# Copyright 2015-2016, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

begin
  require 'chef/chef_class'
rescue LoadError
  # This space left intentionally blank, fallback is below.
end

require 'poise/error'
require 'poise/helpers/resource_name'


module Poise
  module Helpers
    # A resource mixin to help subclass existing resources.
    #
    # @since 2.3.0
    module ResourceSubclass
      include ResourceName

      module ClassMethods
        def subclass_providers!(superclass_resource_name=nil, resource_name: nil)
          resource_name ||= self.resource_name
          superclass_resource_name ||= if superclass.respond_to?(:resource_name)
            superclass.resource_name
          elsif superclass.respond_to?(:dsl_name)
            superclass.dsl_name
          else
            raise Poise::Error.new("Unable to determine superclass resource name for #{superclass}. Please specify name manually via subclass_providers!('name').")
          end.to_sym
          # Deal with the node maps.
          node_maps = {}
          node_maps['handler map'] = Chef.provider_handler_map if defined?(Chef.provider_handler_map)
          node_maps['priority map'] = if defined?(Chef.provider_priority_map)
            Chef.provider_priority_map
          else
            require 'chef/platform/provider_priority_map'
            Chef::Platform::ProviderPriorityMap.instance.send(:priority_map)
          end
          # Patch anything in the descendants tracker.
          Chef::Provider.descendants.each do |provider|
            node_maps["#{provider} node map"] = provider.node_map if defined?(provider.node_map)
          end if defined?(Chef::Provider.descendants)
          node_maps.each do |map_name, node_map|
            map = node_map.respond_to?(:map, true) ? node_map.send(:map) : node_map.instance_variable_get(:@map)
            if map.include?(superclass_resource_name)
              Chef::Log.debug("[#{self}] Copying provider mapping in #{map_name} from #{superclass_resource_name} to #{resource_name}")
              map[resource_name] = map[superclass_resource_name].dup
            end
          end
          # Add any needed equivalent names.
          if superclass.respond_to?(:subclass_resource_equivalents)
            subclass_resource_equivalents.concat(superclass.subclass_resource_equivalents)
          else
            subclass_resource_equivalents << superclass_resource_name
          end
          subclass_resource_equivalents.uniq!
        end

        # An array of names for the resources this class is equivalent to for
        # the purposes of provider resolution.
        #
        # @return [Array<Symbol>]
        def subclass_resource_equivalents
          @subclass_resource_names ||= [resource_name.to_sym]
        end

        # @api private
        def included(klass)
          super
          klass.extend(ClassMethods)
        end
      end

      extend ClassMethods
    end

  end
end
