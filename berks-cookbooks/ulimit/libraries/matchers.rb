#
# Cookbook Name:: ulimit
# Library:: matchers
#
# Copyright © 2015 Cask Data, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Only define these if we've got ChefSpec
if defined?(ChefSpec)
  def create_ulimit_domain(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ulimit_domain, :create, resource_name)
  end

  def delete_ulimit_domain(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ulimit_domain, :delete, resource_name)
  end

  def create_ulimit_rule(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ulimit_rule, :create, resource_name)
  end

  def delete_ulimit_rule(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ulimit_rule, :delete, resource_name)
  end
end
