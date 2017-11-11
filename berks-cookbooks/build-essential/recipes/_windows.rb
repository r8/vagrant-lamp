#
# Cookbook:: build-essential
# Recipe:: _windows
#
# Copyright:: 2016-2017, Chef Software, Inc.
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

node.default['seven_zip']['syspath'] = true
include_recipe 'seven_zip::default'

tool_path = node['build-essential']['msys2']['path']

directory tool_path do
  action :create
  recursive true
end

[
  'base-devel', # Brings down msys based bash/make/awk/patch/stuff..
  'mingw-w64-x86_64-toolchain', # Puts 64-bit SEH mingw toolchain in msys2\mingw64
  'mingw-w64-i686-toolchain' # Puts 32-bit DW2 mingw toolchain in msys2\ming32
].each do |package|
  msys2_package package do
    root tool_path
  end
end

# Certain build steps assume that a tar command is available on the
# system path. The default tar present in msys2\usr\bin is an msys GNU tar
# that expects forward slashes and consider ':' to be a remote tape separator
# or something weird like that. We therefore drop bat file in msys2\bin that
# redirect to the underlying executables without mucking around with
# msys2's /usr/bin itself.
{
  'bsdtar.exe' => 'tar.bat',
  'patch.exe' => 'patch.bat',
}.each do |reference, link|
  file "#{tool_path}\\bin\\#{link}" do
    content "@%~dp0..\\usr\\bin\\#{reference} %*"
  end
end
