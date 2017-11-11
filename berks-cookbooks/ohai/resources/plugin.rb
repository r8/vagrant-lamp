property :plugin_name, String, name_property: true
property :path, String
property :source_file, String
property :cookbook, String
property :resource, [:cookbook_file, :template], default: :cookbook_file
property :variables, Hash
property :compile_time, [true, false], default: true

action :create do
  # why create_if_missing you ask?
  # no one can agree on perms and this allows them to manage the perms elsewhere
  directory desired_plugin_path do
    action :create
    recursive true
    not_if { ::File.exist?(desired_plugin_path) }
  end

  if new_resource.resource.eql?(:cookbook_file)
    cookbook_file ::File.join(desired_plugin_path, new_resource.plugin_name + '.rb') do
      cookbook new_resource.cookbook
      source new_resource.source_file || "#{new_resource.plugin_name}.rb"
      notifies :reload, "ohai[#{new_resource.plugin_name}]", :immediately
    end
  elsif new_resource.resource.eql?(:template)
    template ::File.join(desired_plugin_path, new_resource.plugin_name + '.rb') do
      cookbook new_resource.cookbook
      source new_resource.source_file || "#{new_resource.plugin_name}.rb"
      variables new_resource.variables
      notifies :reload, "ohai[#{new_resource.plugin_name}]", :immediately
    end
  end

  # Add the plugin path to the ohai plugin path if need be and warn
  # the user that this is going to result in a reload every run
  unless in_plugin_path?(desired_plugin_path)
    plugin_path_warning
    Chef::Log.warn("Adding #{desired_plugin_path} to the Ohai plugin path for this chef-client run only")
    add_to_plugin_path(desired_plugin_path)
    reload_required = true
  end

  ohai new_resource.plugin_name do
    action :nothing
    action :reload if reload_required
  end
end

action :delete do
  file ::File.join(desired_plugin_path, new_resource.plugin_name + '.rb') do
    action :delete
    notifies :reload, 'ohai[reload ohai post plugin removal]'
  end

  ohai 'reload ohai post plugin removal' do
    action :nothing
  end
end

action_class do
  include OhaiCookbook::PluginHelpers
end

# this resource forces itself to run at compile_time
def after_created
  return unless compile_time
  Array(action).each do |action|
    run_action(action)
  end
end
