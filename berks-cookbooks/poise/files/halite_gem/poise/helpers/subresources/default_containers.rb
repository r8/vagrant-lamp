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
    module Subresources
      # Helpers to track default container resources. This is used to find a
      # default parent for a child with no parent set. It flat out violates
      # encapsulation to allow for the use of default parents to act as
      # system-level defaults even when created in a nested scope.
      #
      # @api private
      # @since 2.0.0
      module DefaultContainers
        # Mutex to sync access to the containers array.
        #
        # @see .containers
        CONTAINER_MUTEX = Mutex.new

        # Add a resource to the array of default containers.
        #
        # @param resource [Chef::Resource] Resource to add.
        # @param run_context [Chef::RunContext] Context of the current run.
        # @return [void]
        def self.register!(resource, run_context)
          CONTAINER_MUTEX.synchronize do
            containers(run_context) << resource
          end
        end

        # Find a default container for a resource class.
        #
        # @param klass [Class] Resource class to search for.
        # @param run_context [Chef::RunContext] Context of the current run.
        # @return [Chef::Resource]
        def self.find(klass, run_context, self_resource: nil)
          CONTAINER_MUTEX.synchronize do
            containers(run_context).reverse_each do |resource|
              return resource if resource.is_a?(klass) && (!self_resource || self_resource != resource)
            end
            # Nothing found.
            nil
          end
        end

        private

        # Get the array of all default container resources.
        #
        # @note MUST BE CALLED FROM A LOCKED CONTEXT!
        # @param run_context [Chef::RunContext] Context of the current run.
        # @return [Array<Chef::Resource>]
        def self.containers(run_context)
          # For test cases where nil gets used sometimes.
          return [] unless run_context && run_context.node && run_context.node.run_state
          run_context.node.run_state[:poise_default_containers] ||= []
        end
      end
    end
  end
end
