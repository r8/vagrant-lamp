#
# Copyright 2015-2017, Noah Kantrowitz
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

require 'shellwords'

require 'poise'

require 'poise_languages/error'
require 'poise_languages/utils'


module PoiseLanguages
  module Command
    # A mixin for resources and providers that run language commands.
    #
    # @since 1.0.0
    module Mixin
      include Poise::Utils::ResourceProviderMixin

      # A mixin for resources that run language commands. Also available as a
      # parameterized mixin via `include PoiseLanguages::Command::Mixin::Resource(name)`.
      #
      # @example
      #   class MyLangThing
      #     include PoiseLanguages::Command::Mixin::Resource(:mylang)
      #     # ...
      #   end
      module Resource
        include Poise::Resource
        poise_subresource(true)

        private

        # Implementation of the $name accessor.
        #
        # @api private
        # @param name [Symbol] Language name.
        # @param runtime [Symbol] Language runtime resource name.
        # @param val [String, Chef::Resource, Poise::NOT_PASSED, nil] Accessor value.
        # @return [String]
        def language_command_runtime(name, runtime, default_binary, val=Poise::NOT_PASSED)
          unless val == Poise::NOT_PASSED
            path_arg = parent_arg = nil
            # Figure out which property we are setting.
            if val.is_a?(String)
              # Check if it is a runtime resource.
              begin
                parent_arg = run_context.resource_collection.find("#{runtime}[#{val}]")
              rescue Chef::Exceptions::ResourceNotFound
                # Check if something looks like a path, defined as containing
                # either / or \. While a single word could be a path, I think the
                # UX win of better error messages should take priority.
                might_be_path = val =~ %r{/|\\}
                if might_be_path
                  Chef::Log.debug("[#{self}] #{runtime}[#{val}] not found, treating it as a path")
                  path_arg = val
                else
                  # Surface the error up to the user.
                  raise
                end
              end
            else
              parent_arg = val
            end
            # Set both attributes.
            send(:"parent_#{name}", parent_arg)
            set_or_return(name, path_arg, kind_of: [String, NilClass])
          else
            # Getter behavior. Using the ivar directly is kind of gross but oh well.
            instance_variable_get(:"@#{name}") || default_language_command_runtime(name, default_binary)
          end
        end

        # Compute the path to the default runtime binary.
        #
        # @api private
        # @param name [Symbol] Language name.
        # @return [String]
        def default_language_command_runtime(name, default_binary)
          parent = send(:"parent_#{name}")
          if parent
            parent.send(:"#{name}_binary")
          else
            PoiseLanguages::Utils.which(default_binary || name.to_s)
          end
        end

        # Inherit language parent from another resource.
        #
        # @api private
        # @param name [Symbol] Language name.
        # @param resource [Chef::Resource] Resource to inherit from.
        # @return [void]
        def language_command_runtime_from_parent(name, resource)
          parent = resource.send(:"parent_#{name}")
          if parent
            send(:"parent_#{name}", parent)
          else
            path = resource.send(name)
            if path
              send(name, path)
            end
          end
        end

        module ClassMethods
          # Configure this module or class for a specific language.
          #
          # @param name [Symbol] Language name.
          # @param runtime [Symbol] Language runtime resource name.
          # @param timeout [Boolean] Enable the timeout attribute.
          # @param default_binary [String] Name of the default language binary.
          # @return [void]
          def language_command_mixin(name, runtime: :"#{name}_runtime", timeout: true, default_binary: nil)
            # Create the parent attribute.
            parent_attribute(name, type: runtime, optional: true)

            # Timeout attribute for the shell_out wrappers in the provider.
            attribute(:timeout, kind_of: Integer, default: 900) if timeout

            # Create the main accessor for the parent/path.
            define_method(name) do |val=Poise::NOT_PASSED|
              language_command_runtime(name, runtime, default_binary, val)
            end

            # Create the method to inherit settings from another resource.
            define_method(:"#{name}_from_parent") do |resource|
              language_command_runtime_from_parent(name, resource)
            end
            private :"#{name}_from_parent"
          end

          def language_command_default_binary(val=Poise::NOT_PASSED)
            @language_command_default_binary = val if val != Poise::NOT_PASSED
            @language_command_default_binary
          end

          # @api private
          def included(klass)
            super
            klass.extend(ClassMethods)
          end
        end

        extend ClassMethods
        Poise::Utils.parameterized_module(self) {|*args| language_command_mixin(*args) }
      end # /module Resource

      # A mixin for providers that run language commands.
      module Provider
        include Poise::Utils::ShellOut

        private

        # Run a command using the configured language via `shell_out`.
        #
        # @api private
        # @param name [Symbol] Language name.
        # @param command_args [Array] Arguments to `shell_out`.
        # @return [Mixlib::ShellOut]
        def language_command_shell_out(name, *command_args, **options)
          # Inject our environment variables if needed.
          options[:environment] ||= {}
          parent = new_resource.send(:"parent_#{name}")
          if parent
            options[:environment].update(parent.send(:"#{name}_environment"))
          end
          # Inject other options.
          options[:timeout] ||= new_resource.timeout
          # Find the actual binary to use. Raise an exception if we see false
          # which happens if no parent resource is found, no explicit default
          # binary was given, and which() fails to find a thing.
          binary = new_resource.send(name)
          raise Error.new("Unable to find a #{name} binary for command: #{command_args.is_a?(Array) ? Shellwords.shelljoin(command_args) : command_args}") unless binary
          command = if command_args.length == 1 && command_args.first.is_a?(String)
            # String mode, sigh.
            "#{Shellwords.escape(binary)} #{command_args.first}"
          else
            # Array mode. Handle both ('one', 'two') and (['one', 'two']).
            [binary] + command_args.flatten
          end
          Chef::Log.debug("[#{new_resource}] Running #{name} command: #{command.is_a?(Array) ? Shellwords.shelljoin(command) : command}")
          # Run the command
          poise_shell_out(command, options)
        end

        # Run a command using the configured language via `shell_out!`.
        #
        # @api private
        # @param name [Symbol] Language name.
        # @param command_args [Array] Arguments to `shell_out!`.
        # @return [Mixlib::ShellOut]
        def language_command_shell_out!(name, *command_args)
          send(:"#{name}_shell_out", *command_args).tap(&:error!)
        end

        module ClassMethods
          # Configure this module or class for a specific language.
          #
          # @param name [Symbol] Language name.
          # @return [void]
          def language_command_mixin(name)
            define_method(:"#{name}_shell_out") do |*command_args|
              language_command_shell_out(name, *command_args)
            end
            private :"#{name}_shell_out"

            define_method(:"#{name}_shell_out!") do |*command_args|
              language_command_shell_out!(name, *command_args)
            end
            private :"#{name}_shell_out!"
          end

          # @api private
          def included(klass)
            super
            klass.extend(ClassMethods)
          end
        end

        extend ClassMethods
        Poise::Utils.parameterized_module(self) {|*args| language_command_mixin(*args) }
      end # /module Provider

      Poise::Utils.parameterized_module(self) {|*args| language_command_mixin(*args) }
    end # /module Mixin
  end
end
