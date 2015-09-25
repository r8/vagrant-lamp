if defined?(ChefSpec)
  if ChefSpec.respond_to?(:define_matcher)
    # ChefSpec >= 4.1
    ChefSpec.define_matcher :mysql_config
    ChefSpec.define_matcher :mysql_service
    ChefSpec.define_matcher :mysql_client
  elsif defined?(ChefSpec::Runner) &&
        ChefSpec::Runner.respond_to?(:define_runner_method)
    # ChefSpec < 4.1
    ChefSpec::Runner.define_runner_method :mysql_config
    ChefSpec::Runner.define_runner_method :mysql_service
    ChefSpec::Runner.define_runner_method :mysql_client
  end

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

  def start_mysql_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_service, :start, resource_name)
  end

  def stop_mysql_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_service, :stop, resource_name)
  end

  def restart_mysql_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_service, :restart, resource_name)
  end

  def reload_mysql_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_service, :reload, resource_name)
  end

  # client
  def create_mysql_client(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_client, :create, resource_name)
  end

  def delete_mysql_client(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_client, :delete, resource_name)
  end
end
