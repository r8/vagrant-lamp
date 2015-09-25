#
# Cookbook Name:: percona
# Attributes:: package_repo
#

default["percona"]["use_percona_repos"] = true

arch = node["kernel"]["machine"] == "x86_64" ? "x86_64" : "i386"
pversion = value_for_platform(
  "amazon" => { "default" => "latest" },
  "default" => node["platform_version"].to_i
)

default["percona"]["apt"]["key"] = "0x1C4CBDCDCD2EFD2A"
default["percona"]["apt"]["keyserver"] = "hkp://keys.gnupg.net:80"
default["percona"]["apt"]["uri"] = "http://repo.percona.com/apt"

default["percona"]["yum"]["description"] = "Percona Packages"
default["percona"]["yum"]["baseurl"] = "http://repo.percona.com/centos/#{pversion}/os/#{arch}/"
default["percona"]["yum"]["gpgkey"] = "http://www.percona.com/downloads/RPM-GPG-KEY-percona"
default["percona"]["yum"]["gpgcheck"] = true
default["percona"]["yum"]["sslverify"] = true
