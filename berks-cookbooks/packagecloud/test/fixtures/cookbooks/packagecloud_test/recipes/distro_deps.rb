case node['platform_family']
when 'rhel', 'fedora', 'amazon'
  if node['platform_version'].to_i == 5
    execute 'fixup repos' do
      command 'sed -i "/mirrorlist/d" /etc/yum.repos.d/*.repo; sed -i -e "s/#baseurl/baseurl/g" /etc/yum.repos.d/*.repo; sed -i -e "s/mirror.centos.org\/centos\/\$releasever/vault.centos.org\/5.11/g" /etc/yum.repos.d/*.repo'
    end

    yum_repository 'epel5' do
      baseurl 'https://mirrors.rit.edu/fedora/archive/epel/5/$basearch'
      description 'Extra Packages for Enterprise Linux 5 - $basearch'
      enabled true
      gpgcheck true
      gpgkey 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL'
    end
  end
  package %w(ruby rubygems)
when 'debian'
  apt_update 'update'
  package %w(ruby dpkg-dev)
  package 'rubygems' unless node['platform_version'].to_f == 14.04
end
