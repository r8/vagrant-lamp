include Chef::SELinuxPolicy::Helpers

# Support whyrun
def whyrun_supported?
  true
end

def port_defined(protocol, port, label = nil)
  base_command = "seinfo --protocol=#{protocol} --portcon=#{port} | awk -F: '$(NF-1) !~ /reserved_port_t$/ {print $(NF-1)}'"
  grep = if label
           "grep -P '#{Regexp.escape(label)}'"
         else
           'grep -q ^'
         end
  "#{base_command} | #{grep}"
end

def validate_port(port)
  raise ArgumentError, "port value: #{port} is invalid." unless port.to_s =~ /^\d+$/
end

use_inline_resources

# Create if doesn't exist, do not touch if port is already registered (even under different type)
action :add do
  validate_port(new_resource.port)
  execute "selinux-port-#{new_resource.port}-add" do
    command "/usr/sbin/semanage port -a -t #{new_resource.secontext} -p #{new_resource.protocol} #{new_resource.port}"
    not_if port_defined(new_resource.protocol, new_resource.port)
    only_if { use_selinux }
  end
end

# Delete if exists
action :delete do
  validate_port(new_resource.port)
  execute "selinux-port-#{new_resource.port}-delete" do
    command "/usr/sbin/semanage port -d -p #{new_resource.protocol} #{new_resource.port}"
    only_if port_defined(new_resource.protocol, new_resource.port)
    only_if { use_selinux }
  end
end

action :modify do
  execute "selinux-port-#{new_resource.port}-modify" do
    command "/usr/sbin/semanage port -m -t #{new_resource.secontext} -p #{new_resource.protocol} #{new_resource.port}"
    only_if port_defined(new_resource.protocol, new_resource.port)
    not_if port_defined(new_resource.protocol, new_resource.port, new_resource.secontext)
    only_if { use_selinux }
  end
end

action :addormodify do
  # Try to add new port
  run_action(:add)
  # Try to modify existing port
  run_action(:modify)
end
