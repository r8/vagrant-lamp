#
# Author:: Chris Marchesi <cmarchesi@paybyphone.com>
# Cookbook Name:: php
# Resource:: fpm_pool
#
# Copyright:: 2015, Opscode, Inc <legal@opscode.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default_action :install
actions :install, :uninstall

attribute :pool_name, :kind_of => String, :name_attribute => true
attribute :listen, :default => '/var/run/php5-fpm.sock'
attribute :user, :kind_of => String, :default => node['php']['fpm_user']
attribute :group, :kind_of => String, :default => node['php']['fpm_user']
attribute :process_manager, :kind_of => String, :default => 'dynamic'
attribute :max_children, :kind_of => Integer, :default => 5
attribute :start_servers, :kind_of => Integer, :default => 2
attribute :min_spare_servers, :kind_of => Integer, :default => 1
attribute :max_spare_servers, :kind_of => Integer, :default => 3
attribute :chdir, :kind_of => String, :default => '/'
attribute :additional_config, :kind_of => Hash, :default => {}
