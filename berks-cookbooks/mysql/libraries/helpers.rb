require 'shellwords'

module MysqlCookbook
  module Helpers
    include Chef::DSL::IncludeRecipe

    def base_dir
      prefix_dir || '/usr'
    end

    def configure_package_repositories
      # we need to enable the yum-mysql-community repository to get packages
      return unless %w(rhel fedora).include? node['platform_family']
      case parsed_version
      when '5.5'
        # Prefer packages from native repos
        return if node['platform_family'] == 'rhel' && node['platform_version'].to_i == 5
        return if node['platform_family'] == 'fedora'
        include_recipe('yum-mysql-community::mysql55')
      when '5.6'
        include_recipe('yum-mysql-community::mysql56')
      when '5.7'
        include_recipe('yum-mysql-community::mysql57')
      end
    end

    def client_package_name
      return new_resource.package_name if new_resource.package_name
      client_package
    end

    def defaults_file
      "#{etc_dir}/my.cnf"
    end

    def error_log
      "#{log_dir}/error.log"
    end

    def etc_dir
      return "/opt/mysql#{pkg_ver_string}/etc/#{mysql_name}" if node['platform_family'] == 'omnios'
      return "#{prefix_dir}/etc/#{mysql_name}" if node['platform_family'] == 'smartos'
      "#{prefix_dir}/etc/#{mysql_name}"
    end

    def include_dir
      "#{etc_dir}/conf.d"
    end

    def lc_messages_dir
    end

    def log_dir
      return "/var/adm/log/#{mysql_name}" if node['platform_family'] == 'omnios'
      "#{prefix_dir}/var/log/#{mysql_name}"
    end

    def mysql_name
      "mysql-#{new_resource.instance}"
    end

    def pkg_ver_string
      parsed_version.gsub('.', '') if node['platform_family'] == 'omnios'
    end

    def prefix_dir
      return "/opt/mysql#{pkg_ver_string}" if node['platform_family'] == 'omnios'
      return '/opt/local' if node['platform_family'] == 'smartos'
      return "/opt/rh/#{scl_name}/root" if scl_package?
    end

    def scl_name
      return unless node['platform_family'] == 'rhel'
      return 'mysql51' if parsed_version == '5.1' && node['platform_version'].to_i == 5
      return 'mysql55' if parsed_version == '5.5' && node['platform_version'].to_i == 5
    end

    def scl_package?
      return unless node['platform_family'] == 'rhel'
      return true if parsed_version == '5.1' && node['platform_version'].to_i == 5
      return true if parsed_version == '5.5' && node['platform_version'].to_i == 5
      false
    end

    def system_service_name
      return 'mysql51-mysqld' if node['platform_family'] == 'rhel' && scl_name == 'mysql51'
      return 'mysql55-mysqld' if node['platform_family'] == 'rhel' && scl_name == 'mysql55'
      return 'mysqld' if node['platform_family'] == 'rhel'
      return 'mysqld' if node['platform_family'] == 'fedora'
      return 'mysql' if node['platform_family'] == 'debian'
      return 'mysql' if node['platform_family'] == 'suse'
      return 'mysql' if node['platform_family'] == 'omnios'
      return 'mysql' if node['platform_family'] == 'smartos'
    end

    def mysql_install_db_script
      if scl_package?
        <<-EOF
          scl enable #{scl_name} \
          "#{mysql_install_db_bin} --datadir=#{parsed_data_dir} --defaults-file=#{etc_dir}/my.cnf"
          EOF
      else
        "#{mysql_install_db_bin} --datadir=#{parsed_data_dir} --defaults-file=#{etc_dir}/my.cnf"
      end
    end

    def mysql_safe_init_cmd
      if scl_package?
        "scl enable #{scl_name} \"#{mysqld_safe_bin} --defaults-file=#{etc_dir}/my.cnf --init-file=/tmp/#{mysql_name}/my.sql &\""
      else
        "#{mysqld_safe_bin} --defaults-file=#{defaults_file} --init-file=/tmp/#{mysql_name}/my.sql &"
      end
    end

    def init_records_script
      <<-EOS
        set -e
        rm -rf /tmp/#{mysql_name}
        mkdir /tmp/#{mysql_name}
        cat > /tmp/#{mysql_name}/my.sql <<-EOSQL
