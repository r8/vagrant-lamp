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

require 'chef/mash'

require 'poise/backports'
require 'poise/error'


module Poise
  module Helpers
    module Inversion
      # A mixin for inversion options resources.
      #
      # @api private
      # @since 2.0.0
      # @see Poise::Helpers::Inversion
      module OptionsResource
        include Poise

        # Method missing delegation to allow DSL-style options.
        #
        # @example
        #   my_app_options 'app' do
        #     key1 'value1'
        #     key2 'value2'
        #   end
        def method_missing(method_sym, *args, &block)
          super(method_sym, *args, &block)
        rescue NoMethodError
          # First time we've seen this key and using it as an rvalue, NOPE.GIF.
          raise unless !args.empty? || block || _options[method_sym]
          if !args.empty? || block
            _options[method_sym] = block || args.first
          end
          _options[method_sym]
        end

        # Capture setting the provider and make it Do What I Mean. This does
        # mean you can't set the actual provider for the options resource, which
        # is fine because the provider is a no-op.
        #
        # @api private
        def provider(val=Poise::NOT_PASSED)
          if val == Poise::NOT_PASSED
            super()
          else
            _options[:provider] = val
          end
        end

        # Insert the options data in to the run state. This has to match the
        # layout used in {Poise::Helpers::Inversion::Provider.inversion_options}.
        #
        # @api private
        def after_created
          raise Poise::Error.new("Inversion resource name not set for #{self.class.name}") unless self.class.inversion_resource
          node.run_state['poise_inversion'] ||= {}
          node.run_state['poise_inversion'][self.class.inversion_resource] ||= {}
          node.run_state['poise_inversion'][self.class.inversion_resource][resource] ||= {}
          node.run_state['poise_inversion'][self.class.inversion_resource][resource][for_provider] ||= {}
          node.run_state['poise_inversion'][self.class.inversion_resource][resource][for_provider].update(_options)
        end

        module ClassMethods
          # @overload inversion_resource()
          #   Return the inversion resource name for this class.
          #   @return [Symbol]
          # @overload inversion_resource(val)
          #   Set the inversion resource name for this class. You can pass either
          #   a symbol in DSL format or a resource class that uses Poise. This
          #   name is used to determine which resources the inversion provider is
          #   a candidate for.
          #   @param val [Symbol, Class] Name to set.
          #   @return [Symbol]
          def inversion_resource(val=nil)
            if val
              val = val.resource_name if val.is_a?(Class)
              Chef::Log.debug("[#{self.name}] Setting inversion resource to #{val}")
              @poise_inversion_resource = val.to_sym
            end
            @poise_inversion_resource || (superclass.respond_to?(:inversion_resource) ? superclass.inversion_resource : nil)
          end

          # @api private
          def included(klass)
            super
            klass.extend(ClassMethods)
            klass.class_exec do
              actions(:run)
              attribute(:resource, kind_of: String, name_attribute: true)
              attribute(:for_provider, kind_of: [String, Symbol], default: '*')
              attribute(:_options, kind_of: Hash, default: lazy { Mash.new })
            end
          end
        end

        extend ClassMethods
      end
    end
  end
end
