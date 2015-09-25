class Chef
  class Provider
    class MysqlServiceSmf < Chef::Provider::MysqlServiceBase
      # FIXME: we should have a service_helper to determine if the platform supports SMF similarly
      # to how we handle systemd on linux
      if defined?(provides)
        provides :mysql_service, os: %w(solaris2 omnios smartos openindiana opensolaris nexentacore) do
          File.exist?('/usr/sbin/svccfg')
        end
      end

      action :start do
        method_script_path = "/lib/svc/method/#{mysql_name}" if node['platform'] == 'omnios'
        method_script_path = "/opt/local/lib/svc/method/#{mysql_name}" if node['platform'] == 'smartos'

        template "#{new_resource.name} :start #{method_script_path}" do
          path method_script_path
          cookbook 'mysql'
          source 'smf/svc.method.mysqld.erb'
          owner 'root'
          group 'root'
          mode '0555'
          variables(
            base_dir: base_dir,
            data_dir: parsed_data_dir,
            defaults_file: defaults_file,
            error_log: error_log,
            mysql_name: mysql_name,
            mysqld_bin: mysqld_bin,
            pid_file: pid_file
          )
          action :create
        end

        smf "#{new_resource.name} :start #{mysql_name}" do
          name mysql_name
          user new_resource.run_user
          group new_resource.run_group
          start_command "#{method_script_path} start"
        end

        service "#{new_resource.name} :start #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Solaris
          supports restart: true
          action [:enable]
        end
      end

      action :stop do
        service "#{new_resource.name} :stop #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Solaris
          supports restart: true
          action :stop
        end
      end

      action :restart do
        service "#{new_resource.name} :restart #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Solaris
          supports restart: true
          action :restart
        end
      end

      action :reload do
        service "#{new_resource.name} :reload #{mysql_name}" do
          provider Chef::Provider::Service::Solaris
          service_name mysql_name
          supports reload: true
          action :reload
        end
      end

      def create_stop_system_service
        # nothing to do here
      end

      def delete_stop_service
        service "#{new_resource.name} :delete #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Solaris
          supports restart: true
          action :stop
        end
      end
    end
  end
end
