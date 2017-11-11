#
# Author:: Paul Morton (<pmorton@biaprotect.com>)
# Cookbook:: windows
# Resource:: path
#
# Copyright:: 2011-2017, Business Intelligence Associates, Inc
# Copyright:: 2017, Chef Software, Inc.
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

property :path, String, name_property: true

include Windows::Helper

action :add do
  env 'path' do
    action :modify
    delim ::File::PATH_SEPARATOR
    value new_resource.path.tr('/', '\\')
    notifies :run, "ruby_block[fix ruby ENV['PATH']]", :immediately
  end

  # The windows Env provider does not correctly expand variables in
  # the PATH environment variable. Ruby expects these to be expanded.
  # This is a temporary fix for that.
  #
  # Follow at https://github.com/chef/chef/pull/1876
  #
  ruby_block "fix ruby ENV['PATH']" do
    block do
      ENV['PATH'] = expand_env_vars(ENV['PATH'])
    end
    action :nothing
  end
end

action :remove do
  env 'path' do
    action :delete
    delim ::File::PATH_SEPARATOR
    value new_resource.path.tr('/', '\\')
  end
end
