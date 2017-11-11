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

require 'poise_python/python_providers/base'


module PoisePython
  module PythonProviders
    # Inversion provider for the `python_runtime` resource to use a fake Python,
    # for use in unit tests.
    #
    # @since 1.1.0
    # @provides dummy
    class Dummy < Base
      provides(:dummy)

      # Enable by default on ChefSpec.
      #
      # @api private
      def self.provides_auto?(node, _resource)
        node.platform?('chefspec')
      end

      # Manual overrides for dummy data.
      #
      # @api private
      def self.default_inversion_options(node, resource)
        super.merge({
          python_binary: ::File.join('', 'python'),
          python_environment: nil,
        })
      end

      # The `install` action for the `python_runtime` resource.
      #
      # @return [void]
      def action_install
        # This space left intentionally blank.
      end

      # The `uninstall` action for the `python_runtime` resource.
      #
      # @return [void]
      def action_uninstall
        # This space left intentionally blank.
      end

      # Path to the non-existent python.
      #
      # @return [String]
      def python_binary
        options['python_binary']
      end

      # Environment for the non-existent python.
      #
      # @return [String]
      def python_environment
        options['python_environment'] || super
      end

    end
  end
end

