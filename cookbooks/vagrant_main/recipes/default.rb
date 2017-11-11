include_recipe "apt"
include_recipe "build-essential"
include_recipe "git"
include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_ssl"
include_recipe "percona::toolkit"
include_recipe "php"
include_recipe "apache2::mod_php"
include_recipe "composer"
include_recipe "phing"
include_recipe "mailhog"
include_recipe "postfix"
include_recipe "redisio"
include_recipe "redisio::enable"

# Install packages
%w{ debconf vim screen tmux mc subversion curl make g++ libsqlite3-dev graphviz libxml2-utils lynx links }.each do |name|
  package name
end

# Generate selfsigned ssl
execute "make-ssl-cert" do
  command "make-ssl-cert generate-default-snakeoil --force-overwrite"
end

# Install Mysql
mysql_service 'default' do
  port node['mysql']['port']
  version node['mysql']['version']
  initial_root_password node['mysql']['initial_root_password']
  action [:create, :start]
end
mysql_client 'default' do
  action :create
end

mysql_config 'default' do
  source 'innodb.conf.erb'
  notifies :restart, 'mysql_service[default]'
  action :create
end

directory '/var/run/mysqld' do
  action :delete
  only_if { Dir.exist? '/var/run/mysqld' }
end

link '/var/run/mysqld' do
  to '/var/run/mysql-default'
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
    notifies :restart, resources("service[apache2]"), :delayed
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

php_packages = if node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 16.04
  %w{ php-xsl php-mysql php-curl php-xdebug }
else
  %w{ php5-xsl php5-mysql php5-curl php5-xdebug }
end

# Install php extensions
php_packages.each do |name|
  package name
end

# Install Webgrind
git "/var/www/webgrind" do
  repository 'git://github.com/jokkedk/webgrind.git'
  reference "master"
  action :sync
end
apache_conf "webgrind" do
  enable true
  notifies :restart, resources("service[apache2]"), :delayed
end
template "/var/www/webgrind/config.php" do
  source "webgrind.config.php.erb"
  owner "root"
  group "root"
  mode 0644
  action :create
end

# Temp workaround for https://github.com/sous-chefs/apache2/issues/480
if node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 16.04
  link '/etc/apache2/mods-enabled/php7.conf' do
    to '/etc/apache2/mods-available/php.conf'
    notifies :restart, resources("service[apache2]"), :delayed
  end
end
