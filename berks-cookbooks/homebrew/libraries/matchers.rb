if defined?(ChefSpec)
  ChefSpec.define_matcher :homebrew_tap
  ChefSpec.define_matcher :homebrew_cask

  def tap_homebrew_tap(tap)
    ChefSpec::Matchers::ResourceMatcher.new(:homebrew_tap, :tap, tap)
  end

  def untap_homebrew_tap(tap)
    ChefSpec::Matchers::ResourceMatcher.new(:homebrew_tap, :untap, tap)
  end

  def cask_homebrew_cask(cask)
    ChefSpec::Matchers::ResourceMatcher.new(:homebrew_cask, :cask, cask)
  end

  def uncask_homebrew_cask(cask)
    ChefSpec::Matchers::ResourceMatcher.new(:homebrew_cask, :uncask, cask)
  end

  def install_homebrew_cask(cask)
    ChefSpec::Matchers::ResourceMatcher.new(:homebrew_cask, :install, cask)
  end

  def uninstall_homebrew_cask(cask)
    ChefSpec::Matchers::ResourceMatcher.new(:homebrew_cask, :uninstall, cask)
  end

end
