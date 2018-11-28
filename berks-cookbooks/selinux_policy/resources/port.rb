# Manages a port assignment in SELinux
# See http://docs.fedoraproject.org/en-US/Fedora/13/html/SELinux_FAQ/index.html#id3715134

property :port, [Integer, String], name_property: true
property :protocol, String, equal_to: %w(tcp udp)
property :secontext, String
property :allow_disabled, [true, false], default: true

action :addormodify do
  # TODO: We can be a bit more clever here, and try to detect if it's already
  # there then modify
  # Try to add new port
  run_action(:add)
  # Try to modify existing port
  run_action(:modify)
end

# Create if doesn't exist, do not touch if port is already registered (even under different type)
action :add do
  validate_port(new_resource.port)
  execute "selinux-port-#{new_resource.port}-add" do
    command "semanage port -a -t #{new_resource.secontext} -p #{new_resource.protocol} #{new_resource.port}"
    not_if port_defined(new_resource.protocol, new_resource.port, new_resource.secontext)
    not_if port_defined(new_resource.protocol, new_resource.port)
    only_if { use_selinux(new_resource) }
  end
end

# Delete if exists
action :delete do
  validate_port(new_resource.port)
  execute "selinux-port-#{new_resource.port}-delete" do
    command "semanage port -d -p #{new_resource.protocol} #{new_resource.port}"
    only_if port_defined(new_resource.protocol, new_resource.port)
    only_if { use_selinux(new_resource) }
  end
end

action :modify do
  execute "selinux-port-#{new_resource.port}-modify" do
    command "semanage port -m -t #{new_resource.secontext} -p #{new_resource.protocol} #{new_resource.port}"
    only_if port_defined(new_resource.protocol, new_resource.port)
    not_if port_defined(new_resource.protocol, new_resource.port, new_resource.secontext)
    only_if { use_selinux(new_resource) }
  end
end

action_class do
  include Chef::SELinuxPolicy::Helpers
end
