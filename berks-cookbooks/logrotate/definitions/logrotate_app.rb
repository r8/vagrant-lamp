#
# Cookbook Name:: logrotate
# Definition:: logrotate_instance
#
# Copyright 2009, Scott M. Likens
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

log_rotate_params = {
  :enable         => true,
  :frequency      => 'weekly',
  :template       => 'logrotate.erb',
  :cookbook       => 'logrotate',
  :template_mode  => '0440',
  :template_owner => 'root',
  :template_group => 'root',
  :postrotate     => nil,
  :prerotate      => nil,
  :firstaction    => nil,
  :lastaction     => nil,
  :sharedscripts  => false
}

define(:logrotate_app, log_rotate_params) do
  include_recipe 'logrotate::default'

  options_tmp = params[:options] ||= %w(missingok compress delaycompress copytruncate notifempty)
  options = options_tmp.respond_to?(:each) ? options_tmp : options_tmp.split
  options << 'sharedscripts' if params[:sharedscripts]

  if params[:enable]
    invalid_options = options - CookbookLogrotate::DIRECTIVES

    unless invalid_options.empty?
      Chef::Log.error("Invalid option(s) passed to logrotate: #{invalid_options.join(', ')}")
      raise
    end

    logrotate_config = {
      :path => Array(params[:path]).map { |path| path.to_s.inspect }.join(' '),
      :frequency => params[:frequency],
      :options => options
    }
    CookbookLogrotate::VALUES.each do |opt_name|
      logrotate_config[opt_name.to_sym] = params[opt_name.to_sym]
    end

    CookbookLogrotate::SCRIPTS.each do |script_name|
      logrotate_config[script_name.to_sym] = Array(params[script_name.to_sym]).join("\n")
    end

    template "/etc/logrotate.d/#{params[:name]}" do
      source   params[:template]
      cookbook params[:cookbook]
      mode     params[:template_mode]
      owner    params[:template_owner]
      group    params[:template_group]
      backup   false
      variables logrotate_config
    end
  else
    file "/etc/logrotate.d/#{params[:name]}" do
      action :delete
    end
  end
end
