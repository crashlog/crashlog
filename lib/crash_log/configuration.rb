module CrashLog
  class Configuration

    DEFAULT_PARAMS_FILTERS = %w(password password_confirmation).freeze

    DEFAULT_BACKTRACE_FILTERS = [
      lambda { |line|
        if defined?(CrashLog.configuration.project_root) &&
          CrashLog.configuration.project_root.to_s != ''
          line.sub(/#{CrashLog.configuration.project_root}/, "[PROJECT_ROOT]")
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

    # The default logging device
    #
    # This will be set to Rails.logger automatically if using Rails,
    # otherwise it defaults to STDOUT.
    attr_accessor :logger

    # The API key to authenticate this project with CrashLog
    #
    # Get this from your projects configuration page within http://CrashLog.io
    attr_accessor :api_key

    # Stages (environments) which we consider to be in a production environment
    # and thus you want to be sent notifications for.
    attr_accessor :release_stages

    # The name of the current stage
    attr_reader :stage

    # Project Root directory
    attr_accessor :project_root

    # If set, this will serialize the object returned by sending this key to
    # the controller context. You can use this to send user data CrashLog to
    # correlate errors with users to give you more advanced data about directly
    # who was affected.
    #
    # All user data is stored encrypted for security and always remains your
    # property.
    attr_accessor :user_context_key

    # Reporter configuration options
    #
    # Host to send exceptions to. Default: crashlog.io
    attr_accessor :host

    # Port to use for http connections. 80 or 443 by default.
    attr_writer :port

    def port
      if @port
        @port
      else
        secure? ? 443 : 80
      end
    end

    # HTTP transfer scheme, default: https
    attr_accessor :scheme

    # API endpoint to context for notifications. Default /notify
    attr_accessor :endpoint

    # Reader for Array of ignored error class names
    attr_reader :ignore

    def initialize
      @secure                   = true
      @use_system_ssl_cert_chain= false
      @host                     = 'crashlog.io'
      @http_open_timeout        = 2
      @http_read_timeout        = 5
      @params_filters           = DEFAULT_PARAMS_FILTERS.dup
      @backtrace_filters        = DEFAULT_BACKTRACE_FILTERS.dup
      @ignore_by_filters        = []
      @ignore                   = IGNORE_DEFAULT.dup
      @release_stages           = %w(production staging)
      @notifier_version         = CrashLog::VERSION
      @notifier_url             = 'https://github.com/ivanvanderbyl/crashlog'
      @framework                = 'Standalone'
      @stage                    = 'development'
      @host                     = 'crashlog.io'
      @port                     = nil
      @scheme                   = 'https'
      @endpoint                 = '/notify'
    end

    def release_stage?
      @release_stages.include?(stage)
    end

    def stage=(name)
      @stage = name.downcase.strip
    end

    # Is this configuration valid for sending exceptions to CrashLog
    #
    # Returns true if all required keys are provided, otherwise false
    def valid?
      [:api_key, :host, :port].all? do |key|
        !__send__(key).nil?
      end
    end

    def ignored?(exception)
      ignore.include?(error_class(exception))
    end

    def secure?
      scheme == 'https'
    end

    # Hash like accessor
    def [](key)
      if self.respond_to?(key)
        self.__send__(key)
      end
    end

  private

    def error_class(exception)
      # The "Class" check is for some strange exceptions like Timeout::Error
      # which throw the error class instead of an instance
      (exception.is_a? Class) ? exception.name : exception.class.name
    end

  end
end
