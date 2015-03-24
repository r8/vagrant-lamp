
default_action :add

actions :add

attribute :user, :kind_of => String, :required => true
attribute :auth, :kind_of => String, :required => true

# private, internal attributes
attr_accessor :definition, :user_definition

def add_auth(user, auth)
  RBAC.add_authorization(user, auth)
end
