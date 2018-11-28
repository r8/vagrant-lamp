# Manages file specs in SELinux
# See http://docs.fedoraproject.org/en-US/Fedora/13/html/SELinux_FAQ/index.html#id3715134

property :file_spec, String, name_property: true
property :secontext, String
property :file_type, String, default: 'a', equal_to: %w(a f d c b s l p)
property :allow_disabled, [true, false], default: true

action :addormodify do
  run_action(:add)
  run_action(:modify)
end

# Run restorecon to fix label
# https://github.com/sous-chefs/selinux_policy/pull/72#issuecomment-338718721
action :relabel do
  converge_by 'relabel' do
    spec = new_resource.file_spec
    escaped = Regexp.escape spec

    common =
      if spec == escaped
        spec
      else
        index = spec.size.times { |i| break i if spec[i] != escaped[i] }
        ::File.dirname spec[0...index]
      end

    # Just in case the spec is very weird...
    common = '/' if common[0] != '/'

    if ::File.exist? common
      shell_out!('find', common, '-ignore_readdir_race', '-regextype', 'posix-egrep', '-regex', spec, '-prune', '-execdir', 'restorecon', '-iRv', '{}', '+')
    end
  end
end

# Create if doesn't exist, do not touch if fcontext is already registered
action :add do
  execute "selinux-fcontext-#{new_resource.secontext}-add" do
    command "semanage fcontext -a #{semanage_options(new_resource.file_type)} -t #{new_resource.secontext} '#{new_resource.file_spec}'"
    not_if fcontext_defined(new_resource.file_spec, new_resource.file_type)
    only_if { use_selinux(new_resource) }
    notifies :relabel, new_resource, :immediate
  end
end

# Delete if exists
action :delete do
  execute "selinux-fcontext-#{new_resource.secontext}-delete" do
    command "semanage fcontext #{semanage_options(new_resource.file_type)} -d '#{new_resource.file_spec}'"
    only_if fcontext_defined(new_resource.file_spec, new_resource.file_type, new_resource.secontext)
    only_if { use_selinux(new_resource) }
    notifies :relabel, new_resource, :immediate
  end
end

action :modify do
  execute "selinux-fcontext-#{new_resource.secontext}-modify" do
    command "semanage fcontext -m #{semanage_options(new_resource.file_type)} -t #{new_resource.secontext} '#{new_resource.file_spec}'"
    only_if { use_selinux(new_resource) }
    only_if fcontext_defined(new_resource.file_spec, new_resource.file_type)
    not_if  fcontext_defined(new_resource.file_spec, new_resource.file_type, new_resource.secontext)
    notifies :relabel, new_resource, :immediate
  end
end

action_class do
  include Chef::SELinuxPolicy::Helpers
end
