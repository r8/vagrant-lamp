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

require 'chef/provider'


module Poise
  module Helpers
    # Resource mixin to create "fused" resources where the resource and provider
    # are implemented in the same class.
    #
    # @since 2.0.0
    # @example
    #   class Chef::Resource::MyResource < Chef::Resource
    #     include Poise(fused: true)
    #     attribute(:path, kind_of: String)
    #     attribute(:message, kind_of: String)
    #     action(:run) do
    #       file new_resource.path do
    #         content new_resource.message
    #       end
    #     end
    #   end
    module Fused
      # Hack is_a? so that the DSL will consider this a Provider for the
      # purposes of attaching enclosing_provider.
      #
      # @api private
      # @param klass [Class]
      # @return [Boolean]
      def is_a?(klass)
        if klass == Chef::Provider
          # Lies, damn lies, and Ruby code.
          true
        else
          super
        end
      end

      # Hack provider_for_action so that the resource is also the provider.
      #
      # @api private
      # @param action [Symbol]
      # @return [Chef::Provider]
      def provider_for_action(action)
        provider(self.class.fused_provider_class) unless provider
        super
      end

      # @!classmethods
      module ClassMethods
        # Define a provider action. The block should contain the usual provider
        # code.
        #
        # @param name [Symbol] Name of the action.
        # @param block [Proc] Action implementation.
        # @example
        #   action(:run) do
        #     file '/temp' do
        #       user 'root'
        #       content 'temp'
        #     end
        #   end
        def action(name, &block)
          fused_actions[name.to_sym] = block
          # Make sure this action is allowed, also sets the default if first.
          if respond_to?(:actions)
            actions(name.to_sym)
          end
        end

        # Storage accessor for fused action blocks. Maps action name to proc.
        #
        # @api private
        # @return [Hash<Symbol, Proc>]
        def fused_actions
          (@fused_actions ||= {})
        end

        # Create a provider class for the fused actions in this resource.
        # Inherits from the fused provider class of the resource's superclass if
        # present.
        #
        # @api private
        # @return [Class]
        def fused_provider_class
          @fused_provider_class ||= begin
            provider_superclass = begin
              self.superclass.fused_provider_class
            rescue NoMethodError
              Chef::Provider
            end
            actions = fused_actions
            class_name = self.name
            Class.new(provider_superclass) do
              include Poise
              define_singleton_method(:name) { class_name + ' (fused)' }
              actions.each do |action, block|
                define_method(:"action_#{action}", &block)
              end
            end
          end
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
