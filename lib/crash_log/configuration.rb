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
      @ignore_user_agent        = []
      @release_stages           = %w(production staging)
      @notifier_version         = CrashLog::VERSION
      @notifier_url             = 'https://github.com/ivanvanderbyl/crashlog'
      @framework                = 'Standalone'
      @stage                    = 'development'
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

    # Hash like accessor
    def [](key)
      if self.respond_to?(key)
        self.__send__(key)
      end
    end

  end
end
