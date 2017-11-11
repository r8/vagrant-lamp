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

require 'poise/utils/win32'


module Poise
  module Helpers
    # A resource mixin to intercept properties named `user`, `group`, or `owner`,
    # if their default value is `'root'` and make it work on Windows (and
    # FreeBSD, AIX).
    #
    # @since 2.7.0
    # @example
    #   class MyResource < Chef::Resource
    #     include Poise::Helpers::Win32User
    #     attribute(:user, default: 'root')
    #     attribute(:group, default: 'root')
    #   end
    # @example Avoiding automatic translation
    #   class MyResource < Chef::Resource
    #     include Poise::Helpers::Win32User
    #     attribute(:user, default: lazy { 'root' })
    #     attribute(:group, default: lazy { 'root' })
    #   end
    module Win32User
      # User-ish property names.
      # @api private
      USER_PROPERTIES = ['user', :user, 'owner', :owner]

      # Group-ish property names.
      # @api private
      GROUP_PROPERTIES = ['group', :group]

      # Intercept property access to swap out the default value.
      # @api private
      def set_or_return(symbol, arg, options={})
        if options && options[:default] == 'root'
          if USER_PROPERTIES.include?(symbol) && node.platform_family?('windows')
            options = options.dup
            options[:default] = Poise::Utils::Win32.admin_user
          elsif GROUP_PROPERTIES.include?(symbol)
            options = options.dup
            options[:default] = node['root_group']
          end
        end
        super(symbol, arg, options)
      end
    end
  end
end
