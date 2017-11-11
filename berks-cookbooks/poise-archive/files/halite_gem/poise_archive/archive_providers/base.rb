#
# Copyright 2016-2017, Noah Kantrowitz
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

require 'fileutils'

require 'chef/provider'
require 'poise'


module PoiseArchive
  module ArchiveProviders
    # The provider base class for `poise_archive`.
    #
    # @see PoiseArchive::Resources::PoiseArchive::Resource
    # @provides poise_archive
    class Base < Chef::Provider
      include Poise

      # Set the file extension this provider will handle.
      #
      # @param match [RegExp] Regular expression to match against the archive
      #   file name.
      # @return [void]
      # @example
      #   class MyProvider < Base
      #     provides_extension(/\.hqx$/)
      #   end
      def self.provides_extension(match)
        provides(:poise_archive)
        @provides_extension = match
      end

      # Override normal provider resolution to also check file extension if one
      # was specified in the provider.
      #
      # @api private
      def self.provides?(node, resource)
        super && (!@provides_extension || @provides_extension.match(resource.path))
      end

      # `unpack` action for `poise_archive`.
      #
      # @return [void]
      def action_unpack
        if new_resource.is_url?
          download_resource = download_file
          # Check if the download resource updated, if not don't run the rest
          # of the unpack for idempotence. I could also check
          # new_resource.updated? but this seems more future proof.
          return if !download_resource.updated_by_last_action?
        end
        converge_by("unpack archive #{new_resource.path} to #{new_resource.destination}") do
          notifying_block do
            create_directory
          end
          empty_directory
          unpack_archive
        end
      end

      private

      # Download the source file to a cache path.
      #
      # @return [Chef::Resource]
      def download_file
        # resource_state used for closure breaking on the notifying block.
        resource_state = []
        notifying_block do
          # TODO handle cookbook:// for cookbook_file "downloads".
          resource_state << remote_file(new_resource.absolute_path) do
            source new_resource.path
            retries 5 # As a default, could be overridden by source_properties.
            new_resource.merged_source_properties.each do |key, value|
              send(key, value)
            end
          end
        end
        # Return the download resource for state tracking.
        resource_state.first
      end

      # Make sure the destination directory exists.
      #
      # @return [void]
      def create_directory
        directory new_resource.destination do
          group new_resource.group if new_resource.group
          owner new_resource.user if new_resource.user
          # There is explicitly no mode being set here. If a non-default mode
          # is needed, you should manage that outside of poise_archive.
        end
      end

      # Remove all existing content from the destination so we can unpack the
      # new content.
      #
      # @return [void]
      def empty_directory
        # If you want to keep it, not my problem.
        return if new_resource.keep_existing
        dest = new_resource.destination
        Dir.entries(dest).each do |entry|
          next if entry == '.' || entry == '..'
          FileUtils.remove_entry_secure(::File.join(dest, entry))
        end
      end

      # Run the provider-specific unpack behavior.
      #
      # @abstract
      # @return [void]
      def unpack_archive
        raise NotImplementedError
      end

    end
  end
end
