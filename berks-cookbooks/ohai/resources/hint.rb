property :hint_name, String, name_property: true
property :content, Hash
property :compile_time, [true, false], default: true

action :create do
  directory ::Ohai::Config.ohai.hints_path.first do
    action :create
    recursive true
  end

  file ohai_hint_file_path(new_resource.hint_name) do
    action :create
    content format_content(new_resource.content)
  end
end

action :delete do
  file ohai_hint_file_path(new_resource.hint_name) do
    action :delete
    notifies :reload, ohai[reload ohai post hint removal]
  end

  ohai 'reload ohai post hint removal' do
    action :nothing
  end
end

action_class do
  include OhaiCookbook::HintHelpers
end

# this resource forces itself to run at compile_time
def after_created
  return unless compile_time
  Array(action).each do |action|
    run_action(action)
  end
end
