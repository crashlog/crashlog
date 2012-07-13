require "faraday"
require "uuid"
require "json"

module CrashLog
  class Reporter
    include Logging

    attr_reader :url, :endpoint
    attr_reader :result

    def initialize
      @url = "http://crashlog.io"
      @endpoint = '/notify'
    end

    def notify(payload)
      response = connection.post(endpoint, JSON.dump(payload))
      report_result(response.body)
      response.success?
    rescue => e
      error("Sending exception failed due to a connectivity issue")
    end

    def report_result(body)
      @result = JSON.load(body).symbolize_keys
    end

  private

    def connection
      @connection ||= Faraday.new(:url => url) do |faraday|
        faraday.adapter  Faraday.default_adapter
        faraday.request :url_encoded
        faraday.request :token_authentication
        faraday.response :logger
      end
    end
  end
end
