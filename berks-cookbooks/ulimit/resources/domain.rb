attr_reader :subresource_rules

def initialize(*args)
  @subresource_rules = []
  super
end

def load_current_resource
  # do full type check
  valid_types = [Chef::Resource::UlimitDomain, String]
  unless(valid_types.include?(new_resource.domain.class))
    raise TypeError.new(
      "Expecting `domain` attribute to be of type: #{valid_types.map(&:to_s).join(', ')}. " <<
      "Got: #{new_resource.domain.class}"
    )
  end
end

actions :create, :delete
default_action :create

attribute :domain_name, :kind_of => String, :name_attribute => true
attribute :filename, :kind_of => String

def rule(name=nil, &block)
  @subresource_rules << [name, block]
end
