require "faraday"
require "uuid"
require "json"

module CrashLog
  class Reporter
    include Logging

    attr_reader :host, :port, :scheme, :endpoint, :announce_endpoint
    attr_reader :result, :config

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
      response = connection.post(endpoint, JSON.dump(payload))
      report_result(response.body)
      response.success?
    rescue => e
      error("Sending exception failed due to a connectivity issue")
    end

    def announce
      return "Unknown application" unless announce_endpoint

      response = connection.post('/announce', JSON.dump(identification_hash))
      JSON.load(response.body).symbolize_keys[:application]
    rescue => e
      # We only want to log our mess when testing
      log_exception(e) if respond_to?(:should)
      error("Failed to announce application launch")
      nil
    end

    def report_result(body)
      @result = JSON.load(body).symbolize_keys
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

  # private

    def connection
      @connection ||= Faraday.new(:url => url) do |faraday|
        faraday.adapter   Faraday.default_adapter
        faraday.request   :url_encoded
        faraday.response  :logger
        faraday.token_auth config.api_key
      end
    end
  end
end
