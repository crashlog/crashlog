require 'crashlog'

CrashLog.configure do |config|
  config.api_key = "API_KEY"
  config.secret  = "SECRET"
  config.dry_run = true
end
