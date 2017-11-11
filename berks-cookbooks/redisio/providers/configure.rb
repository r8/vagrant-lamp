#
# Cookbook Name:: redisio
# Provider::configure
#
# Copyright 2013, Brian Bianco <brian.bianco@gmail.com>
# Copyright 2013, Rackspace Hosting <ryan.cleere@rackspace.com>
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

include SELinuxPolicy::Helpers

action :run do
  configure
  new_resource.updated_by_last_action(true)
end

def configure
  base_piddir = new_resource.base_piddir

  if !new_resource.version
    redis_output = Mixlib::ShellOut.new("#{node['redisio']['bin_path']}/redis-server -v")
    redis_output.run_command
    redis_output.error!
    current_version = redis_output.stdout.gsub(/.*v=((\d+\.){2}\d+).*/, '\1').chomp
  else
    current_version = new_resource.version
  end
  version_hash = RedisioHelper.version_to_hash(current_version)

  # Setup a configuration file and init script for each configuration provided
  new_resource.servers.each do |current_instance|
    # Retrieve the default settings hash and the current server setups settings hash.
    current_instance_hash = current_instance.to_hash
    current_defaults_hash = new_resource.default_settings.to_hash

    # Merge the configuration defaults with the provided array of configurations provided
    current = current_defaults_hash.merge(current_instance_hash)

    # Merge in the default maxmemory
    node_memory_kb = node['memory']['total']
    # On BSD platforms Ohai reports total memory as a Fixnum
    if node_memory_kb.is_a? String
      node_memory_kb = node_memory_kb.sub('kB', '').to_i
    end

    # Here we determine what the logfile is.  It has these possible states
    #
    # Redis 2.6 and lower can be
    #   stdout
    #   A path
    #   nil
    # Redis 2.8 and higher can be
    #   empty string, which means stdout)
    #   A path
    #   nil

    if current['logfile'].nil?
      log_file = nil
      log_directory = nil
    elsif current['logfile'] == 'stdout' || current['logfile'].empty?
      log_directory = nil
      log_file = current['logfile']
    else
      log_directory = ::File.dirname(current['logfile'])
      log_file      = ::File.basename(current['logfile'])
      if current['syslogenabled'] == 'yes'
        Chef::Log.warn("log file is set to #{current['logfile']} but syslogenabled is also set to 'yes'")
      end
    end

    maxmemory = current['maxmemory'].to_s
    if !maxmemory.empty? && maxmemory.include?('%')
      # Just assume this is sensible like "95%" or "95 %"
      percent_factor = current['maxmemory'].to_f / 100.0
      # Ohai reports memory in KB as it looks in /proc/meminfo
      maxmemory = (node_memory_kb * 1024 * percent_factor / new_resource.servers.length).round.to_s
    end

    descriptors = if current['ulimit'].zero?
                    current['maxclients'] + 32
                  elsif current['ulimit'] > current['maxclients']
                    current['ulimit']
                  else
                    current['maxclients']
                  end

    recipe_eval do
      include_recipe 'selinux_policy::install' if use_selinux

      server_name = current['name'] || current['port']
      piddir = "#{base_piddir}/#{server_name}"
      aof_file = current['appendfilename'] || "#{current['datadir']}/appendonly-#{server_name}.aof"
      rdb_file = current['dbfilename'] || "#{current['datadir']}/dump-#{server_name}.rdb"

      # Create the owner of the redis data directory
      user current['user'] do
        comment 'Redis service account'
        manage_home true
        home current['homedir']
        shell current['shell']
        system current['systemuser']
        uid current['uid'] unless current['uid'].nil?

        not_if do
          begin
            Etc.getpwnam current['user']
          rescue ArgumentError
            false
          end
        end
      end
      # Create the redis configuration directory
      directory current['configdir'] do
        owner 'root'
        group node['platform_family'] == 'freebsd' ? 'wheel' : 'root'
        mode '0755'
        recursive true
        action :create
      end
      selinux_policy_fcontext "#{current['configdir']}(/.*)?" do
        secontext 'redis_conf_t'
      end
      # Create the instance data directory
      directory current['datadir'] do
        owner current['user']
        group current['group']
        mode '0775'
        recursive true
        action :create
      end
      selinux_policy_fcontext "#{current['datadir']}(/.*)?" do
        secontext 'redis_var_lib_t'
      end
      # Create the pid file directory
      directory piddir do
        owner current['user']
        group current['group']
        mode '0755'
        recursive true
        action :create
      end
      selinux_policy_fcontext "#{piddir}(/.*)?" do
        secontext 'redis_var_run_t'
      end
      # Create the log directory if syslog is not being used
      if log_directory
        directory log_directory do
          owner current['user']
          group current['group']
          mode '0755'
          recursive true
          action :create
        end
        selinux_policy_fcontext "#{log_directory}(/.*)?" do
          secontext 'redis_log_t'
        end
      end
      # Create the log file if syslog is not being used
      if log_file
        file current['logfile'] do
          owner current['user']
          group current['group']
          mode '0644'
          backup false
          action :touch
          # in version 2.8 or higher the empty string is used instead of stdout
          only_if { !log_file.empty? && log_file != 'stdout' }
        end
      end
      # Set proper permissions on the AOF or RDB files
      file aof_file do
        owner current['user']
        group current['group']
        mode '0644'
        only_if { current['backuptype'] == 'aof' || current['backuptype'] == 'both' }
        only_if { ::File.exist?(aof_file) }
      end
      file rdb_file do
        owner current['user']
        group current['group']
        mode '0644'
        only_if { current['backuptype'] == 'rdb' || current['backuptype'] == 'both' }
        only_if { ::File.exist?(rdb_file) }
      end

      # Setup the redis users descriptor limits
      # Pending response on https://github.com/brianbianco/redisio/commit/4ee9aad3b53029cc3b6c6cf741f5126755e712cd#diff-8ae42a59a6f4e8dc5b4e6dd2d6a34eab
      # TODO: ulimit cookbook v0.1.2 doesn't work with freeBSD
      if current['ulimit'] && node['platform_family'] != 'freebsd' # ~FC023
        user_ulimit current['user'] do
          filehandle_limit descriptors
        end
      end

      computed_save = current['save']
      if current['save'] && current['save'].respond_to?(:each_line)
        computed_save = current['save'].each_line
        Chef::Log.warn("#{server_name}: given a save argument as a string, instead of an array.")
        Chef::Log.warn("#{server_name}: This will be deprecated in future versions of the redisio cookbook.")
      end

      # Load password for use with requirepass from data bag if needed
      if current['data_bag_name'] && current['data_bag_item'] && current['data_bag_key']
        bag = Chef::EncryptedDataBagItem.load(current['data_bag_name'], current['data_bag_item'])
        current['requirepass'] = bag[current['data_bag_key']]
        current['masterauth'] = bag[current['data_bag_key']]
      end

      # Lay down the configuration files for the current instance
      template "#{current['configdir']}/#{server_name}.conf" do
        source node['redisio']['redis_config']['template_source']
        cookbook node['redisio']['redis_config']['template_cookbook']
        owner current['user']
        group current['group']
        mode '0644'
        action :create
        variables(
          version:                    version_hash,
          piddir:                     piddir,
          name:                       server_name,
          job_control:                node['redisio']['job_control'],
          port:                       current['port'],
          tcpbacklog:                 current['tcpbacklog'],
          address:                    current['address'],
          databases:                  current['databases'],
          backuptype:                 current['backuptype'],
          datadir:                    current['datadir'],
          unixsocket:                 current['unixsocket'],
          unixsocketperm:             current['unixsocketperm'],
          timeout:                    current['timeout'],
          keepalive:                  current['keepalive'],
          loglevel:                   current['loglevel'],
          logfile:                    current['logfile'],
          syslogenabled:              current['syslogenabled'],
          syslogfacility:             current['syslogfacility'],
          save:                       computed_save,
          stopwritesonbgsaveerror:    current['stopwritesonbgsaveerror'],
          rdbcompression:             current['rdbcompression'],
          rdbchecksum:                current['rdbchecksum'],
          dbfilename:                 current['dbfilename'],
          slaveof:                    current['slaveof'],
          protected_mode:             current['protected_mode'],
          masterauth:                 current['masterauth'],
          slaveservestaledata:        current['slaveservestaledata'],
          slavereadonly:              current['slavereadonly'],
          replpingslaveperiod:        current['replpingslaveperiod'],
          repltimeout:                current['repltimeout'],
          repldisabletcpnodelay:      current['repldisabletcpnodelay'],
          replbacklogsize:            current['replbacklogsize'],
          replbacklogttl:             current['replbacklogttl'],
          slavepriority:              current['slavepriority'],
          requirepass:                current['requirepass'],
          rename_commands:            current['rename_commands'],
          maxclients:                 current['maxclients'],
          maxmemory:                  maxmemory,
          maxmemorypolicy:            current['maxmemorypolicy'],
          maxmemorysamples:           current['maxmemorysamples'],
          appendfilename:             current['appendfilename'],
          appendfsync:                current['appendfsync'],
          noappendfsynconrewrite:     current['noappendfsynconrewrite'],
          aofrewritepercentage:       current['aofrewritepercentage'],
          aofrewriteminsize:          current['aofrewriteminsize'],
          aofloadtruncated:           current['aofloadtruncated'],
          luatimelimit:               current['luatimelimit'],
          slowloglogslowerthan:       current['slowloglogslowerthan'],
          slowlogmaxlen:              current['slowlogmaxlen'],
          notifykeyspaceevents:       current['notifykeyspaceevents'],
          hashmaxziplistentries:      current['hashmaxziplistentries'],
          hashmaxziplistvalue:        current['hashmaxziplistvalue'],
          listmaxziplistentries:      current['listmaxziplistentries'],
          listmaxziplistvalue:        current['listmaxziplistvalue'],
          setmaxintsetentries:        current['setmaxintsetentries'],
          zsetmaxziplistentries:      current['zsetmaxziplistentries'],
          zsetmaxziplistvalue:        current['zsetmaxziplistvalue'],
          hllsparsemaxbytes:          current['hllsparsemaxbytes'],
          activerehasing:             current['activerehasing'],
          clientoutputbufferlimit:    current['clientoutputbufferlimit'],
          hz:                         current['hz'],
          aofrewriteincrementalfsync: current['aofrewriteincrementalfsync'],
          clusterenabled:             current['clusterenabled'],
          clusterconfigfile:          current['clusterconfigfile'],
          clusternodetimeout:         current['clusternodetimeout'],
          includes:                   current['includes'],
          minslavestowrite:           current['minslavestowrite'],
          minslavesmaxlag:            current['minslavesmaxlag'],
          repldisklesssync:           current['repldisklesssync'],
          repldisklesssyncdelay:      current['repldisklesssyncdelay']
        )
        not_if { ::File.exist?("#{current['configdir']}/#{server_name}.conf.breadcrumb") }
      end

      file "#{current['configdir']}/#{server_name}.conf.breadcrumb" do
        content 'This file prevents the chef cookbook from overwritting the redis config more than once'
        action :create_if_missing
        only_if { current['breadcrumb'] == true }
      end

      # Setup init.d file
      bin_path = if node['redisio']['install_dir']
                   ::File.join(node['redisio']['install_dir'], 'bin')
                 else
                   node['redisio']['bin_path']
                 end

      case node['redisio']['job_control']
      when 'initd'
        template "/etc/init.d/redis#{server_name}" do
          source 'redis.init.erb'
          cookbook 'redisio'
          owner 'root'
          group 'root'
          mode '0755'
          variables(
            name: server_name,
            bin_path: bin_path,
            port: current['port'],
            address: current['address'],
            user: current['user'],
            configdir: current['configdir'],
            piddir: piddir,
            requirepass: current['requirepass'],
            shutdown_save: current['shutdown_save'],
            platform: node['platform'],
            unixsocket: current['unixsocket'],
            ulimit: descriptors,
            required_start: node['redisio']['init.d']['required_start'].join(' '),
            required_stop: node['redisio']['init.d']['required_stop'].join(' ')
          )
        end
      when 'upstart'
        template "/etc/init/redis#{server_name}.conf" do
          source 'redis.upstart.conf.erb'
          cookbook 'redisio'
          owner current['user']
          group current['group']
          mode '0644'
          variables(
            name: server_name,
            bin_path: bin_path,
            port: current['port'],
            user: current['user'],
            group: current['group'],
            configdir: current['configdir'],
            piddir: piddir
          )
        end
      when 'rcinit'
        template "/usr/local/etc/rc.d/redis#{server_name}" do
          source 'redis.rcinit.erb'
          cookbook 'redisio'
          owner current['user']
          group current['group']
          mode '0755'
          variables(
            name: server_name,
            bin_path: bin_path,
            user: current['user'],
            configdir: current['configdir'],
            piddir: piddir
          )
        end
      when 'systemd'
        service_name = "redis@#{server_name}"
        reload_name = "#{service_name} systemd reload"

        file "/etc/tmpfiles.d/#{service_name}.conf" do
          content "d #{piddir} 0755 #{current['user']} #{current['group']}\n"
          owner 'root'
          group 'root'
          mode '0644'
        end

        execute reload_name do
          command 'systemctl daemon-reload'
          action :nothing
        end

        template "/lib/systemd/system/#{service_name}.service" do
          source 'redis@.service.erb'
          cookbook 'redisio'
          owner 'root'
          group 'root'
          mode '0644'
          variables(
            bin_path: bin_path,
            user: current['user'],
            group: current['group'],
            limit_nofile: descriptors
          )
          notifies :run, "execute[#{reload_name}]", :immediately
        end
      end
    end
  end # servers each loop
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:redisio_configure, node).new(new_resource.name)
  @current_resource
end
