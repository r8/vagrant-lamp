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

require 'chef/provider'
require 'poise'


module PoisePython
  module PythonProviders
    class Base < Chef::Provider
      include Poise(inversion: :python_runtime)

      # Set default inversion options.
      #
      # @api private
      def self.default_inversion_options(node, new_resource)
        super.merge({
          get_pip_url: new_resource.get_pip_url,
          pip_version: new_resource.pip_version,
          setuptools_version: new_resource.setuptools_version,
          version: new_resource.version,
          virtualenv_version: new_resource.virtualenv_version,
          wheel_version: new_resource.wheel_version,
        })
      end

      # The `install` action for the `python_runtime` resource.
      #
      # @return [void]
      def action_install
        # First inner converge for the Python install.
        notifying_block do
          install_python
        end
        # Second inner converge for the support tools. This is needed because
        # we run a python command to check if venv is available.
        notifying_block do
          install_pip
          install_setuptools
          install_wheel
          install_virtualenv
        end
      end

      # The `uninstall` action for the `python_runtime` resource.
      #
      # @abstract
      # @return [void]
      def action_uninstall
        notifying_block do
          uninstall_python
        end
      end

      # The path to the `python` binary. This is an output property.
      #
      # @abstract
      # @return [String]
      def python_binary
        raise NotImplementedError
      end

      # The environment variables for this Python. This is an output property.
      #
      # @return [Hash<String, String>]
      def python_environment
        {}
      end

      private

      # Install the Python runtime. Must be implemented by subclass.
      #
      # @abstract
      # @return [void]
      def install_python
        raise NotImplementedError
      end

      # Uninstall the Python runtime. Must be implemented by subclass.
      #
      # @abstract
      # @return [void]
      def uninstall_python
        raise NotImplementedError
      end

      # Install pip in to the Python runtime.
      #
      # @return [void]
      def install_pip
        pip_version_or_url = options[:pip_version]
        return unless pip_version_or_url
        # If there is a : in the version, use it as a URL and ignore the actual
        # URL option.
        if pip_version_or_url.is_a?(String) && pip_version_or_url.include?(':')
          pip_version = nil
          pip_url = pip_version_or_url
        else
          pip_version = pip_version_or_url
          pip_url = options[:get_pip_url]
        end
        Chef::Log.debug("[#{new_resource}] Installing pip #{pip_version || 'latest'}")
        # Install or bootstrap pip.
        python_runtime_pip new_resource.name do
          parent new_resource
          # If the version is `true`, don't pass it at all.
          version pip_version if pip_version.is_a?(String)
          get_pip_url pip_url
        end
      end

      # Install setuptools in to the Python runtime. This is very similar to the
      # {#install_wheel} and {#install_virtualenv} methods but they are kept
      # separate for the benefit of subclasses being able to override them
      # individually.
      #
      # @return [void]
      def install_setuptools
        # Captured because #options conflicts with Chef::Resource::Package#options.
        setuptools_version = options[:setuptools_version]
        return unless setuptools_version
        Chef::Log.debug("[#{new_resource}] Installing setuptools #{setuptools_version == true ? 'latest' : setuptools_version}")
        # Install setuptools via pip.
        python_package 'setuptools' do
          parent_python new_resource
          version setuptools_version if setuptools_version.is_a?(String)
        end
      end

      # Install wheel in to the Python runtime.
      #
      # @return [void]
      def install_wheel
        # Captured because #options conflicts with Chef::Resource::Package#options.
        wheel_version = options[:wheel_version]
        return unless wheel_version
        Chef::Log.debug("[#{new_resource}] Installing wheel #{wheel_version == true ? 'latest' : wheel_version}")
        # Install wheel via pip.
        python_package 'wheel' do
          parent_python new_resource
          version wheel_version if wheel_version.is_a?(String)
        end
      end

      # Install virtualenv in to the Python runtime.
      #
      # @return [void]
      def install_virtualenv
        # Captured because #options conflicts with Chef::Resource::Package#options.
        virtualenv_version = options[:virtualenv_version]
        return unless virtualenv_version
        # Check if the venv module exists.
        cmd = poise_shell_out([python_binary, '-m', 'venv', '-h'], environment: python_environment)
        return unless cmd.error?
        Chef::Log.debug("[#{new_resource}] Installing virtualenv #{virtualenv_version == true ? 'latest' : virtualenv_version}")
        # Install virtualenv via pip.
        python_package 'virtualenv' do
          parent_python new_resource
          version virtualenv_version if virtualenv_version.is_a?(String)
        end
      end

    end
  end
end
