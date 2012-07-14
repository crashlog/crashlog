module CrashLog
  class SystemInformation
    class << self

      def to_hash
        {
          :hostname => hostname,
          :ruby_version => ruby_version,
          :username => username,
          :environment => environment,
          :libraries_loaded => libraries_loaded,
          :platform => platform,
          :application_root => application_root,
          :stage => stage
        }
      end

      def hostname
        require 'socket' unless defined?(Socket)
        Socket.gethostname
      rescue
        'UNKNOWN'
      end

      def ruby_version
        "#{RUBY_VERSION rescue '?.?.?'}-p#{RUBY_PATCHLEVEL rescue '???'} #{RUBY_RELEASE_DATE rescue '????-??-??'} #{RUBY_PLATFORM rescue '????'}"
      end

      def username
        ENV['LOGNAME'] || ENV['USER'] || ENV['USERNAME'] || ENV['APACHE_RUN_USER'] || 'UNKNOWN'
      end

      def environment
        ENV.dup.reject do |k, v|
          (k =~ /^HTTP_/) || CrashLog.configuration.environment_filters.include?(k)
        end
      end

      def libraries_loaded
        Hash[*Gem.loaded_specs.map {|name, gem_specification|
          [name, gem_specification.version.to_s]
        }.flatten]
      rescue
        {}
      end

      def platform
        RUBY_PLATFORM rescue '????'
      end

      def application_root
        CrashLog.configuration.root
      end

      def stage
        CrashLog.configuration.stage
      end
    end
  end
end
