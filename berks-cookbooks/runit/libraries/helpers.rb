#
# Cookbook:: runit
# Libraries:: helpers
#
# Author: Joshua Timberman <joshua@chef.io>
# Author: Sean OMeara <sean@chef.io>
# Copyright 2008-2015, Chef Software, Inc. <legal@chef.io>
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

module RunitCookbook
  module Helpers
    # include Chef::Mixin::ShellOut if it is not already included in the calling class
    def self.included(klass)
      unless klass.ancestors.include?(Chef::Mixin::ShellOut)
        klass.class_eval { include Chef::Mixin::ShellOut }
      end
    end

    # Default settings for resource properties.
    def parsed_sv_bin
      return new_resource.sv_bin if new_resource.sv_bin
      '/usr/bin/sv'
    end

    def parsed_sv_dir
      return new_resource.sv_dir if new_resource.sv_dir
      '/etc/sv'
    end

    def parsed_service_dir
      return new_resource.service_dir if new_resource.service_dir
      '/etc/service'
    end

    def parsed_lsb_init_dir
      return new_resource.lsb_init_dir if new_resource.lsb_init_dir
      '/etc/init.d'
    end

    # misc helper functions
    def inside_docker?
      results = `cat /proc/1/cgroup`.strip.split("\n")
      results.any? { |val| /docker/ =~ val }
    end

    def down_file
      "#{sv_dir_name}/down"
    end

    def env_dir
      "#{sv_dir_name}/env"
    end

    def extra_env_files?
      files = []
      Dir.glob("#{sv_dir_name}/env/*").each do |f|
        files << File.basename(f)
      end
      return true if files.sort != new_resource.env.keys.sort
      false
    end

    def zap_extra_env_files
      Dir.glob("#{sv_dir_name}/env/*").each do |f|
        unless new_resource.env.key?(File.basename(f))
          File.unlink(f)
          Chef::Log.info("removing file #{f}")
        end
      end
    end

    def wait_for_service
      unless inside_docker?
        sleep 1 until ::FileTest.pipe?("#{service_dir_name}/supervise/ok")

        if new_resource.log
          sleep 1 until ::FileTest.pipe?("#{service_dir_name}/log/supervise/ok")
        end
      end
    end

    def runit_sv_works?
      sv = shell_out("#{sv_bin} --help")
      sv.exitstatus == 100 && sv.stderr =~ /usage: sv .* command service/
    end

    def runit_send_signal(signal, friendly_name = nil)
      friendly_name ||= signal
      converge_by("send #{friendly_name} to #{new_resource}") do
        shell_out!("#{sv_bin} #{sv_args}#{signal} #{service_dir_name}")
        Chef::Log.info("#{new_resource} sent #{friendly_name}")
      end
    end

    def running?
      cmd = shell_out("#{sv_bin} #{sv_args}status #{service_dir_name}")
      (cmd.stdout =~ /^run:/ && cmd.exitstatus == 0)
    end

    def log_running?
      cmd = shell_out("#{sv_bin} #{sv_args}status #{service_dir_name}/log")
      (cmd.stdout =~ /^run:/ && cmd.exitstatus == 0)
    end

    def enabled?
      ::File.exist?("#{service_dir_name}/run")
    end

    def log_service_name
      "#{new_resource.service_name}/log"
    end

    def sv_dir_name
      "#{parsed_sv_dir}/#{new_resource.service_name}"
    end

    def sv_args
      sv_args = ''
      sv_args += "-w '#{new_resource.sv_timeout}' " unless new_resource.sv_timeout.nil?
      sv_args += '-v ' if new_resource.sv_verbose
      sv_args
    end

    def sv_bin
      parsed_sv_bin
    end

    def service_dir_name
      "#{new_resource.service_dir}/#{new_resource.service_name}"
    end

    def log_dir_name
      "#{new_resource.service_dir}/#{new_resource.service_name}/log"
    end

    def template_cookbook
      new_resource.cookbook.nil? ? new_resource.cookbook_name.to_s : new_resource.cookbook
    end

    def default_logger_content
      <<-EOS
#!/bin/sh
exec svlogd -tt #{new_resource.log_dir}
      EOS
    end

    def disable_service
      shell_out("#{new_resource.sv_bin} #{sv_args}down #{service_dir_name}")
      FileUtils.rm(service_dir_name)
    end

    def start_service
      shell_out!("#{new_resource.sv_bin} #{sv_args}start #{service_dir_name}")
    end

    def stop_service
      shell_out!("#{new_resource.sv_bin} #{sv_args}stop #{service_dir_name}")
    end

    def restart_service
      shell_out!("#{new_resource.sv_bin} #{sv_args}restart #{service_dir_name}")
    end

    def restart_log_service
      shell_out!("#{new_resource.sv_bin} #{sv_args}restart #{service_dir_name}/log")
    end

    def reload_service
      shell_out!("#{new_resource.sv_bin} #{sv_args}force-reload #{service_dir_name}")
    end

    def reload_log_service
      if log_running?
        shell_out!("#{new_resource.sv_bin} #{sv_args}force-reload #{service_dir_name}/log")
      end
    end
  end
end
