#
# Cookbook Name:: percona
# Attributes:: client
#

version = value_for_platform_family(
  "debian" => node["percona"]["version"],
  "rhel" => node["percona"]["version"].tr(".", "")
)

case node["platform_family"]
when "debian"
  abi_version = case version
                when "5.5" then "18"
                when "5.6" then "18.1"
                else ""
                end

  default["percona"]["client"]["packages"] = %W[
    libperconaserverclient#{abi_version}-dev percona-server-client-#{version}
  ]
when "rhel"
  default["percona"]["client"]["packages"] = %W[
    Percona-Server-devel-#{version} Percona-Server-client-#{version}
  ]
end
