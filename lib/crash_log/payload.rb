require 'rabl'

module CrashLog
  class Payload
    include Logging

    def self.build(exception, config, &block)
      payload = new(exception, config)
      yield(payload) if block_given?
      payload
    end

    # Delivers this payload to CrashLog
    #
    # Captures any exceptions and logs them.
    def deliver!
      deliver
    rescue Exception => e
      error('Failed to deliver notification to CrashLog collector')
      log_exception(e)
    end

    attr_reader :config, :backtrace_filters, :data

    def initialize(event_data, config)
      @config = config || {}
      @event_data = event_data
      @context = {}
      @environment = {}
      @data = {}
      @backtrace_filters = config[:backtrace_filters] || []

      # Actually serialize the exception/event hash for transport
      @event = serialize_event(event_data)

      add_environment_data(:system => SystemInformation.to_hash)
      add_context(:stage => config.stage)
    end

    def deliver
      if reporter.notify(self.body)
        reporter.result
      end
    end

    def reporter
      CrashLog.reporter
    end

    attr_reader :event, :backtrace, :exception_object, :environment, :context

    def body
      renderer.render
    end

    def add_context(data)
      (@context ||= {}).merge!(data) if data.is_a?(Hash)
    end

    def add_data(data)
      (@data ||= {}).merge!(data) if data.is_a?(Hash)
    end

    def add_session_data(data)
      (@data[:session] ||= {}).merge!(data) if data.is_a?(Hash)
    end

    def add_environment_data(data)
      @environment.merge!(data) if data.respond_to?(:keys)
    end

    # The canonical time this exception occurred.
    #
    # Other notifiers leave this to the collector to set, we however take time
    # more seriously and use this figure internally to detect processing time
    # irregularities.
    #
    # Returns UNIX UTC timestamp integer.
    def timestamp
      Time.now.utc.to_i
    end

    # Various meta data about this notifier gem
    def notifier
      {
        :name => "crashlog",
        :version => CrashLog::VERSION
      }
    end

  private

    def serialize_event(event_data)
      if event_data.is_a?(Exception)
        @backtrace = build_backtrace(event_data)
        serialize_exception(event_data)

      elsif event_data.is_a?(Hash)
        event_data.merge(:timestamp => timestamp)

      elsif event_data.respond_to?(:message) && event_data.respond_to?(:type)
        ducktype_event(event_data)

      end
    end

    def ducktype_event(event_data)
      {}.tap do |response|
        response[:timestamp] = timestamp
        response[:type] = event_data.type
        response[:message] = event_data.message
      end
    end

    def serialize_exception(exception)
      exception = unwrap_exception(exception)
      # opts = opts.merge(:exception => exception) if exception.is_a?(Exception)
      # opts = opts.merge(exception.to_hash) if exception.respond_to?(:to_hash)

      {}.tap do |response|
        response[:timestamp] = timestamp
        response[:message] = exception.message
        response[:type] = error_class(exception)
      end
    end

    def build_backtrace(exception)
      Backtrace.parse((exception.backtrace || caller),
                      :filters => @backtrace_filters).to_a
    end

    def error_class(exception)
      # The "Class" check is for some strange exceptions like Timeout::Error
      # which throw the error class instead of an instance
      (exception.is_a? Class) ? exception.name : exception.class.name
    end

    def unwrap_exception(exception)
      if exception.respond_to?(:original_exception)
        exception.original_exception
      elsif exception.respond_to?(:continued_exception)
        exception.continued_exception
      else
        exception
      end
    end

    def renderer
      Rabl::Renderer.new('payload', self, { :format => 'hash', :view_path => view_path })
    end

    def view_path
      File.expand_path('../templates', __FILE__)
    end
  end
end
