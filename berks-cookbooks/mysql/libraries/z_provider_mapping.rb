# provider mappings for Chef 11

#########
# service
#########
Chef::Platform.set platform: :amazon, resource: :mysql_service, provider: Chef::Provider::MysqlService::Sysvinit
Chef::Platform.set platform: :centos, version: '< 7.0', resource: :mysql_service, provider: Chef::Provider::MysqlService::Sysvinit
Chef::Platform.set platform: :centos, version: '>= 7.0', resource: :mysql_service, provider: Chef::Provider::MysqlService::Systemd
Chef::Platform.set platform: :debian, resource: :mysql_service, provider: Chef::Provider::MysqlService::Sysvinit
Chef::Platform.set platform: :fedora, version: '< 19', resource: :mysql_service, provider: Chef::Provider::MysqlService::Sysvinit
Chef::Platform.set platform: :fedora, version: '>= 19', resource: :mysql_service, provider: Chef::Provider::MysqlService::Systemd
Chef::Platform.set platform: :omnios, resource: :mysql_service, provider: Chef::Provider::MysqlService::Smf
Chef::Platform.set platform: :redhat, version: '< 7.0', resource: :mysql_service, provider: Chef::Provider::MysqlService::Sysvinit
Chef::Platform.set platform: :redhat, version: '>= 7.0', resource: :mysql_service, provider: Chef::Provider::MysqlService::Systemd
Chef::Platform.set platform: :scientific, version: '< 7.0', resource: :mysql_service, provider: Chef::Provider::MysqlService::Sysvinit
Chef::Platform.set platform: :scientific, version: '>= 7.0', resource: :mysql_service, provider: Chef::Provider::MysqlService::Systemd
Chef::Platform.set platform: :smartos, resource: :mysql_service, provider: Chef::Provider::MysqlService::Smf
Chef::Platform.set platform: :suse, resource: :mysql_service, provider: Chef::Provider::MysqlService::Sysvinit
Chef::Platform.set platform: :ubuntu, resource: :mysql_service, provider: Chef::Provider::MysqlService::Upstart

#########
# config
#########
Chef::Platform.set platform: :amazon, resource: :mysql_config, provider: Chef::Provider::MysqlConfig
Chef::Platform.set platform: :centos, resource: :mysql_config, provider: Chef::Provider::MysqlConfig
Chef::Platform.set platform: :debian, resource: :mysql_config, provider: Chef::Provider::MysqlConfig
Chef::Platform.set platform: :fedora, resource: :mysql_config, provider: Chef::Provider::MysqlConfig
Chef::Platform.set platform: :omnios, resource: :mysql_config, provider: Chef::Provider::MysqlConfig
Chef::Platform.set platform: :redhat, resource: :mysql_config, provider: Chef::Provider::MysqlConfig
Chef::Platform.set platform: :scientific, resource: :mysql_config, provider: Chef::Provider::MysqlConfig
Chef::Platform.set platform: :smartos, resource: :mysql_config, provider: Chef::Provider::MysqlConfig
Chef::Platform.set platform: :suse, resource: :mysql_config, provider: Chef::Provider::MysqlConfig
Chef::Platform.set platform: :ubuntu, resource: :mysql_config, provider: Chef::Provider::MysqlConfig

#########
# client
#########
Chef::Platform.set platform: :amazon, resource: :mysql_client, provider: Chef::Provider::MysqlClient
Chef::Platform.set platform: :centos, resource: :mysql_client, provider: Chef::Provider::MysqlClient
Chef::Platform.set platform: :debian, resource: :mysql_client, provider: Chef::Provider::MysqlClient
Chef::Platform.set platform: :fedora, resource: :mysql_client, provider: Chef::Provider::MysqlClient
Chef::Platform.set platform: :omnios, resource: :mysql_client, provider: Chef::Provider::MysqlClient
Chef::Platform.set platform: :redhat, resource: :mysql_client, provider: Chef::Provider::MysqlClient
Chef::Platform.set platform: :scientific, resource: :mysql_client, provider: Chef::Provider::MysqlClient
Chef::Platform.set platform: :smartos, resource: :mysql_client, provider: Chef::Provider::MysqlClient
Chef::Platform.set platform: :suse, resource: :mysql_client, provider: Chef::Provider::MysqlClient
Chef::Platform.set platform: :ubuntu, resource: :mysql_client, provider: Chef::Provider::MysqlClient
