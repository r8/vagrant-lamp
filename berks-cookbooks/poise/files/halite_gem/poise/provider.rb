#
# Copyright 2013-2016, Noah Kantrowitz
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

require 'poise/helpers'
require 'poise/utils'


module Poise
  # Master provider mixin for Poise-based providers.
  #
  # @since 1.0.0
  # @example Default helpers.
  #   class MyProvider < Chef::Provider
  #     include Poise::Provider
  #   end
  # @example With optional helpers.
  #   class MyProvider < Chef::Provider
  #     include Poise::Provider
  #     poise_inversion(MyResource)
  #   end
  module Provider
    include Poise::Helpers::DefinedIn
    include Poise::Helpers::LWRPPolyfill
    # IncludeRecipe must come after LWRPPolyfill because that pulls in the
    # recipe DSL which has its own #include_recipe.
    include Poise::Helpers::IncludeRecipe
    include Poise::Helpers::NotifyingBlock
    include Poise::Utils::ShellOut

    # @!classmethods
    module ClassMethods
      def poise_inversion(resource, attribute=nil)
        include Poise::Helpers::Inversion
        inversion_resource(resource)
        inversion_attribute(attribute) if attribute
      end

      def included(klass)
        super
        klass.extend(ClassMethods)
      end
    end

    extend ClassMethods
  end
end
