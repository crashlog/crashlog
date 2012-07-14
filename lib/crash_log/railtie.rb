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

      # Attach our Rails Controller methods
      ActiveSupport.on_load(:action_controller) do
        # Lazily load action_controller methods
        require 'crash_log/rails/controller_methods'

        include CrashLog::Rails::ControllerMethods
      end

    end

  end
end
