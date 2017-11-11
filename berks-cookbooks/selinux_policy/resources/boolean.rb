# A resource for managing SELinux Booleans

actions :set, :setpersist
default_action :setpersist

attribute :name, kind_of: String, name_attribute: true
attribute :value, kind_of: [TrueClass, FalseClass]
attribute :force, kind_of: [TrueClass, FalseClass], default: false
