
require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

actions :install, :add_rbac, :delete
default_action :install

attribute :name, kind_of: String, name_attribute: true, required: true
attribute :user, kind_of: [String, NilClass], default: nil
attribute :group, kind_of: [String, NilClass], default: nil
attribute :project, kind_of: [String, NilClass], default: nil

attribute :authorization, kind_of: [String, NilClass], default: nil

attribute :start_command, kind_of: [String, NilClass], default: nil
attribute :start_timeout, kind_of: Integer, default: 5
attribute :stop_command, kind_of: String, default: ':kill'
attribute :stop_timeout, kind_of: Integer, default: 5
attribute :restart_command, kind_of: [String, NilClass], default: nil
attribute :restart_timeout, kind_of: Integer, default: 5
attribute :refresh_command, kind_of: [String, NilClass], default: nil
attribute :refresh_timeout, kind_of: Integer, default: 5

attribute :include_default_dependencies, kind_of: [TrueClass, FalseClass], default: true
attribute :dependencies, kind_of: [Array], default: []

attribute :privileges, kind_of: [Array], default: %w(basic net_privaddr)
attribute :working_directory, kind_of: [String, NilClass], default: nil
attribute :environment, kind_of: [Hash, NilClass], default: nil
attribute :locale, kind_of: String, default: 'C'

attribute :manifest_type, kind_of: String, default: 'application'
attribute :service_path, kind_of: String, default: '/var/svc/manifest'

attribute :duration, kind_of: String, default: 'contract', regex: '(contract|wait|transient|child)'
attribute :ignore, kind_of: [Array, NilClass], default: nil
attribute :fmri, kind_of: String, default: nil

attribute :stability, kind_of: String, equal_to: %(Standard Stable Evolving Unstable External Obsolete),
                      default: 'Evolving'

attribute :property_groups, kind_of: Hash, default: {}

# Deprecated
attribute :credentials_user, kind_of: [String, NilClass], default: nil

## internal methods

def xml_path
  "#{service_path}/#{manifest_type}"
end

def xml_file
  "#{xml_path}/#{name}.xml"
end

require 'fileutils'
require 'digest/md5'

# Save a checksum out to a file, for future chef runs
#
def save_checksum
  Chef::Log.debug("Saving checksum for SMF #{name}: #{checksum}")
  ::FileUtils.mkdir_p(Chef::Config.checksum_path)
  f = ::File.new(checksum_file, 'w')
  f.write checksum
end

def remove_checksum
  return unless ::File.exist?(checksum_file)

  Chef::Log.debug("Removing checksum for SMF #{name}")
  ::File.delete(checksum_file)
end

# Load current resource from checksum file and projects database.
# This should only ever be called on @current_resource, never on new_resource.
#
def load
  @checksum ||= ::File.exist?(checksum_file) ? ::File.read(checksum_file) : ''
  @smf_exists = shell_out("svcs #{fmri}").exitstatus == 0
  Chef::Log.debug("Loaded checksum for SMF #{name}: #{@checksum}")
  Chef::Log.debug("SMF service already exists for #{fmri}? #{@smf_exists.inspect}")
end

def authorization_name
  authorization || name
end

def checksum
  attributes = [
    user, credentials_user, group,
    project, start_command, start_timeout, stop_command,
    stop_timeout, restart_command, restart_timeout,
    refresh_command, refresh_timeout, working_directory,
    locale, authorization, manifest_type, service_path,
    duration, ignore.to_s, include_default_dependencies,
    dependencies, fmri, stability, environment_as_string,
    privilege_list, property_groups_as_string, '0'
  ]
  @checksum ||= Digest::MD5.hexdigest(attributes.join(':'))
end

def checksum_file
  "#{Chef::Config.checksum_path}/smf--#{name}"
end

def environment_as_string
  return nil if environment.nil?
  environment.inject('') { |memo, k, v| memo << [k, v].join('|') }
end

def privilege_list
  privileges.join(',')
end

def property_groups_as_string
  return nil if property_groups.empty?
  property_groups.inject('') { |memo, k, v| memo << [k, v].join('|') }
end

def smf_exists?
  !!@smf_exists
end
