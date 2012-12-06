require 'faraday'
require 'multi_json'
require 'time'

require File.expand_path('../core_ext/kernel/require_relative', __FILE__)

require_relative 'core_ext/hash/keys'
require_relative 'crash_log/version'
require_relative 'crash_log/logging'
require_relative 'crash_log/helpers'
require_relative 'crash_log/backtrace'
require_relative 'crash_log/configuration'
require_relative 'crash_log/payload'
require_relative 'crash_log/reporter'
require_relative 'crash_log/system_information'
require_relative 'crash_log/rack'

require_relative "crash_log/sidekiq" if defined?(Sidekiq)

module CrashLog
  extend Logging::ClassMethods

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
    #     CrashLog.notify(e, {context: {current_user: current_user}})
    #   end
    #
    # Returns true if successful, otherwise false
    def notify(exception, data = {})
      send_notification(exception, data).tap do |notification|
        if notification
          info "Event sent to CrashLog.io"
          if notification.has_key?(:location_id)
            info "Event URL: http://crashlog.io/locate/#{notification[:location_id]}"
          else
            error "No Event location ID returned. There may have been a problem processing this Event"
          end
        else
          error "Failed to send event to CrashLog.io"
          log_exception(exception)
        end
      end
    end

    # Sends the notice unless it is one of the default ignored exceptions.
    def notify_or_ignore(exception, context = {})
      notify(exception, context) unless ignored?(exception)
    end

    # Print a message at the top of the applciation's logs to say we're ready.
    def report_for_duty!
      application = reporter.announce

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

        if live?
          self.reporter = CrashLog::Reporter.new(configuration)

          if configuration.valid?
            if announce.eql?(true)
              report_for_duty!
            else
              debug("Configuration updated successfully")
            end
          elsif !configuration.invalid_keys.include?(:api_key)
            error("Not configured correctly. Missing the following keys: #{configuration.invalid_keys.join(', ')}")
          end
        end
      end
      configuration
    end

    # The global configuration object.
    def configuration
      @configuration ||= Configuration.new
    end

    def reset_configuration!
      @configuration = Configuration.new
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

# Require this last to resolve an issue with Rails apps that use Bundler.setup
# instead of Bundler.require which results in the CrashLog module not being made
# available in time. FIXES: https://github.com/crashlog/crashlog/issues/7
require_relative 'crash_log/railtie' if defined?(Rails::Railtie)
