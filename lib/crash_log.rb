require 'crash_log/version'
begin
  require 'active_support'
  require 'active_support/core_ext'
rescue LoadError
  require 'activesupport'
  require 'activesupport/core_ext'
end
require 'faraday'
require 'crash_log/railtie' if defined?(Rails::Railtie)
require 'crash_log/logging'

module CrashLog
  autoload :Reporter, 'crash_log/reporter'

  LOG_PREFIX = "** [CrashLog] "
  extend Logging

  class << self

    def report_for_duty!
      info("CrashLog initialized and ready to handle exceptions")
    end
  end
end
