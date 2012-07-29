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
          controller = env['action_controller.instance']

          begin
            env['crash_log.error_id'] = CrashLog.notify(exception,
                                                        crash_log_context(controller, env))
          rescue Exception => e
            # Fail silently, we don't want to be responsible for more issues
          end

          if defined?(controller.rescue_action_in_public_without_crash_log)
            controller.rescue_action_in_public_without_crash_log(exception)
          end

          render_exception_without_crash_log(env, exception)
        end

      private

        def crash_log_context(controller, env)
          # TODO: Replace this with user context lookup
          if controller.respond_to?(:crash_log_request_data)
            controller.crash_log_request_data
          else
            {:rack_env => env}
          end
        end

      end
    end
  end
end
