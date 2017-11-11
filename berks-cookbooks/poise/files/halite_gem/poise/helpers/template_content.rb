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

require 'chef/provider/template_finder'
require 'chef/mixin/template'

require 'poise/helpers/lazy_default'
require 'poise/helpers/lwrp_polyfill'
require 'poise/helpers/option_collector'
require 'poise/utils'


module Poise
  module Helpers
    # A resource mixin to add a new kind of attribute, template content. TODO
    #
    # @since 1.0.0
    module TemplateContent
      include LazyDefault
      include LWRPPolyfill
      include OptionCollector

      # @!classmethods
      module ClassMethods
        def attribute(name, options={})
          if options.delete(:template)
            name_prefix = name.empty? ? '' : "#{name}_"

            # If you are reading this, I'm so sorry
            # This is used for computing the default cookbook below
            parent_filename = caller.first.reverse.split(':', 4).last.reverse

            # If our parent class also declared a template_content attribute on the same name, inherit its options
            if superclass.respond_to?("_#{name_prefix}_template_content_options")
              options = superclass.send("_#{name_prefix}_template_content_options").merge(options)
            end

            # Template source path if using a template
            attribute("#{name_prefix}source", kind_of: String)
            define_method("_#{name_prefix}source") do
              send("#{name_prefix}source") || maybe_eval(options[:default_source])
            end

            # Template cookbook name if using a template
            attribute("#{name_prefix}cookbook", kind_of: [String, Symbol], default: lazy do
              if send("#{name_prefix}source")
                cookbook_name
              elsif options[:default_cookbook]
                maybe_eval(options[:default_cookbook])
              else
                Poise::Utils.find_cookbook_name(run_context, parent_filename)
              end
            end)

            # Template variables if using a template
            attribute("#{name_prefix}options", option_collector: true)

            # Make an alias for #variables to match the template resource.
            alias_method("#{name_prefix}variables", "#{name_prefix}options")

            # The big one, get/set content, but if you are getting and no
            # explicit content was given, try to render the template
            define_method("#{name_prefix}content") do |arg=nil, no_compute=false|
              ret = set_or_return("#{name_prefix}content", arg, kind_of: String)
              if !ret && !arg && !no_compute
                ret = send("_#{name_prefix}content")
                # Cache the results for next time
                set_or_return("#{name_prefix}content", ret, {}) if ret
              end
              ret
            end

            # Validate that arguments work
            define_method("_#{name_prefix}validate") do
              if options[:required] && !send("_#{name_prefix}source") && !send("#{name_prefix}content", nil, true)
                raise Chef::Exceptions::ValidationFailed, "#{self}: One of #{name_prefix}source or #{name_prefix}content is required"
              end
              if send("#{name_prefix}source") && send("#{name_prefix}content", nil, true)
                raise Chef::Exceptions::ValidationFailed, "#{self}: Only one of #{name_prefix}source or #{name_prefix}content can be specified"
              end
            end

            # Monkey patch #after_create to run best-effort validation. Arguments
            # could be changed after creation, but this gives nicer errors for
            # most cases.
            unless options[:no_validate_on_create]
              old_after_created = instance_method(:after_created)
              define_method(:after_created) do
                old_after_created.bind(self).call
                send("_#{name_prefix}validate") if Array(action) == Array(self.class.default_action)
              end
            end

            # Compile the needed content
            define_method("_#{name_prefix}content") do
              # Run validation again
              send("_#{name_prefix}validate")
              # Get all the relevant parameters
              content = send("#{name_prefix}content", nil, true)
              source = send("_#{name_prefix}source")
              if content
                content # I don't think it can ever hit this branch
              elsif source
                cookbook = send("#{name_prefix}cookbook")
                template_options = send("#{name_prefix}options")
                send("_#{name_prefix}render_template", source, cookbook, template_options)
              else
                maybe_eval(options[:default])
              end
            end

            # Actually render a template
            define_method("_#{name_prefix}render_template") do |source, cookbook, template_options|
              all_template_options = {}
              all_template_options.update(maybe_eval(options[:default_options])) if options[:default_options]
              all_template_options.update(template_options)
              all_template_options[:new_resource] = self
              finder = Chef::Provider::TemplateFinder.new(run_context, cookbook, node)
              context = Chef::Mixin::Template::TemplateContext.new(all_template_options)
              context[:node] = node
              context[:template_finder] = finder
              context.render_template(finder.find(source))
            end

            # Used to check if a parent class already defined a template_content thing here
            define_singleton_method("_#{name_prefix}_template_content_options") do
              options
            end
          else
            super if defined?(super)
          end
        end

        def included(klass)
          super
          klass.extend(ClassMethods)
        end
      end

      extend ClassMethods

      private

      # Evaluate lazy blocks if needed
      def maybe_eval(val)
        if val.is_a?(Chef::DelayedEvaluator)
          instance_eval(&val)
        else
          val
        end
      end

    end
  end
end
