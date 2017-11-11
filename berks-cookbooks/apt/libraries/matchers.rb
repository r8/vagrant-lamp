if defined?(ChefSpec)

  #################
  # apt_preference
  #################

  ChefSpec.define_matcher :apt_preference

  def add_apt_preference(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:apt_preference, :add, resource_name)
  end

  def remove_apt_preference(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:apt_preference, :remove, resource_name)
  end
end
