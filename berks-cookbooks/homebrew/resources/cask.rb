actions :cask, :uncask, :install, :uninstall
attribute :name,
  :name_attribute => true,
  :kind_of        => String,
  :regex          => /^[\w-]+$/

attribute :casked,
  :kind_of => [TrueClass, FalseClass]

attribute :options,
  :kind_of        => String

if defined?(:default_action)
  default_action :install
else
  Chef::Log.warn("It appears you have Chef version #{Chef::VERSION},")
  Chef::Log.warn('homebrew_cask resource will remove support for versions of Chef < 10.10 in the next major release of the cookbook')
  def initialize(*args)
    super
    @action = :install
  end
end
