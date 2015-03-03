#
# Cookbook Name:: percona
# Recipe:: package_repo
#

return unless node["percona"]["use_percona_repos"]

case node["platform_family"]
when "debian"
  include_recipe "apt"

  # Pin this repo as to avoid upgrade conflicts with distribution repos.
  apt_preference "00percona" do
    glob "*"
    pin "release o=Percona Development Team"
    pin_priority "1001"
  end

  apt_repository "percona" do
    uri node["percona"]["apt_uri"]
    distribution node["lsb"]["codename"]
    components ["main"]
    keyserver node["percona"]["apt_keyserver"]
    key node["percona"]["apt_key"]
    action :add
  end

when "rhel"
  include_recipe "yum"

  yum_repository "percona" do
    description node["percona"]["yum"]["description"]
    baseurl node["percona"]["yum"]["baseurl"]
    gpgkey node["percona"]["yum"]["gpgkey"]
    gpgcheck node["percona"]["yum"]["gpgcheck"]
    sslverify node["percona"]["yum"]["sslverify"]
    action :create
  end
end
