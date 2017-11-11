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

require 'poise'

# Break a require loop by letting autoload work its magic.
require 'poise_python'


module PoisePython
  module Resources
    # (see PythonVirtualenv::Resource)
    # @since 1.0.0
    module PythonVirtualenv
      # A `python_virtualenv` resource to manage Python virtual environments.
      #
      # @provides python_virtualenv
      # @action create
      # @action delete
      # @example
      #   python_virtualenv '/opt/myapp'
      class Resource < PoisePython::Resources::PythonRuntime::Resource
        include PoisePython::PythonCommandMixin
        provides(:python_virtualenv)
        # Add create and delete actions as more semantically relevant aliases.
        default_action(:create)
        actions(:create, :delete)

        # @!attribute path
        #   Path to create the environment at.
        #   @return [String]
        attribute(:path, kind_of: String, name_attribute: true)
        # @!attribute group
        #   System group to create the virtualenv.
        #   @return [String, Integer, nil]
        attribute(:group, kind_of: [String, Integer, NilClass])
        # @!attribute system_site_packages
        #   Enable or disable visibilty of system packages in the environment.
        #   @return [Boolean]
        attribute(:system_site_packages, equal_to: [true, false], default: false)
        # @!attribute user
        #   System user to create the virtualenv.
        #   @return [String, Integer, nil]
        attribute(:user, kind_of: [String, Integer, NilClass])

        # Lock the default provider.
        #
        # @api private
        def initialize(*args)
          super
          # Sidestep all the normal provider lookup stuffs. This is kind of
          # gross but it will do for now. The hard part is that the base classes
          # for the resource and provider are using Poise::Inversion, which we
          # don't want to use for python_virtualenv.
          @provider = Provider
        end

        # Upstream attribute we don't support. Sets are an error and gets always
        # return nil.
        #
        # @api private
        # @param arg [Object] Ignored
        # @return [nil]
        def version(arg=nil)
          raise NoMethodError if arg
        end

        # (see #version)
        def virtualenv_version(arg=nil)
          raise NoMethodError if arg
        end
      end

      # The default provider for `python_virtualenv`.
      #
      # @see Resource
      # @provides python_virtualenv
      class Provider < PoisePython::PythonProviders::Base
        include PoisePython::PythonCommandMixin
        provides(:python_virtualenv)

        # Alias our actions. Slightly annoying that they will show in
        # tracebacks with the original names, but oh well.
        alias_method :action_create, :action_install
        alias_method :action_delete, :action_uninstall

        def python_binary
          if node.platform_family?('windows')
            ::File.join(new_resource.path, 'Scripts', 'python.exe')
          else
            ::File.join(new_resource.path, 'bin', 'python')
          end
        end

        def python_environment
          if new_resource.parent_python
            new_resource.parent_python.python_environment
          else
            {}
          end
        end

        private

        def install_python
          return if ::File.exist?(python_binary)

          cmd = python_shell_out(%w{-m venv -h})
          if cmd.error?
            converge_by("Creating virtualenv at #{new_resource.path}") do
              create_virtualenv(%w{virtualenv})
            end
          else
            converge_by("Creating venv at #{new_resource.path}") do
              use_withoutpip = cmd.stdout.include?('--without-pip')
              create_virtualenv(use_withoutpip ? %w{venv --without-pip} : %w{venv})
            end
          end
        end

        def uninstall_python
          directory new_resource.path do
            action :delete
            recursive true
          end
        end

        # Don't install virtualenv inside virtualenv.
        #
        # @api private
        # @return [void]
        def install_virtualenv
          # This space left intentionally blank.
        end

        # Create a virtualenv using virtualenv or venv.
        #
        # @param driver [Array<String>] Command snippet to actually make it.
        # @return [void]
        def create_virtualenv(driver)
          cmd = %w{-m} + driver
          cmd << '--system-site-packages' if new_resource.system_site_packages
          cmd << new_resource.path
          python_shell_out!(cmd, environment: {
            # Use the environment variables to cope with older virtualenv not
            # supporting --no-wheel. The env var will be ignored if unsupported.
            'VIRTUALENV_NO_PIP' => '1',
            'VIRTUALENV_NO_SETUPTOOLS' => '1',
            'VIRTUALENV_NO_WHEEL' => '1',
          }, group: new_resource.group, user: new_resource.user)
        end

      end
    end
  end
end
