if defined?(ChefSpec)
  # config
  def create_mysql_config(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_config, :create, resource_name)
  end

  def delete_mysql_config(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_config, :delete, resource_name)
  end

  # service
  def create_mysql_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_service, :create, resource_name)
  end

  def delete_mysql_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_service, :delete, resource_name)
  end

  # client
  def create_mysql_client(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_client, :create, resource_name)
  end

  def delete_mysql_client(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_client, :delete, resource_name)
  end
end
