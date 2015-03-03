directory '/opt/scripts' do
  action :create
  mode '0755'
  owner 'root'
  group 'root'
end

directory '/opt/local/etc/snmp/conf.d' do
  action :create
  mode '0755'
  owner 'root'
  group 'root'
end

template '/opt/scripts/SMFServicesOK.sh' do
  path '/opt/scripts/SMFServicesOK.sh'
  source 'SMFServicesOK.sh.erb'
  mode '0755'
end

template 'SMFServicesOK.snmpd.conf' do
  path '/opt/local/etc/snmp/conf.d/SMFServicesOK.snmpd.conf'
  source 'SMFServicesOK.snmpd.conf.erb'
  mode '0644'
end
