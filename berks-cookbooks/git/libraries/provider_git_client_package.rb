class Chef
  class Provider
    class GitClient
      class Package < Chef::Provider::GitClient
        provides :git_client, os: 'linux'

        action :install do
          # Software installation
          package "#{new_resource.name} :create #{parsed_package_name}" do
            package_name parsed_package_name
            version parsed_package_version
            action new_resource.package_action
            action :install
          end
        end

        action :delete do
        end
      end
    end
  end
end
