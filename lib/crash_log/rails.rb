require "crash_log"
require "crash_log/rails/controller_methods"
require "crash_log/rails/action_controller_rescue"

# Rails 2.x support
module CrashLog
  module Rails
    def self.initialize
      if defined?(ActionController::Base)
        ActionController::Base.send(:include, CrashLog::Rails::ActionControllerRescue)
        ActionController::Base.send(:include, CrashLog::Rails::ControllerMethods)
      end

      # Try to find where to log to
      rails_logger = nil
      if defined?(::Rails.logger)
        rails_logger = ::Rails.logger
      elsif defined?(RAILS_DEFAULT_LOGGER)
        rails_logger = RAILS_DEFAULT_LOGGER
      end

      CrashLog.configure do |config|
        config.logger = rails_logger
        config.stage = RAILS_ENV  if defined?(RAILS_ENV)
        config.project_root = RAILS_ROOT if defined?(RAILS_ROOT)
        config.framework = "Rails: #{::Rails::VERSION::STRING}" if defined?(::Rails::VERSION)
      end
    end
  end
end

CrashLog::Rails.initialize
