#
# Cookbook:: homebrew
# Recipes:: install_taps
#
# Copyright:: 2015-2017, Chef Software, Inc <legal@chef.io>
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

include_recipe 'homebrew'

node['homebrew']['taps'].each do |tap|
  if tap.is_a?(String)
    homebrew_tap tap
  elsif tap.is_a?(Hash)
    raise unless tap.key?('tap')
    homebrew_tap tap['tap'] do
      url tap['url'] if tap.key?('url')
      full tap['full'] if tap.key?('full')
    end
  else
    raise
  end
end
