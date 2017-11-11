default['yum']['epel-testing']['repositoryid'] = 'epel-testing'
default['yum']['epel-testing']['description'] = "Extra Packages for #{node['platform_version'].to_i} - $basearch - Testing "
case node['platform']
when 'amazon'
  default['yum']['epel-testing']['mirrorlist'] = 'http://mirrors.fedoraproject.org/mirrorlist?repo=testing-epel6&arch=$basearch'
  default['yum']['epel-testing']['gpgkey'] = 'http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
else
  default['yum']['epel-testing']['mirrorlist'] = "http://mirrors.fedoraproject.org/mirrorlist?repo=testing-epel#{node['platform_version'].to_i}&arch=$basearch"
  default['yum']['epel-testing']['gpgkey'] = "https://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-#{node['platform_version'].to_i}"
end
default['yum']['epel-testing']['failovermethod'] = 'priority'
default['yum']['epel-testing']['gpgcheck'] = true
default['yum']['epel-testing']['enabled'] = false
default['yum']['epel-testing']['managed'] = false
default['yum']['epel-testing']['make_cache'] = true
