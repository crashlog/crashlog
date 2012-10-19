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
      rescue
        nil
      end

      def environment
        if ENV.respond_to?(:to_hash)
          env = ENV.to_hash.reject do |k, v|
            (k =~ /^HTTP_/)
          end

          unless CrashLog.configuration.environment_filters.empty?
            env.each do |k, v|
              if CrashLog.configuration.environment_filters.any? { |f|
                  f.is_a?(Regexp) ? f =~ k.to_s : f.to_s == k.to_s
                }
                env[k] = '[FILTERED]'
              end
            end
          end

          env
        else
          {}
        end
      rescue
        {}
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
