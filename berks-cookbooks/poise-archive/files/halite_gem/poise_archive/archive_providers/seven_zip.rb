#
# Copyright 2017, Noah Kantrowitz
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
    # The `seven_zip` provider class for `poise_archive` to upack archives
    # using 7-Zip.
    #
    # @since 1.4.0
    # @see PoiseArchive::Resources::PoiseArchive::Resource
    # @provides poise_archive
    class SevenZip < Base
      provides_extension(/\.(t(ar|gz|bz|xz)|zip|7z)/)

      # Only works on Windows, because use less silly things elsewhere.
      #
      # @api private
      def self.provides?(node, _resource)
        super && node['platform_family'] == 'windows'
      end

      private

      def unpack_archive
        notifying_block do
          install_seven_zip
        end
        # Create a temp directory to unpack in to. Do I want to try and force
        # this to be on the same filesystem as the target?
        self.class.mktmpdir do |tmpdir|
          unpack_using_seven_zip(tmpdir)
          chown_files(tmpdir) if new_resource.user || new_resource.group
          move_files(tmpdir)
        end
      end

      # Install 7-Zip to a cache folder.
      #
      # @api private
      # @return [void]
      def install_seven_zip
        url = seven_zip_url
        path = "#{Chef::Config[:file_cache_path]}/#{url.split(/\//).last}"

        install = execute "#{windows_path(path)} /S /D=#{seven_zip_home}" do
          action :nothing
        end

        remote_file path do
          source url
          notifies :run, install, :immediately
        end
      end

      # Unpack the whole archive to a temp directory.
      #
      # @api private
      # @param tmpdir [String] Temp directory to unpack to.
      # @return [void]
      def unpack_using_seven_zip(tmpdir)
        if new_resource.absolute_path =~ /\.t(ar\.)?(gz|bz(2)?|xz)$/
          # 7-Zip doesn't know to unpack both levels of the archive on its own
          # so we need to handle this more explicitly.
          shell_out!("#{seven_zip_home}\\7z.exe x -so \"#{windows_path(new_resource.absolute_path)}\" | #{seven_zip_home}\\7z.exe x -si -ttar -o\"#{windows_path(tmpdir)}\"")
        else
          shell_out!("#{seven_zip_home}\\7z.exe x -o\"#{windows_path(tmpdir)}\" \"#{windows_path(new_resource.absolute_path)}\"")
        end
      end

      # Fix file ownership if requested.
      #
      # @api private
      # @param tmpdir [String] Temp directory to change ownership in.
      # @return [void]
      def chown_files(tmpdir)
        notifying_block do
          Dir["#{tmpdir}/**/*"].each do |path|
            declare_resource(::File.directory?(path) ? :directory : :file, path) do
              owner new_resource.user if new_resource.user
              group new_resource.group if new_resource.group
            end
          end
        end
      end

      # Manual implementation of --strip-components since 7-Zip doesn't support
      # it internally.
      #
      # @api private
      # @param tmpdir [String] Temp directory to move from.
      # @return [void]
      def move_files(tmpdir)
        entries_at_depth(tmpdir, new_resource.strip_components).each do |source|
          target = ::File.join(new_resource.destination, ::File.basename(source))
          FileUtils.mv(source, target, secure: true)
        end
      end

      # Compute the URL to download the 7-Zip installer from.
      #
      # @api private
      # @return [String]
      def seven_zip_url
        node['poise-archive']['seven_zip']['url'] % {
          version: node['poise-archive']['seven_zip']['version'],
          version_tag: node['poise-archive']['seven_zip']['version'].gsub(/\./, ''),
          arch: node['kernel']['machine'],
          arch_tag: node['kernel']['machine'] == 'x86_64' ? '-x64' : '',
        }
      end

      # Path to install 7-Zip in to.
      #
      # @api private
      # @return [String]
      def seven_zip_home
        "#{windows_path(Chef::Config[:file_cache_path])}\\seven_zip_#{node['poise-archive']['seven_zip']['version']}"
      end

      # Flip the slashes in a path because 7z wants "normal" paths.
      #
      # @api private
      # @param path [String] Path to convert.
      # @return [String]
      def windows_path(path)
        path.gsub(/\//, '\\')
      end

      # Find the absolute paths for entries under a path at a depth.
      #
      # @api private
      # @param path [String] Base path to search under.
      # @param depth [Integer] Number of intermediary directories to skip.
      # @return [Array<String>]
      def entries_at_depth(path, depth)
        entries = [path]
        current_depth = 0
        while current_depth <= depth
          entries.map! do |ent|
            if ::File.directory?(ent)
              Dir.entries(ent).select {|e| e != '.' && e != '..' }.map {|e| ::File.join(ent, e) }
            else
              []
            end
          end
          entries.flatten!
          current_depth += 1
        end
        entries
      end

      # Indirection so I can stub this for testing without breaking RSpec.
      #
      # @api private
      def self.mktmpdir(*args, &block)
        # :nocov:
        Dir.mktmpdir(*args, &block)
        # :nocov:
      end

    end
  end
end
