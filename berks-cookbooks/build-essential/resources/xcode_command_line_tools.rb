#
# Cookbook:: build-essential
# Resource:: xcode_command_line_tools
#
# Copyright:: 2014-2018, Chef Software, Inc.
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

resource_name :xcode_command_line_tools

action :install do
  if installed?
    Chef::Log.debug("#{new_resource} already installed - skipping")
  else
    converge_by("Install #{new_resource}") do
      # This script was graciously borrowed and modified from Tim Sutton's
      # osx-vm-templates at https://github.com/timsutton/osx-vm-templates/blob/b001475df54a9808d3d56d06e71b8fa3001fff42/scripts/xcode-cli-tools.sh
      execute 'install XCode Command Line tools' do
        command <<-EOH.gsub(/^ {14}/, '')
          # create the placeholder file that's checked by CLI updates' .dist code
          # in Apple's SUS catalog
          touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
          # find the CLI Tools update
          PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
          # install it
          softwareupdate -i "$PROD" --verbose
          # Remove the placeholder to prevent perpetual appearance in the update utility
          rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        EOH
      end
    end
  end
end

action_class do
  #
  # Determine if the XCode Command Line Tools are installed
  #
  # @return [true, false]
  #
  def installed?
    cmd = Mixlib::ShellOut.new('pkgutil --pkgs=com.apple.pkg.CLTools_Executables')
    cmd.run_command
    cmd.error? ? false : true
  end
end
