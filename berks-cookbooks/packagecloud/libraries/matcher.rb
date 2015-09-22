if defined?(ChefSpec)

  def create_packagecloud_repo(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:packagecloud_repo, :add, resource_name)
  end

end
