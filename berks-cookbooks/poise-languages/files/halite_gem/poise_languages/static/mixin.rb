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

require 'poise_languages/static/resource'


module PoiseLanguages
  module Static
    # Mixin for language providers to install from static archives.
    #
    # @since 1.1.0
    module Mixin
      private

      def install_static
        url = static_url
        poise_languages_static static_folder do
          source url
          strip_components options['strip_components']
        end
      end

      def uninstall_static
        install_static.tap do |r|
          r.action(:uninstall)
        end
      end

      def static_folder
        options['path'] || ::File.join('', 'opt', "#{self.class.static_name}-#{options['static_version']}")
      end

      def static_url
        options['url'] % static_url_variables
      end

      def static_url_variables
        {
          version: options['static_version'],
          kernel: node['kernel']['name'].downcase,
          machine: node['kernel']['machine'],
          machine_label: self.class.static_machine_label_wrapper(node, new_resource),
        }
      end

      module ClassMethods
        attr_accessor :static_name
        attr_accessor :static_versions
        attr_accessor :static_machines
        attr_accessor :static_url
        attr_accessor :static_strip_components
        attr_accessor :static_retries

        def provides_auto?(node, resource)
          # Check that the version starts with our project name and the machine
          # we are on is supported.
          resource.version.to_s =~ /^#{static_name}(-|$)/ && static_machines.include?(static_machine_label_wrapper(node, resource))
        end

        # Set some default inversion provider options. Package name can't get
        # a default value here because that would complicate the handling of
        # {system_package_candidates}.
        #
        # @api private
        def default_inversion_options(node, resource)
          super.merge({
            # Path to install the package. Defaults to /opt/name-version.
            path: nil,
            # Number of times to retry failed downloads.
            retries: static_retries,
            # Full version number for use in interpolation.
            static_version: static_version(node, resource),
            # Value to pass to tar --strip-components.
            strip_components: static_strip_components,
            # URL template to download from.
            url: static_url,
          })
        end

        def static_options(name: nil, versions: [], machines: %w{linux-i686 linux-x86_64}, url: nil, strip_components: 1, retries: 5)
          raise PoiseLanguages::Error.new("Static archive URL is required, on #{self}") unless url
          self.static_name = name || provides.to_s
          self.static_versions = versions
          self.static_machines = Set.new(machines)
          self.static_url = url
          self.static_strip_components = strip_components
          self.static_retries = retries
        end

        def static_version(node, resource)
          raw_version = resource.version.to_s.gsub(/^#{static_name}(-|$)/, '')
          if static_versions.include?(raw_version)
            raw_version
          else
            # Prefix match or just use the given version number if not found.
            # This allow mild future proofing in some cases.
            static_versions.find {|v| v.start_with?(raw_version) } || raw_version
          end
        end

        def static_machine_label(node, _resource=nil)
          "#{node['kernel']['name'].downcase}-#{node['kernel']['machine']}"
        end

        # Wrapper for {#static_machine_label} because I need to add an argument.
        # This preserves backwards compat.
        #
        # @api private
        def static_machine_label_wrapper(node, resource)
          args = [node]
          arity = method(:static_machine_label).arity
          args << resource if arity > 1 || arity < 0
          static_machine_label(*args)
        end

        def included(klass)
          super
          klass.extend ClassMethods
        end

      end

      extend ClassMethods

      Poise::Utils.parameterized_module(self) do |opts|
        static_options(opts)
      end

    end
  end
end
