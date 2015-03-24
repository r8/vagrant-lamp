#
# Cookbook Name:: percona
# Attributes:: monitoring
#

default["percona"]["plugins_version"] = "1.1.3"
default["percona"]["plugins_packages"] = %w[percona-nagios-plugins percona-zabbix-templates percona-cacti-templates]
