require 'chef/provider/lwrp_base'
require_relative 'helpers'

class Chef
  class Provider
    class MysqlClient < Chef::Provider::LWRPBase
      include MysqlCookbook::Helpers
      provides :mysql_client if defined?(provides)

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        # From helpers.rb
        configure_package_repositories

        client_package_name.each do |p|
          package "#{new_resource.name} :create #{p}" do
            package_name p
            version new_resource.version if node['platform'] == 'smartos'
            version new_resource.package_version
            action :install
          end
        end
      end

      action :delete do
        parsed_package_name.each do |p|
          package "#{new_resource.name} :delete #{p}" do
            action :remove
          end
        end
      end
    end
  end
end
