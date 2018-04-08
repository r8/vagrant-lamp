if defined?(ChefSpec)
  ChefSpec.define_matcher :packagecloud_repo

  def create_packagecloud_repo(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:packagecloud_repo, :add, resource_name)
  end

  def add_packagecloud_repo(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:packagecloud_repo, :add, resource_name)
  end
end
