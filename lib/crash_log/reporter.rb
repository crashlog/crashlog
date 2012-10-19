require 'faraday'
require File.expand_path('../../faraday/request/hmac_authentication', __FILE__)
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

      payload[:data] = CrashLog::Helpers.cleanup_obj(payload[:data])
      payload_string = MultiJson.encode({:payload => payload})

      # Useful to make sure we're successfully capturing the right data
      debug(payload.inspect) if config.development_mode?

      response = post(endpoint, payload_string)
      @response = response
      report_result(response.body)
      response.success?
    rescue => e
      error("Sending exception failed due to a connectivity issue")
      raise if config.development_mode?
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
      raise if config.development_mode?
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
        :timestamp => Time.now.utc.to_i,
        :stage => config.stage,
        :notifier => {
          :name => "crashlog",
          :version => CrashLog::VERSION,
          :language => 'Ruby'
        }
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

          if config.secure?
            faraday.ssl[:verify]            = true
            faraday.ssl[:ca_path] = config.ca_bundle_path
          end
        end
      end
    end

    def adapter
      config.adapter
    end
  end
end
