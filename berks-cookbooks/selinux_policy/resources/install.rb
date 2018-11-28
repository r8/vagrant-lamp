property :allow_disabled, [true, false], default: true

action :install do
  case node['platform_family']
  when 'debian'
    raise 'Install SELinux manually on Ubuntu. See https://wiki.ubuntu.com/SELinux' if node['platform'] == 'ubuntu'

    execute 'selinux-activate' do
      action :nothing
    end

    # package ['policycoreutils', 'selinux-policy-dev', 'setools', 'make']
    package %w(selinux-policy-default selinux-basics auditd) do
      notifies :run, 'execute[selinux-activate]', :immediately
    end

  when 'rhel'
    case node['platform_version'].to_i
    when 6
      package ['policycoreutils-python', 'selinux-policy', 'setools-console', 'make']
    when 7
      package ['policycoreutils-python', 'selinux-policy-devel', 'setools-console', 'make']
    when 8
      package ['policycoreutils-python-utils', 'selinux-policy-devel', 'setools-console', 'make']
    else
      raise 'Unknown version of RHEL/derivative, cannot determine required package names'
    end
  when 'fedora'
    package ['policycoreutils-python', 'selinux-policy-devel', 'setools-console', 'make']
  else
    raise 'Unknown distro, cannot determine required package names'
  end
end
