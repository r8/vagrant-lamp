require 'chef/provider/lwrp_base'
require_relative 'helpers'

class Chef
  class Provider
    class MysqlConfig < Chef::Provider::LWRPBase
      include MysqlCookbook::Helpers
      provides :mysql_config if defined?(provides)

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        group "#{new_resource.name} :create #{new_resource.group}" do
          group_name new_resource.group
          system true if new_resource.name == 'mysql'
          action :create
        end

        user "#{new_resource.name} :create #{new_resource.owner}" do
          username new_resource.owner
          gid new_resource.owner
          system true if new_resource.name == 'mysql'
          action :create
        end

        directory "#{new_resource.name} :create #{include_dir}" do
          path include_dir
          owner new_resource.owner
          group new_resource.group
          mode '0750'
          recursive true
          action :create
        end

        template "#{new_resource.name} :create #{include_dir}/#{new_resource.config_name}.cnf" do
          path "#{include_dir}/#{new_resource.config_name}.cnf"
          owner new_resource.owner
          group new_resource.group
          mode '0640'
          variables(new_resource.variables)
          source new_resource.source
          cookbook new_resource.cookbook
          action :create
        end
      end

      action :delete do
        file "#{new_resource.name} :delete #{include_dir}/#{new_resource.config_name}.conf" do
          path "#{include_dir}/#{new_resource.config_name}.conf"
          action :delete
        end
      end
    end
  end
end
