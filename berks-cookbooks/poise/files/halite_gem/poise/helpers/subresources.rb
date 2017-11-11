#
# Copyright 2015-2016, Noah Kantrowitz
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


module Poise
  module Helpers
    # Mixins and helpers for managing subresources, resources with a
    # parent/child relationship.
    #
    # @since 2.0.0
    module Subresources
      autoload :Child, 'poise/helpers/subresources/child'
      autoload :Container, 'poise/helpers/subresources/container'
    end
  end
end
