require_relative 'provider_mysql_service_base'

class Chef
  class Provider
    class MysqlServiceSystemd < Chef::Provider::MysqlServiceBase
      if defined?(provides)
        provides :mysql_service, os: 'linux' do
          Chef::Platform::ServiceHelpers.service_resource_providers.include?(:systemd)
        end
      end

      action :start do
        # Needed for Debian / Ubuntu
        directory '/usr/libexec' do
          owner 'root'
          group 'root'
          mode '0755'
          action :create
        end

        # this script is called by the main systemd unit file, and
        # spins around until the service is actually up and running.
        template "#{new_resource.name} :start /usr/libexec/#{mysql_name}-wait-ready" do
          path "/usr/libexec/#{mysql_name}-wait-ready"
          source 'systemd/mysqld-wait-ready.erb'
          owner 'root'
          group 'root'
          mode '0755'
          variables(socket_file: socket_file)
          cookbook 'mysql'
          action :create
        end

        # this is the main systemd unit file
        template "#{new_resource.name} :start /lib/systemd/system/#{mysql_name}.service" do
          path "/lib/systemd/system/#{mysql_name}.service"
          source 'systemd/mysqld.service.erb'
          owner 'root'
          group 'root'
          mode '0644'
          variables(
            config: new_resource,
            etc_dir: etc_dir,
            base_dir: base_dir,
            mysqld_bin: mysqld_bin
          )
          cookbook 'mysql'
          notifies :run, "execute[#{new_resource.name} :start systemctl daemon-reload]", :immediately
          action :create
        end

        # avoid 'Unit file changed on disk' warning
        execute "#{new_resource.name} :start systemctl daemon-reload" do
          command '/bin/systemctl daemon-reload'
          action :nothing
        end

        # tmpfiles.d config so the service survives reboot
        template "#{new_resource.name} :start /usr/lib/tmpfiles.d/#{mysql_name}.conf" do
          path "/usr/lib/tmpfiles.d/#{mysql_name}.conf"
          source 'tmpfiles.d.conf.erb'
          owner 'root'
          group 'root'
          mode '0644'
          variables(
            run_dir: run_dir,
            run_user: new_resource.run_user,
            run_group: new_resource.run_group
          )
          cookbook 'mysql'
          action :create
        end

        # service management resource
        service "#{new_resource.name} :start #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Systemd
          supports restart: true, status: true
          action [:enable, :start]
        end
      end

      action :stop do
        # service management resource
        service "#{new_resource.name} :stop #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Systemd
          supports status: true
          action [:disable, :stop]
          only_if { ::File.exist?("/usr/lib/systemd/system/#{mysql_name}.service") }
        end
      end

      action :restart do
        # service management resource
        service "#{new_resource.name} :restart #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Systemd
          supports restart: true
          action :restart
        end
      end

      action :reload do
        # service management resource
        service "#{new_resource.name} :reload #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Systemd
          action :reload
        end
      end

      def create_stop_system_service
        # service management resource
        service "#{new_resource.name} :create mysql" do
          service_name system_service_name
          provider Chef::Provider::Service::Systemd
          supports status: true
          action [:stop, :disable]
        end
      end

      def delete_stop_service
        # service management resource
        service "#{new_resource.name} :delete #{mysql_name}" do
          service_name mysql_name
          provider Chef::Provider::Service::Systemd
          supports status: true
          action [:disable, :stop]
          only_if { ::File.exist?("/usr/lib/systemd/system/#{mysql_name}.service") }
        end
      end
    end
  end
end
