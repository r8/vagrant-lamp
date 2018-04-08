require 'chef/resource'

class Chef
  class Resource
    class UlimitDomain < Chef::Resource
      property :domain, String
      property :domain_name, String, name_property: true
      property :filename, String

      load_current_value do |new_resource|
        new_resource.filename new_resource.name unless new_resource.filename
        new_resource.filename "#{new_resource.filename}.conf" unless new_resource.filename.end_with?('.conf')

        new_resource.subresource_rules.map! do |name, block|
          urule = Chef::Resource::UlimitRule.new("#{new_resource.name}:#{name}]", nil)
          urule.domain new_resource
          urule.action :nothing
          urule.instance_eval(&block)
          unless name
            urule.name "ulimit_rule[#{new_resource.name}:#{urule.item}-#{urule.type}-#{urule.value}]"
          end
          urule
        end
      end

      attr_reader :subresource_rules

      def initialize(*args)
        @subresource_rules = []
        super
      end

      def rule(name = nil, &block)
        @subresource_rules << [name, block]
      end

      action :create do
        new_resource.subresource_rules.map do |sub_resource|
          sub_resource.run_context = new_resource.run_context
          sub_resource.run_action(:create)
        end

        new_resource.filename new_resource.name unless new_resource.filename
        new_resource.filename "#{new_resource.filename}.conf" unless new_resource.filename.end_with?('.conf')
        template ::File.join(node['ulimit']['security_limits_directory'], new_resource.filename) do
          source 'domain.erb'
          cookbook 'ulimit'
          variables domain: new_resource.domain_name
        end
      end

      action :delete do
        file ::File.join(node['ulimit']['security_limits_directory'], new_resource.filename) do
          action :delete
        end
      end
    end
  end
end
