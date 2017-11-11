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

require 'rubygems/package'
require 'zlib'

require 'poise_archive/archive_providers/base'
require 'poise_archive/bzip2'


module PoiseArchive
  module ArchiveProviders
    # The `tar` provider class for `poise_archive` to install from tar archives.
    #
    # @see PoiseArchive::Resources::PoiseArchive::Resource
    # @provides poise_archive
    class Tar < Base
      provides_extension(/\.t(ar|gz|bz)/)

      # Hack that GNU tar uses for paths over 100 bytes.
      #
      # @api private
      # @see #unpack_tar
      TAR_LONGLINK = '././@LongLink'

      private

      def unpack_archive
        unpack_tar
        chown_entries if new_resource.user || new_resource.group
      end

      # Unpack the archive.
      #
      # @return [void]
      def unpack_tar
        @tar_entry_paths = []
        tar_each_with_longlink do |entry|
          entry_name = entry.full_name.split(/\//).drop(new_resource.strip_components).join('/')
          # If strip_components wiped out the name, don't process this entry.
          next if entry_name.empty?
          dest = ::File.join(new_resource.destination, entry_name)
          if entry.directory?
            Dir.mkdir(dest, entry.header.mode)
            @tar_entry_paths << [:directory, dest]
          elsif entry.file?
            ::File.open(dest, 'wb', entry.header.mode) do |dest_f|
              while buf = entry.read(4096)
                dest_f.write(buf)
              end
            end
            @tar_entry_paths << [:file, dest]
          elsif entry.header.typeflag == '2' # symlink? is new in Ruby 2.0, apparently.
            ::File.symlink(entry.header.linkname, dest)
            @tar_entry_paths << [:link, dest]
          else
            raise RuntimeError.new("Unknown tar entry type #{entry.header.typeflag.inspect} in #{new_resource.path}")
          end
        end
      end

      def tar_each_with_longlink(&block)
        entry_name = nil
        tar_each do |entry|
          if entry.full_name == TAR_LONGLINK
            # Stash the longlink name so it will be used for the next entry.
            entry_name = entry.read.strip
            # And then skip forward because this isn't a real block.
            next
          end
          # For entries not preceded by a longlink block, use the normal name.
          entry_name ||= entry.full_name
          # Make the entry return the correct name.
          entry.define_singleton_method(:full_name) { entry_name }
          block.call(entry)
          # Reset entry_name for the next entry.
          entry_name = nil
        end
      end

      # Sequence the opening, iteration, and closing.
      #
      # @param block [Proc] Block to process each tar entry.
      # @return [void]
      def tar_each(&block)
        # In case of extreme weirdness where this happens twice.
        close_file!
        open_file!
        @tar_reader.each(&block)
      ensure
        close_file!
      end

      # Open a file handle of the correct flavor.
      #
      # @return [void]
      def open_file!
        @raw_file = ::File.open(new_resource.absolute_path, 'rb')
        @file = case new_resource.absolute_path
        when /\.tar$/
          nil # So it uses @raw_file instead.
        when /\.t?gz/
          Zlib::GzipReader.wrap(@raw_file)
        when /\.t?bz/
          # This can't take a block, hence the gross non-block forms for everything.
          PoiseArchive::Bzip2::Decompressor.new(@raw_file)
        else
          raise RuntimeError.new("Unknown or unsupported file extension for #{new_resource.path}")
        end
        @tar_reader = Gem::Package::TarReader.new(@file || @raw_file)
      end

      # Close all the various file handles.
      #
      # @return [void]
      def close_file!
        if @tar_reader
          @tar_reader.close
          @tar_reader = nil
        end
        if @file
          @file.close
          @file = nil
        end
        if @raw_file
          @raw_file.close unless @raw_file.closed?
          @raw_file = nil
        end
      end

      def chown_entries
        paths = @tar_entry_paths
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
