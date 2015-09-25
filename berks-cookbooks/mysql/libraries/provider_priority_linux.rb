
begin
  require 'chef/platform/provider_priority_map'
rescue LoadError
end

require_relative 'provider_mysql_service_smf'
require_relative 'provider_mysql_service_systemd'
require_relative 'provider_mysql_service_sysvinit'
require_relative 'provider_mysql_service_upstart'
require_relative 'provider_mysql_config'
require_relative 'provider_mysql_client'

if defined? Chef::Platform::ProviderPriorityMap
  Chef::Platform::ProviderPriorityMap.instance.priority(
    :mysql_service,
    [Chef::Provider::MysqlServiceSystemd, Chef::Provider::MysqlServiceUpstart, Chef::Provider::MysqlServiceSysvinit],
    os: 'linux'
  )
else
  # provider mappings for Chef 11

  # systemd service
  Chef::Platform.set platform: :fedora, version: '>= 19', resource: :mysql_service, provider: Chef::Provider::MysqlServiceSystemd
  Chef::Platform.set platform: :redhat, version: '>= 7.0', resource: :mysql_service, provider: Chef::Provider::MysqlServiceSystemd
  Chef::Platform.set platform: :centos, version: '>= 7.0', resource: :mysql_service, provider: Chef::Provider::MysqlServiceSystemd
  Chef::Platform.set platform: :scientific, version: '>= 7.0', resource: :mysql_service, provider: Chef::Provider::MysqlServiceSystemd
  Chef::Platform.set platform: :oracle, version: '>= 7.0', resource: :mysql_service, provider: Chef::Provider::MysqlServiceSystemd

  # smf service
  Chef::Platform.set platform: :omnios, resource: :mysql_service, provider: Chef::Provider::MysqlServiceSmf
  Chef::Platform.set platform: :smartos, resource: :mysql_service, provider: Chef::Provider::MysqlServiceSmf

  # upstart service
  Chef::Platform.set platform: :ubuntu, resource: :mysql_service, provider: Chef::Provider::MysqlServiceUpstart

  # default service
  Chef::Platform.set resource: :mysql_service, provider: Chef::Provider::MysqlServiceSysvinit

  # config
  Chef::Platform.set resource: :mysql_config, provider: Chef::Provider::MysqlConfig

  # client
  Chef::Platform.set resource: :mysql_client, provider: Chef::Provider::MysqlClient
end
