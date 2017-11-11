#
# Cookbook:: ohai
# Library:: matchers
#
# Author:: Tim Smith (<tsmith@chef.io>)
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

if defined?(ChefSpec)
  ChefSpec.define_matcher :ohai_hint
  ChefSpec.define_matcher :ohai_plugin

  def create_ohai_hint(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:ohai_hint, :create, resource)
  end

  def delete_ohai_hint(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:ohai_hint, :delete, resource)
  end

  def create_ohai_plugin(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:ohai_plugin, :create, resource)
  end

  def delete_ohai_plugin(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:ohai_plugin, :delete, resource)
  end
end
