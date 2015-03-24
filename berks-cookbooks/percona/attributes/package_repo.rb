#
# Cookbook Name:: percona
# Attributes:: package_repo
#

default["percona"]["use_percona_repos"] = true
default["percona"]["apt_uri"] = "http://repo.percona.com/apt"
default["percona"]["apt_keyserver"] = "keys.gnupg.net"
default["percona"]["apt_key"] = "CD2EFD2A"

arch = node["kernel"]["machine"] == "x86_64" ? "x86_64" : "i386"
pversion = node["platform_version"].to_i

default["percona"]["yum"]["description"] = "Percona Packages"
default["percona"]["yum"]["baseurl"] = "http://repo.percona.com/centos/#{pversion}/os/#{arch}/"
default["percona"]["yum"]["gpgkey"] = "http://www.percona.com/downloads/RPM-GPG-KEY-percona"
default["percona"]["yum"]["gpgcheck"] = true
default["percona"]["yum"]["sslverify"] = true
