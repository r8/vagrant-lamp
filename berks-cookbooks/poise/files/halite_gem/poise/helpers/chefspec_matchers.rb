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

# Not requiring chefspec or rspec/expectations since this code should only
# activate if they are already loaded.

require 'poise/helpers/lwrp_polyfill'
require 'poise/helpers/resource_name'


module Poise
  module Helpers
    # A resource mixin to register ChefSpec matchers for a resource
    # automatically.
    #
    # If you are using the provides() form for naming resources, ensure that is
    # set before declaring actions.
    #
    # @since 2.0.0
    # @example Define a class
    #   class Chef::Resource::MyResource < Chef::Resource
    #     include Poise::Helpers::ChefspecMatchers
    #     actions(:run)
    #   end
    # @example Use a matcher
    #   expect(chef_run).to run_my_resource('...')
    module ChefspecMatchers
      include Poise::Helpers::LWRPPolyfill::Resource
      include Poise::Helpers::ResourceName

      # Create a matcher for a given resource type and action. This is
      # idempotent so if a matcher already exists, it will not be recreated.
      #
      # @api private
      def self.create_matcher(resource, action)
        # Check that we have everything we need.
        return unless defined?(ChefSpec) && defined?(RSpec::Matchers) && resource
        method = :"#{action}_#{resource}"
        return if RSpec::Matchers.method_defined?(method)
        RSpec::Matchers.send(:define_method, method) do |resource_name|
          ChefSpec::Matchers::ResourceMatcher.new(resource, action, resource_name)
        end
      end

      # @!classmethods
      module ClassMethods
        # Create a resource-level matcher for this resource.
        #
        # @see Resource::ResourceName.provides
        def provides(name, *args, &block)
          super(name, *args, &block)
          ChefSpec.define_matcher(name) if defined?(ChefSpec)
          # Call #actions here to grab any actions from a parent class.
          actions.each do |action|
            ChefspecMatchers.create_matcher(name, action)
          end
        end

        # Create matchers for all declared actions.
        #
        # @see Resource::LWRPPolyfill.actions
        def actions(*names)
          super.tap do |actions|
            actions.each do |action|
              ChefspecMatchers.create_matcher(resource_name, action)
            end if resource_name && resource_name != :resource && !names.empty?
          end
        end

        def included(klass)
          super
          klass.extend ClassMethods
        end
      end

      extend ClassMethods
    end
  end
end
