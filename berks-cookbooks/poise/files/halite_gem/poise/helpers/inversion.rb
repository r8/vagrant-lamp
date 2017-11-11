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

require 'chef/node'
require 'chef/node_map'
require 'chef/provider'
require 'chef/resource'

require 'poise/backports'
require 'poise/helpers/defined_in'
require 'poise/error'
require 'poise/helpers/inversion/options_resource'
require 'poise/utils/resource_provider_mixin'


module Poise
  module Helpers
    # A mixin for dependency inversion in Chef.
    #
    # @since 2.0.0
    module Inversion
      autoload :OptionsResource, 'poise/helpers/inversion/options_resource'
      autoload :OptionsProvider, 'poise/helpers/inversion/options_provider'

      include Poise::Utils::ResourceProviderMixin

      # Resource implementation for {Poise::Helpers::Inversion}.
      # @see Poise::Helpers::Inversion
      module Resource
        # @overload options(val=nil)
        #   Set or return provider options for all providers.
        #   @param val [Hash] Provider options to set.
        #   @return [Hash]
        #   @example
        #     my_resource 'thing_one' do
        #       options depends: 'thing_two'
        #     end
        # @overload options(provider, val=nil)
        #   Set or return provider options for a specific provider.
        #   @param provider [Symbol] Provider to set for.
        #   @param val [Hash] Provider options to set.
        #   @return [Hash]
        #   @example
        #     my_resource 'thing_one' do
        #       options :my_provider, depends: 'thing_two'
        #     end
        def options(provider=nil, val=nil)
          key = :options
          if !val && provider.is_a?(Hash)
            val = provider
          elsif provider
            key = :"options_#{provider}"
          end
          set_or_return(key, val ? Mash.new(val) : val, kind_of: Hash, default: lazy { Mash.new })
        end

        # Allow setting the provider directly using the same names as the attribute
        # settings.
        #
        # @param val [String, Symbol, Class, nil] Value to set the provider to.
        # @return [Class]
        # @example
        #   my_resource 'thing_one' do
        #     provider :my_provider
        #   end
        def provider(val=nil)
          if val && !val.is_a?(Class)
            resource_names = [resource_name]
            # If subclass_providers! might be in play, check for those names too.
            resource_names.concat(self.class.subclass_resource_equivalents) if self.class.respond_to?(:subclass_resource_equivalents)
            # Silly ruby tricks to find the first provider that exists and no more.
            provider_class = resource_names.lazy.map {|name| Poise::Helpers::Inversion.provider_for(name, node, val) }.select {|x| x }.first
            Poise.debug("[#{self}] Checking for an inversion provider for #{val}: #{provider_class && provider_class.name}")
            val = provider_class if provider_class
          end
          super
        end

        # Set or return the array of provider names to be blocked from
        # auto-resolution.
        #
        # @param val [String, Array<String>] Value to set.
        # @return [Array<String>]
        def provider_no_auto(val=nil)
          # Coerce to an array.
          val = Array(val).map(&:to_s) if val
          set_or_return(:provider_no_auto, val, kind_of: Array, default: [])
        end

        # @!classmethods
        module ClassMethods
          # Options resource class.
          attr_reader :inversion_options_resource_class
          # Options provider class.
          attr_reader :inversion_options_provider_class

          # @overload inversion_options_resource()
          #   Return the options resource mode for this class.
          #   @return [Boolean]
          # @overload inversion_options_resource(val)
          #   Set the options resource mode for this class. Set to true to
          #   automatically create an options resource. Defaults to true.
          #   @param val [Boolean] Enable/disable setting.
          #   @return [Boolean]
          def inversion_options_resource(val=nil)
            @poise_inversion_options_resource = val unless val.nil?
            @poise_inversion_options_resource
          end

          # Create resource and provider classes for an options resource.
          #
          # @param name [String, Symbol] DSL name for the base resource.
          # @return [void]
          def create_inversion_options_resource!(name)
            enclosing_class = self
            options_resource_name = :"#{name}_options"
            # Create the resource class.
            @inversion_options_resource_class = Class.new(Chef::Resource) do
              include Poise::Helpers::Inversion::OptionsResource
              define_singleton_method(:name) do
                "#{enclosing_class}::OptionsResource"
              end
              define_singleton_method(:inversion_resource_class) do
                enclosing_class
              end
              provides(options_resource_name)
              inversion_resource(name)
            end
            # Create the provider class.
            @inversion_options_provider_class = Class.new(Chef::Provider) do
              include Poise::Helpers::Inversion::OptionsProvider
              define_singleton_method(:name) do
                "#{enclosing_class}::OptionsProvider"
              end
              define_singleton_method(:inversion_resource_class) do
                enclosing_class
              end
              provides(options_resource_name)
            end
          end

          # Wrap #provides() to create an options resource if desired.
          #
          # @param name [Symbol] Resource name
          # return [void]
          def provides(name, *args, &block)
            create_inversion_options_resource!(name) if inversion_options_resource
            super(name, *args, &block) if defined?(super)
          end

          def included(klass)
            super
            klass.extend(ClassMethods)
          end
        end

        extend ClassMethods
      end

      # Provider implementation for {Poise::Helpers::Inversion}.
      # @see Poise::Helpers::Inversion
      module Provider
        include DefinedIn

        # Compile all the different levels of inversion options together.
        #
        # @return [Hash]
        # @example
        #   def action_run
        #     if options['depends']
        #       # ...
        #     end
        #   end
        def options
          @options ||= self.class.inversion_options(node, new_resource)
        end

        # @!classmethods
        module ClassMethods
          # @overload inversion_resource()
          #   Return the inversion resource name for this class.
          #   @return [Symbo, nill]
          # @overload inversion_resource(val)
          #   Set the inversion resource name for this class. You can pass either
          #   a symbol in DSL format or a resource class that uses Poise. This
          #   name is used to determine which resources the inversion provider is
          #   a candidate for.
          #   @param val [Symbol, Class] Name to set.
          #   @return [Symbol, nil]
          def inversion_resource(val=Poise::NOT_PASSED)
            if val != Poise::NOT_PASSED
              val = val.resource_name if val.is_a?(Class)
              Chef::Log.debug("[#{self.name}] Setting inversion resource to #{val}")
              @poise_inversion_resource = val.to_sym
            end
            if defined?(@poise_inversion_resource)
              @poise_inversion_resource
            else
              Poise::Utils.ancestor_send(self, :inversion_resource, default: nil)
            end
          end

          # @overload inversion_attribute()
          #   Return the inversion attribute name(s) for this class.
          #   @return [Array<String>, nil]
          # @overload inversion_attribute(val)
          #   Set the inversion attribute name(s) for this class. This is
          #   used by {.resolve_inversion_attribute} to load configuration data
          #   from node attributes. To specify a nested attribute pass an array
          #   of strings corresponding to the keys.
          #   @param val [String, Array<String>] Attribute path.
          #   @return [Array<String>, nil]
          def inversion_attribute(val=Poise::NOT_PASSED)
            if val != Poise::NOT_PASSED
              # Coerce to an array of strings.
              val = Array(val).map {|name| name.to_s }
              @poise_inversion_attribute = val
            end
            if defined?(@poise_inversion_attribute)
              @poise_inversion_attribute
            else
              Poise::Utils.ancestor_send(self, :inversion_attribute, default: nil)
            end
          end

          # Default attribute paths to check for inversion options. Based on
          # the cookbook this class and its superclasses are defined in.
          #
          # @param node [Chef::Node] Node to load from.
          # @return [Array<Array<String>>]
          def default_inversion_attributes(node)
            klass = self
            tried = []
            while klass.respond_to?(:poise_defined_in_cookbook)
              cookbook = klass.poise_defined_in_cookbook(node.run_context)
              if node[cookbook]
                return [cookbook]
              end
              tried << cookbook
              klass = klass.superclass
            end
            raise Poise::Error.new("Unable to find inversion attributes, tried: #{tried.join(', ')}")
          end

          # Resolve the node attribute used as the base for inversion options
          # for this class. This can be set explicitly with {.inversion_attribute}
          # or the default is to use the name of the cookbook the provider is
          # defined in.
          #
          # @param node [Chef::Node] Node to load from.
          # @return [Chef::Node::Attribute]
          def resolve_inversion_attribute(node)
            # Default to using just the name of the cookbook.
            attribute_names = inversion_attribute || default_inversion_attributes(node)
            return {} if attribute_names.empty?
            attribute_names.inject(node) do |memo, key|
              memo[key] || begin
                raise Poise::Error.new("Attribute #{key} not set when expanding inversion attribute for #{self.name}: #{memo}")
              end
            end
          end

          # Compile all the different levels of inversion options together.
          #
          # @param node [Chef::Node] Node to load from.
          # @param resource [Chef::Resource] Resource to load from.
          # @return [Hash]
          def inversion_options(node, resource)
            Mash.new.tap do |opts|
              attrs = resolve_inversion_attribute(node)
              # Cast the run state to a Mash because string vs. symbol keys. I can
              # at least promise poise_inversion will be a str so cut down on the
              # amount of data to convert.
              run_state = Mash.new(node.run_state.fetch('poise_inversion', {}).fetch(inversion_resource, {}))[resource.name] || {}
              # Class-level defaults.
              opts.update(default_inversion_options(node, resource))
              # Resource options for all providers.
              opts.update(resource.options) if resource.respond_to?(:options)
              # Global provider from node attributes.
              opts.update(provider: attrs['provider']) if attrs['provider']
              # Attribute options for all providers.
              opts.update(attrs['options']) if attrs['options']
              # Resource options for this provider.
              opts.update(resource.options(provides)) if resource.respond_to?(:options)
              # Attribute options for this resource name.
              opts.update(attrs[resource.name]) if attrs[resource.name]
              # Options resource options for all providers.
              opts.update(run_state['*']) if run_state['*']
              # Options resource options for this provider.
              opts.update(run_state[provides]) if run_state[provides]
              # Vomitdebug output for tracking down weirdness.
              Poise.debug("[#{resource}] Resolved inversion options: #{opts.inspect}")
            end
          end

          # Default options data for this provider class.
          #
          # @param node [Chef::Node] Node to load from.
          # @param resource [Chef::Resource] Resource to load from.
          # @return [Hash]
          def default_inversion_options(node, resource)
            {}
          end

          # Resolve which provider name should be used for a resource.
          #
          # @param node [Chef::Node] Node to load from.
          # @param resource [Chef::Resource] Resource to query.
          # @return [String]
          def resolve_inversion_provider(node, resource)
            inversion_options(node, resource)['provider'] || 'auto'
          end

          # Override the normal #provides to set the inversion provider name
          # instead of adding to the normal provider map.
          #
          # @overload provides()
          #   Return the inversion provider name for the class.
          #   @return [Symbol]
          # @overload provides(name, opts={}, &block)
          #   Set the inversion provider name for the class.
          #   @param name [Symbol] Provider name.
          #   @param opts [Hash] NodeMap filter options.
          #   @param block [Proc] NodeMap filter proc.
          #   @return [Symbol]
          def provides(name=nil, opts={}, &block)
            if name
              raise Poise::Error.new("Inversion resource name not set for #{self.name}") unless inversion_resource
              @poise_inversion_provider = name
              Chef::Log.debug("[#{self.name}] Setting inversion provider name to #{name}")
              Poise::Helpers::Inversion.provider_map(inversion_resource).set(name.to_sym, self, opts, &block)
              # Set the actual Chef-level provides name for DSL dispatch.
              super(inversion_resource)
            end
            @poise_inversion_provider
          end

          # Override the default #provides? to check for our inverted providers.
          #
          # @api private
          # @param node [Chef::Node] Node to use for attribute checks.
          # @param resource [Chef::Resource] Resource instance to match.
          # @return [Boolean]
          def provides?(node, resource)
            raise Poise::Error.new("Inversion resource name not set for #{self.name}") unless inversion_resource
            resource_name_equivalents = {resource.resource_name => true}
            # If subclass_providers! might be in play, check for those names too.
            if resource.class.respond_to?(:subclass_resource_equivalents)
              resource.class.subclass_resource_equivalents.each do |name|
                resource_name_equivalents[name] = true
              end
            end
            return false unless resource_name_equivalents[inversion_resource]
            provider_name = resolve_inversion_provider(node, resource).to_s
            Poise.debug("[#{resource}] Checking provides? on #{self.name}. Got provider_name #{provider_name.inspect}")
            provider_name == provides.to_s || ( provider_name == 'auto' && !resource.provider_no_auto.include?(provides.to_s) && provides_auto?(node, resource) )
          end

          # Subclass hook to provide auto-detection for providers.
          #
          # @param node [Chef::Node] Node to check against.
          # @param resource [Chef::Resource] Resource to check against.
          # @return [Boolean]
          def provides_auto?(node, resource)
            false
          end

          def included(klass)
            super
            klass.extend(ClassMethods)
          end
        end

        extend ClassMethods
      end

      # The provider map for a given resource type.
      #
      # @param resource_type [Symbol] Resource type in DSL format.
      # @return [Chef::NodeMap]
      # @example
      #   Poise::Helpers::Inversion.provider_map(:my_resource)
      def self.provider_map(resource_type)
        @provider_maps ||= {}
        @provider_maps[resource_type.to_sym] ||= Chef::NodeMap.new
      end

      # Find a specific provider class for a resource.
      #
      # @param resource_type [Symbol] Resource type in DSL format.
      # @param node [Chef::Node] Node to use for the lookup.
      # @param provider_type [Symbol] Provider type in DSL format.
      # @return [Class]
      # @example
      #   Poise::Helpers::Inversion.provider_for(:my_resource, node, :my_provider)
      def self.provider_for(resource_type, node, provider_type)
        provider_map(resource_type).get(node, provider_type.to_sym)
      end
    end
  end
end
