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

require 'poise_archive/archive_providers/base'


module PoiseArchive
  module ArchiveProviders
    # The `zip` provider class for `poise_archive` to install from ZIP archives.
    #
    # @see PoiseArchive::Resources::PoiseArchive::Resource
    # @provides poise_archive
    class Zip < Base
      provides_extension(/\.zip$/)

      private

      def unpack_archive
        check_rubyzip
        unpack_zip
        chown_entries if new_resource.user || new_resource.group
      end

      def check_rubyzip
        require 'zip'
      rescue LoadError
        notifying_block do
          install_rubyzip
        end
        require 'zip'
      end

      def install_rubyzip
        chef_gem 'rubyzip'
      end

      def unpack_zip
        @zip_entry_paths = []
        ::Zip::File.open(new_resource.absolute_path) do |zip_file|
          zip_file.each do |entry|
            entry_name = entry.name.split(/\//).drop(new_resource.strip_components).join('/')
            # If strip_components wiped out the name, don't process this entry.
            next if entry_name.empty?
            entry_path = ::File.join(new_resource.destination, entry_name)
            # Ensure parent directories exist because some ZIP files don't
            # include those for some reason.
            ensure_directory(entry_path)
            entry.extract(entry_path)
            # Make sure we restore file permissions. RubyZip won't do this
            # unless we also turn on UID/GID restoration, which we don't want.
            # Mask filters out setuid and setgid bits because no.
            ::File.chmod(entry.unix_perms & 01777, entry_path) if !node.platform_family?('windows') && entry.unix_perms
            @zip_entry_paths << [entry.directory? ? :directory : entry.file? ? :file : :link, entry_path]
          end
        end
      end

      # Make sure all enclosing directories exist before writing a path.
      #
      # @param oath [String] Path to check.
      def ensure_directory(path)
        base = ::File.dirname(path)
        unless ::File.exist?(base)
          ensure_directory(base)
          Dir.mkdir(base)
          @zip_entry_paths << [:directory, base]
        end
      end

      def chown_entries
        paths = @zip_entry_paths
        notifying_block do
          paths.each do |type, path|
            send(type, path) do
              group new_resource.group
              owner new_resource.user
            end
          end
        end
      end

    end
  end
end
