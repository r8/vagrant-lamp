require 'chef/provider/lwrp_base'
require_relative 'helpers'

class Chef
  class Provider
    class MysqlServiceBase < Chef::Provider::LWRPBase
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      # Mix in helpers from libraries/helpers.rb
      include MysqlCookbook::Helpers

      # Service related methods referred to in the :create and :delete
      # actions need to be implemented in the init system subclasses.
      #
      # create_stop_system_service
      # delete_stop_service

      # All other methods are found in libraries/helpers.rb
      #
      # etc_dir, run_dir, log_dir, etc

      action :create do
        # Yum, Apt, etc. From helpers.rb
        configure_package_repositories

        # Software installation
        package "#{new_resource.name} :create #{server_package_name}" do
          package_name server_package_name
          version parsed_version if node['platform'] == 'smartos'
          version new_resource.package_version
          action new_resource.package_action
        end

        create_stop_system_service

        # Apparmor
        configure_apparmor

        # System users
        group "#{new_resource.name} :create mysql" do
          group_name 'mysql'
          action :create
        end

        user "#{new_resource.name} :create mysql" do
          username 'mysql'
          gid 'mysql'
          action :create
        end

        # Yak shaving secion. Account for random errata.
        #
        # Turns out that mysqld is hard coded to try and read
        # /etc/mysql/my.cnf, and its presence causes problems when
        # setting up multiple services.
        file "#{new_resource.name} :create #{prefix_dir}/etc/mysql/my.cnf" do
          path "#{prefix_dir}/etc/mysql/my.cnf"
          action :delete
        end

        file "#{new_resource.name} :create #{prefix_dir}/etc/my.cnf" do
          path "#{prefix_dir}/etc/my.cnf"
          action :delete
        end

        # mysql_install_db is broken on 5.6.13
        link "#{new_resource.name} :create #{prefix_dir}/usr/share/my-default.cnf" do
          target_file "#{prefix_dir}/usr/share/my-default.cnf"
          to "#{etc_dir}/my.cnf"
          action :create
        end

        # Support directories
        directory "#{new_resource.name} :create #{etc_dir}" do
          path etc_dir
          owner new_resource.run_user
          group new_resource.run_group
          mode '0750'
          recursive true
          action :create
        end

        directory "#{new_resource.name} :create #{include_dir}" do
          path include_dir
          owner new_resource.run_user
          group new_resource.run_group
          mode '0750'
          recursive true
          action :create
        end

        directory "#{new_resource.name} :create #{run_dir}" do
          path run_dir
          owner new_resource.run_user
          group new_resource.run_group
          mode '0755'
          recursive true
          action :create
        end

        directory "#{new_resource.name} :create #{log_dir}" do
          path log_dir
          owner new_resource.run_user
          group new_resource.run_group
          mode '0750'
          recursive true
          action :create
        end

        directory "#{new_resource.name} :create #{parsed_data_dir}" do
          path parsed_data_dir
          owner new_resource.run_user
          group new_resource.run_group
          mode '0750'
          recursive true
          action :create
        end

        # Main configuration file
        template "#{new_resource.name} :create #{etc_dir}/my.cnf" do
          path "#{etc_dir}/my.cnf"
          source 'my.cnf.erb'
          cookbook 'mysql'
          owner new_resource.run_user
          group new_resource.run_group
          mode '0600'
          variables(
            config: new_resource,
            error_log: error_log,
            include_dir: include_dir,
            lc_messages_dir: lc_messages_dir,
            pid_file: pid_file,
            socket_file: socket_file,
            tmp_dir: tmp_dir,
            data_dir: parsed_data_dir
          )
          action :create
        end

        # initialize database and create initial records
        bash "#{new_resource.name} :create initial records" do
          code init_records_script
          returns [0, 1, 2] # facepalm
          not_if "/usr/bin/test -f #{parsed_data_dir}/mysql/user.frm"
          action :run
        end
      end

      action :delete do
        # Stop the service before removing support directories
        delete_stop_service

        directory "#{new_resource.name} :delete #{etc_dir}" do
          path etc_dir
          recursive true
          action :delete
        end

        directory "#{new_resource.name} :delete #{run_dir}" do
          path run_dir
          recursive true
          action :delete
        end

        directory "#{new_resource.name} :delete #{log_dir}" do
          path log_dir
          recursive true
          action :delete
        end
      end

      #
      # Platform specific bits
      #
      def configure_apparmor
        # Do not add these resource if inside a container
        # Only valid on Ubuntu

        unless ::File.exist?('/.dockerenv') || ::File.exist?('/.dockerinit')
          if node['platform'] == 'ubuntu'
            # Apparmor
            package "#{new_resource.name} :create apparmor" do
              package_name 'apparmor'
              action :install
            end

            directory "#{new_resource.name} :create /etc/apparmor.d/local/mysql" do
              path '/etc/apparmor.d/local/mysql'
              owner 'root'
              group 'root'
              mode '0755'
              recursive true
              action :create
            end

            template "#{new_resource.name} :create /etc/apparmor.d/local/usr.sbin.mysqld" do
              path '/etc/apparmor.d/local/usr.sbin.mysqld'
              cookbook 'mysql'
              source 'apparmor/usr.sbin.mysqld-local.erb'
              owner 'root'
              group 'root'
              mode '0644'
              action :create
              notifies :restart, "service[#{new_resource.name} :create apparmor]", :immediately
            end

            template "#{new_resource.name} :create /etc/apparmor.d/usr.sbin.mysqld" do
              path '/etc/apparmor.d/usr.sbin.mysqld'
              cookbook 'mysql'
              source 'apparmor/usr.sbin.mysqld.erb'
              owner 'root'
              group 'root'
              mode '0644'
              action :create
              notifies :restart, "service[#{new_resource.name} :create apparmor]", :immediately
            end

            template "#{new_resource.name} :create /etc/apparmor.d/local/mysql/#{new_resource.instance}" do
              path "/etc/apparmor.d/local/mysql/#{new_resource.instance}"
              cookbook 'mysql'
              source 'apparmor/usr.sbin.mysqld-instance.erb'
              owner 'root'
              group 'root'
              mode '0644'
              variables(
                data_dir: parsed_data_dir,
                mysql_name: mysql_name,
                log_dir: log_dir,
                run_dir: run_dir,
                pid_file: pid_file,
                socket_file: socket_file
              )
              action :create
              notifies :restart, "service[#{new_resource.name} :create apparmor]", :immediately
            end

            service "#{new_resource.name} :create apparmor" do
              service_name 'apparmor'
              action :nothing
            end
          end
        end
      end
    end
  end
end
