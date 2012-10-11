module CrashLog
  module Rails

    # CrashLog Rails 2.x controller integration
    # Aliases method chain for Rails internal rescue action
    module ActionControllerRescue
      def self.included(base)
        base.send(:alias_method, :rescue_action_in_public_without_crash_log, :rescue_action_in_public)
        base.send(:alias_method, :rescue_action_in_public, :rescue_action_in_public_with_crash_log)

        base.send(:alias_method, :rescue_action_locally_without_crash_log, :rescue_action_locally)
        base.send(:alias_method, :rescue_action_locally, :rescue_action_locally_with_crash_log)
      end

    private

      # crash_log_context is defined in controller_methods.rb
      def rescue_action_in_public_with_crash_log(exception)
        CrashLog.notify_or_ignore(exception, crash_log_context)
      ensure
        rescue_action_in_public_without_crash_log(exception)
      end

      # crash_log_context is defined in controller_methods.rb
      def rescue_action_locally_with_crash_log(exception)
        CrashLog.notify_or_ignore(exception, crash_log_context)
      ensure
        rescue_action_locally_without_crash_log(exception)
      end
    end
  end

end

