require 'rails/generators'

class CrashlogGenerator < Rails::Generators::Base

  class_option :api_key, :aliases => "-k", :type => :string, :desc => "Your CrashLog API key"

  def self.source_root
    @_crashlog_source_root ||= File.expand_path("../../../../../generators/crashlog/templates", __FILE__)
  end

  def install
    ensure_api_key_was_configured
    generate_initializer unless api_key_configured?
    test_crashlog
  end

  private

  def ensure_api_key_was_configured
    if !options[:api_key] && !api_key_configured?
      puts "Must pass --api-key or create config/initializers/crashlog.rb"
      exit
    end
  end

  def api_key_expression
    "'#{options[:api_key]}'"
  end

  def generate_initializer
    template 'initializer.rb', 'config/initializers/crashlog.rb'
  end

  def api_key_configured?
    File.exists?('config/initializers/crashlog.rb')
  end

  def test_crashlog
    puts run("rake crashlog:test")
  end
end

