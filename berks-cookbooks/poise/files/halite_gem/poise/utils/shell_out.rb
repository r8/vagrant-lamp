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

require 'etc'

require 'chef/mixin/shell_out'


module Poise
  module Utils
    # A mixin to provider a better shell_out.
    #
    # @since 2.5.0
    # @example
    #   Poise::Utils::ShellOut.poise_shell_out('ruby myapp.rb', user: 'myuser')
    module ShellOut
      extend self
      include Chef::Mixin::ShellOut

      # An enhanced version of Chef's `shell_out` which sets some default
      # parameters. If possible it will set $HOME, $USER, $LOGNAME, and the
      # group to run as.
      #
      # @param command_args [Array] Command arguments to be passed to `shell_out`.
      # @param options [Hash<Symbol, Object>] Options to be passed to `shell_out`,
      #   with modifications.
      # @return [Mixlib::ShellOut]
      def poise_shell_out(*command_args, **options)
        # Allow the env option shorthand.
        options[:environment] ||= {}
        if options[:env]
          options[:environment].update(options[:env])
          options.delete(:env)
        end
        # Convert environment keys to strings to be safe.
        options[:environment] = options[:environment].inject({}) do |memo, (key, value)|
          memo[key.to_s] = value.to_s
          memo
        end
        # Populate some standard environment variables.
        ent = begin
          if options[:user].is_a?(Integer)
            Etc.getpwuid(options[:user])
          elsif options[:user]
            Etc.getpwnam(options[:user])
          end
        rescue ArgumentError
          nil
        end
        username = ent ? ent.name : options[:name]
        if username
          options[:environment]['HOME'] ||= Dir.home(username)
          options[:environment]['USER'] ||= username
          # On the off chance they set one manually but not the other.
          options[:environment]['LOGNAME'] ||= options[:environment]['USER']
        end
        # Set the default group on Unix.
        options[:group] ||= ent.gid if ent
        # Mixlib-ShellOut doesn't support array commands on Windows and has
        # super wonky escaping for cmd.exe.
        if respond_to?(:node) && node.platform_family?('windows')
          command_args = [Poise::Utils::Win32.reparse_command(*command_args)]
        end
        # Call Chef's shell_out wrapper.
        shell_out(*command_args, **options)
      end

      # The `error!` version of {#poise_shell_out}.
      #
      # @see #poise_shell_out
      # @return [Mixlib::ShellOut]
      def poise_shell_out!(*command_args)
        poise_shell_out(*command_args).tap(&:error!)
      end
    end
  end
end
