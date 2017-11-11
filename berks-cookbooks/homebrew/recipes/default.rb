#
# Author:: Joshua Timberman (<jtimberman@chef.io>)
# Author:: Graeme Mathieson (<mathie@woss.name>)
# Cookbook:: homebrew
# Recipe:: default
#
# Copyright:: 2011-2017, Chef Software, Inc.
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

unless Homebrew.exist?
  homebrew_go = "#{Chef::Config[:file_cache_path]}/homebrew_go"

  remote_file homebrew_go do
    source node['homebrew']['installer']['url']
    checksum node['homebrew']['installer']['checksum'] unless node['homebrew']['installer']['checksum'].nil?
    mode '755'
  end

  execute 'install homebrew' do
    command homebrew_go
    environment lazy { { 'HOME' => ::Dir.home(Homebrew.owner), 'USER' => Homebrew.owner } }
    user Homebrew.owner
  end
end

execute 'set analytics' do
  environment lazy { { 'HOME' => ::Dir.home(Homebrew.owner), 'USER' => Homebrew.owner } }
  user Homebrew.owner
  command "/usr/local/bin/brew analytics #{node['homebrew']['enable-analytics'] ? 'on' : 'off'}"
  only_if { shell_out('/usr/local/bin/brew analytics state', user: Homebrew.owner).stdout.include?('enabled') != node['homebrew']['enable-analytics'] }
end

if node['homebrew']['auto-update']
  package 'git' do
    not_if 'which git'
  end

  execute 'update homebrew from github' do
    environment lazy { { 'HOME' => ::Dir.home(Homebrew.owner), 'USER' => Homebrew.owner } }
    user Homebrew.owner
    command '/usr/local/bin/brew update || true'
  end
end
