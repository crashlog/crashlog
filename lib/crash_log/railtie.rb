# Rails 3.x support
module CrashLog
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "crash_log/tasks/crash_log.rake"
    end

    config.before_initialize do
      require File.expand_path('../../crash_log', __FILE__)

      CrashLog.configure do |config|
        config.stage            = ::Rails.env
        config.project_root     = ::Rails.root
        config.framework        = "Rails: #{::Rails::VERSION::STRING}"
      end
    end

    config.after_initialize do
      CrashLog.configure(true) do |config|
        config.params_filters   += ::Rails.application.config.filter_parameters
        config.logger            = ::Rails.logger
      end

      # Attach our Rails Controller methods
      if defined?(::ActionController::Metal)
        require "crash_log/rails/controller_methods"
        ::ActionController::Base.send(:include, CrashLog::Rails::ControllerMethods)
      end

      if defined?(::ActionDispatch::DebugExceptions)
        # We should catch the exceptions in ActionDispatch::DebugExceptions in Rails 3.2.x.
        require 'crash_log/rails/middleware/debug_exception_catcher'
        ::ActionDispatch::DebugExceptions.__send__(:include, CrashLog::Rails::Middleware::DebugExceptionCatcher)
      elsif defined?(::ActionDispatch::ShowExceptions)


        # ActionDispatch::DebugExceptions is not defined in Rails 3.0.x and 3.1.x so
        # catch the exceptions in ShowExceptions.
        require 'crash_log/rails/middleware/debug_exception_catcher'
        ::ActionDispatch::ShowExceptions.__send__(:include, CrashLog::Rails::Middleware::DebugExceptionCatcher)
      end
    end

    initializer "crash_log.use_rack_middleware" do |app|
      begin
        app.config.middleware.insert_after ActionDispatch::DebugExceptions, "CrashLog::Rack"
      rescue
        app.config.middleware.use "CrashLog::Rack"
      end
    end

  end
end
