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

require 'poise/helpers/subcontext_block'
require 'poise/subcontext/runner'


module Poise
  module Helpers
    # A provider mixin to provide #notifying_block, a scoped form of Chef's
    # use_inline_resources.
    #
    # @since 1.0.0
    # @example
    #   class MyProvider < Chef::Provider
    #     include Chef::Helpers::NotifyingBlock
    #
    #     def action_run
    #       notifying_block do
    #         template '/etc/myapp.conf' do
    #           # ...
    #         end
    #       end
    #     end
    #   end
    module NotifyingBlock
      include Poise::Helpers::SubcontextBlock

      private

      # Create and converge a subcontext for the recipe DSL. This is similar to
      # Chef's use_inline_resources but is scoped to a block. All DSL resources
      # declared inside the block will be converged when the block returns, and
      # the updated_by_last_action flag will be set if any of the inner
      # resources are updated.
      #
      # @api public
      # @param block [Proc] Block to run in the subcontext.
      # @return [void]
      # @example
      #   def action_run
      #     notifying_block do
      #       template '/etc/myapp.conf' do
      #         # ...
      #       end
      #     end
      #   end
      def notifying_block(&block)
        # Make sure to mark the resource as updated-by-last-action if
        # any sub-run-context resources were updated (any actual
        # actions taken against the system) during the
        # sub-run-context convergence.
        begin
          subcontext = subcontext_block(&block)
          # Converge the new context.
          Poise::Subcontext::Runner.new(new_resource, subcontext).converge
        ensure
          new_resource.updated_by_last_action(
            subcontext && subcontext.resource_collection.any?(&:updated?)
          )
        end
      end
    end
  end
end
