## This is kind of a hack, to ensure that the cookbook can be
#  loaded. On first load, nokogiri may not be present. It is
#  installed at load time by recipes/default.rb, so that at run
#  time nokogiri will be present.
#
require 'forwardable'

# rubocop:disable Metrics/ClassLength
module SMFManifest
  # XMLBuilder manages the translation of the SMF Chef resource attributes into
  # XML that can be parsed by `svccfg import`.
  #
  #   SMFManifest::XMLBuilder.new(resource, node).to_xml
  #
  class XMLBuilder
    # allow delegation
    extend Forwardable

    attr_reader :resource, :node

    # delegate methods to :resource
    def_delegators :resource, :name, :authorization_name, :dependencies, :duration, :environment, :group, :ignore,
                   :include_default_dependencies, :locale, :manifest_type, :project, :property_groups,
                   :service_path, :stability, :working_directory

    public

    def initialize(smf_resource, node)
      @resource = smf_resource
      @node = node
    end

    def to_xml
      @xml_output ||= xml_output
    end

    protected

    ## methods that need to be called from within the context
    #  of the Nokogiri builder block need to be protected, rather
    #  than private.

    def commands
      @commands ||= {
        'start' => resource.start_command,
        'stop' => resource.stop_command,
        'restart' => resource.restart_command,
        'refresh' => resource.refresh_command
      }
    end

    def timeout
      @timeouts ||= {
        'start' => resource.start_timeout,
        'stop' => resource.stop_timeout,
        'restart' => resource.restart_timeout,
        'refresh' => resource.refresh_timeout
      }
    end

    def default_dependencies
      if node.platform == 'solaris2' && node.platform_version == '5.11'
        [
          { 'name' => 'milestone', 'value' => '/milestone/config' },
          { 'name' => 'fs-local', 'value' => '/system/filesystem/local' },
          { 'name' => 'name-services', 'value' => '/milestone/name-services' },
          { 'name' => 'network', 'value' => '/milestone/network' }
        ]
      else
        [
          { 'name' => 'milestone', 'value' => '/milestone/sysconfig' },
          { 'name' => 'fs-local', 'value' => '/system/filesystem/local' },
          { 'name' => 'name-services', 'value' => '/milestone/name-services' },
          { 'name' => 'network', 'value' => '/milestone/network' }
        ]
      end
    end

    private

    def xml_output
      xml_builder = ::Builder::XmlMarkup.new(indent: 2)
      xml_builder.instruct!
      xml_builder.declare! :DOCTYPE, :service_bundle, :SYSTEM, '/usr/share/lib/xml/dtd/service_bundle.dtd.1'
      xml_builder.service_bundle('name' => name, 'type' => 'manifest') do |xml|
        xml.service('name' => service_fmri, 'type' => 'service', 'version' => '1') do |service|
          service.create_default_instance('enabled' => 'false')
          service.single_instance

          if include_default_dependencies
            default_dependencies.each do |dependency|
              service.dependency('name' => dependency['name'],
                                 'grouping' => 'require_all',
                                 'restart_on' => 'none',
                                 'type' => 'service') do |dep|
                dep.service_fmri('value' => "svc:#{dependency['value']}")
              end
            end
          end

          dependencies.each do |dependency|
            service.dependency('name' => dependency['name'],
                               'grouping' => dependency['grouping'],
                               'restart_on' => dependency['restart_on'],
                               'type' => dependency['type']) do |dep|
              dependency['fmris'].each do |service_fmri|
                dep.service_fmri('value' => service_fmri)
              end
            end
          end

          service.method_context(exec_context) do |context|
            context.method_credential(credentials) if user != 'root'

            if environment
              context.method_environment do |env|
                environment.each_pair do |var, value|
                  env.envvar('name' => var, 'value' => value)
                end
              end
            end
          end

          commands.each_pair do |type, command|
            if command
              service.exec_method('type' => 'method', 'name' => type, 'exec' => command, 'timeout_seconds' => timeout[type])
            end
          end

          service.property_group('name' => 'general', 'type' => 'framework') do |group|
            group.propval('name' => 'action_authorization',
                          'type' => 'astring',
                          'value' => "solaris.smf.manage.#{authorization_name}")
            group.propval('name' => 'value_authorization',
                          'type' => 'astring',
                          'value' => "solaris.smf.value.#{authorization_name}")
          end

          if sets_duration? || ignores_faults?
            service.property_group('name' => 'startd', 'type' => 'framework') do |group|
              group.propval('name' => 'duration', 'type' => 'astring', 'value' => duration) if sets_duration?
              group.propval('name' => 'ignore_error', 'type' => 'astring', 'value' => ignore.join(',')) if ignores_faults?
            end
          end

          property_groups.each_pair do |name, properties|
            service.property_group('name' => name, 'type' => properties.delete('type') { |_type| 'application' }) do |group|
              properties.each_pair do |key, value|
                group.propval('name' => key, 'value' => value, 'type' => check_type(value))
              end
            end
          end

          service.stability('value' => stability)

          service.template do |template|
            template.common_name do |common_name|
              common_name.loctext(name, 'xml:lang' => locale)
            end
          end
        end
      end

      xml_builder.target!
    end

    def credentials
      creds = { 'user' => user, 'privileges' => resource.privilege_list }
      creds.merge!('group' => group) unless group.nil?
      creds
    end

    def user
      resource.user || resource.credentials_user || 'root'
    end

    def exec_context
      context = {}
      context['working_directory'] = working_directory unless working_directory.nil?
      context['project'] = project unless project.nil?
      context
    end

    def check_type(value)
      if value == value.to_i
        'integer'
      else
        'astring'
      end
    end

    def ignores_faults?
      !ignore.nil?
    end

    def sets_duration?
      duration != 'contract'
    end

    # resource.fmri is set in the SMF :install action of the default provider.
    # If there is already a service with a name that is matched by our resource.name
    # then we grab the FMRI (fault management resource identifier) from the system.
    # If a service is not found, we set this to our own FMRI.
    def service_fmri
      resource.fmri.nil? || resource.fmri.empty? ? "#{manifest_type}/management/#{name}" : resource.fmri.gsub(/^\//, '')
    end
  end
end
# rubocop:enable Metrics/ClassLength
