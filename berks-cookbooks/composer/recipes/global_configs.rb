#
# Cookbook Name:: composer
# Recipe:: global_configs
#
# Copyright (c) 2016, David Joos
#

configs = node['composer']['global_configs']

unless configs.nil?
  configs.each_pair do |user, user_configs|
    user_composer_dir = "#{Dir.home(user)}/.composer"

    directory user_composer_dir do
      owner user
      group user
      mode '0755'
      action :create
    end

    user_configs.nil? && next

    user_configs.each_pair do |option, value|
      if value.respond_to?(:each_pair)
        value.each_pair do |value_k, value_v|
          execute "composer-config-for-#{user}" do
            command "composer config --global #{option}.#{value_k} #{value_v}"
            environment 'COMPOSER_HOME' => user_composer_dir
            user user
            group user
            action :run
          end
        end
      else
        execute "composer-config-for-#{user}" do
          command "composer config --global #{option} #{value}"
          environment 'COMPOSER_HOME' => user_composer_dir
          user user
          group user
          action :run
        end
      end
    end
  end
end
