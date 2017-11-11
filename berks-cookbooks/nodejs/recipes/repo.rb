case node['platform_family']
when 'debian'
  package 'apt-transport-https'

  apt_repository 'node.js' do
    uri node['nodejs']['repo']
    distribution node['lsb']['codename']
    components ['main']
    keyserver node['nodejs']['keyserver']
    key node['nodejs']['key']
  end
when 'rhel', 'amazon'
  yum_repository 'node.js' do
    description 'nodesource.com nodejs repository'
    baseurl node['nodejs']['repo']
    gpgkey node['nodejs']['key']
  end
end
