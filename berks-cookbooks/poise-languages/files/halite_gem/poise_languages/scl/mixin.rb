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

require 'poise_languages/scl/resource'


module PoiseLanguages
  module Scl
    module Mixin
      private

      def install_scl_package
        pkg = scl_package
        poise_languages_scl options[:package_name] || pkg[:name] do
          action :upgrade if options[:package_upgrade]
          dev_package options[:dev_package] == true ? pkg[:devel_name] : options[:dev_package]
          parent new_resource
          version options[:package_version]
        end
      end

      def uninstall_scl_package
        install_scl_package.tap do |r|
          r.action(:uninstall)
        end
      end

      def scl_package
        @scl_package ||= self.class.find_scl_package(node, options['version']).tap do |p|
          raise PoiseLanguages::Error.new("No SCL repoistory package for #{node['platform']} #{node['platform_version']}") unless p
        end
      end

      def scl_folder
        ::File.join('', 'opt', 'rh', scl_package[:name])
      end

      def scl_environment
        parse_enable_file(::File.join(scl_folder, 'enable'))
      end

      # Parse an SCL enable file to extract the environment variables set in it.
      #
      # @param path [String] Path to the enable file.
      # @return [Hash<String, String>]
      def parse_enable_file(path, env={})
        # Doesn't exist yet, so running Python will fail anyway. Just make sure
        # it fails in the expected way.
        return {} unless File.exist?(path)
        # Yes, this is a bash parser in regex. Feel free to be mad at me.
        IO.readlines(path).inject(env) do |memo, line|
          if match = line.match(/^export (\w+)=(.*)$/)
            memo[match[1]] = match[2].gsub(/\$(?:\{(\w+)(:\+:\$\{\w+\})?\}|(\w+))/) do
              key = $1 || $3
              value = (memo[key] || ENV[key]).to_s
              value = ":#{value}" if $2 && !value.empty?
              value
            end
          elsif match = line.match(/^\. scl_source enable (\w+)$/)
            # Parse another file.
            memo.update(parse_enable_file(::File.join('', 'opt', 'rh', match[1], 'enable'), memo))
          end
          memo
        end
      end

      module ClassMethods
        def provides_auto?(node, resource)
          # They don't build 32-bit versions for these and only for RHEL/CentOS.
          # TODO: What do I do about Fedora and/or Amazon?
          return false unless node['kernel']['machine'] == 'x86_64' && node.platform?('redhat', 'centos')
          version = inversion_options(node, resource)['version']
          !!find_scl_package(node, version)
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

        def find_scl_package(node, version)
          platform_version = ::Gem::Version.create(node['platform_version'])
          # Filter out anything that doesn't match this EL version.
          candidate_packages = scl_packages.select {|p| p[:platform_version].satisfied_by?(platform_version) }
          # Find something with a prefix match on the Python version.
          candidate_packages.find {|p| p[:version].start_with?(version) }
        end

        private

        def scl_packages
          @scl_packages ||= []
        end

        def scl_package(version, name, devel_name=nil, platform_version='>= 6.0')
          scl_packages << {version: version, name: name, devel_name: devel_name, platform_version: ::Gem::Requirement.create(platform_version)}
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
