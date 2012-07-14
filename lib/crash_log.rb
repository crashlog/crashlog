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
  autoload :Rails,              'crash_log/rails'
  autoload :Reporter,           'crash_log/reporter'
  autoload :SystemInformation,  'crash_log/system_information'

  LOG_PREFIX = '** [CrashLog]'

  class << self

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
    #   This will try to serialize the current user by calling `as_json`
    #   otherwise it will try `to_s`
    #
    # Returns true if successful, otherwise false
    def notify(exception, context = {})
      send_notification(exception, context)
    end

    # Sends the notice unless it is one of the default ignored exceptions.
    def notify_or_ignore(exception, context = {})
      send_notification(exception, context = {}) unless ignored?(exception)
    end

    # Print a message at the top of the applciation's logs to say we're ready.
    def report_for_duty!
      application = CrashLog::Reporter.new(configuration).announce

      if application
        info("Initialized and ready to handle exceptions for #{application}")
      else
        error("Failed to report for duty, it is possible we are having issues or your application is not configured correctly")
      end
    end

    # Configure the gem to send notifications, at the very least an api_key is
    # required.
    def configure
      yield(configuration) if block_given?
      if configuration.valid?
        report_for_duty!
      else
        error('Not configured correctly')
      end
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
      build_payload(exception, context).deliver! if live?
    end

    def build_payload(exception, context = {})
      Payload.build(exception, configuration) do |payload|
        payload.add_context(context)
      end
    end
  end
end
