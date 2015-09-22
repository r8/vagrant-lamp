require_relative 'provider_mysql_service_base'

class Chef
  class Provider
    class MysqlServiceSysvinit < Chef::Provider::MysqlServiceBase
      provides :mysql_service, os: '!windows' if defined?(provides)

      action :start do
        template "#{new_resource.name} :start /etc/init.d/#{mysql_name}" do
          path "/etc/init.d/#{mysql_name}"
          source 'sysvinit/mysqld.erb'
          owner 'root'
          group 'root'
          mode '0755'
          variables(
            config: new_resource,
            defaults_file: defaults_file,
            error_log: error_log,
            mysql_name: mysql_name,
            mysqladmin_bin: mysqladmin_bin,
            mysqld_safe_bin: mysqld_safe_bin,
            pid_file: pid_file,
            scl_name: scl_name
          )
          cookbook 'mysql'
          action :create
        end

        service "#{new_resource.name} :start #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Init::Redhat if node['platform_family'] == 'redhat'
          provider Chef::Provider::Service::Init::Insserv if node['platform_family'] == 'debian'
          supports restart: true, status: true
          action [:enable, :start]
        end
      end

      action :stop do
        service "#{new_resource.name} :stop #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Init::Redhat if node['platform_family'] == 'redhat'
          provider Chef::Provider::Service::Init::Insserv if node['platform_family'] == 'debian'
          supports restart: true, status: true
          action [:stop]
        end
      end

      action :restart do
        service "#{new_resource.name} :restart #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Init::Redhat if node['platform_family'] == 'redhat'
          provider Chef::Provider::Service::Init::Insserv if node['platform_family'] == 'debian'
          supports restart: true
          action :restart
        end
      end

      action :reload do
        service "#{new_resource.name} :reload #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Init::Redhat if node['platform_family'] == 'redhat'
          provider Chef::Provider::Service::Init::Insserv if node['platform_family'] == 'debian'
          action :reload
        end
      end

      def create_stop_system_service
        service "#{new_resource.name} :create #{system_service_name}" do
          service_name system_service_name
          provider Chef::Provider::Service::Init::Redhat if node['platform_family'] == 'redhat'
          provider Chef::Provider::Service::Init::Insserv if node['platform_family'] == 'debian'
          supports status: true
          action [:stop, :disable]
        end
      end

      def delete_stop_service
        service "#{new_resource.name} :delete #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Init::Redhat if node['platform_family'] == 'redhat'
          provider Chef::Provider::Service::Init::Insserv if node['platform_family'] == 'debian'
          supports status: true
          action [:disable, :stop]
          only_if { ::File.exist?("#{etc_dir}/init.d/#{mysql_name}") }
        end
      end
    end
  end
end
