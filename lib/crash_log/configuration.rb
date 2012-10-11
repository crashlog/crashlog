require 'hashr'
module CrashLog
  class Configuration < Hashr
    DEFAULT_PARAMS_FILTERS = %w(password password_confirmation).freeze
    DEFAULT_USER_ATTRIBUTES = %w(id name full_name username email created_at).freeze

    DEFAULT_BACKTRACE_FILTERS = [
      lambda { |line|
        if defined?(CrashLog.configuration.root) &&
           CrashLog.configuration.root.to_s != ''
          line.sub(/#{CrashLog.configuration.root}/, "[PROJECT_ROOT]")
        else
          line
        end
      },
      lambda { |line| line.gsub(/^\.\//, "") },
      lambda { |line|
        if defined?(Gem)
          Gem.path.inject(line) do |line, path|
            line.gsub(/#{path}/, "[GEM_ROOT]")
          end
        end
      },
      lambda { |line| line if line !~ %r{lib/crash_log} }
    ].freeze

    IGNORE_DEFAULT = ['ActiveRecord::RecordNotFound',
                      'ActionController::RoutingError',
                      'ActionController::InvalidAuthenticityToken',
                      'CGI::Session::CookieStore::TamperedWithCookie',
                      'ActionController::UnknownAction',
                      'AbstractController::ActionNotFound',
                      'Mongoid::Errors::DocumentNotFound']


      # The logger to use for internal messages
    define :logger => nil,

      # The API key to authenticate this project with CrashLog
      #
      # Get this from your projects configuration page within http://CrashLog.io
      :api_key => nil,
      :secret => nil,

      # Stages (environments) which we consider to be in a production environment
      # and thus you want to be sent notifications for.
      :release_stages => ['staging', 'production'],

      # The name of the current stage
      :stage => 'production',

      # Project Root directory
      :project_root => nil,

      # If set, this will serialize the object returned by sending this key to
      # the controller context. You can use this to send user data CrashLog to
      # correlate errors with users to give you more advanced data about directly
      # who was affected.
      #
      # All user data is stored encrypted for security and always remains your
      # property.
      :user_context_key => nil,

      # Reporter configuration options
      #
      # Host to send exceptions to. Default: crashlog.io
      :host => 'stdin.crashlog.io',

      # Port to use for http connections. 80 or 443 by default.
      # :port => 443,

      # HTTP transfer scheme, default: https
      :scheme => 'https',

      # API endpoint to context for notifications. Default /events
      :endpoint => '/events',

      # The faraday adapter to use to make the connection.
      #
      # Possible values are:
      # - :test
      # - :net_http
      # - :net_http_persistent
      # - :typhoeus
      # - :patron
      # - :em_synchrony
      # - :em_http
      # - :excon
      # - :rack
      # - :httpclient
      #
      # Possible performance gains can be made by using the em based adapters if
      # your application supports this architecture.
      #
      # Default: net_http
      :adapter => :net_http,

      # Timeout for actually sending the exeption payload
      :http_read_timeout => 2,

      # Timeout for connecting to CrashLog collector interface
      :http_open_timeout => 5,

      # Ignored error class names
      :ignore => IGNORE_DEFAULT.dup,

      # Endpoint used for announcing application launch
      :announce_endpoint => '/announce',
      :announce => true,

      # Send context lines for backtrace.
      #
      # Takes an integer of the number of lines, set to nil to disable.
      :context_lines => 5,

      # Environment variables to discard from ENV.
      :environment_filters => [],

      # Framework name
      :framework => 'Standalone',

      # Run in dry mode (Doesn't actually send exceptions, used for testing)
      :dry_run => false,

      :backtrace_filters => DEFAULT_BACKTRACE_FILTERS.dup,

      :params_filters => DEFAULT_PARAMS_FILTERS.dup,

      :user_attributes => DEFAULT_USER_ATTRIBUTES.dup,

      # Internal
      # Do not change unless you know what this does.
      :service_name => 'CrashLog',

      # MultiJson adapter
      :json_parser => MultiJson.default_adapter

    def root
      fetch(:project_root)
    end

    def root=(string)
      self[:project_root] = string
    end

    def port
      if secure?
        443
      else
        fetch(:port, 80)
      end
    end

    # Release stages are stages which send exceptions
    def release_stage?
      Array(release_stages).include?(stage)
    end

    # Set the current stage
    def stage=(name)
      self[:stage] = name.downcase.strip
    end

    # Is this configuration valid for sending exceptions to CrashLog
    #
    # Returns true if all required keys are provided, otherwise false
    def valid?
      invalid_keys.empty?
    end

    def invalid_keys
      [:api_key, :secret, :host, :port].map do |key|
        key if send(key).nil?
      end.compact
    end

    def ignored?(exception)
      ignore.include?(error_class(exception).to_s)
    end

    def secure?
      fetch(:scheme, 'https') == 'https'
    end

    def notifier_version
      CrashLog::VERSION
    end

  private

    def error_class(exception)
      # The "Class" check is for some strange exceptions like Timeout::Error
      # which throw the error class instead of an instance
      (exception.is_a? Class) ? exception.name : exception.class.name
    end

  end
end
