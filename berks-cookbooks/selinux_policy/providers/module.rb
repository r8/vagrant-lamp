include Chef::SELinuxPolicy::Helpers

# Support whyrun
def whyrun_supported?
  true
end

def module_defined(name)
  "/usr/sbin/semodule -l | grep -w '^#{name}'"
end

def shell_boolean(expression)
  expression ? 'true' : 'false'
end

use_inline_resources

# Get all the components in the right place
action :fetch do
  directory new_resource.directory do
    only_if { use_selinux }
  end

  raise 'dont specify both directory_source and content' if new_resource.directory_source && new_resource.content

  if new_resource.directory_source # ~FC023
    remote_directory new_resource.directory do
      source new_resource.directory_source
      cookbook new_resource.cookbook
      only_if { use_selinux }
    end
  end

  if new_resource.content
    file "#{new_resource.directory}/#{new_resource.module_name}.te" do
      content new_resource.content
      only_if { use_selinux }
    end
  end
end

# compile the module
# XXX allow modifyable path
action :compile do
  make_command = "/usr/bin/make -f /usr/share/selinux/devel/Makefile #{new_resource.module_name}.pp"
  execute "semodule-compile-#{new_resource.module_name}" do
    command make_command
    not_if "#{make_command} -q", cwd: new_resource.directory # $? = 1 means make wants to execute http://www.gnu.org/software/make/manual/html_node/Running.html
    only_if { use_selinux }
    cwd new_resource.directory
  end
end

# deploy / upgrade module
# XXX this looks ugly AF because CentOS 6.X doesn't support extracting
# SELinux modules from the current policy, which I planned on comparing
# to my compiled file. I'll be happy to see anything else (that works).
action :install do
  filename = "#{new_resource.directory}/#{new_resource.module_name}.pp"
  execute "semodule-install-#{new_resource.module_name}" do
    command "/usr/sbin/semodule -i #{filename}"
    only_if "#{shell_boolean(new_resource.updated_by_last_action? || new_resource.force)} || ! (#{module_defined(new_resource.module_name)}) "
    only_if { use_selinux }
  end
end

# deploy should do all three, as it used to do
action :deploy do
  run_action(:fetch)
  run_action(:compile)
  run_action(:install)
end

# remove module
action :remove do
  execute "semodule-remove-#{new_resource.module_name}" do
    command "/usr/sbin/semodule -r #{new_resource.module_name}"
    only_if module_defined(new_resource.module_name)
    only_if { use_selinux }
  end
end
