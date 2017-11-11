# cookbook/libraries/matchers.rb

if defined?(ChefSpec)
  def run_redisio_sentinel(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new('redisio_sentinel', :run, resource_name)
  end
end
