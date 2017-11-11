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

require 'chef/version'


module Poise
  module Helpers
    # Resource mixin to allow lazyily-evaluated defaults in resource attributes.
    # This is designed to be used with {LWRPPolyfill} or a similar #attributes
    # method.
    #
    # @since 1.0.0
    # @example
    #   class MyResource < Chef::Resource
    #     include Poise::Helpers::LWRPPolyfill
    #     include Poise::Helpers::LazyDefault
    #     attribute(:path, default: lazy { name + '_temp' })
    #   end
    module LazyDefault
      # Check if this version of Chef already supports lazy defaults. This is
      # true for Chef 12.5+.
      #
      # @since 2.0.3
      # @api private
      # @return [Boolean]
      def self.needs_polyfill?
        @needs_polyfill ||= Gem::Requirement.new('< 12.5.pre').satisfied_by?(Gem::Version.new(Chef::VERSION))
      end

      # Override the default set_or_return to support lazy evaluation of the
      # default value. This only actually matters when it is called from a class
      # level context via #attributes.
      def set_or_return(symbol, arg, validation)
        if LazyDefault.needs_polyfill? && validation && validation[:default].is_a?(Chef::DelayedEvaluator)
          validation = validation.dup
          if (arg.nil? || arg == Poise::NOT_PASSED) && (!instance_variable_defined?(:"@#{symbol}") || instance_variable_get(:"@#{symbol}").nil?)
            validation[:default] = instance_eval(&validation[:default])
          else
            # Clear the default.
            validation.delete(:default)
          end
        end
        super(symbol, arg, validation)
      end

      # @!classmethods
      module ClassMethods
        # Create a lazyily-evaluated block.
        #
        # @param block [Proc] Callable to return the default value.
        # @return [Chef::DelayedEvaluator]
        def lazy(&block)
          Chef::DelayedEvaluator.new(&block)
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
