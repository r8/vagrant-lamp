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

require 'chef/runner'


module Poise
  module Subcontext
    # A subclass of the normal Chef Runner that migrates delayed notifications
    # to the enclosing run_context instead of running them at the end of the
    # subcontext convergence.
    #
    # @api private
    # @since 1.0.0
    class Runner < Chef::Runner
      def initialize(resource, *args)
        super(*args)
        @resource = resource
      end

      def run_delayed_notifications(error=nil)
        # If there is an error, just do the normal thing. The return shouldn't
        # ever fire because the superclass re-raises if there is an error.
        return super if error
        delayed_actions.each do |notification|
          if @resource.run_context.respond_to?(:add_delayed_action)
            @resource.run_context.add_delayed_action(notification)
          else
            notifications = run_context.parent_run_context.delayed_notifications(@resource)
            if notifications.any? { |existing_notification| existing_notification.duplicates?(notification) }
              Chef::Log.info( "#{@resource} not queuing delayed action #{notification.action} on #{notification.resource}"\
                             " (delayed), as it's already been queued")
            else
              notifications << notification
            end
          end
        end
      end

    end
  end
end
