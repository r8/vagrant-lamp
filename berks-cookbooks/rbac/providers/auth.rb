def load_current_resource
  @current_resource = Chef::Resource::RbacAuth.new(new_resource.name)
  @new_resource.definition = run_context.resource_collection.find(:rbac => @new_resource.auth)
  begin
    @new_resource.user_definition = run_context.resource_collection.find(:rbac_user => @new_resource.user)
  rescue Chef::Exceptions::ResourceNotFound
  end
end

action :add do
  unless new_resource.user_definition
    new_resource.user_definition = rbac_user new_resource.user
  end

  new_resource.add_auth new_resource.user, new_resource.auth

  new_resource.updated_by_last_action(true)

  new_resource.notifies(:apply, new_resource.user_definition, :delayed)
end
