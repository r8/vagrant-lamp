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

require 'chef/dsl/recipe'

require 'poise/helpers/subcontext_block'
require 'poise/helpers/subresources/default_containers'


module Poise
  module Helpers
    module Subresources
      # A resource mixin for subresource containers.
      #
      # @since 1.0.0
      module Container
        # A resource collection that has much more condensed text output. This
        # is used to show the value of @subresources during Chef's error formatting.
        # @api private
        class NoPrintingResourceCollection < Chef::ResourceCollection
          def inspect
            to_text
          end

          def to_text
            "[#{all_resources.map(&:to_s).join(', ')}]"
          end
        end

        include SubcontextBlock
        include Chef::DSL::Recipe

        attr_reader :subresources
        attr_reader :subcontexts

        def initialize(*args)
          super
          @subresources = NoPrintingResourceCollection.new
          @subcontexts = []
        end

        def after_created
          super
          # Register as a default container if needed.
          Poise::Helpers::Subresources::DefaultContainers.register!(self, run_context) if self.class.container_default
          # Add all internal subresources to the resource collection.
          unless @subresources.empty?
            Chef::Log.debug("[#{self}] Adding subresources to collection:")
            # Because after_create is run before adding the container to the resource collection
            # we need to jump through some hoops to get it swapped into place.
            self_ = self
            order_fixer = Chef::Resource::RubyBlock.new('subresource_order_fixer', @run_context)
            # respond_to? is for <= 12.0.2, remove some day when I stop caring.
            order_fixer.declared_type = 'ruby_block' if order_fixer.respond_to?(:declared_type=)
            order_fixer.block do
              Chef::Log.debug("[#{self_}] Running order fixer")
              collection = self_.run_context.resource_collection
              # Delete the current container resource from its current position.
              collection.all_resources.delete(self_)
              # Replace the order fixer with the container so it runs before all
              # subresources.
              collection.all_resources[collection.iterator.position] = self_
              # Hack for Chef 11 to reset the resources_by_name position too.
              # @todo Remove this when I drop support for Chef 11.
              if resources_by_name = collection.instance_variable_get(:@resources_by_name)
                resources_by_name[self_.to_s] = collection.iterator.position
              end
              # Step back so we re-run the "current" resource, which is now the
              # container.
              collection.iterator.skip_back
              Chef::Log.debug("Collection: #{@run_context.resource_collection.map(&:to_s).join(', ')}")
            end
            @run_context.resource_collection.insert(order_fixer)
            @subcontexts.each do |ctx|
              # Copy all resources to the outer context.
              ctx.resource_collection.each do |r|
                Chef::Log.debug("   * #{r}")
                # Fix the subresource to use the outer run context.
                r.run_context = @run_context
                @run_context.resource_collection.insert(r)
              end
              # Copy all notifications to the outer context.
              %w{immediate delayed}.each do |notification_type|
                ctx.send(:"#{notification_type}_notification_collection").each do |key, notifications|
                  notifications.each do |notification|
                    parent_notifications = @run_context.send(:"#{notification_type}_notification_collection")[key]
                    unless parent_notifications.any? { |existing_notification| existing_notification.duplicates?(notification) }
                      parent_notifications << notification
                    end
                  end
                end
              end
            end
            Chef::Log.debug("Collection: #{@run_context.resource_collection.map(&:to_s).join(', ')}")
          end
        end

        def declare_resource(type, name, created_at=nil, &block)
          Chef::Log.debug("[#{self}] Creating subresource from #{type}(#{name})")
          self_ = self
          # Used to break block context, non-local return from subcontext_block.
          resource = []
          # Grab the caller so we can make the subresource look like it comes from
          # correct place.
          created_at ||= caller[0]
          # Run this inside a subcontext to avoid adding to the current resource collection.
          # It will end up added later, indirected via @subresources to ensure ordering.
          @subcontexts << subcontext_block do
            namespace = if self.class.container_namespace == true
              # If the value is true, use the name of the container resource.
              self.name
            elsif self.class.container_namespace.is_a?(Proc)
              instance_eval(&self.class.container_namespace)
            else
              self.class.container_namespace
            end
            sub_name = if name && !name.empty?
              if namespace
                "#{namespace}::#{name}"
              else
                name
              end
            else
              # If you pass in nil or '', you just get the namespace or parent name.
              namespace || self.name
            end
            resource << super(type, sub_name, created_at) do
              # Apply the correct parent before anything else so it is available
              # in after_created for the subresource. It might raise
              # NoMethodError is there isn't a real parent.
              begin
                parent(self_) if respond_to?(:parent)
              rescue NoMethodError
                # This space left intentionally blank.
              end
              # Run the resource block.
              instance_exec(&block) if block
            end
          end
          # Try and add to subresources. For normal subresources this is handled
          # in the after_created.
          register_subresource(resource.first) if resource.first
          # Return whatever we have
          resource.first
        end

        # Register a resource as part of this container. Returns true if the
        # resource was added to the collection and false if it was already
        # known.
        #
        # @note Return value added in 2.4.0.
        # @return [Boolean]
        def register_subresource(resource)
          subresources.lookup(resource)
          false
        rescue Chef::Exceptions::ResourceNotFound
          Chef::Log.debug("[#{self}] Adding #{resource} to subresources")
          subresources.insert(resource)
          true
        end

        private

        # Thanks Array.flatten, big help you are. Specifically the
        # method_missing in the recipe DSL will make a flatten on an array of
        # resources fail, so make this safe.
        def to_ary
          nil
        end

        # @!classmethods
        module ClassMethods
          def container_namespace(val=nil)
            @container_namespace = val unless val.nil?
            if @container_namespace.nil?
              # Not set here, look at the superclass or true by default for backwards compat.
              Poise::Utils.ancestor_send(self, :container_namespace, default: true)
            else
              @container_namespace
            end
          end

          # @overload container_default()
          #   Get the default mode for this resource. If false, this resource
          #   class will not be used for default container lookups. Defaults to
          #   true.
          #   @since 2.3.0
          #   @return [Boolean]
          # @overload container_default(val)
          #   Set the default mode for this resource.
          #   @since 2.3.0
          #   @param val [Boolean] Default mode to set.
          #   @return [Boolean]
          def container_default(val=nil)
            @container_default = val unless val.nil?
            if @container_default.nil?
              # Not set here, look at the superclass or true by default for backwards compat.
              Poise::Utils.ancestor_send(self, :container_default, default: true)
            else
              @container_default
            end
          end

          def included(klass)
            super
            klass.extend(ClassMethods)
            klass.const_get(:HIDDEN_IVARS) << :@subcontexts
            klass.const_get(:FORBIDDEN_IVARS) << :@subcontexts
          end
        end

        extend ClassMethods
      end
    end
  end
end
