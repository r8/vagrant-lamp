#
# Author:: Chris Marchesi <cmarchesi@paybyphone.com>
# Cookbook Name:: php
# Provider:: fpm_pool
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

def whyrun_supported?
  true
end

def install_fpm_package
  # Install the FPM pacakge for this platform, if it's available
  # Fail the run if it's an unsupported OS (FPM pacakge name not populated)
  # also, this is skipped for source
  return if node['php']['install_method'] == 'source'

  if node['php']['fpm_package'].nil?
    raise 'PHP-FPM package not found (you probably have an unsupported distro)'
  else
    file node['php']['fpm_default_conf'] do
      action :nothing
    end
    package node['php']['fpm_package'] do
      action :install
      notifies :delete, "file[#{node['php']['fpm_default_conf']}]"
    end
  end
end

def register_fpm_service
  service node['php']['fpm_service'] do
    action :enable
  end
end

action :install do
  # Ensure the FPM pacakge is installed, and the service is registered
  install_fpm_package
  register_fpm_service
  # I wanted to have this as a function in itself, but doing this seems to
  # break testing suites?
  t = template "#{node['php']['fpm_pooldir']}/#{new_resource.pool_name}.conf" do
    source 'fpm-pool.conf.erb'
    action :create
    cookbook 'php'
    variables ({
      :fpm_pool_name => new_resource.pool_name,
      :fpm_pool_user => new_resource.user,
      :fpm_pool_group => new_resource.group,
      :fpm_pool_listen => new_resource.listen,
      :fpm_pool_manager => new_resource.process_manager,
      :fpm_pool_max_children => new_resource.max_children,
      :fpm_pool_start_servers => new_resource.start_servers,
      :fpm_pool_min_spare_servers => new_resource.min_spare_servers,
      :fpm_pool_max_spare_servers => new_resource.max_spare_servers,
      :fpm_pool_chdir => new_resource.chdir,
      :fpm_pool_additional_config => new_resource.additional_config
    })
    notifies :restart, "service[#{node['php']['fpm_package']}]"
  end
  new_resource.updated_by_last_action(t.updated_by_last_action?)
end

action :uninstall do
  # Ensure the FPM pacakge is installed, and the service is registered
  register_fpm_service
  # Delete the FPM pool.
  f = file "#{node['php']['fpm_pooldir']}/#{new_resource.pool_name}" do
    action :delete
  end
  new_resource.updated_by_last_action(f.updated_by_last_action?)
end
