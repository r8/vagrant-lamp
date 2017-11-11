default['yum']['epel-debuginfo']['repositoryid'] = 'epel-debuginfo'
default['yum']['epel-debuginfo']['description'] = "Extra Packages for #{node['platform_version'].to_i} - $basearch - Debug"
case node['platform']
when 'amazon'
  default['yum']['epel-debuginfo']['mirrorlist'] = 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-debug-6&arch=$basearch'
  default['yum']['epel-debuginfo']['gpgkey'] = 'http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
else
  default['yum']['epel-debuginfo']['mirrorlist'] = "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-debug-#{node['platform_version'].to_i}&arch=$basearch"
  default['yum']['epel-debuginfo']['gpgkey'] = "https://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-#{node['platform_version'].to_i}"
end
default['yum']['epel-debuginfo']['failovermethod'] = 'priority'
default['yum']['epel-debuginfo']['gpgcheck'] = true
default['yum']['epel-debuginfo']['enabled'] = false
default['yum']['epel-debuginfo']['managed'] = false
default['yum']['epel-debuginfo']['make_cache'] = true
