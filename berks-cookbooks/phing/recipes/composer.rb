include_recipe 'composer'

phing_dir = node['phing']['install_dir']

directory phing_dir do
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

# figure out what version to install
if node['phing']['version'] != 'latest'
  version = node['phing']['version']
else
  version = '*.*.*'
end

# composer.json
template "#{phing_dir}/composer.json" do
  source 'composer.json.erb'
  owner 'root'
  group 'root'
  mode 0600
  variables(
    :version => version,
    :bindir => node['phing']['prefix']
  )
end

# composer update
execute 'phing-composer' do
  user 'root'
  cwd phing_dir
  command 'composer update'
  action :run
end
