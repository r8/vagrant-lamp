#
# Author:: Joshua Timberman (<jtimberman@chef.io>)
# Author:: Graeme Mathieson (<mathie@woss.name>)
# Cookbook Name:: homebrew
# Libraries:: homebrew_package
#
# Copyright 2011-2013, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# cookbook libraries are unconditionally included if the cookbook is
# present on a node. This approach should avoid creating this class if
# the node already has Chef::Provider::Package::Homebrew, such as with
# Chef 12.
# https://github.com/chef/chef-rfc/blob/master/rfc016-homebrew-osx-package-provider.md
unless defined?(Chef::Provider::Package::Homebrew) && Chef::Platform.find('mac_os_x', nil)[:package] == Chef::Provider::Package::Homebrew
  require 'chef/provider/package'
  require 'chef/resource/package'
  require 'chef/platform'
  require 'chef/mixin/shell_out'

  class Chef
    class Provider
      class Package
        # Package
        class Homebrew < Package
          # Homebrew packagex
          include Chef::Mixin::ShellOut
          include ::Homebrew::Mixin

          def load_current_resource
            @current_resource = Chef::Resource::Package.new(@new_resource.name)
            @current_resource.package_name(@new_resource.package_name)
            @current_resource.version(current_installed_version)

            @current_resource
          end

          def install_package(name, version)
            brew('install', @new_resource.options, name)
          end

          def upgrade_package(name, version)
            brew('upgrade', name)
          end

          def remove_package(name, version)
            brew('uninstall', @new_resource.options, name)
          end

          # Homebrew doesn't really have a notion of purging, so just remove.
          def purge_package(name, version)
            @new_resource.options = ((@new_resource.options || '') << ' --force').strip
            remove_package(name, version)
          end

          protected

          def brew(*args)
            get_response_from_command("brew #{args.join(' ')}")
          end

          def current_installed_version
            pkg = get_version_from_formula
            versions = pkg.to_hash['installed'].map { |v| v['version'] }
            versions.join(' ') unless versions.empty?
          end

          def candidate_version
            pkg = get_version_from_formula
            pkg.stable ? pkg.stable.version.to_s : pkg.version.to_s
          end

          def get_version_from_command(command)
            version = get_response_from_command(command).chomp
            version.empty? ? nil : version
          end

          def get_version_from_formula
            brew_cmd = shell_out!('brew --prefix', :user => homebrew_owner)
            libpath = ::File.join(brew_cmd.stdout.chomp, 'Library', 'Homebrew')
            $LOAD_PATH.unshift(libpath)

            require 'global'
            require 'cmd/info'

            Formula[new_resource.package_name]
          end

          def get_response_from_command(command)
            require 'etc'
            home_dir = Etc.getpwnam(homebrew_owner).dir

            Chef::Log.debug "Executing '#{command}' as #{homebrew_owner}"
            output = shell_out!(command, :user => homebrew_owner, :environment => { 'HOME' => home_dir, 'RUBYOPT' => nil })
            output.stdout
          end
        end
      end
    end
  end

  Chef::Platform.set :platform => :mac_os_x_server, :resource => :package, :provider => Chef::Provider::Package::Homebrew
  Chef::Platform.set :platform => :mac_os_x, :resource => :package, :provider => Chef::Provider::Package::Homebrew
end
