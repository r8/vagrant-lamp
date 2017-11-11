class Chef
  class Provider
    class GitClient
      class Osx < Chef::Provider::GitClient
        include Chef::DSL::IncludeRecipe

        provides :git_client, platform: 'mac_os_x'

        action :install do
          include_recipe 'homebrew'

          package 'git'
        end

        action :delete do
        end
      end
    end
  end
end
