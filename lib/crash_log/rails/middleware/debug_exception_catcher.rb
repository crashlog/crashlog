module CrashLog
  module Rails
    module Middleware
      module DebugExceptionCatcher

        def self.included(base)
          base.send(:alias_method_chain, :render_exception, :crash_log)
        end

        # Hook into the rails error rendering page to send this exception to
        # CrashLog before rails handlers take over.
        def render_exception_with_crash_log(env,exception)
          controller = env['action_controller.instance']
          env['crash_log.error_id'] = CrashLog.notify(exception, user_context(controller, env))

          if defined?(controller.rescue_action_in_public_without_crash_log)
            controller.rescue_action_in_public_without_crash_log(exception)
          end

          render_exception_without_crash_log(env, exception)
        end

      private

        def user_context(controller, env)
          # TODO: Replace this with user context lookup
          controller.try(:crash_log_request_data) || {:rack_env => env}
        end

      end
    end
  end
end
