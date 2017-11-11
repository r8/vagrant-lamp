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
  # Master resource mixin for Poise-based resources.
  #
  # @since 1.0.0
  # @example Default helpers.
  #   class MyResource < Chef::Resource
  #     include Poise::Resource
  #   end
  # @example With optional helpers.
  #   class MyResource < Chef::Resource
  #     include Poise::Resource
  #     poise_subresource(MyParent)
  #     poise_fused
  #   end
  module Resource
    include Poise::Helpers::ChefspecMatchers
    include Poise::Helpers::DefinedIn
    include Poise::Helpers::LazyDefault if Poise::Helpers::LazyDefault.needs_polyfill?
    include Poise::Helpers::LWRPPolyfill
    include Poise::Helpers::OptionCollector
    include Poise::Helpers::ResourceCloning
    include Poise::Helpers::ResourceName
    include Poise::Helpers::ResourceSubclass
    include Poise::Helpers::TemplateContent
    include Poise::Helpers::Win32User # Must be after LazyDefault.
    include Poise::Utils::ShellOut

    # @!classmethods
    module ClassMethods
      def poise_subresource_container(namespace=nil, default=nil)
        include Poise::Helpers::Subresources::Container
        # false is a valid value.
        container_namespace(namespace) unless namespace.nil?
        container_default(default) unless default.nil?
      end

      def poise_subresource(parent_type=nil, parent_optional=nil, parent_auto=nil)
        include Poise::Helpers::Subresources::Child
        parent_type(parent_type) if parent_type
        parent_optional(parent_optional) unless parent_optional.nil?
        parent_auto(parent_auto) unless parent_auto.nil?
      end

      def poise_fused
        include Poise::Helpers::Fused
      end

      def poise_inversion(options_resource=nil)
        include Poise::Helpers::Inversion
        inversion_options_resource(true) unless options_resource == false
      end

      def included(klass)
        super
        klass.extend(ClassMethods)
      end
    end

    extend ClassMethods
  end
end
