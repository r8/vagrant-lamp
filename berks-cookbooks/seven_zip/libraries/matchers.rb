#
# Author:: Shawn Neal (<sneal@sneal.net>)
# Cookbook:: visualstudio
#
# Copyright:: 2015-2017, Shawn Neal
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
  chefspec_version = Gem.loaded_specs['chefspec'].version
  define_method = if chefspec_version < Gem::Version.new('4.1.0')
                    ChefSpec::Runner.method(:define_runner_method)
                  else
                    ChefSpec.method(:define_matcher)
                  end

  define_method.call :seven_zip_archive

  def extract_seven_zip_archive(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:seven_zip_archive, :extract, resource_name)
  end
end
