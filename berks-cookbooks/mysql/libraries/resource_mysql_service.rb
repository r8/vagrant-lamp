require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class MysqlService < Chef::Resource::LWRPBase
      provides :mysql_service

      self.resource_name = :mysql_service
      actions :create, :delete, :start, :stop, :restart, :reload
      default_action :create

      attribute :charset, kind_of: String, default: 'utf8'
      attribute :data_dir, kind_of: String, default: nil
      attribute :initial_root_password, kind_of: String, default: 'ilikerandompasswords'
      attribute :instance, kind_of: String, name_attribute: true
      attribute :package_action, kind_of: Symbol, default: :install
      attribute :package_name, kind_of: String, default: nil
      attribute :package_version, kind_of: String, default: nil
      attribute :bind_address, kind_of: String, default: nil
      attribute :port, kind_of: [String, Integer], default: '3306'
      attribute :run_group, kind_of: String, default: 'mysql'
      attribute :run_user, kind_of: String, default: 'mysql'
      attribute :socket, kind_of: String, default: nil
      attribute :mysqld_options, kind_of: Hash, default: {}
      attribute :version, kind_of: String, default: nil
      attribute :error_log, kind_of: String, default: nil
      attribute :tmp_dir, kind_of: String, default: nil
      attribute :pid_file, kind_of: String, default: nil
    end
  end
end
