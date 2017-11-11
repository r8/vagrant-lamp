#
# Copyright 2016, Noah Kantrowitz
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


module Poise
  module Utils
    # Utilities for working with Windows.
    #
    # @since 2.7.0
    module Win32
      extend self

      # Code borrowed from https://github.com/chef-cookbooks/chef-client/blob/master/libraries/helpers.rb
      # Used under the terms of the Apache v2 license.
      # Copyright 2012-2016, John Dewey

      # Run a WMI query and extracts a property. This assumes Chef has already
      # loaded the win32 libraries.
      #
      # @api private
      # @param wmi_property [Symbol] Property to extract.
      # @param wmi_query [String] Query to run.
      # @return [String]
      def wmi_property_from_query(wmi_property, wmi_query)
        @wmi = ::WIN32OLE.connect('winmgmts://')
        result = @wmi.ExecQuery(wmi_query)
        return nil unless result.each.count > 0
        result.each.next.send(wmi_property)
      end

      # Find the name of the Administrator user, give or take localization.
      #
      # @return [String]
      def admin_user
        if defined?(::WIN32OLE)
          wmi_property_from_query(:name, "select * from Win32_UserAccount where sid like 'S-1-5-21-%-500' and LocalAccount=True")
        else
          # Warn except under ChefSpec because it will just annoy people.
          Chef::Log.warn('[Poise::Utils::Win32] Unable to query admin user, WIN32OLE not available') unless defined?(ChefSpec)
          'Administrator'
        end
      end

      # Escaping that is compatible with CommandLineToArgvW. Based on
      # https://blogs.msdn.microsoft.com/twistylittlepassagesallalike/2011/04/23/everyone-quotes-command-line-arguments-the-wrong-way/
      #
      # @api private
      # @param string [String] String to escape.
      # @return [String]
      def argv_quote(string, force_quote: false)
        if !force_quote && !string.empty? && string !~ /[ \t\n\v"]/
          # Nothing fancy, no escaping needed.
          string
        else
          command_line = '"'
          i = 0
          while true
            number_backslashes = 0

            while i != string.size && string[i] == '\\'
              i += 1
              number_backslashes += 1
            end

            if i == string.size
              # Escape all backslashes, but let the terminating
              # double quotation mark we add below be interpreted
              # as a metacharacter.
              command_line << '\\' * (number_backslashes * 2)
              break
            elsif string[i] == '"'
              # Escape all backslashes and the following
              # double quotation mark.
              command_line << '\\' * ((number_backslashes * 2) + 1)
              command_line << '"'
            else
              # Backslashes aren't special here.
              command_line << '\\' * number_backslashes
              command_line << string[i]
            end
            i += 1
          end
          command_line << '"'
          command_line
        end
      end

      # Take a string or array command in the format used by shell_out et al and
      # create something we can use on Windows.
      #
      # @
      def reparse_command(*args)
        array_mode = !(args.length == 1 && args.first.is_a?(String))
        # At some point when mixlib-shellout groks array commands on Windows,
        # we should support that here.
        parsed_args = array_mode ? args.flatten : Shellwords.split(args.first)
        cmd = parsed_args.map {|s| argv_quote(s) }.join(' ')
        if array_mode
          # This fails on non-Windows because of win32/process.
          require 'mixlib/shellout/windows'
          if Mixlib::ShellOut::Windows::Utils.should_run_under_cmd?(cmd)
            # If we are in array mode, try to make cmd.exe keep its grubby paws
            # off our metacharacters.
            cmd = cmd.each_char.map {|c| '^'+c }.join('')
          end
        end
        cmd
      end

    end
  end
end
