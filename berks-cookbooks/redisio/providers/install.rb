#
# Cookbook Name:: redisio
# Provider::install
#
# Copyright 2013, Brian Bianco <brian.bianco@gmail.com>
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

action :run do
  # Package install
  if node['redisio']['package_install']
    package_resource = package 'redisio_package_name' do
      package_name node['redisio']['package_name']
      version node['redisio']['version']
      action :nothing
    end

    package_resource.run_action(:install)
    new_resource.updated_by_last_action(true) if package_resource.updated_by_last_action?

  # freeBSD does not support from source since ports does not support versioning (without a lot of hassle)
  elsif node['platform_family'] == 'freebsd'
    raise 'Source install not supported for freebsd'
  # Tarball install
  else
    @tarball = "#{new_resource.base_name}#{new_resource.version}.#{new_resource.artifact_type}"

    unless current_resource.version == new_resource.version || (redis_exists? && new_resource.safe_install)
      Chef::Log.info("Installing Redis #{new_resource.version} from source")
      download
      unpack
      build
      install
      new_resource.updated_by_last_action(true)
    end
  end
end

def download
  Chef::Log.info("Downloading redis tarball from #{new_resource.download_url}")
  remote_file "#{new_resource.download_dir}/#{@tarball}" do
    source new_resource.download_url
  end
end

def unpack
  install_dir = "#{new_resource.base_name}#{new_resource.version}"
  case new_resource.artifact_type
  when 'tar.gz', '.tgz'
    execute %(cd #{new_resource.download_dir} ; mkdir -p '#{install_dir}' ; tar zxf '#{@tarball}' --strip-components=1 -C '#{install_dir}' --no-same-owner) # rubocop:disable Metrics/LineLength
  else
    raise Chef::Exceptions::UnsupportedAction, "Current package type #{new_resource.artifact_type} is unsupported"
  end
end

def build
  execute "cd #{new_resource.download_dir}/#{new_resource.base_name}#{new_resource.version} && make clean && make"
end

def install
  install_prefix = if new_resource.install_dir
                     "PREFIX=#{new_resource.install_dir}"
                   else
                     ''
                   end
  execute "cd #{new_resource.download_dir}/#{new_resource.base_name}#{new_resource.version} && make #{install_prefix} install" # rubocop:disable Metrics/LineLength
  new_resource.updated_by_last_action(true)
end

def redis_exists?
  bin_path = if node['redisio']['install_dir']
               ::File.join(node['redisio']['install_dir'], 'bin')
             else
               node['redisio']['bin_path']
             end
  redis_server = ::File.join(bin_path, 'redis-server')
  ::File.exist?(redis_server)
end

def version
  if redis_exists?
    bin_path = if node['redisio']['install_dir']
                 ::File.join(node['redisio']['install_dir'], 'bin')
               else
                 node['redisio']['bin_path']
               end
    redis_server = ::File.join(bin_path, 'redis-server')
    redis_version = Mixlib::ShellOut.new("#{redis_server} -v")
    redis_version.run_command
    version = redis_version.stdout[/version (\d*.\d*.\d*)/, 1] || redis_version.stdout[/v=(\d*.\d*.\d*)/, 1]
    Chef::Log.info("The Redis server version is: #{version}")
    return version.delete("\n")
  end
  nil
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:redisio_install, node).new(new_resource.name)
  @current_resource.version(version)
  @current_resource
end
