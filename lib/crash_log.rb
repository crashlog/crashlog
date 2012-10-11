$: << File.expand_path('..', __FILE__)

require 'crash_log/version'
begin
  require 'active_support'
  require 'active_support/core_ext'
rescue LoadError
  require 'activesupport'
  require 'activesupport/core_ext'
end
require 'faraday'
require 'crash_log/railtie' if defined?(Rails::Railtie)

require 'crash_log/logging'

module CrashLog
  extend Logging::ClassMethods

  autoload :Backtrace,          'crash_log/backtrace'
  autoload :Configuration,      'crash_log/configuration'
  autoload :Payload,            'crash_log/payload'
  autoload :Rack,               'crash_log/rack'
  autoload :Reporter,           'crash_log/reporter'
  autoload :SystemInformation,  'crash_log/system_information'

  LOG_PREFIX = '** [CrashLog]'

  class << self
    attr_accessor :reporter

    # Sends a notification to CrashLog
    #
    # This is the main entry point into the exception sending stack.
    #
    # Examples:
    #
    #   def something_dangerous
    #     raise RuntimeError, "This is too dangerous for you"
    #   rescue => e
    #     CrashLog.notify(e)
    #   end
    #
    #   You can also include information about the current user and Crashlog
    #   will allow you to correlate errors by affected users:
    #
    #   def something_dangerous
    #     raise RuntimeError, "This is too dangerous for you"
    #   rescue => e
    #     CrashLog.notify(e, {current_user: current_user})
    #   end
    #
    # Returns true if successful, otherwise false
    def notify(exception, data = {})
      send_notification(exception, data).tap do |notification|
        if notification
          info "Event sent to CrashLog.io"
          info "Event URL: http://crashlog.io/locate/#{notification[:location_id]}" if notification.has_key?(:location_id)
        else
          error "Failed to send event to CrashLog.io"
          log_exception(exception)
        end
      end
    end

    # Sends the notice unless it is one of the default ignored exceptions.
    def notify_or_ignore(exception, context = {})
      notify(exception, context = {}) unless ignored?(exception)
    end

    # Print a message at the top of the applciation's logs to say we're ready.
    def report_for_duty!
      application = CrashLog::Reporter.new(configuration).announce

      if application
        info("Configured correctly and ready to handle exceptions for '#{application}'")
      else
        error("Failed to report for duty, your application failed to authenticate correctly with stdin.crashlog.io")
      end
    end

    # Configure the gem to send notifications, at the very least an api_key is
    # required.
    def configure(announce = false, &block)
      if block_given?
        yield(configuration)

        self.reporter = CrashLog::Reporter.new(configuration)

        if configuration.valid?
          if announce.eql?(true)
            report_for_duty!
          else
            info("Configuration updated")
          end
        elsif !configuration.invalid_keys.include?(:api_key)
          error("Not configured correctly. Missing the following keys: #{configuration.invalid_keys.join(', ')}")
        end
      end
      configuration
    end

    # The global configuration object.
    def configuration
      @configuration ||= Configuration.new
    end

    # The default logging device.
    def logger
      self.configuration.logger || Logger.new($stdout)
    end

    # Is the logger live
    #
    # Returns true if the current stage is included in the release
    # stages config, false otherwise.
    def live?
      configuration.release_stage?
    end

    # Looks up ignored exceptions
    #
    # Returns true if this exception should be ignored, false otherwise.
    def ignored?(exception)
      configuration.ignored?(exception)
    end

  private

    def send_notification(exception, context = {})
      if live?
        build_payload(exception, context).deliver!
      end
    end

    def build_payload(exception, data = {})
      Payload.build(exception, configuration) do |payload|
        if context = data.delete(:context)
          payload.add_context(context)
        end
        payload.add_data(data)
      end
    end
  end
end
