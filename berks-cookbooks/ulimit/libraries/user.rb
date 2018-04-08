require 'chef/resource'

class Chef
  class Resource
    class UlimitUser < Chef::Resource
      resource_name :user_ulimit

      property :username, String, name_property: true
      property :filename, String, default: lazy { |r| r.username == '*' ? '00_all_limits' : "#{r.username}_limits" }
      property :filehandle_limit, [String, Integer]
      property :filehandle_soft_limit, [String, Integer]
      property :filehandle_hard_limit, [String, Integer]
      property :process_limit, [String, Integer]
      property :process_soft_limit, [String, Integer]
      property :process_hard_limit, [String, Integer]
      property :memory_limit, [String, Integer]
      property :core_limit, [String, Integer]
      property :core_soft_limit, [String, Integer]
      property :core_hard_limit, [String, Integer]
      property :stack_limit, [String, Integer]
      property :stack_soft_limit, [String, Integer]
      property :stack_hard_limit, [String, Integer]
      property :rtprio_limit, [String, Integer]
      property :rtprio_soft_limit, [String, Integer]
      property :rtprio_hard_limit, [String, Integer]

      action :create do
        new_resource.filename = "#{new_resource.filename}.conf" unless new_resource.filename.include?('.conf')
        template "/etc/security/limits.d/#{new_resource.filename}" do
          source 'ulimit.erb'
          cookbook 'ulimit'
          mode '0644'
          variables(
            ulimit_user: new_resource.username,
            filehandle_limit: new_resource.filehandle_limit,
            filehandle_soft_limit: new_resource.filehandle_soft_limit,
            filehandle_hard_limit: new_resource.filehandle_hard_limit,
            process_limit: new_resource.process_limit,
            process_soft_limit: new_resource.process_soft_limit,
            process_hard_limit: new_resource.process_hard_limit,
            memory_limit: new_resource.memory_limit,
            core_limit: new_resource.core_limit,
            core_soft_limit: new_resource.core_soft_limit,
            core_hard_limit: new_resource.core_hard_limit,
            stack_limit: new_resource.stack_limit,
            stack_soft_limit: new_resource.stack_soft_limit,
            stack_hard_limit: new_resource.stack_hard_limit,
            rtprio_limit: new_resource.rtprio_limit,
            rtprio_soft_limit: new_resource.rtprio_soft_limit,
            rtprio_hard_limit: new_resource.rtprio_hard_limit
          )
        end
      end

      action :delete do
        new_resource.filename = "#{new_resource.filename}.conf" unless new_resource.filename.include?('.conf')
        file "/etc/security/limits.d/#{new_resource.filename}" do
          action :delete
        end
      end
    end
  end
end
