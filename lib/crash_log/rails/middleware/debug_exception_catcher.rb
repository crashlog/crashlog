module CrashLog
  module Rails
    module Middleware
      module DebugExceptionCatcher

        def self.included(base)
          base.send(:alias_method_chain, :render_exception, :crash_log)
        end

        # Hook into the rails error rendering page to send this exception to
        # CrashLog before rails handlers take over.
        def render_exception_with_crash_log(env, exception)
          begin
            controller = env['action_controller.instance']
            CrashLog.notify_or_ignore(exception, crash_log_context(controller, env))

            if defined?(controller.rescue_action_in_public_without_crash_log)
              controller.rescue_action_in_public_without_crash_log(exception)
            end

          rescue Exception => e
            # If it breaks here there is possibly something wrong with us, so
            # instead of crashing again, we'll just pass it on.
          end
          render_exception_without_crash_log(env, exception)
        end

      private

        def crash_log_context(controller, env)
          if controller.respond_to?(:crash_log_context)
            controller.crash_log_context
          else
            {:rack_env => env}
          end

        rescue => e
          {:failed_context => true}
        end

      end
    end
  end
end
