module CrashLog
  module Rails
    module ControllerMethods

      def crash_log_context
        { :parameters       => crash_log_filter_if_filtering(params.to_hash),
          :session_data     => crash_log_filter_if_filtering(crash_log_session_data),
          :controller       => params[:controller],
          :action           => params[:action],
          :url              => crash_log_request_url,
          :cgi_data         => crash_log_filter_if_filtering(request.env)
        }
      end

    private
      def notify_crashlog(exception, custom_data = nil)
        request_data = crash_log_context
        #request_data[:meta_data][:custom] = custom_data if custom_data
        CrashLog.notify(exception, request_data)
      end

      alias_method :notify_airbrake, :notify_crashlog

      def crash_log_session_data
        if session.respond_to?(:to_hash)
          session.to_hash
        else
          session.data
        end
      end

      def crash_log_request_url
        url = "#{request.protocol}#{request.host}"

        unless [80, 443].include?(request.port)
          url << ":#{request.port}"
        end

        url << request.fullpath
        url
      end

    end
  end
end
