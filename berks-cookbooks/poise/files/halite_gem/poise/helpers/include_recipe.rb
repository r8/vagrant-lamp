#
# Copyright 2013-2016, Noah Kantrowitz
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

require 'poise/helpers/subcontext_block'
require 'poise/subcontext/runner'


module Poise
  module Helpers
    # A provider mixin to add #include_recipe that can be called from action
    # methods.
    #
    # @since 2.0.0
    module IncludeRecipe
      include Poise::Helpers::SubcontextBlock

      def include_recipe(*recipes)
        loaded_recipes = []
        subcontext = subcontext_block do
          recipes.flatten.each do |recipe|
            case recipe
            when String
              # Process normally
              Chef::Log.debug("Loading recipe #{recipe} via include_recipe (poise)")
              loaded_recipes += run_context.include_recipe(recipe)
            when Proc
              # Pretend its a block of recipe code
              fake_recipe = Chef::Recipe.new(cookbook_name, new_resource.recipe_name, run_context)
              fake_recipe.instance_eval(&recipe)
              loaded_recipes << fake_recipe
            end
          end
        end
        # Converge the new context.
        Poise::Subcontext::Runner.new(new_resource, subcontext).converge
        collection = global_resource_collection
        subcontext.resource_collection.each do |r|
          Chef::Log.debug("Poise::IncludeRecipe: Adding #{r} to global collection #{collection.object_id}")
          # Insert the local resource into the global context
          collection.insert(r)
          # Skip the iterator forward so we don't double-execute the inserted resource
          # If running at compile time, the iterator is nil
          collection.iterator.skip_forward if collection.iterator
        end
        loaded_recipes
      end
    end
  end
end
