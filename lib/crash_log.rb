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

  autoload :Reporter,       'crash_log/reporter'
  autoload :Configuration,  'crash_log/configuration'
  autoload :Payload,        'crash_log/payload'
  autoload :Backtrace,      'crash_log/backtrace'

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
    #     CrashLog.notify(e, current_user)
    #   end
    #
    #   This will try to serialize the current user by calling `as_json`
    #   otherwise it will try `to_s`
    #
    # Returns true if successful, otherwise false
    def notify(exception, user_data = {})
      send_notification(exception, user_data)
    end

    # Print a message at the top of the applciation's logs to say we're ready.
    def report_for_duty!
      info('Initialized and ready to handle exceptions')
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

    def live?
      configuration.release_stage?
    end

  private

    def send_notification(exception, user_data = {})
      build_payload(exception, user_data).deliver! if live?
    end

    def build_payload(exception, user_data = {})
      Payload.build(exception, configuration) do |payload|
        payload.add_user_data(user_data)
      end
    end
  end
end
