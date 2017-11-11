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
    class PortablePyPy < Base
      provides(:portable_pypy)
      include PoiseLanguages::Static(
        name: 'pypy',
        versions: %w{5.7.1 5.6 5.4.1 5.4 5.3.1 5.1.1 5.1 5.0.1 5.0 4.0.1 2.6.1 2.5.1 2.5 2.4 2.3.1 2.3 2.2.1 2.2 2.1 2.0.2},
        machines: %w{linux-i686 linux-x86_64},
        url: 'https://bitbucket.org/squeaky/portable-pypy/downloads/pypy-%{version}-%{kernel}_%{machine}-portable.tar.bz2'
      )

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