DELETE FROM mysql.user ;
CREATE USER 'root'@'%' IDENTIFIED BY '#{Shellwords.escape(new_resource.initial_root_password)}' ;
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
FLUSH PRIVILEGES;
DROP DATABASE IF EXISTS test ;
EOSQL

       #{mysql_safe_init_cmd}
       while [ ! -f #{pid_file} ] ; do sleep 1 ; done
       kill `cat #{pid_file}`
       while [ -f #{pid_file} ] ; do sleep 1 ; done
       rm -rf /tmp/#{mysql_name}
       EOS
    end

    def mysql_bin
      return "#{prefix_dir}/bin/mysql" if node['platform_family'] == 'smartos'
      return "#{base_dir}/bin/mysql" if node['platform_family'] == 'omnios'
      "#{prefix_dir}/usr/bin/mysql"
    end

    def mysql_install_db_bin
      return "#{base_dir}/scripts/mysql_install_db" if node['platform_family'] == 'omnios'
      return "#{prefix_dir}/bin/mysql_install_db" if node['platform_family'] == 'smartos'
      'mysql_install_db'
    end

    def mysql_version
      new_resource.version
    end

    def mysqladmin_bin
      return "#{prefix_dir}/bin/mysqladmin" if node['platform_family'] == 'smartos'
      return 'mysqladmin' if scl_package?
      "#{prefix_dir}/usr/bin/mysqladmin"
    end

    def mysqld_bin
      return "#{prefix_dir}/libexec/mysqld" if node['platform_family'] == 'smartos'
      return "#{base_dir}/bin/mysqld" if node['platform_family'] == 'omnios'
      return 'mysqld' if scl_package?
      "#{prefix_dir}/usr/sbin/mysqld"
    end

    def mysqld_safe_bin
      return "#{prefix_dir}/bin/mysqld_safe" if node['platform_family'] == 'smartos'
      return "#{base_dir}/bin/mysqld_safe" if node['platform_family'] == 'omnios'
      return 'mysqld_safe' if scl_package?
      "#{prefix_dir}/usr/bin/mysqld_safe"
    end

    def pid_file
      "#{run_dir}/mysqld.pid"
    end

    def run_dir
      return "#{prefix_dir}/var/run/#{mysql_name}" if node['platform_family'] == 'rhel'
      return "/run/#{mysql_name}" if node['platform_family'] == 'debian'
      "/var/run/#{mysql_name}"
    end

    def sensitive_supported?
      Gem::Version.new(Chef::VERSION) >= Gem::Version.new('11.14.0')
    end

    def socket_file
      return new_resource.socket if new_resource.socket
      "#{run_dir}/mysqld.sock"
    end

    def tmp_dir
      '/tmp'
    end

    #######
    # FIXME: There is a LOT of duplication here..
    # There has to be a less gnarly way to look up this information. Refactor for great good!
    #######
    class Pkginfo
      def self.pkginfo
        # Autovivification is Perl.
        @pkginfo = Chef::Node.new

        @pkginfo.set['debian']['10.04']['5.1']['client_package'] = %w(mysql-client-5.1 libmysqlclient-dev)
        @pkginfo.set['debian']['10.04']['5.1']['server_package'] = 'mysql-server-5.1'
        @pkginfo.set['debian']['12.04']['5.5']['client_package'] = %w(mysql-client-5.5 libmysqlclient-dev)
        @pkginfo.set['debian']['12.04']['5.5']['server_package'] = 'mysql-server-5.5'
        @pkginfo.set['debian']['13.04']['5.5']['client_package'] = %w(mysql-client-5.5 libmysqlclient-dev)
        @pkginfo.set['debian']['13.04']['5.5']['server_package'] = 'mysql-server-5.5'
        @pkginfo.set['debian']['13.10']['5.5']['client_package'] = %w(mysql-client-5.5 libmysqlclient-dev)
        @pkginfo.set['debian']['13.10']['5.5']['server_package'] = 'mysql-server-5.5'
        @pkginfo.set['debian']['14.04']['5.5']['client_package'] = %w(mysql-client-5.5 libmysqlclient-dev)
        @pkginfo.set['debian']['14.04']['5.5']['server_package'] = 'mysql-server-5.5'
        @pkginfo.set['debian']['14.04']['5.6']['client_package'] = %w(mysql-client-5.6 libmysqlclient-dev)
        @pkginfo.set['debian']['14.04']['5.6']['server_package'] = 'mysql-server-5.6'
        @pkginfo.set['debian']['14.10']['5.5']['client_package'] = %w(mysql-client-5.5 libmysqlclient-dev)
        @pkginfo.set['debian']['14.10']['5.5']['server_package'] = 'mysql-server-5.5'
        @pkginfo.set['debian']['14.10']['5.6']['client_package'] = %w(mysql-client-5.6 libmysqlclient-dev)
        @pkginfo.set['debian']['14.10']['5.6']['server_package'] = 'mysql-server-5.6'
        @pkginfo.set['debian']['6']['5.1']['client_package'] = %w(mysql-client libmysqlclient-dev)
        @pkginfo.set['debian']['6']['5.1']['server_package'] = 'mysql-server-5.1'
        @pkginfo.set['debian']['7']['5.5']['client_package'] = %w(mysql-client libmysqlclient-dev)
        @pkginfo.set['debian']['7']['5.5']['server_package'] = 'mysql-server-5.5'
        @pkginfo.set['debian']['jessie/sid']['5.5']['client_package'] = %w(mysql-client libmysqlclient-dev)
        @pkginfo.set['debian']['jessie/sid']['5.5']['server_package'] = 'mysql-server-5.5'
        @pkginfo.set['fedora']['20']['5.5']['client_package'] = %w(community-mysql community-mysql-devel)
        @pkginfo.set['fedora']['20']['5.5']['server_package'] = 'community-mysql-server'
        @pkginfo.set['fedora']['20']['5.6']['client_package'] = %w(mysql-community-client mysql-community-devel)
        @pkginfo.set['fedora']['20']['5.6']['server_package'] = 'mysql-community-server'
        @pkginfo.set['fedora']['20']['5.7']['client_package'] = %w(mysql-community-client mysql-community-devel)
        @pkginfo.set['fedora']['20']['5.7']['server_package'] = 'mysql-community-server'
        @pkginfo.set['freebsd']['10']['5.5']['client_package'] = %w(mysql55-client)
        @pkginfo.set['freebsd']['10']['5.5']['server_package'] = 'mysql55-server'
        @pkginfo.set['freebsd']['9']['5.5']['client_package'] = %w(mysql55-client)
        @pkginfo.set['freebsd']['9']['5.5']['server_package'] = 'mysql55-server'
        @pkginfo.set['omnios']['151006']['5.5']['client_package'] = %w(database/mysql-55/library)
        @pkginfo.set['omnios']['151006']['5.5']['server_package'] = 'database/mysql-55'
        @pkginfo.set['omnios']['151006']['5.6']['client_package'] = %w(database/mysql-56)
        @pkginfo.set['omnios']['151006']['5.6']['server_package'] = 'database/mysql-56'
        @pkginfo.set['rhel']['2014.09']['5.1']['server_package'] = %w(mysql51 mysql51-devel)
        @pkginfo.set['rhel']['2014.09']['5.1']['server_package'] = 'mysql51-server'
        @pkginfo.set['rhel']['2014.09']['5.5']['client_package'] = %w(mysql-community-client mysql-community-devel)
        @pkginfo.set['rhel']['2014.09']['5.5']['server_package'] = 'mysql-community-server'
        @pkginfo.set['rhel']['2014.09']['5.6']['client_package'] = %w(mysql-community-client mysql-community-devel)
        @pkginfo.set['rhel']['2014.09']['5.6']['server_package'] = 'mysql-community-server'
        @pkginfo.set['rhel']['2014.09']['5.7']['client_package'] = %w(mysql-community-client mysql-community-devel)
        @pkginfo.set['rhel']['2014.09']['5.7']['server_package'] = 'mysql-community-server'
        @pkginfo.set['rhel']['5']['5.0']['client_package'] = %w(mysql mysql-devel)
        @pkginfo.set['rhel']['5']['5.0']['server_package'] = 'mysql-server'
        @pkginfo.set['rhel']['5']['5.1']['client_package'] = %w(mysql51-mysql)
        @pkginfo.set['rhel']['5']['5.1']['server_package'] = 'mysql51-mysql-server'
        @pkginfo.set['rhel']['5']['5.5']['client_package'] = %w(mysql55-mysql mysql55-mysql-devel)
        @pkginfo.set['rhel']['5']['5.5']['server_package'] = 'mysql55-mysql-server'
        @pkginfo.set['rhel']['5']['5.6']['client_package'] = %w(mysql-community-client mysql-community-devel)
        @pkginfo.set['rhel']['5']['5.6']['server_package'] = 'mysql-community-server'
        @pkginfo.set['rhel']['5']['5.7']['client_package'] = %w(mysql-community-client mysql-community-devel)
        @pkginfo.set['rhel']['5']['5.7']['server_package'] = 'mysql-community-server'
        @pkginfo.set['rhel']['6']['5.1']['client_package'] = %w(mysql mysql-devel)
        @pkginfo.set['rhel']['6']['5.1']['server_package'] = 'mysql-server'
        @pkginfo.set['rhel']['6']['5.5']['client_package'] = %w(mysql-community-client mysql-community-devel)
        @pkginfo.set['rhel']['6']['5.5']['server_package'] = 'mysql-community-server'
        @pkginfo.set['rhel']['6']['5.6']['client_package'] = %w(mysql-community-client mysql-community-devel)
        @pkginfo.set['rhel']['6']['5.6']['server_package'] = 'mysql-community-server'
        @pkginfo.set['rhel']['6']['5.7']['client_package'] = %w(mysql-community-client mysql-community-devel)
        @pkginfo.set['rhel']['6']['5.7']['server_package'] = 'mysql-community-server'
        @pkginfo.set['rhel']['7']['5.5']['client_package'] = %w(mysql-community-client mysql-community-devel)
        @pkginfo.set['rhel']['7']['5.5']['server_package'] = 'mysql-community-server'
        @pkginfo.set['rhel']['7']['5.6']['client_package'] = %w(mysql-community-client mysql-community-devel)
        @pkginfo.set['rhel']['7']['5.6']['server_package'] = 'mysql-community-server'
        @pkginfo.set['rhel']['7']['5.7']['client_package'] = %w(mysql-community-client mysql-community-devel)
        @pkginfo.set['rhel']['7']['5.7']['server_package'] = 'mysql-community-server'
        @pkginfo.set['smartos']['5.11']['5.5']['client_package'] = %w(mysql-client)
        @pkginfo.set['smartos']['5.11']['5.5']['server_package'] = 'mysql-server'
        @pkginfo.set['smartos']['5.11']['5.6']['client_package'] = %w(mysql-client)
        @pkginfo.set['smartos']['5.11']['5.6']['server_package'] = 'mysql-server'
        @pkginfo.set['suse']['11.3']['5.5']['client_package'] = %w(mysql-client)
        @pkginfo.set['suse']['11.3']['5.5']['server_package'] = 'mysql'

        @pkginfo
      end
    end

    def package_name_for(platform, platform_family, platform_version, version, type)
      keyname = keyname_for(platform, platform_family, platform_version)
      info = Pkginfo.pkginfo[platform_family.to_sym][keyname]
      type_label = type.to_s.gsub('_package', '').capitalize
      unless info[version]
        # Show availabe versions if the requested is not available on the current platform
        Chef::Log.error("Unsupported Version: You requested to install a Mysql #{type_label} version that is not supported by your platform")
        Chef::Log.error("Platform: #{platform_family} #{platform_version} - Request Mysql #{type_label} version: #{version}")
        Chef::Log.error("Availabe versions for your platform are: #{info.map { |k, _v| k }.join(' - ')}")
        fail "Unsupported Mysql #{type_label} Version"
      end
      info[version][type]
    end

    def keyname_for(platform, platform_family, platform_version)
      return platform_version if platform_family == 'debian' && platform == 'ubuntu'
      return platform_version if platform_family == 'fedora'
      return platform_version if platform_family == 'omnios'
      return platform_version if platform_family == 'rhel' && platform == 'amazon'
      return platform_version if platform_family == 'smartos'
      return platform_version if platform_family == 'suse'
      return platform_version.to_i.to_s if platform_family == 'debian'
      return platform_version.to_i.to_s if platform_family == 'rhel'
      return platform_version.to_s if platform_family == 'debian' && platform_version =~ /sid$/
      return platform_version.to_s if platform_family == 'freebsd'
    end

    def parsed_data_dir
      return new_resource.data_dir if new_resource.data_dir
      return "/opt/local/lib/#{mysql_name}" if node['os'] == 'solaris2'
      return "/var/lib/#{mysql_name}" if node['os'] == 'linux'
      return "/var/db/#{mysql_name}" if node['os'] == 'freebsd'
    end

    def client_package
      package_name_for(
        node['platform'],
        node['platform_family'],
        node['platform_version'],
        parsed_version,
        :client_package
        )
    end

    def server_package
      package_name_for(
        node['platform'],
        node['platform_family'],
        node['platform_version'],
        parsed_version,
        :server_package
        )
    end

    def server_package_name
      return new_resource.package_name if new_resource.package_name
      server_package
    end

    def parsed_version
      return new_resource.version if new_resource.version
      return '5.0' if node['platform_family'] == 'rhel' && node['platform_version'].to_i == 5
      return '5.1' if node['platform_family'] == 'debian' && node['platform_version'] == '10.04'
      return '5.1' if node['platform_family'] == 'debian' && node['platform_version'].to_i == 6
      return '5.1' if node['platform_family'] == 'rhel' && node['platform_version'].to_i == 6
      return '5.5' if node['platform_family'] == 'debian' && node['platform_version'] == '12.04'
      return '5.5' if node['platform_family'] == 'debian' && node['platform_version'] == '13.04'
      return '5.5' if node['platform_family'] == 'debian' && node['platform_version'] == '13.10'
      return '5.5' if node['platform_family'] == 'debian' && node['platform_version'] == '14.04'
      return '5.5' if node['platform_family'] == 'debian' && node['platform_version'] == '14.10'
      return '5.5' if node['platform_family'] == 'debian' && node['platform_version'] == 'jessie/sid'
      return '5.5' if node['platform_family'] == 'debian' && node['platform_version'].to_i == 7
      return '5.5' if node['platform_family'] == 'fedora'
      return '5.5' if node['platform_family'] == 'freebsd'
      return '5.5' if node['platform_family'] == 'omnios'
      return '5.5' if node['platform_family'] == 'rhel' && node['platform_version'].to_i == 2014
      return '5.5' if node['platform_family'] == 'rhel' && node['platform_version'].to_i == 7
      return '5.5' if node['platform_family'] == 'smartos'
      return '5.5' if node['platform_family'] == 'suse'
    end
  end
end
