module CrashLog
  # CrashLog Middleware for Rack applications. Any errors raised by the upstream
  # application will be delivered to CrashLog and re-raised.
  #
  # Synopsis:
  #
  #   require 'rack'
  #   require 'crashlog'
  #
  #   CrashLog.configure do |config|
  #     config.api_key = 'project-api-key'
  #   end
  #
  #   app = Rack::Builder.app do
  #     run lambda { |env| raise "Fully Racked" }
  #   end
  #
  #   use CrashLog::Rack
  #   run app
  #
  # Use a standard CrashLog.configure call to configure your api key.

  class Rack
    def initialize(app)
      @app = app
      CrashLog.configuration.logger ||= Logger.new($stdout)
    end

    def call(env)
      begin
        response = @app.call(env)
      rescue Exception => exception
        error_id = CrashLog.notify(exception, :rack_env => env)
        env['crash_log.error_id'] = error_id
        raise
      end

      if env['rack.exception']
        error_id = CrashLog.notify(env['rack.exception'], :rack_env => env)
        env['crash_log.error_id'] = error_id
      end

      response
    end
  end
end

