# The rbac_user LWRP is an internal set of classes used by other LWRPs to
# delay writing of user attributes until the end of the chef run. It should not be
# manually run.

def load_current_resource
  @current_resource = Chef::Resource::Rbac::User.new(@new_resource.user)
end

action :apply do
  username = new_resource.user

  auths = RBAC.authorizations[username]
  permissions = auths.inject([]) do |auth, name|
    auth + ["solaris.smf.manage.#{name}", "solaris.smf.value.#{name}"]
  end.sort.uniq.join(',')

  execute "Apply rbac authorizations to #{username}" do
    command "usermod -A #{permissions} #{username}"
    action :nothing
    not_if "grep #{username} /etc/user_attr | grep 'auths=#{permissions}'"
  end.run_action(:run)
end
