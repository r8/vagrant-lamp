if defined?(ChefSpec)
  ChefSpec.define_matcher(:git_client)
  ChefSpec.define_matcher(:git_service)

  def set_git_config(resource_name) # rubocop:disable Style/AccessorMethodName
    ChefSpec::Matchers::ResourceMatcher.new(:git_config, :set, resource_name)
  end

  def install_git_client(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:git_client, :install, resource_name)
  end

  def install_git_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:git_service, :install, resource_name)
  end
end
