default['yum']['epel']['repositoryid'] = 'epel'
default['yum']['epel']['description'] = "Extra Packages for #{node['platform_version'].to_i} - $basearch"
default['yum']['epel']['gpgcheck'] = true
case node['kernel']['machine']
when 'armv7l', 'armv7hl'
  default['yum']['epel']['baseurl'] = 'https://armv7.dev.centos.org/repodir/epel-pass-1/'
  default['yum']['epel']['gpgcheck'] = false
when 's390x'
  default['yum']['epel']['baseurl'] = 'https://kojipkgs.fedoraproject.org/rhel/rc/7/Server/s390x/os/'
  default['yum']['epel']['gpgkey'] = 'https://kojipkgs.fedoraproject.org/rhel/rc/7/Server/s390x/os/RPM-GPG-KEY-redhat-release'
else
  if platform?('amazon')
    if node['platform_version'].to_i > 2010
      default['yum']['epel']['mirrorlist'] = 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
      default['yum']['epel']['gpgkey'] = 'http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
    else
      default['yum']['epel']['mirrorlist'] = 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-7&arch=$basearch'
      default['yum']['epel']['gpgkey'] = 'http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7'
    end
  else
    default['yum']['epel']['mirrorlist'] = "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-#{node['platform_version'].to_i}&arch=$basearch"
    default['yum']['epel']['gpgkey'] = "https://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-#{node['platform_version'].to_i}"
  end
end
default['yum']['epel']['failovermethod'] = 'priority'
default['yum']['epel']['enabled'] = true
default['yum']['epel']['managed'] = true
default['yum']['epel']['make_cache'] = true
