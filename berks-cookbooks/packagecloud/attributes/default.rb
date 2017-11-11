default['packagecloud']['base_repo_path'] = "/install/repositories/"
default['packagecloud']['gpg_key_path'] = "/gpgkey"
default['packagecloud']['hostname_override'] = nil
default['packagecloud']['proxy_host'] = nil
default['packagecloud']['proxy_port'] = nil

default['packagecloud']['default_type'] = value_for_platform_family(
  'debian' => 'deb',
  ['rhel', 'fedora'] => 'rpm'
)
