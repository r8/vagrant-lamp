if defined?(ChefSpec)
  def set_selinux_policy_boolean(resource_name) # rubocop:disable Style/AccessorMethodName
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_boolean, :set, resource_name)
  end

  def setpersist_selinux_policy_boolean(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_boolean, :setpersist, resource_name)
  end

  def add_selinux_policy_fcontext(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_fcontext, :add, resource_name)
  end

  def delete_selinux_policy_fcontext(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_fcontext, :delete, resource_name)
  end

  def modify_selinux_policy_fcontext(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_fcontext, :modify, resource_name)
  end

  def addormodify_selinux_policy_fcontext(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_fcontext, :addormodify, resource_name)
  end

  def deploy_selinux_policy_module(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_module, :deploy, resource_name)
  end

  def remove_selinux_policy_module(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_module, :remove, resource_name)
  end

  def add_selinux_policy_permissive(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_permissive, :add, resource_name)
  end

  def delete_selinux_policy_permissive(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_permissive, :delete, resource_name)
  end

  def add_selinux_policy_port(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_port, :add, resource_name)
  end

  def delete_selinux_policy_port(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_port, :delete, resource_name)
  end

  def modify_selinux_policy_port(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_port, :modify, resource_name)
  end

  def addormodify_selinux_policy_port(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:selinux_policy_port, :addormodify, resource_name)
  end
end
