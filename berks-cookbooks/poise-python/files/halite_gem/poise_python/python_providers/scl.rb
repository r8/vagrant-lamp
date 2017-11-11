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
require 'poise_languages'

require 'poise_python/error'
require 'poise_python/python_providers/base'


module PoisePython
  module PythonProviders
    class Scl < Base
      include PoiseLanguages::Scl::Mixin
      provides(:scl)
      scl_package('3.5.1', 'rh-python35', 'rh-python35-python-devel', '>= 7.0')
      scl_package('3.4.2', 'rh-python34', 'rh-python34-python-devel')
      scl_package('3.3.2', 'python33', 'python33-python-devel')
      scl_package('2.7.8', 'python27', 'python27-python-devel')

      def python_binary
        ::File.join(scl_folder, 'root', 'usr', 'bin', 'python')
      end

      def python_environment
        scl_environment
      end

      private

      def install_python
        install_scl_package
      end

      def uninstall_python
        uninstall_scl_package
      end

    end
  end
end

