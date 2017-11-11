include Chef::SELinuxPolicy::Helpers

# Support whyrun
def whyrun_supported?
  true
end

use_inline_resources

# Set for now, without persisting
action :set do
  sebool(false)
end

# Set and persist
action :setpersist do
  sebool(true)
end

def sebool(persist = false)
  persist_string = persist ? '-P ' :  ''
  new_value = new_resource.value ? 'on' : 'off'
  execute "selinux-setbool-#{new_resource.name}-#{new_value}" do
    command "/usr/sbin/setsebool #{persist_string} #{new_resource.name} #{new_value}"
    not_if "/usr/sbin/getsebool #{new_resource.name} | grep '#{new_value}$' >/dev/null" unless new_resource.force
    only_if { use_selinux }
  end
end
