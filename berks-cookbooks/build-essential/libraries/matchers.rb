if defined?(ChefSpec)
  def install_xcode_command_line_tools(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:xcode_command_line_tools, :install, resource_name)
  end

  def install_build_essential(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:build_essential, :install, resource_name)
  end
end
