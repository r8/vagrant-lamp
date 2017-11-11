#
# Copyright 2015-2016, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


module Poise
  module Helpers
    autoload :ChefspecMatchers, 'poise/helpers/chefspec_matchers'
    autoload :DefinedIn, 'poise/helpers/defined_in'
    autoload :Fused, 'poise/helpers/fused'
    autoload :IncludeRecipe, 'poise/helpers/include_recipe'
    autoload :Inversion, 'poise/helpers/inversion'
    autoload :LazyDefault, 'poise/helpers/lazy_default'
    autoload :LWRPPolyfill, 'poise/helpers/lwrp_polyfill'
    autoload :NotifyingBlock, 'poise/helpers/notifying_block'
    autoload :OptionCollector, 'poise/helpers/option_collector'
    autoload :ResourceCloning, 'poise/helpers/resource_cloning'
    autoload :ResourceName, 'poise/helpers/resource_name'
    autoload :ResourceSubclass, 'poise/helpers/resource_subclass'
    autoload :Subresources, 'poise/helpers/subresources'
    autoload :TemplateContent, 'poise/helpers/template_content'
    autoload :Win32User, 'poise/helpers/win32_user'
  end
end
