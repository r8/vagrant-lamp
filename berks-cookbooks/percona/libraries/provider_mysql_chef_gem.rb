class Chef
  class Provider
    # rubocop:disable LineLength
    #
    # Public:
    # Monkey patch to not install mysql client dev libraries over ours
    # https://github.com/opscode-cookbooks/mysql/blob/master/libraries/provider_mysql_client_ubuntu.rb
    #
    # rubocop:enable LineLength
    class MysqlChefGem < Chef::Provider::LWRPBase
      def action_install
        converge_by "install mysql chef_gem and dependencies" do
          recipe_eval do
            run_context.include_recipe "build-essential::default"
            run_context.include_recipe "percona::client"
          end

          chef_gem "mysql" do
            action :install
          end
        end
      end
    end
  end
end
