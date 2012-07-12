require 'crash_log'
require 'rails'

module CrashLog
  class Railtie < ::Rails::Railtie

    config.after_initialize do
      CrashLog.configure do |config|
        config.logger           ||= ::Rails.logger
        config.environment_name ||= ::Rails.env
        config.project_root     ||= ::Rails.root
        config.framework        = "Rails: #{::Rails::VERSION::STRING}"
      end
    end

  end
end
