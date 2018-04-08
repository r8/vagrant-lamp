module NodeJs
  module Helper
    def npm_dist
      if node['nodejs']['npm']['url']
        { 'url' => node['nodejs']['npm']['url'] }
      else

        require 'open-uri'
        require 'json'
        result = JSON.parse(URI.parse("https://registry.npmjs.org/npm/#{node['nodejs']['npm']['version']}").read, max_nesting: false)
        ret = { 'url' => result['dist']['tarball'], 'version' => result['_npmVersion'], 'shasum' => result['dist']['shasum'] }
        Chef::Log.debug("Npm dist #{ret}")
        ret
      end
    end

    def npm_list(package, path = nil, environment = {})
      require 'json'
      cmd = if path
              Mixlib::ShellOut.new("npm list #{package} -json", cwd: path, environment: environment)
            else
              Mixlib::ShellOut.new("npm list #{package} -global -json", environment: environment)
            end

      JSON.parse(cmd.run_command.stdout, max_nesting: false)
    end

    def version_valid?(list, package, version)
      (version ? list[package]['version'] == version : true)
    end

    def npm_package_installed?(package, version = nil, path = nil, npm_token = nil)
      environment = { 'NPM_TOKEN' => npm_token } if npm_token

      list = npm_list(package, path, environment)['dependencies']
      # Return true if package installed and installed to good version
      !list.nil? && list.key?(package) && version_valid?(list, package, version)
    end
  end
end
