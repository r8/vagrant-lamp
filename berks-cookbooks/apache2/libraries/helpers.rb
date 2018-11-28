module Apache2
  module Cookbook
    module Helpers
      def apache_binary
        case node['platform_family']
        when 'debian'
          '/usr/sbin/apache2'
        when 'freebsd'
          '/usr/local/sbin/httpd'
        else
          '/usr/sbin/httpd'
        end
      end

      def apache_platform_service_name
        case node['platform_family']
        when 'debian', 'suse'
          'apache2'
        when 'freebsd'
          'apache24'
        else
          'httpd'
        end
      end

      def apachectl
        case node['platform_family']
        when 'debian', 'suse'
          '/usr/sbin/apache2ctl'
        when 'freebsd'
          '/usr/local/sbin/apachectl'
        else
          '/usr/sbin/apachectl'
        end
      end

      def apache_dir
        case node['platform_family']
        when 'debian', 'suse'
          '/etc/apache2'
        when 'freebsd'
          '/usr/local/etc/apache24'
        else
          '/etc/httpd'
        end
      end

      def apache_conf_dir
        case node['platform_family']
        when 'debian', 'suse'
          '/etc/apache2'
        when 'freebsd'
          '/usr/local/etc/apache24'
        else
          '/etc/httpd/conf'
        end
      end
    end
  end
end

Chef::Recipe.include(Apache2::Cookbook::Helpers)
Chef::Resource.include(Apache2::Cookbook::Helpers)
