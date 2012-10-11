if ENV['COV']
  require 'simplecov'
  SimpleCov.start
end

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'
require 'delorean'
require 'json_spec'
require 'uuid'
require "crash_log"

# require File.expand_path("../dummy/config/environment.rb",  __FILE__)

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
  end
end
