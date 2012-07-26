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

    attr_reader :config, :backtrace_filters

    def initialize(exception, config)
      @config = config || {}
      @exception_object = exception
      @context = {}
      @session = {}
      @environment = {}
      @backtrace_filters = config[:backtrace_filters] || []

      # Actually serialize the exception for transport
      @exception = serialize_exception(exception_object)
      add_environment_data(:system => SystemInformation.to_hash)
    end

    def deliver
      Reporter.new(config).notify(self.body)
    end

    attr_reader :exception, :exception_object, :environment, :context, :session

    def body
      renderer.render
    end

    def add_context(data)
      (@context ||= {}).merge!(data) if data.is_a?(Hash)
    end

    def add_user_data(data, value = nil)
      if data.respond_to?(:keys)
        @user_data.merge!(data)
      elsif value && data.respond_to?(:to_sym)
        @user_data[data.to_sym] = value
      end
    end

    def add_session_data(data)
      @session.merge!(data) if data.respond_to?(:keys)
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
    # Returns UNIX timestamp integer.
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

    # Returns the hostname of this machine
    def hostname
      SystemInformation.hostname
    end

  private

    def serialize_exception(exception)
      exception = unwrap_exception(exception)
      # opts = opts.merge(:exception => exception) if exception.is_a?(Exception)
      # opts = opts.merge(exception.to_hash) if exception.respond_to?(:to_hash)

      {}.tap do |response|
        response[:timestamp] = timestamp
        response[:message] = exception.message
        response[:class_name] = error_class(exception)
        response[:backtrace] = build_backtrace(exception)
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
