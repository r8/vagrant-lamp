include_recipe "python"

# Install wp2github
python_pip "wp2github"

# Install wp-cli
remote_file "/usr/local/bin/wp" do                                              
  source 'https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
  mode 0755
  action :create_if_missing
end
