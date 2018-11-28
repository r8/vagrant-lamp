property :key, String, name_property: true
property :value, String
property :scope, equal_to: %w(local global system), default: 'global', desired_state: false
property :path, String, desired_state: false
property :user, String, desired_state: false
property :group, String, desired_state: false
property :options, String, desired_state: false

def initialize(*args)
  super

  @run_context.include_recipe 'git'
end

load_current_value do
  cmd_env = user ? { 'USER' => user, 'HOME' => ::Dir.home(user) } : nil
  config_vals = Mixlib::ShellOut.new("git config --get --#{scope} #{key}", user: user, group: group, cwd: path, env: cmd_env)
  config_vals.run_command
  if config_vals.stdout.empty?
    value nil
  else
    value config_vals.stdout.chomp
  end
end

action :set do
  converge_if_changed do
    execute "#{config_cmd} #{new_resource.key} \"#{new_resource.value}\" #{new_resource.options}".rstrip do
      cwd new_resource.path
      user new_resource.user
      group new_resource.group
      environment cmd_env
    end
  end
end

action_class do
  def config_cmd
    "git config --#{new_resource.scope}"
  end

  def cmd_env
    new_resource.user ? { 'USER' => new_resource.user, 'HOME' => ::Dir.home(new_resource.user) } : nil
  end
end
