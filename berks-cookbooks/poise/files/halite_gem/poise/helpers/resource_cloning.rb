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


module Poise
  module Helpers
    # A resource mixin to disable resource cloning.
    #
    # @since 2.2.0
    # @example
    #   class MyResource < Chef::Resource
    #     include Poise::Helpers::ResourceCloning
    #   end
    module ResourceCloning
      # Override to disable resource cloning on Chef 12.0.
      #
      # @api private
      def load_prior_resource(*args)
        # Do nothing.
      end

      # Override to disable resource cloning on Chef 12.1+.
      #
      # @api private
      def load_from(*args)
        # Do nothing.
      end

      # Monkeypatch for Chef::ResourceBuilder to silence the warning if needed.
      #
      # @api private
      module ResourceBuilderPatch
        # @api private
        def self.install!
          begin
            require 'chef/resource_builder'
            Chef::ResourceBuilder.send(:prepend, ResourceBuilderPatch)
          rescue LoadError
            # For 12.0, this is already taken care of.
          end
        end

        # @api private
        def emit_cloned_resource_warning
          super unless resource.is_a?(ResourceCloning)
        end

        # @api private
        def emit_harmless_cloning_debug
          super unless resource.is_a?(ResourceCloning)
        end
      end

      # Install the patch.
      ResourceBuilderPatch.install!

    end
  end
end
