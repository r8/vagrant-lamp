default['yum']['epel-testing-debuginfo']['repositoryid'] = 'epel-testing-debuginfo'
default['yum']['epel-testing-debuginfo']['description'] = "Extra Packages for #{node['platform_version'].to_i} - $basearch - Testing Debug"
case node['platform']
when 'amazon'
  case node['platform_version']
  when /201.*/
    default['yum']['epel-testing-debuginfo']['mirrorlist'] = 'http://mirrors.fedoraproject.org/mirrorlist?repo=testing-debug-epel6&arch=$basearch'
    default['yum']['epel-testing-debuginfo']['gpgkey'] = 'http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
  when /2\..*/
    default['yum']['epel-testing-debuginfo']['mirrorlist'] = 'http://mirrors.fedoraproject.org/mirrorlist?repo=testing-debug-epel7&arch=$basearch'
    default['yum']['epel-testing-debuginfo']['gpgkey'] = 'http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7'
  else
    default['yum']['epel-testing-debuginfo']['mirrorlist'] = 'http://mirrors.fedoraproject.org/mirrorlist?repo=testing-debug-epel6&arch=$basearch'
    default['yum']['epel-testing-debuginfo']['gpgkey'] = 'http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
  end
else
  default['yum']['epel-testing-debuginfo']['mirrorlist'] = "http://mirrors.fedoraproject.org/mirrorlist?repo=testing-debug-epel#{node['platform_version'].to_i}&arch=$basearch"
  default['yum']['epel-testing-debuginfo']['gpgkey'] = "https://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-#{node['platform_version'].to_i}"
end
default['yum']['epel-testing-debuginfo']['failovermethod'] = 'priority'
default['yum']['epel-testing-debuginfo']['gpgcheck'] = true
default['yum']['epel-testing-debuginfo']['enabled'] = false
default['yum']['epel-testing-debuginfo']['managed'] = false
default['yum']['epel-testing-debuginfo']['make_cache'] = true
