require "crash_log"
require "logger"

namespace :crashlog do

  desc "Send a test exception to CrashLog."
  task :test => :load do
    CrashLog.configure do |config|
      config.logger = Logger.new(STDOUT)
      # Ensure we send for this stage, probably development which is disabled
      # by default.
      config.release_stages << config.stage
    end

    begin
      raise RuntimeError, "CrashLog test exception"
    rescue => e
      CrashLog.notify(e, {
        :context => {:action => "rake#crashlog:test"},
        :system => CrashLog::SystemInformation.to_hash
      })
    end
  end

  task :dump_configuration => :load do
    puts "CrashLog: #{CrashLog::VERSION}"
    puts "Configuration:"
    puts '-' * 80
    CrashLog.configuration.each do |key, value|
      puts sprintf("%23s: %s", key.to_s, value.inspect.slice(0, 55))
    end
  end
end

task :load do
  begin
    Rake::Task["environment"].invoke
  rescue
  end
end
