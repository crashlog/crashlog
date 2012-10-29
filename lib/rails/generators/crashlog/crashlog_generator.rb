require 'rails/generators'

class CrashlogGenerator < Rails::Generators::Base
  argument :api_key, :type => :string
  class_option :force, :aliases => "-f", :type => :boolean, :desc => "Replace existing crashlog.rb file"
  source_root File.expand_path("../../../../../generators/crashlog/templates", __FILE__)

  def install
    ensure_api_key_is_valid_format
    generate_initializer unless api_key_configured?
    test_crashlog
  end

  private

  def ensure_api_key_is_valid_format
    unless api_key_pair_provided?
      puts "API_KEY does not match required format: <KEY>:<SECRET>"
      exit(1)
    end
  end

  def api_key_pair_provided?
    !!(self.api_key =~ /^(\h){8}-(\h){4}-(\h){4}-(\h){4}-(\h){12}\:\w+$/)
  end

  def api_key_pair
    /(?<api_key>^(\h){8}-(\h){4}-(\h){4}-(\h){4}-(\h){12})\:(?<secret>\w+)$/.match(self.api_key)
  end

  def api_key_expression
    api_key = api_key_pair[:api_key]
    "'#{api_key}'"
  end

  def secret_expression
    secret = api_key_pair[:secret]
    "'#{secret}'"
  end

  def generate_initializer
    template 'initializer.rb', 'config/initializers/crashlog.rb'
  end

  def api_key_configured?
    return false if options[:force]
    File.exists?('config/initializers/crashlog.rb')
  end

  def test_crashlog
    run("rake crashlog:test")
  end
end
