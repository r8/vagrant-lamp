require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class MysqlConfig < Chef::Resource::LWRPBase
      provides :mysql_config

      self.resource_name = :mysql_config
      actions :create, :delete
      default_action :create

      attribute :config_name, kind_of: String, name_attribute: true, required: true
      attribute :cookbook, kind_of: String, default: nil
      attribute :group, kind_of: String, default: 'mysql'
      attribute :instance, kind_of: String, default: 'default'
      attribute :owner, kind_of: String, default: 'mysql'
      attribute :source, kind_of: String, default: nil
      attribute :variables, kind_of: [Hash], default: nil
      attribute :version, kind_of: String, default: nil
    end
  end
end
