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

require 'poise_languages/static'

require 'poise_python/error'
require 'poise_python/python_providers/base'


module PoisePython
  module PythonProviders
    class PortablePyPy3 < Base
      provides(:portable_pypy3)
      include PoiseLanguages::Static(
        name: 'pypy3',
        # Don't put prereleases first so they aren't used for prefix matches on ''.
        versions: %w{2.4 5.7.1-beta 5.7-beta 5.5-alpha-20161014 5.5-alpha-20161013 5.2-alpha-20160602 2.3.1},
        machines: %w{linux-i686 linux-x86_64},
        url: 'https://bitbucket.org/squeaky/portable-pypy/downloads/pypy3-%{version}-%{kernel}_%{machine}-portable.tar.bz2'
      )

      def self.default_inversion_options(node, resource)
        super.tap do |options|
          if resource.version && resource.version =~ /^(pypy3-)?5(\.\d)?/
            # We need a different default base URL for pypy3.3
            # This is the same as before but `/pypy3.3` as the prefix on the filename.
            basename = if $2 == '.2' || $2 == '.5'
              'pypy3.3'
            else
              'pypy3.5'
            end
            options['url'] = "https://bitbucket.org/squeaky/portable-pypy/downloads/#{basename}-%{version}-%{kernel}_%{machine}-portable.tar.bz2"
          end
        end
      end

      def python_binary
        ::File.join(static_folder, 'bin', 'pypy')
      end

      private

      def install_python
        install_static
      end

      def uninstall_python
        uninstall_static
      end

    end
  end
end

