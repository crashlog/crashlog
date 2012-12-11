begin
  require 'simplecov'
  SimpleCov.start do
    add_filter "spec/"
  end
rescue LoadError
  puts "Skipping SimpleCov"
end

# require 'rspec/rails'
require 'delorean'
require 'json_spec'
require 'uuid'
require "crash_log"

# Super Hax
gemfile = ENV['BUNDLE_GEMFILE'] + '.lock'
rails_version = Bundler::LockfileParser.new(File.read(gemfile)).specs.find { |s| s.name == 'rails' }.version.to_s

case rails_version
when /^3\.(2|1)/
  require File.expand_path("../dummy_rails_3_plus/config/environment.rb",  __FILE__)
when /^3\.0\./
  # Rails 3.0.x
  require File.expand_path("../dummy_rails_3/config/environment.rb",  __FILE__)
when /^2/
  require File.expand_path("../dummy_rails_2/config/environment.rb",  __FILE__)
end

Dir[File.expand_path("../support/*.rb", __FILE__)].each { |file| require file }

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Delorean
  config.include DefinesConstants

  config.before(:each) do
    setup_constants
  end

  config.after(:each) do
    teardown_constants
    CrashLog.reset_configuration!
  end
end
