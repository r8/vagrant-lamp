module NodeJs
  module Helper
    def npm_dist
      if node['nodejs']['npm']['url']
        return { 'url' => node['nodejs']['npm']['url'] }
      else

        require 'open-uri'
        require 'json'
        result = JSON.parse(URI.parse("https://registry.npmjs.org/npm/#{node['nodejs']['npm']['version']}").read, :max_nesting => false)
        ret = { 'url' => result['dist']['tarball'], 'version' => result['_npmVersion'], 'shasum' => result['dist']['shasum'] }
        Chef::Log.debug("Npm dist #{ret}")
        return ret
      end
    end

    def npm_list(path = nil)
      require 'json'
      if path
        cmd = Mixlib::ShellOut.new('npm list -json', :cwd => path)
      else
        cmd = Mixlib::ShellOut.new('npm list -global -json')
      end
      JSON.parse(cmd.run_command.stdout, :max_nesting => false)
    end

    def url_valid?(list, package)
      list.fetch(package, {}).fetch('resolved', '').include?('url')
    end

    def version_valid?(list, package, version)
      (version ? list[package]['version'] == version : true)
    end

    def npm_package_installed?(package, version = nil, path = nil)
      list = npm_list(path)['dependencies']
      # Return true if package installed and installed to good version
      (!list.nil?) && list.key?(package) && version_valid?(list, package, version) && url_valid?(list, package)
    end
  end
end
