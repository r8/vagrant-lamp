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

require 'chef/resource'
require 'poise'


module PoisePython
  module Resources
    # (see PythonRuntime::Resource)
    # @since 1.0.0
    module PythonRuntime
      # A `python_runtime` resource to manage Python installations.
      #
      # @provides python_runtime
      # @action install
      # @action uninstall
      # @example
      #   python_runtime '2.7'
      class Resource < Chef::Resource
        include Poise(inversion: true, container: true)
        provides(:python_runtime)
        actions(:install, :uninstall)

        # @!attribute version
        #   Version of Python to install. The version is prefix-matched so `'2'`
        #   will install the most recent Python 2.x, and so on.
        #   @return [String]
        #   @example Install any version
        #     python_runtime 'any' do
        #       version ''
        #     end
        #   @example Install Python 2.7
        #     python_runtime '2.7'
        attribute(:version, kind_of: String, name_attribute: true)
        # @!attribute get_pip_url
        #   URL to download the get-pip.py script from. If not sure, the default
        #   of https://bootstrap.pypa.io/get-pip.py is used. If you want to skip
        #   the pip installer entirely, set {#pip_version} to `false`.
        #   @return [String]
        attribute(:get_pip_url, kind_of: String, default: 'https://bootstrap.pypa.io/get-pip.py')
        # @!attribute pip_version
        #   Version of pip to install. If set to `true`, the latest available
        #   pip will be used. If set to `false`, pip will not be installed. If
        #   set to a URL, that will be used as the URL to get-pip.py instead of
        #   {#get_pip_url}.
        #   @note Disabling the pip install may result in other resources being
        #     non-functional.
        #   @return [String, Boolean]
        attribute(:pip_version, kind_of: [String, TrueClass, FalseClass], default: true)
        # @!attribute setuptools_version
        #   Version of Setuptools to install. It set to `true`, the latest
        #   available version will be used. If set to `false`, setuptools will
        #   not be installed.
        #   @return [String, Boolean]
        attribute(:setuptools_version, kind_of: [String, TrueClass, FalseClass], default: true)
        # @!attribute virtualenv_version
        #   Version of Virtualenv to install. It set to `true`, the latest
        #   available version will be used. If set to `false`, virtualenv will
        #   not be installed. Virtualenv will never be installed if the built-in
        #   venv module is available.
        #   @note Disabling the virtualenv install may result in other resources
        #     being non-functional.
        #   @return [String, Boolean]
        attribute(:virtualenv_version, kind_of: [String, TrueClass, FalseClass], default: true)
        # @!attribute wheel_version
        #   Version of Wheel to install. It set to `true`, the latest
        #   available version will be used. If set to `false`, wheel will not
        #   be installed.
        #   @return [String, Boolean]
        attribute(:wheel_version, kind_of: [String, TrueClass, FalseClass], default: true)

        # The path to the `python` binary for this Python installation. This is
        # an output property.
        #
        # @return [String]
        # @example
        #   execute "#{resources('python_runtime[2.7]').python_binary} myapp.py"
        def python_binary
          provider_for_action(:python_binary).python_binary
        end

        # The environment variables for this Python installation. This is an
        # output property.
        #
        # @return [Hash<String, String>]
        # @example
        #   execute '/opt/myapp.py' do
        #     environment resources('python_runtime[2.7]').python_environment
        #   end
        def python_environment
          provider_for_action(:python_environment).python_environment
        end
      end

      # Providers can be found under lib/poise_python/python_providers/
    end
  end
end
