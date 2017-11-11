actions :create, :delete
default_action :create

attribute :type, :kind_of => [Symbol,String], :required => true
attribute :item, :kind_of => [Symbol,String], :required => true
attribute :value, :kind_of => [String,Numeric], :required => true
attribute :domain, :kind_of => [Chef::Resource, String], :required => true
