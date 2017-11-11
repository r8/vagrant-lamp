#
# Cookbook:: mingw
# Resource:: get
#
# Copyright:: 2016, Chef Software, Inc.
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

# Installs the core msys utilities needed for mingw/git/any other posix
# based toolchain at a desired location using mingw-get.exe.

property :package, kind_of: String, name_property: true
property :root, kind_of: String, required: true

resource_name :mingw_get

action_class do
  def mingw_do_action(action_cmd)
    seven_zip_archive "fetching mingw-get to #{win_friendly_path(root)}" do
      source 'http://iweb.dl.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip'
      path root
      checksum '2e0e9688d42adc68c5611759947e064156e169ff871816cae52d33ee0655826d'
      not_if do
        ::File.exist?(::File.join(root, 'bin/mingw-get.exe'))
      end
    end

    execute "performing #{action_cmd} for #{package}" do
      command ".\\bin\\mingw-get.exe -v #{action_cmd} #{package}"
      cwd root
    end
  end
end

action :install do
  mingw_do_action('install')
end

action :upgrade do
  mingw_do_action('upgrade')
end

action :remove do
  mingw_do_action('remove')
end
