require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class MysqlClient < Chef::Resource::LWRPBase
      provides :mysql_client

      self.resource_name = :mysql_client
      actions :create, :delete
      default_action :create

      attribute :client_name, kind_of: String, name_attribute: true, required: true
      attribute :package_name, kind_of: Array, default: nil
      attribute :package_version, kind_of: String, default: nil
      attribute :version, kind_of: String, default: nil # mysql_version
    end
  end
end
