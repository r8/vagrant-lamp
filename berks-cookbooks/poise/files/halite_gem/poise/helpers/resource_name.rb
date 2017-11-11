#
# Copyright 2013-2016, Noah Kantrowitz
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

require 'chef/mixin/convert_to_class_name'


module Poise
  module Helpers
    # A resource mixin to automatically set @resource_name.
    #
    # @since 1.0.0
    # @example
    #   class MyResource < Chef::Resource
    #     include Poise::Helpers::ResourceName
    #     provides(:my_resource)
    #   end
    module ResourceName
      def initialize(*args)
        super
        # If provides() was explicitly set, unconditionally set @resource_name.
        # This helps when subclassing core Chef resources which set it
        # themselves in #initialize.
        if self.class.resource_name(false)
          @resource_name = self.class.resource_name
        else
          @resource_name ||= self.class.resource_name
        end
      end

      # @!classmethods
      module ClassMethods
        # Set the DSL name for the the resource class.
        #
        # @param name [Symbol] Name of the resource.
        # @return [void]
        # @example
        #   class MyResource < Chef::Resource
        #     include Poise::Resource::ResourceName
        #     provides(:my_resource)
        #   end
        def provides(name, *args, &block)
          # Patch self.constantize so this can cope with anonymous classes.
          # This does require that the anonymous class define self.name though.
          if self.name && respond_to?(:constantize)
            old_constantize = instance_method(:constantize)
            define_singleton_method(:constantize) do |const_name|
              ( const_name == self.name ) ? self : old_constantize.bind(self).call(const_name)
            end
          end
          # Store the name for later.
          @provides_name ||= name
          # Call the original if present. The defined? is for old Chef.
          super(name, *args, &block) if defined?(super)
        end

        # Retreive the DSL name for the resource class. If not set explicitly
        # via {provides} this will try to auto-detect based on the class name.
        #
        # @param auto [Boolean] Try to auto-detect based on class name.
        # @return [Symbol]
        def resource_name(auto=true)
          # In 12.4+ we need to proxy through the super class for setting.
          return super(auto) if defined?(super) && (auto.is_a?(Symbol) || auto.is_a?(String))
          return @provides_name unless auto
          @provides_name || if name
            mode = if name.start_with?('Chef::Resource')
              [name, 'Chef::Resource']
            else
              [name.split('::').last]
            end
            Chef::Mixin::ConvertToClassName.convert_to_snake_case(*mode).to_sym
          elsif defined?(super)
            # No name on 12.4+ probably means this is an LWRP, use super().
            super()
          end
        end

        # Used by Resource#to_text to find the human name for the resource.
        #
        # @api private
        def dsl_name
          resource_name.to_s
        end

        def included(klass)
          super
          klass.extend(ClassMethods)
        end
      end

      extend ClassMethods
    end
  end
end
