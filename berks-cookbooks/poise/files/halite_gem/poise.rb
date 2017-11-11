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

require 'chef/provider'
require 'chef/resource'
require 'chef/run_context'

require 'poise/utils/resource_provider_mixin'


module Poise
  include Poise::Utils::ResourceProviderMixin
  autoload :Backports, 'poise/backports'
  autoload :Helpers, 'poise/helpers'
  autoload :NOT_PASSED, 'poise/backports/not_passed'
  autoload :Provider, 'poise/provider'
  autoload :Resource, 'poise/resource'
  autoload :Subcontext, 'poise/subcontext'
  autoload :Utils, 'poise/utils'
  autoload :VERSION, 'poise/version'

  # Check if Poise's extra debugging output is enabled. This produces a *lot*
  # of logging.
  #
  # @param node [Chef::Node, Chef::RunContext] Optional node to check for
  #   attributes. If not given, Chef.node is used instead.
  # @return [Boolean]
  def self.debug?(node=nil)
    node = node.node if node.is_a?(Chef::RunContext)
    node ||= Chef.node if defined?(Chef.node)
    @debug_file_upper = ::File.exist?('/POISE_DEBUG') unless defined?(@debug_file_upper)
    @debug_file_lower = ::File.exist?('/poise_debug') unless defined?(@debug_file_lower)
    !!(
      (ENV['POISE_DEBUG'] && ENV['POISE_DEBUG'] != 'false') ||
      (ENV['poise_debug'] && ENV['poise_debug'] != 'false') ||
      (node && node['POISE_DEBUG']) ||
      (node && node['poise_debug']) ||
      @debug_file_upper ||
      @debug_file_lower
    )
  end

  # Log a message only if Poise's extra debugging output is enabled.
  #
  # @see #debug?
  # @param msg [String] Log message.
  # @return [void]
  def self.debug(msg)
    Chef::Log.debug(msg) if debug?
  end
end

# Callable form to allow passing in options:
#   include Poise(ParentResource)
#   include Poise(parent: ParentResource)
#   include Poise(container: true)
def Poise(options={})
  # Allow passing a class as a shortcut
  if options.is_a?(Class) || options.is_a?(Symbol)
    options = {parent: options}
  end

  # Create a new anonymous module
  mod = Module.new

  # Fake the name.
  mod.define_singleton_method(:name) do
    super() || 'Poise'
  end

  mod.define_singleton_method(:included) do |klass|
    super(klass)
    # Pull in the main helper to cover most of the needed logic.
    klass.class_exec { include Poise }
    # Set the defined_in values as needed.
    klass.poise_defined!(caller)
    # Resource-specific options.
    if klass < Chef::Resource
      klass.poise_subresource(options[:parent], options[:parent_optional], options[:parent_auto]) if options[:parent]
      klass.poise_subresource_container(options[:container_namespace], options[:container_default]) if options[:container]
      klass.poise_fused if options[:fused]
      klass.poise_inversion(options[:inversion_options_resource]) if options[:inversion]
    end
    # Provider-specific options.
    if klass < Chef::Provider
      klass.poise_inversion(options[:inversion], options[:inversion_attribute]) if options[:inversion]
    end
  end

  mod
end

# Display a message if poise_debug is enabled. Off in ChefSpec so I don't get
# extra logging stuff that I don't care about.
Poise.debug('[Poise] Extra verbose logging enabled') unless defined?(ChefSpec)
