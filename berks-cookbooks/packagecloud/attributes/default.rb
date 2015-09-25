default['packagecloud']['base_repo_path'] = "/install/repositories/"
default['packagecloud']['gpg_key_path'] = "/gpg.key"
default['packagecloud']['hostname_override'] = nil

default['packagecloud']['default_type'] = value_for_platform_family(
  'debian' => 'deb',
  ['rhel', 'fedora'] => 'rpm'
)
