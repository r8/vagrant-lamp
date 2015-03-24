if defined?(ChefSpec)
  def install_smf(name)
    ChefSpec::Matchers::ResourceMatcher.new(:smf, :install, name)
  end

  def delete_smf(name)
    ChefSpec::Matchers::ResourceMatcher.new(:smf, :delete, name)
  end
end
