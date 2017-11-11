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


module PoiseLanguages
  # Helpers for installing languages from static archives.
  #
  # @since 1.1.0
  module Static
    autoload :Mixin, 'poise_languages/static/mixin'
    autoload :Resource, 'poise_languages/static/resource'
    autoload :Provider, 'poise_languages/static/resource'

    Poise::Utils.parameterized_module(self) do |opts|
      require 'poise_languages/static/mixin'
      include PoiseLanguages::Static::Mixin(opts)
    end
  end
end
