#
# Cookbook:: ohai
# Library:: plugin_helpers
#
# Author:: Tim Smith (<tsmith@chef.io>)
#
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

module OhaiCookbook
  module PluginHelpers
    # return the path property if specified or
    # CHEF_CONFIG_PATH/ohai/plugins if a path isn't specified
    def desired_plugin_path
      if new_resource.path
        new_resource.path
      else
        ::File.join(chef_config_path, 'ohai', 'plugins')
      end
    end

    # return the chef config files dir or fail hard
    def chef_config_path
      if Chef::Config['config_file']
        ::File.dirname(Chef::Config['config_file'])
      else
        Chef::Application.fatal!("No chef config file defined. Are you running \
  chef-solo? If so you will need to define a path for the ohai_plugin as the \
  path cannot be determined")
      end
    end

    # is the desired plugin dir in the ohai config plugin dir array?
    def in_plugin_path?(path)
      normalized_path = normalize_path(path)
      # get the directory where we plan to stick the plugin (not the actual file path)
      desired_dir = ::File.directory?(normalized_path) ? normalized_path : ::File.dirname(normalized_path)
      ::Ohai::Config.ohai['plugin_path'].map { |x| normalize_path(x) }.include?(desired_dir)
    end

    # return path to lower and with forward slashes so we can compare it
    # this works around the 3 different way we can represent windows paths
    def normalize_path(path)
      path.downcase.gsub(/\\+/, '/')
    end

    def add_to_plugin_path(path)
      ::Ohai::Config.ohai['plugin_path'] << path # new format
    end

    # we need to warn the user that unless the path for this plugin is in Ohai's
    # plugin path already we're going to have to reload Ohai on every Chef run.
    # Ideally in future versions of Ohai /etc/chef/ohai/plugins is in the path.
    def plugin_path_warning
      Chef::Log.warn("The Ohai plugin_path does not include #{desired_plugin_path}. \
Ohai will reload on each chef-client run in order to add this directory to the \
path unless you modify your client.rb configuration to add this directory to \
plugin_path. The plugin_path can be set via the chef-client::config recipe. \
See 'Ohai Settings' at https://docs.chef.io/config_rb_client.html#ohai-settings \
for more details.")
    end
  end
end
