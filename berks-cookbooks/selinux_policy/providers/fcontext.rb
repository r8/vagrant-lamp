include Chef::SELinuxPolicy::Helpers

# Support whyrun
def whyrun_supported?
  true
end

def fcontext_defined(file_spec, file_type, label = nil)
  file_hash = {
    'a' => 'all files',
    'f' => 'regular file',
    'd' => 'directory',
    'c' => 'character device',
    'b' => 'block device',
    's' => 'socket',
    'l' => 'symbolic link',
    'p' => 'named pipe',
  }

  label_matcher = label ? "system_u:object_r:#{Regexp.escape(label)}:s0\\s*$" : ''
  "semanage fcontext -l | grep -qP '^#{Regexp.escape(file_spec)}\\s+#{Regexp.escape(file_hash[file_type])}\\s+#{label_matcher}'"
end

def semanage_options(file_type)
  # Set options for file_type
  if node['platform_family'].include?('rhel') && Chef::VersionConstraint.new('< 7.0').include?(node['platform_version'])
    case file_type
    when 'a' then '-f ""'
    when 'f' then '-f --'
    else; "-f -#{file_type}"
    end
  else
    "-f #{file_type}"
  end
end

use_inline_resources

# Run restorecon to fix label
action :relabel do
  res = shell_out!('find', '/', '-regextype', 'posix-egrep', '-regex', new_resource.file_spec, '-execdir', 'restorecon', '-iRv', '{}', ';')
  new_resource.updated_by_last_action(true) unless res.stdout.empty?
end

# Create if doesn't exist, do not touch if fcontext is already registered
action :add do
  execute "selinux-fcontext-#{new_resource.secontext}-add" do
    command "/usr/sbin/semanage fcontext -a #{semanage_options(new_resource.file_type)} -t #{new_resource.secontext} '#{new_resource.file_spec}'"
    not_if fcontext_defined(new_resource.file_spec, new_resource.file_type)
    only_if { use_selinux }
    notifies :relabel, new_resource, :immediate
  end
end

# Delete if exists
action :delete do
  execute "selinux-fcontext-#{new_resource.secontext}-delete" do
    command "/usr/sbin/semanage fcontext #{semanage_options(new_resource.file_type)} -d '#{new_resource.file_spec}'"
    only_if fcontext_defined(new_resource.file_spec, new_resource.file_type, new_resource.secontext)
    only_if { use_selinux }
    notifies :relabel, new_resource, :immediate
  end
end

action :modify do
  execute "selinux-fcontext-#{new_resource.secontext}-modify" do
    command "/usr/sbin/semanage fcontext -m #{semanage_options(new_resource.file_type)} -t #{new_resource.secontext} '#{new_resource.file_spec}'"
    only_if { use_selinux }
    only_if fcontext_defined(new_resource.file_spec, new_resource.file_type)
    not_if  fcontext_defined(new_resource.file_spec, new_resource.file_type, new_resource.secontext)
    notifies :relabel, new_resource, :immediate
  end
end

action :addormodify do
  run_action(:add)
  run_action(:modify)
end
