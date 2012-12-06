module CrashLog
  class Sidekiq
    def call(worker, msg, queue)
      begin
        yield
      rescue => ex
        CrashLog.notify_or_ignore(ex, :context => {:sidekiq => msg })
        raise
      end
    end
  end
end

::Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add ::CrashLog::Sidekiq
  end
end