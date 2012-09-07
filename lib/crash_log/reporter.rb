require 'faraday'
require 'faraday/request/hmac_authentication'
require 'uuid'
require 'yajl'

module CrashLog
  class Reporter
    include Logging

    attr_reader :host, :port, :scheme, :endpoint, :announce_endpoint
    attr_reader :result, :config, :response

    def initialize(config)
      @config     = config
      @scheme     = config.scheme
      @host       = config.host
      @port       = config.port
      @endpoint   = config.endpoint
      @announce_endpoint = config.announce == true ?
                           config.announce_endpoint : nil
    end

    def notify(payload)
      # return if dry_run?
      MultiJson.use(:yajl)
      response = post(endpoint, MultiJson.encode({:payload => payload}))
      @response = response
      report_result(response.body)
      response.success?
    rescue => e
      log_exception e
      error("Sending exception failed due to a connectivity issue")
    end

    def announce
      return if dry_run?
      return "Unknown application" unless announce_endpoint

      response = post(config.announce_endpoint, JSON.dump(identification_hash))
      if response.status == 201
        info(JSON.load(response.body).inspect)
        JSON.load(response.body).symbolize_keys.fetch(:application_name, 'Default')
      else
        false
      end
    rescue => e
      # We only want to log our mess when testing
      # log_exception(e) # if respond_to?(:should)
      error("Failed to announce application launch")
      nil
    end

    def report_result(body)
      @result = JSON.load(body).symbolize_keys
      info @result.inspect
    end

    def url
      URI.parse("#{scheme}://#{host}:#{port}")
    end

    def identification_hash
      {
        :hostname => SystemInformation.hostname,
        :timestamp => Time.now.utc.to_i
      }
    end

    def print_result

    end

    def dry_run?
      config.dry_run == true
    end

    def post(endpoint, body)
      connection.post do |req|
        req.url(endpoint)
        req.headers['Content-Type'] = 'application/json'
        req.body = body
      end
    end

#  private

    def connection
      @connection ||= begin
        Faraday.new(:url => url) do |faraday|
          faraday.request :hmac_authentication, config.api_key, config.secret, {:service_id => config.service_name}
          faraday.adapter(adapter)
          faraday.request :url_encoded
          # faraday.request                 :token_auth, config.api_key
          # faraday.response                :logger
          # faraday.options[:timeout]       = config.http_read_timeout
          # faraday.options[:open_timeout]  = config.http_open_timeout
          # faraday.ssl[:verify]            = false
        end
      end
    end

    def adapter
      config.adapter
    end
  end
end
