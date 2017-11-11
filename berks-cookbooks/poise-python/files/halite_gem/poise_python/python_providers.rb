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

require 'chef/platform/provider_priority_map'

require 'poise_python/python_providers/dummy'
require 'poise_python/python_providers/msi'
require 'poise_python/python_providers/portable_pypy'
require 'poise_python/python_providers/portable_pypy3'
require 'poise_python/python_providers/scl'
require 'poise_python/python_providers/system'


module PoisePython
  # Inversion providers for the python_runtime resource.
  #
  # @since 1.0.0
  module PythonProviders
    autoload :Base, 'poise_python/python_providers/base'

    Chef::Platform::ProviderPriorityMap.instance.priority(:python_runtime, [
      PoisePython::PythonProviders::Dummy,
      PoisePython::PythonProviders::Msi,
      PoisePython::PythonProviders::PortablePyPy3,
      PoisePython::PythonProviders::PortablePyPy,
      PoisePython::PythonProviders::Scl,
      PoisePython::PythonProviders::System,
    ])
  end
end
