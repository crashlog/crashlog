require 'logger'

module CrashLog
  module Logging
    ANSI = {
      :red    => 31,
      :green  => 32,
      :yellow => 33,
      :cyan   => 36
    }

    def self.included(base)
      base.__send__(:include, ClassMethods)
    end

    module ClassMethods
      def logger
        CrashLog.logger
      end

      [:fatal, :error, :warn, :info, :debug].each do |level|
        define_method(level) do |*args|
          message, options = *args
          message.chomp.split("\n").each do |line|
            logger.send(level, prefix(line, color_for_level(level)))
          end
        end
      end

      def prefix(string, color = :green)
        [colorize(:yellow, CrashLog::LOG_PREFIX), colorize(color, string)].join(' ')
      end

      def colorize(color, text)
        if colorize?
          "\e[#{ANSI[color]}m#{text}\e[0m"
        else
          text
        end
      end

      def colorize?
        CrashLog.configuration.colorize.eql?(true)
      rescue
        false
      end

      def color_for_level(level)
        case level.to_sym
        when :fatel, :error, :warn
          :red
        when :debug
          :cyan
        else
          :green
        end
      end

      def log_exception(exception)
        logger.error("#{exception.class.name}: #{exception.message}")
        exception.backtrace.each { |line| logger.error(line) } if exception.backtrace
      rescue Exception => e
        puts '--- FATAL ---'
        puts 'an exception occured while logging an exception'
        puts e.message, e.backtrace
        puts exception.message, exception.backtrace
      end

    end

  end
end
