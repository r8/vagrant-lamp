#
# Cookbook Name:: runit
# Provider:: service
#
# Author:: Joshua Timberman <jtimberman@chef.io>
# Author:: Sean OMeara <sean@chef.io>
# Copyright 2011-2015, Chef Software, Inc.
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

class Chef
  class Provider
    class RunitService < Chef::Provider::LWRPBase
      unless defined?(VALID_SIGNALS)
        # Mapping of valid signals with optional friendly name
        VALID_SIGNALS = Mash.new(
          :down => nil,
          :hup => nil,
          :int => nil,
          :term => nil,
          :kill => nil,
          :quit => nil,
          :up => nil,
          :once => nil,
          :cont => nil,
          1 => :usr1,
          2 => :usr2
        )
      end

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      # Mix in helpers from libraries/helpers.rb
      include RunitCookbook::Helpers

      # actions
      action :create do
        # sv_templates
        if new_resource.sv_templates

          directory sv_dir_name do
            owner new_resource.owner
            group new_resource.group
            mode '0755'
            recursive true
            action :create
          end

          template "#{sv_dir_name}/run" do
            owner new_resource.owner
            group new_resource.group
            source "sv-#{new_resource.run_template_name}-run.erb"
            cookbook template_cookbook
            mode '0755'
            variables(options: new_resource.options)
            action :create
          end

          # log stuff
          if new_resource.log
            directory "#{sv_dir_name}/log" do
              owner new_resource.owner
              group new_resource.group
              recursive true
              action :create
            end

            directory "#{sv_dir_name}/log/main" do
              owner new_resource.owner
              group new_resource.group
              mode '0755'
              recursive true
              action :create
            end

            directory new_resource.log_dir do
              owner new_resource.owner
              group new_resource.group
              mode '00755'
              recursive true
              action :create
            end

            template "#{sv_dir_name}/log/config" do
              owner new_resource.owner
              group new_resource.group
              mode '00644'
              cookbook 'runit'
              source 'log-config.erb'
              variables(config: new_resource)
              action :create
            end

            link "#{new_resource.log_dir}/config" do
              to "#{sv_dir_name}/log/config"
            end

            if new_resource.default_logger
              file "#{sv_dir_name}/log/run" do
                content default_logger_content
                owner new_resource.owner
                group new_resource.group
                mode '00755'
                action :create
              end
            else
              template "#{sv_dir_name}/log/run" do
                owner new_resource.owner
                group new_resource.group
                mode '00755'
                source "sv-#{new_resource.log_template_name}-log-run.erb"
                cookbook template_cookbook
                variables(options: new_resource.options)
                action :create
              end
            end

          end

          # environment stuff
          directory "#{sv_dir_name}/env" do
            owner new_resource.owner
            group new_resource.group
            mode '00755'
            action :create
          end

          new_resource.env.map do |var, value|
            file "#{sv_dir_name}/env/#{var}" do
              owner new_resource.owner
              group new_resource.group
              content value
              mode 00640
              action :create
            end
          end

          ruby_block "zap extra env files for #{new_resource.name} service" do
            block { zap_extra_env_files }
            only_if { extra_env_files? }
            not_if { new_resource.env.empty? }
            action :run
          end

          if new_resource.check
            template "#{sv_dir_name}/check" do
              owner new_resource.owner
              group new_resource.group
              mode '00755'
              cookbook template_cookbook
              source "sv-#{new_resource.check_script_template_name}-check.erb"
              variables(options: new_resource.options)
              action :create
            end
          end

          if new_resource.finish
            template "#{sv_dir_name}/finish" do
              owner new_resource.owner
              group new_resource.group
              mode '00755'
              source "sv-#{new_resource.finish_script_template_name}-finish.erb"
              cookbook template_cookbook
              variables(options: new_resource.options) if new_resource.options.respond_to?(:has_key?)
              action :create
            end
          end

          directory "#{sv_dir_name}/control" do
            owner new_resource.owner
            group new_resource.group
            mode '00755'
            action :create
          end

          new_resource.control.map do |signal|
            template "#{sv_dir_name}/control/#{signal}" do
              owner new_resource.owner
              group new_resource.group
              mode '0755'
              source "sv-#{new_resource.control_template_names[signal]}-#{signal}.erb"
              cookbook template_cookbook
              variables(options: new_resource.options)
              action :create
            end
          end

          # lsb_init
          if node['platform'] == 'debian'
            ruby_block "unlink #{parsed_lsb_init_dir}/#{new_resource.service_name}" do
              block { ::File.unlink("#{parsed_lsb_init_dir}/#{new_resource.service_name}") }
              only_if { ::File.symlink?("#{parsed_lsb_init_dir}/#{new_resource.service_name}") }
            end

            template "#{parsed_lsb_init_dir}/#{new_resource.service_name}" do
              owner 'root'
              group 'root'
              mode '00755'
              cookbook 'runit'
              source 'init.d.erb'
              variables(
                name: new_resource.service_name,
                sv_bin: new_resource.sv_bin,
                init_dir: ::File.join(parsed_lsb_init_dir, '')
              )
              action :create
            end
          else
            link "#{parsed_lsb_init_dir}/#{new_resource.service_name}" do
              to sv_bin
              action :create
            end
          end

          # Create/Delete service down file
          # To prevent unexpected behavior, require users to explicitly set
          # delete_downfile to remove any down file that may already exist
          df_action = :nothing
          if new_resource.start_down
            df_action = :create
          elsif new_resource.delete_downfile
            df_action = :delete
          end

          file down_file do
            mode 00644
            backup false
            content '# File created and managed by chef!'
            action df_action
          end
        end
      end

      action :disable do
        ruby_block "disable #{new_resource.service_name}" do
          block { disable_service }
          only_if { enabled? }
        end
      end

      action :enable do
        # FIXME: remove action_create in next major version
        action_create

        directory new_resource.service_dir

        link "#{service_dir_name}" do
          to sv_dir_name
          action :create
        end

        ruby_block "wait for #{new_resource.service_name} service socket" do
          block do
            wait_for_service
          end
          action :run
        end
      end

      # signals
      VALID_SIGNALS.each do |signal, signal_name|
        action(signal_name || signal) do
          if running?
            Chef::Log.info "#{new_resource} signalled (#{(signal_name || signal).to_s.upcase})"
            runit_send_signal(signal, signal_name)
          else
            Chef::Log.debug "#{new_resource} not running - nothing to do"
          end
        end
      end

      action :nothing do
      end

      action :restart do
        restart_service
      end

      action :start do
        if running?
          Chef::Log.debug "#{new_resource} already running - nothing to do"
        else
          start_service
          Chef::Log.info "#{new_resource} started"
        end
      end

      action :stop do
        if running?
          stop_service
          Chef::Log.info "#{new_resource} stopped"
        else
          Chef::Log.debug "#{new_resource} already stopped - nothing to do"
        end
      end

      action :reload do
        if running?
          reload_service
          Chef::Log.info "#{new_resource} reloaded"
        else
          Chef::Log.debug "#{new_resource} not running - nothing to do"
        end
      end

      action :status do
        running?
      end
    end
  end
end
