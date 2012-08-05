require 'crash_log'
require 'rails'

# Rails 3.x support
module CrashLog
  class Railtie < ::Rails::Railtie

    config.after_initialize do
      CrashLog.configure do |config|
        config.logger           ||= ::Rails.logger
        config.stage            ||= ::Rails.env
        config.project_root     ||= ::Rails.root
        config.framework        = "Rails: #{::Rails::VERSION::STRING}"
      end

      initializer "crash_log.use_rack_middleware" do |app|
        app.config.middleware.insert 0, "CrashLog::Rack"
      end

      # Attach our Rails Controller methods
      ActiveSupport.on_load(:action_controller) do
        # Lazily load action_controller methods
        require 'crash_log/rails/controller_methods'

        include CrashLog::Rails::ControllerMethods
      end

      if defined?(::ActionDispatch::DebugExceptions)
        # We should catch the exceptions in ActionDispatch::DebugExceptions in Rails 3.2.x.
        require 'crash_log/rails/middleware/debug_exception_catcher'
        ::ActionDispatch::DebugExceptions.__send__(:include, CrashLog::Rails::Middleware::DebugExceptionCatcher)
      elsif defined?(::ActionDispatch::ShowExceptions)

        # ActionDispatch::DebugExceptions is not defined in Rails 3.0.x and 3.1.x so
        # catch the exceptions in ShowExceptions.
        require 'crash_log/rails/middleware/debug_exception_catcher'
        ::ActionDispatch::ShowExceptions.send(:include, CrashLog::Rails::Middleware::DebugExceptionCatcher)
      end
    end
  end
end
