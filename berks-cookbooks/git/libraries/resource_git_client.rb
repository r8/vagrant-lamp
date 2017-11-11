require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class GitClient < Chef::Resource::LWRPBase
      self.resource_name = :git_client
      actions :install, :remove
      default_action :install

      provides :git_client

      # used by source providers
      attribute :source_checksum, kind_of: String, default: nil
      attribute :source_prefix, kind_of: String, default: '/usr/local'
      attribute :source_url, kind_of: String, default: nil
      attribute :source_use_pcre, kind_of: [TrueClass, FalseClass], default: false
      attribute :source_version, kind_of: String, default: nil

      # used by linux package providers
      attribute :package_name, kind_of: String, default: nil
      attribute :package_version, kind_of: String, default: nil
      attribute :package_action, kind_of: Symbol, default: :install

      # used by OSX package providers
      attribute :osx_dmg_app_name, kind_of: String, default: 'git-2.7.1-intel-universal-mavericks'
      attribute :osx_dmg_package_id, kind_of: String, default: 'GitOSX.Installer.git271.git.pkg'
      attribute :osx_dmg_volumes_dir, kind_of: String, default: 'Git 2.7.1 Mavericks Intel Universal'
      attribute :osx_dmg_url, kind_of: String, default: 'http://sourceforge.net/projects/git-osx-installer/files/git-2.7.1-intel-universal-mavericks.dmg/download'
      attribute :osx_dmg_checksum, kind_of: String, default: '260b32e8877eb72d07807b26163aeec42e2d98c350f32051ab1ff0cc33626440' # 2.7.1

      # used by Windows providers
      attribute :windows_display_name, kind_of: String, default: nil
      attribute :windows_package_url,  kind_of: String, default: nil
      attribute :windows_package_checksum, kind_of: String, default: nil
      attribute :windows_package_version, kind_of: String, default: nil
    end
  end
end
