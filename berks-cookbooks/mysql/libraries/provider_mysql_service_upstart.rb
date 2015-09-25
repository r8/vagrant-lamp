require_relative 'provider_mysql_service_base'

class Chef
  class Provider
    class MysqlServiceUpstart < Chef::Provider::MysqlServiceBase
      if defined?(provides)
        provides :mysql_service, os: 'linux' do
          Chef::Platform::ServiceHelpers.service_resource_providers.include?(:upstart) &&
            !Chef::Platform::ServiceHelpers.service_resource_providers.include?(:redhat)
        end
      end

      action :start do
        template "#{new_resource.name} :start /usr/sbin/#{mysql_name}-wait-ready" do
          path "/usr/sbin/#{mysql_name}-wait-ready"
          source 'upstart/mysqld-wait-ready.erb'
          owner 'root'
          group 'root'
          mode '0755'
          variables(socket_file: socket_file)
          cookbook 'mysql'
          action :create
        end

        template "#{new_resource.name} :start /etc/init/#{mysql_name}.conf" do
          path "/etc/init/#{mysql_name}.conf"
          source 'upstart/mysqld.erb'
          owner 'root'
          group 'root'
          mode '0644'
          variables(
            defaults_file: defaults_file,
            mysql_name: mysql_name,
            run_group: new_resource.run_group,
            run_user: new_resource.run_user,
            socket_dir: socket_dir
          )
          cookbook 'mysql'
          action :create
        end

        service "#{new_resource.name} :start #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Upstart
          supports status: true
          action [:start]
        end
      end

      action :stop do
        service "#{new_resource.name} :stop #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Upstart
          supports restart: true, status: true
          action [:stop]
        end
      end

      action :restart do
        # With Upstart, restarting the service doesn't behave "as expected".
        # We want the post-start stanzas, which wait until the
        # service is available before returning
        #
        # http://upstart.ubuntu.com/cookbook/#restart
        service "#{new_resource.name} :restart stop #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Upstart
          action :stop
        end

        service "#{new_resource.name} :restart start #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Upstart
          action :start
        end
      end

      action :reload do
        # With Upstart, reload just sends a HUP signal to the process.
        # As far as I can tell, this doesn't work the way it's
        # supposed to, so we need to actually restart the service.
        service "#{new_resource.name} :reload stop #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Upstart
          action :stop
        end

        service "#{new_resource.name} :reload start #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Upstart
          action :start
        end
      end

      def create_stop_system_service
        service "#{new_resource.name} :create #{system_service_name}" do
          service_name system_service_name
          provider Chef::Provider::Service::Upstart
          supports status: true
          action [:stop, :disable]
        end
      end

      def delete_stop_service
        service "#{new_resource.name} :delete #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Upstart
          action [:disable, :stop]
          only_if { ::File.exist?("#{etc_dir}/init/#{mysql_name}") }
        end
      end
    end
  end
end
