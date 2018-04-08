class Chef
  class Provider
    class GitClient
      class Osx < Chef::Provider::GitClient
        provides :git_client, platform: 'mac_os_x'

        action :install do
          package 'git'
        end

        action :delete do
        end
      end
    end
  end
end
