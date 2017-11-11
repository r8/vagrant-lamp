if defined?(ChefSpec)
  [:create, :update, :delete, :create_if_missing].each do |action|
    define_method(:"#{action}_chef_vault_secret") do |resource_name|
      ChefSpec::Matchers::ResourceMatcher.new(:chef_vault_secret, action, resource_name)
    end
  end
end
