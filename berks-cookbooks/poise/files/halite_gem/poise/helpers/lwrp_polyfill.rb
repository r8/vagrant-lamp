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

require 'chef/resource'

require 'poise/utils/resource_provider_mixin'


module Poise
  module Helpers
    # A resource and provider mixin to add back some compatability with Chef's
    # LWRPBase classes.
    #
    # @since 1.0.0
    module LWRPPolyfill
      include Poise::Utils::ResourceProviderMixin

      # Provide default_action and actions like LWRPBase but better equipped for subclassing.
      module Resource
        def initialize(*args)
          super
          # Try to not stomp on stuff if already set in a parent. Coerce @action
          # to an array because this behavior may change in the future in Chef.
          @action = self.class.default_action if Array(@action) == [:nothing]
          (@allowed_actions << self.class.actions).flatten!.uniq!
        end

        module ClassMethods
          # @overload default_action()
          #   Get the default action for this resource class. If no explicit
          #   default is set, the first action in the list will be used.
          #   @see #actions
          #   @return [Array<Symbol>]
          # @overload default_action(name)
          #   Set the default action for this resource class. If this action is
          #   not already allowed, it will be added.
          #   @note It is idiomatic to use {#actions} instead, with the first
          #     action specified being the default.
          #   @param name [Symbol, Array<Symbol>] Name of the action(s).
          #   @return [Array<Symbol>]
          #   @example
          #     class MyApp < Chef::Resource
          #       include Poise
          #       default_action(:install)
          #     end
          def default_action(name=nil)
            if name
              name = Array(name).flatten.map(&:to_sym)
              @default_action = name
              actions(*name)
            end
            if @default_action
              @default_action
            elsif respond_to?(:superclass) && superclass != Chef::Resource && superclass.respond_to?(:default_action) && superclass.default_action && Array(superclass.default_action) != %i{nothing}
              superclass.default_action
            elsif first_non_nothing = actions.find {|action| action != :nothing }
              [first_non_nothing]
            else
              %i{nothing}
            end
          end

          # @overload actions()
          #   Get all actions allowed for this resource class. This includes
          #   any actions allowed on parent classes.
          #   @return [Array<Symbol>]
          # @overload actions(*names)
          #   Set actions as allowed for this resource class. These must
          #   correspond with action methods in the provider class(es).
          #   @param names [Array<Symbol>] One or more actions to set.
          #   @return [Array<Symbol>]
          #   @example
          #     class MyApp < Chef::Resource
          #       include Poise
          #       actions(:install, :uninstall)
          #     end
          def actions(*names)
            @actions ||= ( respond_to?(:superclass) && superclass.respond_to?(:actions) && superclass.actions.dup ) || ( respond_to?(:superclass) && superclass != Chef::Resource && superclass.respond_to?(:allowed_actions) && superclass.allowed_actions.dup ) || []
            (@actions << names).tap {|actions| actions.flatten!; actions.uniq! }
          end

          # Create a resource property (née attribute) on this resource class.
          # This follows the same usage as the helper of the same name in Chef
          # LWRPs.
          #
          # @param name [Symbol] Name of the property.
          # @param opts [Hash<Symbol, Object>] Validation options and flags.
          # @return [void]
          # @example
          #   class MyApp < Chef::Resource
          #     include Poise
          #     attribute(:path, name_attribute: true)
          #     attribute(:port, kind_of: Integer, default: 8080)
          #   end
          def attribute(name, opts={})
            # Freeze the default value. This is done upstream too in Chef 12.5+.
            opts[:default].freeze if opts && opts[:default]
            # Ruby 1.8 can go to hell.
            define_method(name) do |arg=nil, &block|
              arg = block if arg.nil? # Try to allow passing either.
              set_or_return(name, arg, opts)
            end
          end

          # For forward compat with Chef 12.5+.
          alias_method :property, :attribute

          def included(klass)
            super
            klass.extend(ClassMethods)
          end
        end

        extend ClassMethods
      end

      # Helper to handle load_current_resource for direct subclasses of Provider
      module Provider
        module LoadCurrentResource
          def load_current_resource
            @current_resource = if new_resource
              new_resource.class.new(new_resource.name, run_context)
            else
              # Better than nothing, subclass can overwrite anyway.
              Chef::Resource.new(nil, run_context)
            end
          end
        end

        # @!classmethods
        module ClassMethods
          def included(klass)
            super
            klass.extend(ClassMethods)

            # Mask Chef::Provider#load_current_resource because it throws NotImplementedError.
            if klass.is_a?(Class) && klass.superclass == Chef::Provider
              klass.send(:include, LoadCurrentResource)
            end

            # Reinstate the Chef DSL, removed in Chef 12.
            klass.send(:include, Chef::DSL::Recipe)
          end
        end

        extend ClassMethods
      end
    end
  end
end
