module CrashLog
  module Rails
    module ControllerMethods

      def crash_log_context
        {
          :context => {
            :controller       => params[:controller],
            :action           => params[:action],
            :current_user     => crash_log_current_user
          },
          :parameters       => crash_log_filter_if_filtering(params.to_hash),
          :session_data     => crash_log_filter_if_filtering(crash_log_session_data),
          :url              => crash_log_request_url,
          :cgi_data         => crash_log_filter_if_filtering(request.env),
        }
      end

    private

      def notify_crashlog(exception, custom_data = nil)
        request_data = crash_log_context
        request_data[:custom] = custom_data if custom_data
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

      def crash_log_current_user
        user = begin current_user rescue current_member end
        user.attributes.select do |k, v|
          CrashLog.configuration.
            user_attributes.map(&:to_sym).
            include?(k.to_sym) unless v.blank?
        end.symbolize_keys
      rescue NoMethodError, NameError
        {}
      end

    end
  end
end
