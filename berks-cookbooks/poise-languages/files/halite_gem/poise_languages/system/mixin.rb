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

require 'poise_languages/system/resource'


module PoiseLanguages
  module System
    module Mixin

      private

      # Install a language using system packages.
      #
      # @api public
      # @return [PoiseLanguages::System::Resource]
      def install_system_packages(&block)
        dev_package_overrides = system_dev_package_overrides
        poise_languages_system system_package_name do
          # Otherwise use the default install action.
          action(:upgrade) if options['package_upgrade']
          parent new_resource
          # Don't pass true because we want the default computed behavior for that.
          dev_package options['dev_package'] unless options['dev_package'] == true
          dev_package_overrides dev_package_overrides
          package_version options['package_version'] if options['package_version']
          version options['version']
          instance_exec(&block) if block
        end
      end

      # Uninstall a language using system packages.
      #
      # @api public
      # @return [PoiseLanguages::System::Resource]
      def uninstall_system_packages(&block)
        install_system_packages.tap do |r|
          r.action(:uninstall)
          r.instance_exec(&block) if block
        end
      end

      # Compute all possible package names for a given language version. Must be
      # implemented by mixin users. Versions are expressed as prefixes so ''
      # matches all versions, '2' matches 2.x.
      #
      # @abstract
      # @api public
      # @param version [String] Language version prefix.
      # @return [Array<String>]
      def system_package_candidates(version)
        raise NotImplementedError
      end

      # Compute the default package name for the base package for this language.
      #
      # @api public
      # @return [String]
      def system_package_name
        # If we have an override, just use that.
        return options['package_name'] if options['package_name']
        # Look up all packages for this language on this platform.
        system_packages = self.class.packages && node.value_for_platform(self.class.packages)
        if !system_packages && self.class.default_package
          Chef::Log.debug("[#{new_resource}] No known packages for #{node['platform']} #{node['platform_version']}, defaulting to '#{self.class.default_package}'.") if self.class.packages
          system_packages = Array(self.class.default_package)
        end

        # Find the first value on system_package_candidates that is in system_packages.
        system_package_candidates(options['version'].to_s).each do |name|
          return name if system_packages.include?(name)
        end
        # No valid candidate. Sad trombone.
        raise PoiseLanguages::Error.new("Unable to find a candidate package for version #{options['version'].to_s.inspect}. Please set package_name provider option for #{new_resource}.")
      end

      # A hash mapping package names to their override dev package name.
      #
      # @api public
      # @return [Hash<String, String>]
      def system_dev_package_overrides
        {}
      end

      module ClassMethods
        # Install this as a default provider if nothing else matched. Might not
        # work, but worth a try at least for unknown platforms. Windows is a
        # whole different story, and OS X might work sometimes so at least try.
        #
        # @api private
        def provides_auto?(node, resource)
          !node.platform_family?('windows')
        end

        # Set some default inversion provider options. Package name can't get
        # a default value here because that would complicate the handling of
        # {system_package_candidates}.
        #
        # @api private
        def default_inversion_options(node, resource)
          super.merge({
            # Install dev headers?
            dev_package: true,
            # Manual overrides for package name and/or version.
            package_name: nil,
            package_version: nil,
            # Set to true to use action :upgrade on system packages.
            package_upgrade: false,
          })
        end

        # @overload packages()
        #   Return a hash formatted for value_for_platform returning an Array
        #   of package names.
        #   @return [Hash]
        # @overload packages(default_package, packages)
        #   Define what system packages are available for this language on each
        #   platform.
        #   @param default_package [String] Default package name for platforms
        #     not otherwise defined.
        #   @param [Hash] Hash formatted for value_for_platform returning an
        #     Array of package names.
        #   @return [Hash]
        def packages(default_package=nil, packages=nil)
          self.default_package(default_package) if default_package
          if packages
            @packages = packages
          end
          @packages
        end

        # @overload default_package()
        #   Return the default package name for platforms not otherwise defined.
        #   @return [String]
        # @overload default_package(name)
        #   Set the default package name for platforms not defined in {packages}.
        #   @param name [String] Package name.
        #   @return [String]
        def default_package(name=nil)
          if name
            @default_package = name
          end
          @default_package
        end

        # @api private
        def included(klass)
          super
          klass.extend(ClassMethods)
        end
      end

      extend ClassMethods

    end
  end
end
