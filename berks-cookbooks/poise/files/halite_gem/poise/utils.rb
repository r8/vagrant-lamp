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

require 'poise/error'


module Poise
  module Utils
    autoload :ResourceProviderMixin, 'poise/utils/resource_provider_mixin'
    autoload :ShellOut, 'poise/utils/shell_out'
    autoload :Win32, 'poise/utils/win32'

    extend self

    # Find the cookbook name for a given filename. The can used to find the
    # cookbook that corresponds to a caller of a file.
    #
    # @param run_context [Chef::RunContext] Context to check.
    # @param filename [String] Absolute filename to check for.
    # @return [String]
    # @example
    #   def my_thing
    #     caller_filename = caller.first.split(':').first
    #     cookbook = Poise::Utils.find_cookbook_name(run_context, caller_filename)
    #     # ...
    #   end
    def find_cookbook_name(run_context, filename)
      possibles = {}
      Poise.debug("[Poise] Checking cookbook for #{filename.inspect}")
      run_context.cookbook_collection.each do |name, ver|
        # This special method is added by Halite::Gem#as_cookbook_version.
        if ver.respond_to?(:halite_root)
          # The join is there because ../poise-ruby/lib starts with ../poise so
          # we want a trailing /.
          if filename.start_with?(File.join(ver.halite_root, ''))
            Poise.debug("[Poise] Found matching halite_root in #{name}: #{ver.halite_root.inspect}")
            possibles[ver.halite_root] = name
          end
        else
          Chef::CookbookVersion::COOKBOOK_SEGMENTS.each do |seg|
            ver.segment_filenames(seg).each do |file|
              if ::File::ALT_SEPARATOR
                file = file.gsub(::File::ALT_SEPARATOR, ::File::SEPARATOR)
              end
              # Put this behind an environment variable because it is verbose
              # even for normal debugging-level output.
              Poise.debug("[Poise] Checking #{seg} in #{name}: #{file.inspect}")
              if file == filename
                Poise.debug("[Poise] Found matching #{seg} in #{name}: #{file.inspect}")
                possibles[file] = name
              end
            end
          end
        end
      end
      raise Poise::Error.new("Unable to find cookbook for file #{filename.inspect}") if possibles.empty?
      # Sort the items by matching path length, pick the name attached to the longest.
      possibles.sort_by{|key, value| key.length }.last[1]
    end

    # Try to find an ancestor to call a method on.
    #
    # @since 2.2.3
    # @since 2.3.0
    #   Added ignore parameter.
    # @param obj [Object] Self from the caller.
    # @param msg [Symbol] Method to try to call.
    # @param args [Array<Object>] Method arguments.
    # @param default [Object] Default return value if no valid ancestor exists.
    # @param ignore [Array<Object>] Return value to ignore when scanning ancesors.
    # @return [Object]
    # @example
    #   val = @val || Poise::Utils.ancestor_send(self, :val)
    def ancestor_send(obj, msg, *args, default: nil, ignore: [default])
      # Class is a subclass of Module, if we get something else use its class.
      obj = obj.class unless obj.is_a?(Module)
      ancestors = []
      if obj.respond_to?(:superclass)
        # Check the superclass first if present.
        ancestors << obj.superclass
      end
      # Make sure we don't check obj itself.
      ancestors.concat(obj.ancestors.drop(1))
      ancestors.each do |mod|
        if mod.respond_to?(msg)
          val = mod.send(msg, *args)
          # If we get the default back, assume we should keep trying.
          return val unless ignore.include?(val)
        end
      end
      # Nothing valid found, use the default.
      default
    end

    # Create a helper to invoke a module with some parameters.
    #
    # @since 2.3.0
    # @param mod [Module] The module to wrap.
    # @param block [Proc] The module to implement to parameterization.
    # @return [void]
    # @example
    #   module MyMixin
    #     def self.my_mixin_name(name)
    #       # ...
    #     end
    #   end
    #
    #   Poise::Utils.parameterized_module(MyMixin) do |name|
    #     my_mixin_name(name)
    #   end
    def parameterized_module(mod, &block)
      raise Poise::Error.new("Cannot parameterize an anonymous module") unless mod.name && !mod.name.empty?
      parent_name_parts = mod.name.split(/::/)
      # Grab the last piece which will be the method name.
      mod_name = parent_name_parts.pop
      # Find the enclosing module or class object.
      parent = parent_name_parts.inject(Object) {|memo, name| memo.const_get(name) }
      # Object is a special case since we need #define_method instead.
      method_type = if parent == Object
        :define_method
      else
        :define_singleton_method
      end
      # Scoping hack.
      self_ = self
      # Construct the method.
      parent.send(method_type, mod_name) do |*args|
        self_.send(:check_block_arity!, block, args)
        # Create a new anonymous module to be returned from the method.
        Module.new do
          # Fake the name.
          define_singleton_method(:name) do
            super() || mod.name
          end

          # When the stub module gets included, activate our behaviors.
          define_singleton_method(:included) do |klass|
            super(klass)
            klass.send(:include, mod)
            klass.instance_exec(*args, &block)
          end
        end
      end
    end

    private

    # Check that the given arguments match the given block. This is needed
    # because Ruby will nil-pad mismatched argspecs on blocks rather than error.
    #
    # @since 2.3.0
    # @param block [Proc] Block to check.
    # @param args [Array<Object>] Arguments to check.
    # @return [void]
    def check_block_arity!(block, args)
      # Convert the block to a lambda-style proc. You can't make this shit up.
      obj = Object.new
      obj.define_singleton_method(:block, &block)
      block  = obj.method(:block).to_proc
      # Check
      required_args = block.arity < 0 ? ~block.arity : block.arity
      if args.length < required_args || (block.arity >= 0 && args.length > block.arity)
        raise ArgumentError.new("wrong number of arguments (#{args.length} for #{required_args}#{block.arity < 0 ? '+' : ''})")
      end
    end

  end
end
