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

require 'poise/error'
require 'poise/helpers/subresources/default_containers'


module Poise
  module Helpers
    module Subresources
      # A resource mixin for child subresources.
      #
      # @since 1.0.0
      module Child
        # Little class used to fix up the display of subresources in #to_text.
        # Without this you get the full parent resource shown for @parent et al.
        # @api private
        class ParentRef
          attr_accessor :resource

          def initialize(resource)
            @resource = resource
          end

          def inspect
            to_text
          end

          def to_text
            if @resource.nil?
              'nil'
            else
              @resource.to_s
            end
          end
        end

        # @overload parent()
        #   Get the parent resource for this child. This may be nil if the
        #   resource is set to parent_optional = true.
        #   @return [Chef::Resource, nil]
        # @overload parent(val)
        #   Set the parent resource. The parent can be set as  resource
        #   object, a string (either a bare resource name or a type[name]
        #   string), or a type:name hash.
        #   @param val [String, Hash, Chef::Resource] Parent resource to set.
        #   @return [Chef::Resource, nil]
        def parent(*args)
          # Lie about this method if the parent type is true.
          if self.class.parent_type == true
            raise NoMethodError.new("undefined method `parent' for #{self}")
          end
          _parent(:parent, self.class.parent_type, self.class.parent_optional, self.class.parent_auto, self.class.parent_default, *args)
        end

        # Register ourself with parents in case this is not a nested resource.
        #
        # @api private
        def after_created
          super
          self.class.parent_attributes.each_key do |name|
            parent = self.send(name)
            parent.register_subresource(self) if parent && parent.respond_to?(:register_subresource)
          end
        end

        private

        # Generic form of the parent getter/setter.
        #
        # @since 2.0.0
        # @see #parent
        def _parent(name, parent_type, parent_optional, parent_auto, parent_default, *args)
          # Allow using a DSL symbol as the parent type.
          if parent_type.is_a?(Symbol)
            parent_type = Chef::Resource.resource_for_node(parent_type, node)
          end
          # Grab the ivar for local use.
          parent_ref = instance_variable_get(:"@#{name}")
          if !args.empty?
            val = args.first
            if val.nil?
              # Unsetting the parent.
              parent = parent_ref = nil
            else
              if val.is_a?(String) && !val.include?('[')
                raise Poise::Error.new("Cannot use a string #{name} without defining a parent type") if parent_type == Chef::Resource
                # Try to find the most recent instance of parent_type with a
                # matching name. This takes subclassing parent_type into account.
                found_val = nil
                iterator = run_context.resource_collection.respond_to?(:recursive_each) ? :recursive_each : :each
                # This will find the last matching value due to overwriting
                # found_val as it goes. Will be the nearest match.
                run_context.resource_collection.public_send(iterator) do |res|
                  found_val = res if res.is_a?(parent_type) && res.name == val
                end
                # If found_val is nil, fall back to using lookup even though
                # it won't work with subclassing, better than nothing?
                val = found_val || "#{parent_type.resource_name}[#{val}]"
              end
              if val.is_a?(String) || val.is_a?(Hash)
                parent = @run_context.resource_collection.find(val)
              else
                parent = val
              end
              if !parent.is_a?(parent_type)
                raise Poise::Error.new("Parent resource is not an instance of #{parent_type.name}: #{val.inspect}")
              end
              parent_ref = ParentRef.new(parent)
            end
          elsif !parent_ref || !parent_ref.resource
            if parent_default
              parent = if parent_default.is_a?(Chef::DelayedEvaluator)
                instance_eval(&parent_default)
              else
                parent_default
              end
            end
            # The @parent_ref means we won't run this if we previously set
            # ParentRef.new(nil). This means auto-lookup only happens during
            # after_created.
            if !parent && !parent_ref && parent_auto
              # Automatic sibling lookup for sequential composition.
              # Find the last instance of the parent class as the default parent.
              # This is super flaky and should only be a last resort.
              parent = Poise::Helpers::Subresources::DefaultContainers.find(parent_type, run_context, self_resource: self)
            end
            # Can't find a valid parent, if it wasn't optional raise an error.
            raise Poise::Error.new("No #{name} found for #{self}") unless parent || parent_optional
            parent_ref = ParentRef.new(parent)
          else
            parent = parent_ref.resource
          end
          raise Poise::Error.new("Cannot set the #{name} of #{self} to itself") if parent.equal?(self)
          # Store the ivar back.
          instance_variable_set(:"@#{name}", parent_ref)
          # Return the actual resource.
          parent
        end

        module ClassMethods
          # @overload parent_type()
          #   Get the class of the default parent link on this resource.
          #   @return [Class, Symbol]
          # @overload parent_type(type)
          #   Set the class of the default parent link on this resource.
          #   @param type [Class, Symbol] Class to set.
          #   @return [Class, Symbol]
          def parent_type(type=nil)
            if type
              raise Poise::Error.new("Parent type must be a class, symbol, or true, got #{type.inspect}") unless type.is_a?(Class) || type.is_a?(Symbol) || type == true
              # Setting to true shouldn't actually do anything if a type was already set.
              @parent_type = type unless type == true && !@parent_type.nil?
            end
            # First ancestor_send looks for a non-true && non-default value,
            # second one is to check for default vs true if no real value is found.
            @parent_type || Poise::Utils.ancestor_send(self, :parent_type, ignore: [Chef::Resource, true]) || Poise::Utils.ancestor_send(self, :parent_type, default: Chef::Resource)
          end

          # @overload parent_optional()
          #   Get the optional mode for the default parent link on this resource.
          #   @return [Boolean]
          # @overload parent_optional(val)
          #   Set the optional mode for the default parent link on this resource.
          #   @param val [Boolean] Mode to set.
          #   @return [Boolean]
          def parent_optional(val=nil)
            unless val.nil?
              @parent_optional = val
            end
            if @parent_optional.nil?
              Poise::Utils.ancestor_send(self, :parent_optional, default: false)
            else
              @parent_optional
            end
          end

          # @overload parent_auto()
          #   Get the auto-detect mode for the default parent link on this resource.
          #   @return [Boolean]
          # @overload parent_auto(val)
          #   Set the auto-detect mode for the default parent link on this resource.
          #   @param val [Boolean] Mode to set.
          #   @return [Boolean]
          def parent_auto(val=nil)
            unless val.nil?
              @parent_auto = val
            end
            if @parent_auto.nil?
              Poise::Utils.ancestor_send(self, :parent_auto, default: true)
            else
              @parent_auto
            end
          end

          # @overload parent_default()
          #   Get the default value for the default parent link on this resource.
          #   @since 2.3.0
          #   @return [Object, Chef::DelayedEvaluator]
          # @overload parent_default(val)
          #   Set the default value for the default parent link on this resource.
          #   @since 2.3.0
          #   @param val [Object, Chef::DelayedEvaluator] Default value to set.
          #   @return [Object, Chef::DelayedEvaluator]
          def parent_default(*args)
            unless args.empty?
              @parent_default = args.first
            end
            if defined?(@parent_default)
              @parent_default
            else
              Poise::Utils.ancestor_send(self, :parent_default)
            end
          end

          # Create a new kind of parent link.
          #
          # @since 2.0.0
          # @param name [Symbol] Name of the relationship. This becomes a method
          #   name on the resource instance.
          # @param type [Class] Class of the parent.
          # @param optional [Boolean] If the parent is optional.
          # @param auto [Boolean] If the parent is auto-detected.
          # @return [void]
          def parent_attribute(name, type: Chef::Resource, optional: false, auto: true, default: nil)
            name = :"parent_#{name}"
            (@parent_attributes ||= {})[name] = type
            define_method(name) do |*args|
              _parent(name, type, optional, auto, default, *args)
            end
          end

          # Return the name of all parent relationships on this class.
          #
          # @since 2.0.0
          # @return [Hash<Symbol, Class>]
          def parent_attributes
            {}.tap do |attrs|
              # Grab superclass's attributes if possible.
              attrs.update(Poise::Utils.ancestor_send(self, :parent_attributes, default: {}))
              # Local default parent.
              attrs[:parent] = parent_type
              # Extra locally defined parents.
              attrs.update(@parent_attributes) if @parent_attributes
              # Remove anything with the type set to true.
              attrs.reject! {|name, type| type == true }
            end
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
end
