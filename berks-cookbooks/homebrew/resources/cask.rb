property :name, String, regex: /^[\w-]+$/, name_property: true
property :options, String

action :install do
  execute "installing cask #{new_resource.name}" do
    command "/usr/local/bin/brew cask install #{new_resource.name} #{new_resource.options}"
    user Homebrew.owner
    environment lazy { { 'HOME' => ::Dir.home(Homebrew.owner), 'USER' => Homebrew.owner } }
    not_if { casked? }
  end
end

action :uninstall do
  execute "uninstalling cask #{new_resource.name}" do
    command "/usr/local/bin/brew cask uninstall #{new_resource.name}"
    user Homebrew.owner
    environment lazy { { 'HOME' => ::Dir.home(Homebrew.owner), 'USER' => Homebrew.owner } }
    only_if { casked? }
  end
end

action_class do
  alias_method :action_cask, :action_install
  alias_method :action_uncask, :action_uninstall

  def casked?
    shell_out('/usr/local/bin/brew cask list 2>/dev/null').stdout.split.include?(name)
    shell_out('/usr/local/bin/brew cask list 2>/dev/null', user: Homebrew.owner).stdout.split.include?(name)
  end
end
