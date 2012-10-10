<% if Rails::VERSION::MAJOR < 3 && Rails::VERSION::MINOR < 2 -%>
require 'crash_log/rails'
<% end -%>
CrashLog.configure do |config|
  config.api_key  = <%= api_key_expression %>
  config.secret   = <%= secret_expression %>
end
