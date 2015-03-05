include_recipe "apt"
include_recipe "build-essential"
include_recipe "git"
include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_ssl"
include_recipe "percona::toolkit"
include_recipe "php"
include_recipe "php::module_mysql"
include_recipe "php::module_apc"
include_recipe "php::module_curl"
include_recipe "apache2::mod_php5"
include_recipe "composer"
include_recipe "phing"

# Initialize php extensions list
php_extensions = []

# Install packages
%w{ debconf vim screen tmux mc subversion curl make g++ libsqlite3-dev graphviz libxml2-utils lynx links}.each do |a_package|
  package a_package
end

# Install ruby gems
%w{ rdoc mailcatcher }.each do |a_gem|
  gem_package a_gem
end

gem_package "rake" do
  version "0.8.7"
end

# Generate selfsigned ssl
execute "make-ssl-cert" do
  command "make-ssl-cert generate-default-snakeoil --force-overwrite"
  ignore_failure true
  action :nothing
end

# Install Mysql
mysql_service "default" do
  port node['mysql']['port']
  version node['mysql']['version']
  initial_root_password node['mysql']['initial_root_password']
  action [:create, :start]
end
mysql_client 'default' do
  action :create
end

# Initialize sites data bag
sites = []
begin
  sites = data_bag("sites")
rescue
  puts "Unable to load sites data bag."
end

# Configure sites
sites.each do |name|
  site = data_bag_item("sites", name)

  # Add site to apache config
  web_app site["host"] do
    template "web_app.conf.erb"
    server_name site["host"]
    server_aliases site["aliases"]
    server_include site["include"]
    docroot site["docroot"]?site["docroot"]:"/vagrant/public/#{site["host"]}"
  end

   # Add site info in /etc/hosts
   bash "hosts" do
     code "echo 127.0.0.1 #{site["host"]} #{site["aliases"].join(' ')} >> /etc/hosts"
   end
end

# Disable default site
apache_site "default" do
  enable false
end

# Install phpmyadmin
cookbook_file "/tmp/phpmyadmin.deb.conf" do
  source "phpmyadmin.deb.conf"
end
bash "debconf_for_phpmyadmin" do
  code "debconf-set-selections /tmp/phpmyadmin.deb.conf"
end
package "phpmyadmin"

# Install Xdebug
php_pear "xdebug" do
  # Specify that xdebug.so must be loaded as a zend extension
  zend_extensions ["xdebug.so"]
  directives(
      :remote_enable => 1,
      :remote_connect_back => 1,
      :remote_port => 9000,
      :remote_handler => "dbgp",
      :profiler_enable => 0,
      :profiler_enable_trigger => 1
  )
  action :install
end
php_extensions.push 'xdebug'

# Install Webgrind
git "/var/www/webgrind" do
  repository 'git://github.com/jokkedk/webgrind.git'
  reference "master"
  action :sync
end
apache_conf "webgrind" do
  enable true
end
template "/var/www/webgrind/config.php" do
  source "webgrind.config.php.erb"
  owner "root"
  group "root"
  mode 0644
  action :create
end

# Install php-xsl
package "php5-xsl" do
  action :install
end

# Setup MailCatcher
bash "mailcatcher" do
  code "mailcatcher --http-ip 0.0.0.0 --smtp-port 25"
  not_if "ps ax | grep -v grep | grep mailcatcher";
end
template "#{node['php']['ext_conf_dir']}/mailcatcher.ini" do
  source "mailcatcher.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, resources("service[apache2]"), :delayed
end
cookbook_file "/etc/rc.local" do
  source "rc.local"
  owner "root"
  group "root"
  mode "0755"
  action :create
end
php_extensions.push 'mailcatcher'

# Enable installed php extensions
case node['platform']
  when 'ubuntu'
    if node['platform_version'].to_f >= 14.04
      php_extensions.each do |extension|
        execute 'enable_php_extension' do
          command "php5enmod #{extension}"
        end
      end
    end
  else
end
