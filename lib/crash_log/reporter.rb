require 'faraday'
require 'faraday/request/hmac_authentication'
require 'uuid'
require 'multi_json'

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

      # Old versions of MultiJson don't support use.
      # TODO: Figure out what they do support. IV.
      if MultiJson.respond_to?(:use)
        MultiJson.use(config.json_parser || MultiJson.default_adapter)
      end
    end

    def notify(payload)
      return if dry_run?

      response = post(endpoint, MultiJson.encode({:payload => payload}))
      @response = response
      report_result(response.body)
      response.success?
    rescue => e
      # log_exception e
      error("Sending exception failed due to a connectivity issue")
      nil
    end

    def announce
      return if dry_run?
      return "Unknown application" unless announce_endpoint

      response = post(config.announce_endpoint, MultiJson.encode({:payload => identification_hash}))
      if response.status == 201
        MultiJson.load(response.body).symbolize_keys.fetch(:application_name, 'Default')
      else
        nil
      end
    rescue => e
      error("Failed to announce application launch")
      nil
    end

    def report_result(body)
      @result = MultiJson.load(body).symbolize_keys
    end

    def url
      URI.parse("#{scheme}://#{host}:#{port}").to_s
    end

    def identification_hash
      {
        :hostname => SystemInformation.hostname,
        :timestamp => Time.now.utc.to_i
      }
    end

    def dry_run?
      config.dry_run == true
    end

    def post(endpoint, body)
      connection.post do |req|
        req.url(endpoint)
        req.headers['Content-Type'] = 'application/json; charset=UTF-8'
        req.options[:timeout]       = config.http_read_timeout
        req.options[:open_timeout]  = config.http_open_timeout
        req.body                    = body
      end
    end

    def connection
      @connection ||= begin
        Faraday.new(:url => url) do |faraday|
          faraday.request :hmac_authentication, config.api_key, config.secret, {:service_id => config.service_name}
          faraday.adapter(adapter)
          faraday.request :url_encoded
          # faraday.response                :logger
          # faraday.ssl[:verify]            = false
        end
      end
    end

    def adapter
      config.adapter
    end
  end
end
