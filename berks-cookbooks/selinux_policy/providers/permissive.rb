include Chef::SELinuxPolicy::Helpers

# Support whyrun
def whyrun_supported?
  true
end

use_inline_resources

# Create if doesn't exist, do not touch if port is already registered (even under different type)
action :add do
  execute "selinux-permissive-#{new_resource.name}-add" do
    command "/usr/sbin/semanage permissive -a '#{new_resource.name}'"
    not_if  "/usr/sbin/semanage permissive -l | grep  '^#{new_resource.name}$'"
    only_if { use_selinux }
  end
end

# Delete if exists
action :delete do
  execute "selinux-port-#{new_resource.name}-delete" do
    command "/usr/sbin/semanage permissive -d '#{new_resource.name}'"
    not_if  "/usr/sbin/semanage permissive -l | grep  '^#{new_resource.name}$'"
    only_if { use_selinux }
  end
end
