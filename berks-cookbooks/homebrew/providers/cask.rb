require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut
include ::Homebrew::Mixin

use_inline_resources if defined?(:use_inline_resources)

def whyrun_supported?
  true
end

def load_current_resource
  @cask = Chef::Resource::HomebrewCask.new(new_resource.name)
  Chef::Log.debug("Checking whether #{new_resource.name} is installed")
  @cask.casked shell_out("/usr/local/bin/brew cask list | grep #{new_resource.name}").exitstatus == 0
end

action :install do
  unless @cask.casked
    execute "installing cask #{new_resource.name}" do
      command "/usr/local/bin/brew cask install #{new_resource.name} #{new_resource.options}"
      user homebrew_owner
    end
  end
end

action :uninstall do
  if @cask.casked
    execute "uninstalling cask #{new_resource.name}" do
      command "/usr/local/bin/brew cask uninstall #{new_resource.name}"
      user homebrew_owner
    end
  end
end

alias_method :action_cask, :action_install
alias_method :action_uncask, :action_uninstall
