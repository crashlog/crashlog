module CrashLog
  module Rails
    module ControllerMethods

      # def crash_log_context_old(env = nil)
      #   {
      #     :context => {
      #       :controller       => params[:controller],
      #       :action           => params[:action],
      #       :current_user     => crash_log_current_user
      #     },
      #     :request          => process_headers(request.env),
      #     :response         => process_response,
      #     :parameters       => crash_log_filter_if_filtering(params.to_hash),
      #     :session_data     => crash_log_filter_if_filtering(crash_log_session_data),
      #     :url              => crash_log_request_url,
      #     :cgi_data         => crash_log_filter_if_filtering(request.env),
      #   }
      # end

      def crash_log_context
        payload = {}

        payload[:request]   = process_request(request.env)
        payload[:response]  = process_response
        payload[:user]      = crash_log_current_user
        payload[:context]   = process_context

        payload
      end

    private

      def notify_crashlog(exception, custom_data = nil)
        request_data = crash_log_context
        request_data[:custom] = custom_data if custom_data
        CrashLog.notify(exception, request_data)
      end

      def crash_log_session_data
        if session.respond_to?(:to_hash)
          session.to_hash
        else
          session.data
        end
      end

      def process_response
        response = {}

        if self.respond_to?(:response) && self.response.respond_to?(:headers)
          response.merge!({:headers => self.response.headers})
        end

        response
      end

      def process_request(env)
        headers, environment = {}, {}
        data = nil
        env.each_pair do |key, value|
          next unless key.upcase == key # Non-upper case stuff isn't a header
          if key.start_with?('HTTP_')
            # Header
            http_key = key[5..key.length-1].split('_').map{|s| s.capitalize}.join('-')
            headers[http_key] = value.to_s
          else
            # Environment
            environment[key] = value.to_s
          end
        end

        require 'rack'
        req = ::Rack::Request.new(env)
        query_string = req.query_string
        method = req.request_method
        url = req.url.split('?').first
        cookies = req.cookies

        data = if req.form_data?
          req.POST
        elsif req.body
          data = req.body.read
          req.body.rewind
          data
        end

        {
          :url => url,
          :query_string => query_string,
          :method => method,
          :headers => headers,
          :cookies => cookies,
          :parameters => crash_log_filter_if_filtering(params.to_hash),
          :environment => environment,
          :session => crash_log_filter_if_filtering(crash_log_session_data),
          :data => data
        }
      end

      def process_context
        {
          :controller => params[:controller],
          :action     => params[:action]
        }

      rescue NoMethodError
        {}
      end

      def crash_log_request_url
        url = "#{request.protocol}#{request.host}"

        unless [80, 443].include?(request.port)
          url << ":#{request.port}"
        end

        url << request.fullpath
        url
      end

      def crash_log_filter_if_filtering(hash)
        return hash if !hash.is_a?(Hash)

        if respond_to?(:filter_parameters) # Rails 2
          filter_parameters(hash)
        elsif defined?(ActionDispatch::Http::ParameterFilter) # Rails 3
          ActionDispatch::Http::ParameterFilter.new(::Rails.application.config.filter_parameters).filter(hash)
        else
          hash
        end rescue hash
      end

      def crash_log_current_user
        user_hash = {}
        user_attributes = CrashLog.configuration.user_attributes
        user = begin current_user rescue current_member end

        user_attributes.map(&:to_sym).each do |attribute|
          if user.respond_to?(attribute)
            if attribute.to_sym == :id
              user_hash[:user_id] = user.__send__(attribute)
            else
              user_hash[attribute] = user.__send__(attribute)
            end
          end
        end

        user_hash
      rescue NoMethodError, NameError
        {}
      end

    end
  end
end
