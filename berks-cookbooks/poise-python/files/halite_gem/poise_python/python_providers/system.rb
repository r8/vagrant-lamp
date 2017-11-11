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
    class System < Base
      include PoiseLanguages::System::Mixin
      provides(:system)
      packages('python', {
        debian: {
          '~> 8.0' => %w{python3.4 python2.7},
          '~> 7.0' => %w{python3.2 python2.7 python2.6},
          '~> 6.0' => %w{python3.1 python2.6 python2.5},
        },
        ubuntu: {
          '16.04' => %w{python3.5 python2.7},
          '14.04' => %w{python3.4 python2.7},
          '12.04' => %w{python3.2 python2.7},
          '10.04' => %w{python3.1 python2.6},
        },
        redhat: {default: %w{python}},
        centos: {default: %w{python}},
        fedora: {default: %w{python3 python}},
        amazon: {default: %w{python34 python27 python26 python}},
      })

      # Output value for the Python binary we are installing. Seems to match
      # package name on all platforms I've checked.
      def python_binary
        ::File.join('', 'usr', 'bin', system_package_name)
      end

      private

      def install_python
        install_system_packages
      end

      def uninstall_python
        uninstall_system_packages
      end

      def system_package_candidates(version)
        [].tap do |names|
          # For two (or more) digit versions.
          if match = version.match(/^(\d+\.\d+)/)
            # Debian style pythonx.y
            names << "python#{match[1]}"
            # Amazon style pythonxy
            names << "python#{match[1].gsub(/\./, '')}"
          end
          # Aliases for 2 and 3.
          if version == '3' || version == ''
            names.concat(%w{python3.5 python35 python3.4 python34 python3.3 python33 python3.2 python32 python3.1 python31 python3.0 python30 python3})
          end
          if version == '2' || version == ''
            names.concat(%w{python2.7 python27 python2.6 python26 python2.5 python25})
          end
          # For RHEL and friends.
          names << 'python'
          names.uniq!
        end
      end

    end
  end
end
