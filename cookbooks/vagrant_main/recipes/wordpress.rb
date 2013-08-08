include_recipe "python"

# Install wp2github
python_pip "wp2github"

# Install wp-cli

# Create wp-cli dir
directory "/usr/share/wp-cli" do
  recursive true
end

# Download installer
remote_file "/usr/share/wp-cli/installer.sh" do
  source 'http://wp-cli.org/installer.sh'
  mode 0755
  action :create_if_missing
end

# Run installer
bash 'install wp-cli' do
  code './installer.sh'
  cwd "/usr/share/wp-cli"
  environment 'INSTALL_DIR' => "/usr/share/wp-cli"
end

# Link wp binary
link "/usr/bin/wp" do
  to "/usr/share/wp-cli/bin/wp"
end
