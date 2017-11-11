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
require 'tmpdir'

require 'poise_archive/archive_providers/base'


module PoiseArchive
  module ArchiveProviders
    # The `gnu_tar` provider class for `poise_archive` to install from TAR
    # archives using GNU's tar executable.
    #
    # @see PoiseArchive::Resources::PoiseArchive::Resource
    # @provides poise_archive
    class GnuTar < Base
      provides_extension(/\.t(ar|gz|bz|xz)/)

      # Only use this if we are on Linux. Everyone else gets the slow Ruby code.
      #
      # @api private
      def self.provides?(node, _resource)
        super && node['os'] == 'linux'
      end

      private

      def unpack_archive
        notifying_block do
          install_prereqs
        end
        unpack_tar
      end

      # Install any needed prereqs.
      #
      # @return [void]
      def install_prereqs
        utils = ['tar']
        utils << 'bzip2' if new_resource.absolute_path =~ /\.t?bz/
        if new_resource.absolute_path =~ /\.t?xz/
          xz_package = node.value_for_platform_family(
            debian: 'xz-utils',
            rhel: 'xz',
          )
          utils << xz_package if xz_package
        end
        # This is a resource.
        package utils
      end

      # Unpack the archive and process `strip_components`.
      #
      # @return [void]
      def unpack_tar
        # Build the tar command.
        cmd = %w{tar}
        cmd << "--strip-components=#{new_resource.strip_components}" if new_resource.strip_components && new_resource.strip_components > 0
        cmd << if new_resource.absolute_path =~ /\.t?gz/
          '-xzvf'
        elsif new_resource.absolute_path =~ /\.t?bz/
          '-xjvf'
        elsif new_resource.absolute_path =~ /\.t?xz/
          '-xJvf'
        else
          '-xvf'
        end
        cmd << new_resource.absolute_path
        poise_shell_out!(cmd, cwd: new_resource.destination, group: new_resource.group, user: new_resource.user)
      end

    end
  end
end
