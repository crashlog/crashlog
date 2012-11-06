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

      if MultiJson.respond_to?(:use)
        MultiJson.use(config.json_parser || MultiJson.default_adapter)
      elsif MultiJson.respond_to?(:engine=)
        MultiJson.engine = (config.json_parser || MultiJson.default_engine)
      end
    end

    def notify(payload)
      return if dry_run?

      # TODO: Move this to Payload.
      payload[:data] = CrashLog::Helpers.cleanup_obj(payload[:data])
      payload_string = encode({:payload => payload})

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

      response = post(config.announce_endpoint, encode({:payload => identification_hash}))
      if response.status == 201
        decode(response.body).symbolize_keys.fetch(:application_name, 'Default')
      else
        nil
      end
    rescue => e
      error("Failed to announce application launch")
      raise if config.development_mode?
      nil
    end

    def report_result(body)
      @result = decode(body).symbolize_keys
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
          # faraday.response :logger

          if config.secure?
            faraday.ssl[:verify]        = true
            faraday.ssl[:verify_mode]   = OpenSSL::SSL::VERIFY_PEER
            faraday.ssl[:ca_path]       = config.ca_bundle_path
          end
        end
      end
    end

    def adapter
      config.adapter
    end

    # FIXME: This is some seriously annoying shit.
    # MultiJson should not have deprecated its old API and we wouldn't need
    # to do this.
    def encode(object)
      if MultiJson.respond_to?(:dump)
        # MultiJson >= 1.3
        MultiJson.dump(object)
      elsif MultiJson.respond_to?(:encode)
        # MultiJson < 1.3
        MultiJson.encode(object)
      end
    end

    def decode(string, options = {})
      if MultiJson.respond_to?(:load)
        # MultiJson >= 1.3
        MultiJson.load(string, options)
      elsif MultiJson.respond_to?(:decode)
        # MultiJson < 1.3
        MultiJson.decode(string, options)
      end
    end
  end
end
