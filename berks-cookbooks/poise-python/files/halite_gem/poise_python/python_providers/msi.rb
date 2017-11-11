#
# Copyright 2016-2017, Noah Kantrowitz
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

require 'poise_python/error'
require 'poise_python/python_providers/base'


module PoisePython
  module PythonProviders
    class Msi < Base
      provides(:msi)

      MSI_VERSIONS = %w{3.4.4 3.3.5 3.2.5 3.1.4 3.0.1 2.7.10 2.6.5 2.5.4}

      def self.provides_auto?(node, resource)
        # Only enable by default on Windows and not for Python 3.5 because that
        # uses the win_binaries provider.
        node.platform_family?('windows') #&& resource.version != '3' && ::Gem::Requirement.create('< 3.5').satisfied_by(::Gem::Version.create(new_resource.version))
      end

      def python_binary
        return options['python_binary'] if options['python_binary']
        if package_version =~ /^(\d+)\.(\d+)\./
          ::File.join(ENV['SystemDrive'], "Python#{$1}#{$2}", 'python.exe')
        else
          raise "Can't find Python binary for #{package_version}"
        end
      end

      private

      def install_python
        version = package_version
        windows_package 'python' do
          source "https://www.python.org/ftp/python/#{version}/python-#{version}#{node['machine'] == 'x86_64' ? '.amd64' : ''}.msi"
        end
      end

      def uninstall_python
        raise NotImplementedError
      end

      def package_version
        MSI_VERSIONS.find {|ver| ver.start_with?(new_resource.version) } || new_resource.version
      end

    end
  end
end
