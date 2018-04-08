require 'chef/resource'

class Chef
  class Resource
    class UlimitRule < Chef::Resource
      property :type, [Symbol, String], required: true
      property :item, [Symbol, String], required: true
      property :value, [String, Numeric], required: true
      property :domain, [Chef::Resource, String], required: true

      load_current_value do |new_resource|
        new_resource.domain new_resource.domain.domain_name if new_resource.domain.is_a?(Chef::Resource)
        node.run_state[:ulimit] ||= Mash.new
        node.run_state[:ulimit][new_resource.domain] ||= Mash.new
      end

      action :create do
        new_resource.domain new_resource.domain.domain_name if new_resource.domain.is_a?(Chef::Resource)
        node.run_state[:ulimit] ||= Mash.new
        node.run_state[:ulimit][new_resource.domain] ||= Mash.new
        node.run_state[:ulimit][new_resource.domain][new_resource.item] ||= Mash.new
        node.run_state[:ulimit][new_resource.domain][new_resource.item][new_resource.type] = new_resource.value
        puts "Create: #{node.run_state[:ulimit].inspect}"
      end

      action :delete do
        # NOOP
      end
    end
  end
end
