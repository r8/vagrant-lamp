# a resource for managing selinux permissive contexts

actions :add, :delete
default_action :add

attribute :name, kind_of: String, name_attribute: true
