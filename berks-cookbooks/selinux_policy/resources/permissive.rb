# a resource for managing selinux permissive contexts

property :allow_disabled, [true, false], default: true

# Create if doesn't exist, do not touch if port is already registered (even under different type)
action :add do
  execute "selinux-permissive-#{new_resource.name}-add" do
    command "semanage permissive -a '#{new_resource.name}'"
    not_if  "semanage permissive -l | grep  '^#{new_resource.name}$'"
    only_if { use_selinux }
  end
end

# Delete if exists
action :delete do
  execute "selinux-port-#{new_resource.name}-delete" do
    command "semanage permissive -d '#{new_resource.name}'"
    not_if  "semanage permissive -l | grep  '^#{new_resource.name}$'"
    only_if { use_selinux }
  end
end

action_class do
  include Chef::SELinuxPolicy::Helpers
end
