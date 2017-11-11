#
# Copyright 2015-2017, Noah Kantrowitz
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

require 'chef/resource'
require 'chef/provider'
require 'poise'


module PoiseLanguages
  module Scl
    # A `poise_language_scl` resource to manage installing a language from
    # SCL packages. This is an internal implementation detail of
    # poise-languages.
    #
    # @api private
    # @since 1.0
    # @provides poise_languages_scl
    # @action install
    # @action uninstall
    class Resource < Chef::Resource
      include Poise
      provides(:poise_languages_scl)
      actions(:install, :upgrade, :uninstall)

      # @!attribute package_name
      #   Name of the SCL package for the language.
      #   @return [String]
      attribute(:package_name, kind_of: String, name_attribute: true)
      # @!attribute dev_package
      #   Name of the -devel package with headers and whatnot.
      #   @return [String, nil]
      attribute(:dev_package, kind_of: [String, NilClass])
      # @!attribute version
      #   Version of the SCL package(s) to install. If unset, follows the same
      #   semantics as the core `package` resource.
      #   @return [String, nil]
      attribute(:version, kind_of: [String, NilClass])
      # @!attribute parent
      #   Resource for the language runtime. Used only for messages.
      #   @return [Chef::Resource]
      attribute(:parent, kind_of: Chef::Resource, required: true)
    end

    # The default provider for `poise_languages_scl`.
    #
    # @api private
    # @since 1.0
    # @see Resource
    # @provides poise_languages_scl
    class Provider < Chef::Provider
      include Poise
      provides(:poise_languages_scl)

      # The `install` action for the `poise_languages_scl` resource.
      #
      # @return [void]
      def action_install
        notifying_block do
          install_scl_repo
          flush_yum_cache
          install_scl_package(:install)
          install_scl_devel_package(:install) if new_resource.dev_package
        end
      end

      # The `upgrade` action for the `poise_languages_scl` resource.
      #
      # @return [void]
      def action_upgrade
        notifying_block do
          install_scl_repo
          flush_yum_cache
          install_scl_package(:upgrade)
          install_scl_devel_package(:upgrade) if new_resource.dev_package
        end
      end

      # The `uninstall` action for the `poise_languages_scl` resource.
      #
      # @return [void]
      def action_uninstall
        notifying_block do
          uninstall_scl_devel_package if new_resource.dev_package
          uninstall_scl_package
        end
      end

      private

      def install_scl_repo
        if node.platform?('redhat')
          # Set up the real RHSCL subscription.
          # NOTE: THIS IS NOT TESTED BECAUSE REDHAT DOESN'T OFFER ANY WAY TO DO
          # AUTOMATED TESTING. IF YOU USE REDHAT AND THIS BREAKS, PLEASE LET ME
          # KNOW BY FILING A GITHUB ISSUE AT http://github.com/poise/poise-languages/issues/new.
          repo_name = "rhel-server-rhscl-#{node['platform_version'][0]}-rpms"
          execute "subscription-manager repos --enable #{repo_name}" do
            not_if { shell_out!('subscription-manager repos --list-enabled').stdout.include?(repo_name) }
          end
        else
          package 'centos-release-scl-rh' do
            # Using upgrade here because changes very very rare and always
            # important when they happen. If this breaks your prod infra, I'm
            # sorry :-(
            action :upgrade
            retries 5
          end
        end
      end

      def flush_yum_cache
        ruby_block 'flush_yum_cache' do
          block do
            # Equivalent to flush_cache after: true
            Chef::Provider::Package::Yum::YumCache.instance.reload
          end
        end
      end

      def install_scl_package(action)
        package new_resource.package_name do
          action action
          retries 5
          version new_resource.version
        end
      end

      def install_scl_devel_package(action)
        package new_resource.dev_package do
          action action
          retries 5
          version new_resource.version
        end
      end

      def uninstall_scl_package
        install_scl_package(:remove)
      end

      def uninstall_scl_devel_package
        install_scl_devel_package(:remove)
      end

    end
  end
end
