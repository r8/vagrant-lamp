if defined?(ChefSpec)
  ChefSpec.define_matcher :nodejs_npm

  def install_nodejs_npm(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:nodejs_npm, :install, resource_name)
  end

  def uninstall_nodejs_npm(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:nodejs_npm, :uninstall, resource_name)
  end
end
