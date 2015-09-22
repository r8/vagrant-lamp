if defined?(ChefSpec)
  ChefSpec.define_matcher :php_pear
  def install_php_pear(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:php_pear, :install, resource_name)
  end

  def remove_php_pear(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:php_pear, :remove, resource_name)
  end

  def upgrade_php_pear(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:php_pear, :upgrade, resource_name)
  end

  def purge_php_pear(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:php_pear, :purge, resource_name)
  end

  ChefSpec.define_matcher :php_pear_channel
  def discover_php_pear_channel(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:php_pear_channel, :discover, resource_name)
  end

  def remove_php_pear_channel(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:php_pear_channel, :remove, resource_name)
  end

  def update_php_pear_channel(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:php_pear_channel, :update, resource_name)
  end

  def add_php_pear_channel(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:php_pear_channel, :add, resource_name)
  end
end
