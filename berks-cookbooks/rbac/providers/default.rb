
def load_current_resource
  @current_resource = Chef::Resource::Rbac.new(@new_resource.name)
end

action :create do
  definition = new_resource.name

  new_resource.updated_by_last_action(false)

  manage_auth = "solaris.smf.manage.#{definition}:::Manage #{definition} Service States::"
  manage = execute "add RBAC #{definition} management to /etc/security/auth_attr" do
    command "echo \"#{manage_auth}\" >> /etc/security/auth_attr"
    not_if "grep \"#{manage_auth}\" /etc/security/auth_attr"
  end

  # This additional permission allows the user to call svccfg -s service setprop
  # to set dynamic properties without having to re-run chef. This may be
  # moved into a separate LWRP in the future.
  value_auth = "solaris.smf.value.#{definition}:::Change value of #{definition} Service::"
  value = execute "add RBAC #{definition} value to /etc/security/auth_attr" do
    command "echo \"#{value_auth}\" >> /etc/security/auth_attr"
    not_if "grep \"#{value_auth}\" /etc/security/auth_attr"
  end

  new_resource.updated_by_last_action(manage.updated_by_last_action? || value.updated_by_last_action?)
end
