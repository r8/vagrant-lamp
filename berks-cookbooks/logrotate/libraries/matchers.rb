if defined?(ChefSpec)
  def enable_logrotate_app(name)
    LogrotateAppMatcher.new(name)
  end

  class LogrotateAppMatcher
    def initialize(name)
      @name = name
    end

    def with(parameters = {})
      params.merge!(parameters)
      self
    end

    def at_compile_time
      raise ArgumentError, 'Cannot specify both .at_converge_time and .at_compile_time!' if @converge_time
      @compile_time = true
      self
    end

    def at_converge_time
      raise ArgumentError, 'Cannot specify both .at_compile_time and .at_converge_time!' if @compile_time
      @converge_time = true
      self
    end

    #
    # Allow users to specify fancy #with matchers.
    #
    def method_missing(m, *args, &block)
      if m.to_s =~ /^with_(.+)$/
        with($1.to_sym => args.first)
        self
      else
        super
      end
    end

    def description
      %Q{"enable" #{@name} "logrotate_app"}
    end

    def matches?(runner)
      @runner = runner

      if resource
        resource.performed_action?('create') && unmatched_parameters.empty? && correct_phase?
      else
        false
      end
    end

    def failure_message_for_should
      if resource
        if resource.performed_action?('create')
          if unmatched_parameters.empty?
            if @compile_time
              %Q{expected "#{resource}" to be run at compile time}
            else
              %Q{expected "#{resource}" to be run at converge time}
            end
          else
            %Q{expected "#{resource}" to have parameters:} \
            "\n\n" \
            "  " + unmatched_parameters.collect { |parameter, h|
              "#{parameter} #{h[:expected].inspect}, was #{h[:actual].inspect}"
            }.join("\n  ")
          end
        else
          %Q{expected "#{resource}" actions #{resource.performed_actions.inspect}} \
          " to include : create"
        end
      else
        %Q{expected "logrotate_app[#{@name}] with"} \
        " enable : true to be in Chef run. Other" \
        " #{@name} resources:" \
        "\n\n" \
        "  " + similar_resources.map(&:to_s).join("\n  ") + "\n "
      end
    end

    def failure_message_for_should_not
      if resource
        message = %Q{expected "#{resource}" actions #{resource.performed_actions.inspect} to not exist}
      else
        message = %Q{expected "#{resource}" to not exist}
      end

      message << " at compile time"  if @compile_time
      message << " at converge time" if @converge_time
      message
    end

    private
      def unmatched_parameters
        return @_unmatched_parameters if @_unmatched_parameters

        @_unmatched_parameters = {}

        params.each do |parameter, expected|
          unless matches_parameter?(parameter, expected)
            @_unmatched_parameters[parameter] = {
              :expected => expected,
              :actual => safe_send(parameter),
            }
          end
        end

        @_unmatched_parameters
      end

      def matches_parameter?(parameter, expected)
        # Chef 11+ stores the source parameter internally as an Array
        #
        case parameter
        when :cookbook
          expected === safe_send(parameter)
        when :path
          Array(expected == safe_send('variables')[parameter])
        else
          expected == safe_send('variables')[parameter]
        end
      end

      def correct_phase?
        if @compile_time
          resource.performed_action('create')[:compile_time]
        elsif @converge_time
          resource.performed_action('create')[:converge_time]
        else
          true
        end
      end

      def safe_send(parameter)
        resource.send(parameter)
      rescue NoMethodError
        nil
      end

      def similar_resources
        @_similar_resources ||= @runner.find_resources('template')
      end

      def resource
        @_resource ||= @runner.find_resource('template',  "/etc/logrotate.d/#{@name}")
      end

      def params
        @_params ||= {}
      end
  end
end
