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

require 'poise/utils'
require 'poise_languages'


module PoisePython
  # Mixin for resources and providers which run Python commands.
  #
  # @since 1.0.0
  module PythonCommandMixin
    include Poise::Utils::ResourceProviderMixin

    # Mixin for resources which run Python commands.
    module Resource
      include PoiseLanguages::Command::Mixin::Resource(:python)

      # Wrapper for setting the parent to be a virtualenv.
      #
      # @param name [String] Name of the virtualenv resource.
      # @return [void]
      def virtualenv(name)
        if name.is_a?(PoisePython::Resources::PythonVirtualenv::Resource)
          parent_python(name)
        else
          parent_python("python_virtualenv[#{name}]")
        end
      end
    end

    module Provider
      include PoiseLanguages::Command::Mixin::Provider(:python)
    end
  end
end
