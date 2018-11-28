#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook:: seven_zip
# Attribute:: default
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

if node['kernel']['machine'] == 'x86_64'
  default['seven_zip']['url']          = 'https://www.7-zip.org/a/7z1805-x64.msi'
  default['seven_zip']['checksum']     = '898c1ca0015183fe2ba7d55cacf0a1dea35e873bf3f8090f362a6288c6ef08d7'
  default['seven_zip']['package_name'] = '7-Zip 18.05 (x64 edition)'
else
  default['seven_zip']['url']          = 'https://www.7-zip.org/a/7z1805.msi'
  default['seven_zip']['checksum']     = 'c554238bee18a03d736525e06d9258c9ecf7f64ead7c6b0d1eb04db2c0de30d0'
  default['seven_zip']['package_name'] = '7-Zip 18.05'
end

default['seven_zip']['default_extract_timeout'] = 600
