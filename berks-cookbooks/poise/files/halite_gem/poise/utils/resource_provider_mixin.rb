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
  module Utils
    # A mixin to dispatch other mixins with resource and provider
    # implementations. The module this is included in must have Resource and
    # Provider sub-modules.
    #
    # @since 2.0.0
    # @example
    #   module MyHelper
    #     include Poise::Utils::ResourceProviderMixin
    #     module Resource
    #       # ...
    #     end
    #
    #     module Provider
    #       # ...
    #     end
    #   end
    module ResourceProviderMixin
      def self.included(klass)
        # Warning here be dragons.
        # Create a new anonymous module, klass will be the module that
        # actually included ResourceProviderMixin. We want to keep a reference
        # to that locked down so that we can close over it and use it in the
        # "real" .included defined below to find the original relative consts.
        mod = Module.new do
          # Use define_method instead of def so we can close over klass and mod.
          define_method(:included) do |inner_klass|
            # Has to be explicit because super inside define_method.
            super(inner_klass)
            # Cargo this .included to things which include us.
            inner_klass.extend(mod)
            # Dispatch to submodules, inner_klass is the most recent includer.
            if inner_klass < Chef::Resource || inner_klass.name.to_s.end_with?('::Resource')
              # Use klass::Resource to look up relative to the original module.
              inner_klass.class_exec { include klass::Resource }
            elsif inner_klass < Chef::Provider || inner_klass.name.to_s.end_with?('::Provider')
              # As above, klass::Provider.
              inner_klass.class_exec { include klass::Provider }
            end
          end
        end
        # Add our .included to the original includer.
        klass.extend(mod)
      end
    end
  end
end
