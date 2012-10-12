require "crash_log"

namespace :crashlog do

  desc "Send a test exception to CrashLog."
  task :test => :load do
    begin
      raise RuntimeError, "CrashLog test exception"
    rescue => e
      CrashLog.notify(e, {:context => {:action => "rake#crashlog:test"}})
    end
  end
end

task :load do
  begin
    Rake::Task["environment"].invoke
  rescue
  end
end
