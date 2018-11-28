#
# Author:: Annih (<b.courtois@criteo.com>)
# Cookbook:: seven_zip
# Resource:: tool
#
# Copyright:: 2018, Baptiste Courtois
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
property :package, ::String, default: lazy { node['seven_zip']['package_name'] }
property :source, ::String, default: lazy { node['seven_zip']['url'] }
property :checksum, [::NilClass, ::String], default: lazy { node['seven_zip']['checksum'] }
property :path, [::NilClass, ::String], default: lazy { node['seven_zip']['home'] }

action :install do
  windows_package new_resource.package do
    action :install
    source new_resource.source
    checksum new_resource.checksum unless new_resource.checksum.nil?
    options "INSTALLDIR=\"#{new_resource.path}\"" unless new_resource.path.nil?
  end
end

action :add_to_path do
  windows_path 'seven_zip' do
    action :add
    path new_resource.path || registry_path
  end
end

action_class do
  REG_PATH = 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe'.freeze

  def registry_path
    ::Win32::Registry::HKEY_LOCAL_MACHINE.open(REG_PATH, ::Win32::Registry::KEY_READ).read_s('Path')
  end
end
