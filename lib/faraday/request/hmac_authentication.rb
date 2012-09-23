module Faraday
  class Request

    require 'crash_log/auth_hmac'
    require 'uri'

    attr_reader :access_id, :secret

    # # Sign the request with the specified `access_id` and `secret`.
    # def sign!(access_id, secret)
    #   @access_id, @secret = access_id, secret

    #   #self.sign_with = access_id
    #   #CrashLog::AuthHMAC.keys[access_id] = secret
    # end

    class HMACAuthentication < Faraday::Middleware
      # Modified CanonicalString to know how to pull from the Faraday-specific
      # env hash.
      class CanonicalString < CrashLog::AuthHMAC::CanonicalString
        def request_method(request)
          request[:method].to_s.upcase
        end

        def request_body(request)
          request[:body]
        end

        def request_path(request)
          URI.parse(request[:url].to_s).path
        end

        def headers(request)
          request[:request_headers]
        end
      end

      KEY = "Authorization".freeze

      attr_reader :auth, :token, :secret

      def initialize(app, token, secret, options = {})
        options.merge!(:signature => HMACAuthentication::CanonicalString)
        keys = {token => secret}
        @token, @secret = token, secret
        @auth = CrashLog::AuthHMAC.new(keys, options)
        super(app)
      end

      # Public
      def call(env)
        env[:request_headers][KEY] ||= hmac_auth_header(env).to_s if sign_request?
        @app.call(env)
      end

      def hmac_auth_header(env)
        auth.authorization(env, token, secret)
      end

      def sign_request?
        !!@token && !!@secret
      end
    end
  end

  Faraday.register_middleware :request, :hmac_authentication => Faraday::Request::HMACAuthentication
end

